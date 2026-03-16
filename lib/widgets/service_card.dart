import 'package:flutter/material.dart';
import '../screens/hospital_screen.dart';

class ServiceCard extends StatefulWidget {

  final String name;
  final IconData icon;

  const ServiceCard({
    super.key,
    required this.name,
    required this.icon,
  });

  @override
  State<ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard> {

  double scale = 1;

  @override
  Widget build(BuildContext context) {

    return GestureDetector(

      onTapDown: (_) {
        setState(() => scale = 0.92);
      },

      onTapUp: (_) {
        setState(() => scale = 1);
      },

      onTapCancel: () {
        setState(() => scale = 1);
      },

      onTap: () {

        if (widget.name == "Hospital") {

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const HospitalScreen(),
            ),
          );

        }

      },

      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 120),

        child: Container(

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),

            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0,4),
              ),
            ],
          ),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.indigo.shade100,

                child: Icon(
                  widget.icon,
                  color: Colors.indigo,
                  size: 28,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                widget.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}