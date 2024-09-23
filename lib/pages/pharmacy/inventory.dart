import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medifinder/controllers/pharmacycontroller.dart';
import 'package:shimmer/shimmer.dart';
import 'package:medifinder/pages/pharmacy/add_item.dart';
import 'package:medifinder/pages/pharmacy/drugs_stock.dart';
import 'package:medifinder/services/pharmacy_database_services.dart';
import 'package:badges/badges.dart' as badges;

class Inventory extends StatefulWidget {
  const Inventory({super.key});

  @override
  State<Inventory> createState() => _InventoryState();
}

class _InventoryState extends State<Inventory> {
  final PharmacyDatabaseServices _databaseServices = PharmacyDatabaseServices();
  final pharmacyController = Get.put(PharmacyController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Inventory Management'),
        backgroundColor: Colors.white38,
        elevation: 0.0,
      ),
      body: FutureBuilder(
        future: _databaseServices.getCurrentPharmacyDoc(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingSkeleton();
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Text('No data available');
          } else {
            var docs = snapshot.data!;
            return Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background2.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SafeArea(child: SizedBox()),
                    Text(
                      docs['Name'],
                      style: const TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: GridView.count(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        crossAxisCount: 1,
                        mainAxisSpacing: 40.0,
                        crossAxisSpacing: 50.0,
                        childAspectRatio: 3 / 2,
                        children: [
                          _buildCard(
                              context,
                              'Drugs In Store',
                              Icons.local_pharmacy,
                              const Color.fromRGBO(21, 201, 180, 1),
                              DrugStock(pharmacyDoc: docs)
                          ),
                          _buildCard(
                            context,
                            'Add New Drug',
                            Icons.add,
                            Colors.white,
                            const AddItem(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
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
        currentIndex: 0,
        onTap: (int n) {
          if (n == 1) Navigator.pushNamedAndRemoveUntil(context, '/orders', (route) => false);
          if (n == 2) Navigator.pushNamedAndRemoveUntil(context, '/message', (route) => false);
          if (n == 3) Navigator.pushNamedAndRemoveUntil(context, '/pharmacy_profile', (route) => false);
        },
        selectedItemColor: const Color(0xFF0CAC8F),
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/background2.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SafeArea(child: SizedBox()),
            Shimmer.fromColors(
              baseColor: Colors.grey[400]!,
              highlightColor: Colors.grey[200]!,
              period: const Duration(milliseconds: 800),
              child: Container(
                height: 28,
                width: 150,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                crossAxisCount: 1,
                mainAxisSpacing: 40.0,
                crossAxisSpacing: 50.0,
                childAspectRatio: 3 / 2,
                children: List.generate(2, (index) {
                  return Shimmer.fromColors(
                    baseColor: Colors.grey[400]!,
                    highlightColor: Colors.grey[200]!,
                    period: const Duration(milliseconds: 800),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                      color: Colors.grey.withOpacity(0.2),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, String title, IconData icon,
      Color color, Widget page) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
        color: color,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 50,
                color: color == Colors.white
                    ? const Color.fromRGBO(21, 201, 180, 1)
                    : Colors.white,
              ),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: color == Colors.white
                      ? const Color.fromRGBO(21, 201, 180, 1)
                      : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
