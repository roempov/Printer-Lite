import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AddFireStore {
  final String _sortDate = DateFormat('yy-MM-dd HHmmss').format(DateTime.now());

  Future city(String address, String amount, String phoneNumber, String dateTime) async {
    final CollectionReference collCod = FirebaseFirestore.instance.collection('cod');

    await collCod.add({"address": address, "price": amount, "phone": phoneNumber, "date": dateTime, "sort": _sortDate});
  }

  Future province(
    String receiverNum,
    String destination,
    String delivery,
    String dateTime,
  ) async {
    final CollectionReference collPro = FirebaseFirestore.instance.collection('province');

    await collPro.add({"phone": receiverNum, "destination": destination, "deliver": delivery, "date": dateTime, "sort": _sortDate});
  }
}
