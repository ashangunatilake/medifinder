import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medifinder/controllers/customercontroller.dart';
import 'package:medifinder/pages/customer/activities.dart';
import 'package:medifinder/pages/customer/home.dart';
import 'package:medifinder/pages/customer/profile.dart';
import 'package:medifinder/pages/message.dart';
import 'package:badges/badges.dart' as badges;

class CustomerView extends StatefulWidget {
  final int index;
  const CustomerView({super.key, this.index = 0});

  @override
  State<CustomerView> createState() => _CustomerViewState();
}

class _CustomerViewState extends State<CustomerView> {
  late PageController pagecontroller;
  final customerController = Get.put(CustomerController());
  late bool isSwipingEnabled = (widget.index != 0) ? true : false;
  var pages = const [CustomerHome(), Activities(), NotificationMessage(), Profile()];
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
    Get.delete<CustomerController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: pagecontroller,
        physics: (isSwipingEnabled) ? const BouncingScrollPhysics() : const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            isSwipingEnabled = index != 0;
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
              showBadge: customerController.activitiesCount.value > 0,
              badgeContent: Text('${customerController.activitiesCount.value}',
                style: const TextStyle(color: Colors.white, fontSize: 10),),
              child: const Icon(Icons.shopping_cart),
            )),
            label: "Activities",
          ),
          BottomNavigationBarItem(
            icon: Obx(() => badges.Badge(
              showBadge: customerController.notificationCount.value > 0,
              badgeContent: Text('${customerController.notificationCount.value}',
                style: const TextStyle(color: Colors.white, fontSize: 10),),
              child: const Icon(Icons.notifications),
            )),
            label: "Notifications",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
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
