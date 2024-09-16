import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:medifinder/services/database_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerController extends GetxController {
  final UserDatabaseServices _userDatabaseServices = UserDatabaseServices();
  User? user = FirebaseAuth.instance.currentUser;
  RxInt activitiesCount = 0.obs;
  RxInt notificationCount = 0.obs;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    _setupFirestoreListener();
    _fetchAndListenToNotifications();
  }

  void _setupFirestoreListener() async {
    final pharmaciesSnapshot = await firestore.collection('Pharmacies').get();

    for (var pharmacyDoc in pharmaciesSnapshot.docs) {
      final ordersCollection = firestore.collection('Pharmacies').doc(pharmacyDoc.id).collection('Orders').doc(user!.uid).collection('UserOrders');
      ordersCollection.snapshots().listen((event) {
        for (var change in event.docChanges) {
          if (change.type == DocumentChangeType.modified || change.type == DocumentChangeType.added || change.type == DocumentChangeType.removed) {
            // Update orders count for top-level changes
            _updateActivitiesCount();

            ordersCollection.doc(change.doc.id).collection('UserOrders').snapshots().listen((subEvent) {
              print("Listening to 'UserOrders' subcollection changes inside ${change.doc.id}");
              for (var subChange in subEvent.docChanges) {
                if (subChange.type == DocumentChangeType.modified || subChange.type == DocumentChangeType.added || subChange.type == DocumentChangeType.removed) {
                  _updateActivitiesCount();
                }
              }
            });
          }
        }
      });
    }
  }

  void _updateActivitiesCount() {
    _userDatabaseServices.getOngoingUserOrders(user!.uid).listen((orders) {
      activitiesCount.value = orders.length;
      print('Orders count updated: ${activitiesCount.value}');
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