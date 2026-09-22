import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Describes how a HistoryPage should read and display one Firestore
/// collection's documents. Each screen (City, Province, ...) supplies
/// its own config instead of duplicating the whole page.
class HistoryConfig {
  final String collectionName;
  final String appBarTitle;
  final Color accentColor;
  final Color filteredAccentColor;

  final String Function(Map<String, dynamic> data) topLeft;
  final String Function(Map<String, dynamic> data) topRight;
  final Color topRightColor;

  final String Function(Map<String, dynamic> data) bottomLeft;
  final Color Function(Map<String, dynamic> data)? bottomLeftColor;
  final String Function(Map<String, dynamic> data) bottomRight;

  final String emptyLabel;

  // was: final String emptyForDayLabel(...) => ...;
  String emptyForDayLabel(String formattedDay) => 'គ្មានទិន្នន័យសម្រាប់ $formattedDay';

  HistoryConfig({
    required this.collectionName,
    required this.appBarTitle,
    required this.accentColor,
    required this.filteredAccentColor,
    required this.topLeft,
    required this.topRight,
    required this.topRightColor,
    required this.bottomLeft,
    this.bottomLeftColor,
    required this.bottomRight,
    this.emptyLabel = 'គ្មានទិន្នន័យ',
  });
}

/// Reads a Firestore field defensively — never lets a missing/null field
/// throw at render time (this was a real bug in the old duplicated screens).
String _field(Map<String, dynamic> data, String key) => data[key]?.toString().trim() ?? '';

class HistoryPage extends StatefulWidget {
  final HistoryConfig config;
  const HistoryPage({Key? key, required this.config}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late final CollectionReference _collection = FirebaseFirestore.instance.collection(widget.config.collectionName);

  static const int _pageSize = 100;
  int _limit = _pageSize;
  String? _filterDay;

  Stream<int>? _todayStream;

  List<String> _cachedDays = [];
  bool _daysLoaded = false;

  @override
  void initState() {
    super.initState();
    _initTodayStream();
    _preloadDays();
  }

  void _initTodayStream() {
    _collection.orderBy('sort', descending: true).limit(1).get().then((snap) {
      if (snap.docs.isEmpty) return;
      final latestOrder = _field(snap.docs.first.data() as Map<String, dynamic>, 'sort');
      if (latestOrder.length < 8) return;
      final day = latestOrder.substring(0, 8);
      if (mounted) {
        setState(() {
          _todayStream = _collection.orderBy('sort').startAt(['$day 000000']).endAt(['$day 999999']).snapshots().map((s) => s.docs.length);
        });
      }
    });
  }

  Future<void> _preloadDays() async {
    final snap = await _collection.orderBy('sort', descending: true).limit(600).get();
    _cachedDays = _extractDays(snap);
    if (mounted) setState(() => _daysLoaded = true);
  }

  List<String> _extractDays(QuerySnapshot snap) {
    final Set<String> days = {};
    for (final doc in snap.docs) {
      final order = _field(doc.data() as Map<String, dynamic>, 'sort');
      if (order.length >= 8) days.add(order.substring(0, 8));
    }
    return days.toList()..sort((a, b) => b.compareTo(a));
  }

  Stream<int> _filteredCountStream(String day) {
    return _collection.orderBy('sort').startAt(['$day 000000']).endAt(['$day 999999']).snapshots().map((s) => s.docs.length);
  }

  Stream<QuerySnapshot> _listStream() {
    if (_filterDay != null) {
      return _collection.orderBy('sort', descending: true).startAt(['$_filterDay 999999']).endAt(['$_filterDay 000000']).snapshots();
    }
    return _collection.orderBy('sort', descending: true).limit(_limit).snapshots();
  }

  String _formatDay(String day) {
    final parts = day.split('-');
    return parts.length == 3 ? '${parts[2]}/${parts[1]}/${parts[0]}' : day;
  }

  Future<void> _showDateFilterDialog(BuildContext context) async {
    final navigator = Navigator.of(context);

    if (!_daysLoaded) {
      final snap = await _collection.orderBy('sort', descending: true).limit(300).get();
      _cachedDays = _extractDays(snap);
      _daysLoaded = true;
    }

    showDialog(
      context: navigator.context,
      builder: (_) => AlertDialog(
        title: const Text('ជ្រើសរើសថ្ងៃ', style: TextStyle(fontSize: 15)),
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                dense: true,
                title: const Text('ទាំងអស់', style: TextStyle(fontSize: 13)),
                trailing: _filterDay == null ? Icon(Icons.check, color: widget.config.accentColor, size: 18) : null,
                onTap: () {
                  setState(() {
                    _filterDay = null;
                    _limit = _pageSize;
                  });
                  Navigator.pop(navigator.context);
                },
              ),
              ..._cachedDays.take(8).map((day) {
                return ListTile(
                  dense: true,
                  title: Text(_formatDay(day), style: const TextStyle(fontSize: 13)),
                  trailing: _filterDay == day ? Icon(Icons.check, color: widget.config.accentColor, size: 18) : null,
                  onTap: () {
                    setState(() {
                      _filterDay = day;
                      _limit = _pageSize;
                    });
                    Navigator.pop(navigator.context);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _delete(String docId, Map<String, dynamic> data) async {
    final label = widget.config.topRight(data);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete'),
        content: Text(
          '"$label"',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.blue),
        ),
        actions: [
          MaterialButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          MaterialButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await _collection.doc(docId).delete();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('មិនអាចលុបបាន។ សូមព្យាយាមម្តងទៀត'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('OK', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;
    final countStream = _filterDay != null ? _filteredCountStream(_filterDay!) : (_todayStream ?? const Stream.empty());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black26,
        title: Text(config.appBarTitle, style: const TextStyle(fontSize: 15)),
        actions: [
          if (_filterDay != null)
            Center(
              child: Text(
                _formatDay(_filterDay!),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white, size: 20),
            onPressed: () => _showDateFilterDialog(context),
          ),
          StreamBuilder<int>(
            stream: countStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData && _filterDay == null && _todayStream == null) {
                return const Padding(
                  padding: EdgeInsets.only(right: 14),
                  child: Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    ),
                  ),
                );
              }
              final count = snapshot.data ?? 0;
              return Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _filterDay == null ? config.accentColor : config.filteredAccentColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$count',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _listStream(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          final hasMore = _filterDay == null && docs.length == _limit;

          if (docs.isEmpty) {
            return Center(
              child: Text(
                _filterDay != null ? config.emptyForDayLabel(_formatDay(_filterDay!)) : config.emptyLabel,
                style: const TextStyle(fontSize: 14, color: Colors.black45),
              ),
            );
          }

          return ListView.builder(
            itemCount: docs.length + 1,
            itemBuilder: (context, index) {
              if (index == docs.length) {
                if (!hasMore) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        '— បានបង្ហាញទាំងអស់ (${docs.length}) —',
                        style: const TextStyle(fontSize: 11, color: Colors.black45),
                      ),
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 16),
                  child: OutlinedButton.icon(
                    onPressed: () => setState(() => _limit += _pageSize),
                    icon: const Icon(Icons.expand_more, size: 18),
                    label: const Text('បង្ហាញបន្ថែម 100', style: TextStyle(fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      minimumSize: const Size(double.infinity, 40),
                    ),
                  ),
                );
              }

              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final seqNumber = index + 1;
              final bottomLeftColor = config.bottomLeftColor?.call(data) ?? Colors.black45;

              return Card(
                elevation: 1.5,
                margin: const EdgeInsets.only(left: 8, right: 8, top: 2),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 24,
                        child: Text(
                          '$seqNumber',
                          style: const TextStyle(fontSize: 11, color: Colors.black38),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    config.topLeft(data),
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    config.topRight(data),
                                    style: TextStyle(fontSize: 14, color: config.topRightColor),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: true,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    config.bottomLeft(data),
                                    style: TextStyle(fontSize: 11, color: bottomLeftColor),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    config.bottomRight(data),
                                    style: const TextStyle(fontSize: 11, color: Colors.black45),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 17),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        onPressed: () => _delete(doc.id, data),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
