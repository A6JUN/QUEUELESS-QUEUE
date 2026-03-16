import 'package:flutter/material.dart';
import '../widgets/service_card.dart';
import 'login_screen.dart';

class ServiceSelectionScreen extends StatelessWidget {
  const ServiceSelectionScreen({super.key});

  final List<Map<String, dynamic>> services = const [
    {"name": "Hospital", "icon": Icons.local_hospital},
    {"name": "Bank", "icon": Icons.account_balance},
    {"name": "College Office", "icon": Icons.school},
    {"name": "Government Office", "icon": Icons.account_balance_wallet},
    {"name": "Service Center", "icon": Icons.miscellaneous_services},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      body: SafeArea(
        child: Column(
          children: [
            /// HEADER WITH LOGOUT
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Colors.indigo, Colors.blue]),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// HEADER TEXT
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Queueless",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 6),

                      Text(
                        "Skip the line. Save your time.",
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ],
                  ),

                  /// LOGOUT BUTTON
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),

                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// TITLE
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Select a Service",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const SizedBox(height: 15),

            /// GRID SERVICES
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: services.length,

                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),

                itemBuilder: (context, index) {
                  return ServiceCard(
                    name: services[index]["name"],
                    icon: services[index]["icon"],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
