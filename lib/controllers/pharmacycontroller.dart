import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/pharmacy_database_services.dart';

class PharmacyController extends GetxController {
  final PharmacyDatabaseServices _pharmacyDatabaseServices = PharmacyDatabaseServices();
  User? user = FirebaseAuth.instance.currentUser;
  RxInt ordersCount = 0.obs;
  RxInt notificationCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _setupFirestoreListener();
    _fetchAndListenToNotifications();
  }

  void _setupFirestoreListener() {
    final ordersCollection = _pharmacyDatabaseServices.getPharmacyDocReference(user!.uid).collection('Orders');

    // Listen to changes in the 'Orders' subcollection
    ordersCollection.snapshots().listen((event) {
      print("Listening to 'Orders' collection changes");
      for (var change in event.docChanges) {
        if (change.type == DocumentChangeType.modified || change.type == DocumentChangeType.added || change.type == DocumentChangeType.removed) {
          // Update orders count for top-level changes
          _updateOrdersCount();

          ordersCollection.doc(change.doc.id).collection('UserOrders').snapshots().listen((subEvent) {
            print("Listening to 'UserOrders' subcollection changes inside ${change.doc.id}");
            for (var subChange in subEvent.docChanges) {
              if (subChange.type == DocumentChangeType.modified || subChange.type == DocumentChangeType.added || subChange.type == DocumentChangeType.removed) {
                _updateOrdersCount();
              }
            }
          });
        }
      }
    });
  }


  void _updateOrdersCount() {
    // Fetch and update the orders count
    _pharmacyDatabaseServices.getUsersWithToAcceptOrders(user!.uid).listen((orders) {
      ordersCount.value = orders.length;
      print('Orders count updated: ${ordersCount.value}');
    });
  }

  void _fetchAndListenToNotifications() async {
    // Initial load
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _updateNotificationCount(prefs);

    // Periodically check for updates
    ever(notificationCount, (_) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _updateNotificationCount(prefs);
    });
  }

  void _updateNotificationCount(SharedPreferences prefs) {
    prefs.reload().then((value) {
      if (prefs.containsKey('notifications')) {
        notificationCount.value = prefs.getStringList('notifications')!.length;
        notificationCount.refresh();
      }
    });
  }
}
