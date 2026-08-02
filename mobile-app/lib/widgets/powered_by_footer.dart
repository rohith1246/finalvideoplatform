import 'package:flutter/material.dart';

class PoweredByFooter extends StatelessWidget {
  const PoweredByFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Center(
        child: Text(
          'Powered by ElevateIQ SoftTech',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
