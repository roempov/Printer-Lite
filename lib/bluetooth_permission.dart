import 'package:permission_handler/permission_handler.dart';

Future<bool> requestBluetoothPermissions() async {
  final statuses = await [
    Permission.bluetoothScan,
    Permission.bluetoothConnect,
    Permission.locationWhenInUse,
  ].request();

  return statuses.values.every((status) => status.isGranted);
}