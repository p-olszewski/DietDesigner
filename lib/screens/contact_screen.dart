import 'package:diet_designer/shared/logo.dart';
import 'package:flutter/material.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Logo(),
                ],
              ),
              const SizedBox(height: 40),
              const Text('Thank you for using DietDesigner, a nutrition app designed specifically for Lodz University of Technology.'),
              const SizedBox(height: 20),
              const Text(
                  'If you have any questions, feedback, or need support, please do not hesitate to contact us. We are here to assist you.'),
              const SizedBox(height: 20),
              const Text('Contact Information:', style: TextStyle(fontWeight: FontWeight.bold)),
              const Text('• Lodz University of Technology\n• Przemysław Olszewski, 229299@edu.p.lodz.pl'),
              const SizedBox(height: 20),
              const Text('We value your input and strive to continuously improve DietDesigner to meet your dietary needs and goals.'),
              const SizedBox(height: 60),
              const Text('© 2023 DietDesigner®. All rights reserved.'),
            ],
          ),
        ),
      ),
    );
  }
}
