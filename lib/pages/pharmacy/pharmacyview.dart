import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medifinder/controllers/pharmacycontroller.dart';
import 'package:medifinder/pages/message.dart';
import 'package:medifinder/pages/pharmacy/inventory.dart';
import 'package:medifinder/pages/pharmacy/orders.dart';
import 'package:medifinder/pages/pharmacy/pharmacyprofile.dart';
import 'package:badges/badges.dart' as badges;

class PharmacyView extends StatefulWidget {
  final int index;
  const PharmacyView({super.key, this.index = 0});

  @override
  State<PharmacyView> createState() => _PharmacyViewState();
}

class _PharmacyViewState extends State<PharmacyView> {
  late PageController pagecontroller;
  final pharmacyController = Get.put(PharmacyController());
  var pages = const [Inventory(), Orders(), NotificationMessage(), PharmacyProfile()];
  late int currentIndex;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pagecontroller = PageController(initialPage: widget.index);
    currentIndex = widget.index;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    Get.delete<PharmacyController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: pagecontroller,
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Obx(() => badges.Badge(
              showBadge: pharmacyController.ordersCount.value > 0,
              badgeContent: Text('${pharmacyController.ordersCount.value}',
                style: const TextStyle(color: Colors.white, fontSize: 10),),
              child: const Icon(Icons.shopping_cart),
            )),
            label: "Orders",
          ),
          BottomNavigationBarItem(
            icon: Obx(() => badges.Badge(
              showBadge: pharmacyController.notificationCount.value > 0,
              badgeContent: Text('${pharmacyController.notificationCount.value}',
                style: const TextStyle(color: Colors.white, fontSize: 10),),
              child: const Icon(Icons.notifications),
            )),
            label: "Notifications",
          ),
          const BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Profile"
          )
        ],
        currentIndex: currentIndex,
        onTap: (index) {
          pagecontroller.animateToPage(index, duration: const Duration(milliseconds: 500), curve: Curves.ease);
        },
        selectedItemColor: const Color(0xFF0CAC8F),
      ),
    );
  }
}
