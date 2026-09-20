import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:final_printer/pages/city.dart';
import 'package:final_printer/pages/province.dart';
import 'package:final_printer/pages/connect.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        debugShowCheckedModeBanner: false, home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int myIndex = 0;
  List<Widget> pageList = const [City(), Province(), Setting()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: myIndex,
        children: pageList,
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.grey[400],
        height: 65,
        selectedIndex: myIndex,
        onDestinationSelected: (index) {
          setState(() {
            myIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
              selectedIcon: Icon(Icons.delivery_dining),
              icon: Icon(Icons.delivery_dining_outlined),
              label: 'Delivery'),
          NavigationDestination(
              selectedIcon: Icon(Icons.local_shipping),
              icon: Icon(Icons.local_shipping_outlined),
              label: 'Shipping'),
          NavigationDestination(
              selectedIcon: Icon(Icons.bluetooth_audio),
              icon: Icon(Icons.bluetooth_outlined),
              label: 'Connect')
        ],
      ),
    );
  }
}
