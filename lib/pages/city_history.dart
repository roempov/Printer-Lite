import 'package:flutter/material.dart';
import 'history_page.dart';

class CityHistory extends StatelessWidget {
  const CityHistory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HistoryPage(
      config: HistoryConfig(
        collectionName: 'cod',
        appBarTitle: 'ប្រវត្តិលក់',
        accentColor: Colors.blue,
        filteredAccentColor: Colors.indigo,
        topLeft: (data) => data['phone']?.toString() ?? '',
        topRight: (data) => data['address']?.toString().trim() ?? '',
        topRightColor: Colors.blue,
        bottomLeft: (data) => data['price']?.toString() ?? '',
        bottomLeftColor: (_) => Colors.green,
        bottomRight: (data) => data['date']?.toString() ?? '',
      ),
    );
  }
}
