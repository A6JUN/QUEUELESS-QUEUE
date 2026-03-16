import 'package:flutter/material.dart';

class HospitalScreen extends StatefulWidget {
  const HospitalScreen({super.key});

  @override
  State<HospitalScreen> createState() => _HospitalScreenState();
}

class _HospitalScreenState extends State<HospitalScreen> {

  int? token;
  int peopleAhead = 0;
  int waitingTime = 0;

  void generateToken() {

    setState(() {

      token = DateTime.now().millisecondsSinceEpoch % 1000;

      peopleAhead = token! % 5;

      waitingTime = peopleAhead * 3;

    });

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Hospital Queue"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const Icon(
              Icons.local_hospital,
              size: 80,
              color: Colors.red,
            ),

            const SizedBox(height: 20),

            const Text(
              "Hospital Service",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 40),

            if (token != null) ...[

              Container(
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),

                child: Column(
                  children: [

                    const Text(
                      "Your Token",
                      style: TextStyle(fontSize: 18),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "H-$token",
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text("People Ahead: $peopleAhead"),
                    Text("Estimated Wait: $waitingTime min"),

                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],

            ElevatedButton(
              onPressed: generateToken,
              child: const Text("Generate Token"),
            )

          ],
        ),
      ),
    );
  }
}