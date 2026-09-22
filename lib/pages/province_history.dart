import 'package:flutter/material.dart';
import 'history_page.dart';

class ProvinceHistory extends StatelessWidget {
  const ProvinceHistory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HistoryPage(
      config: HistoryConfig(
        collectionName: 'province',
        appBarTitle: 'ប្រវត្តិផ្ញើ',
        accentColor: Colors.orange,
        filteredAccentColor: Colors.deepOrange,
        topLeft: (data) => data['phone']?.toString() ?? '',
        topRight: (data) => data['destination']?.toString().trim() ?? '',
        topRightColor: Colors.orange,
        bottomLeft: (data) => data['deliver']?.toString() ?? '',
        bottomLeftColor: (data) => data['deliver'] == 'J&T'
            ? Colors.red
            : data['deliver'] == 'កាពីតូល'
                ? Colors.blue.shade700
                : Colors.black45,
        bottomRight: (data) => data['date']?.toString() ?? '',
      ),
    );
  }
}
