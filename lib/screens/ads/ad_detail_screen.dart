import 'package:flutter/material.dart';

class AdDetailScreen extends StatelessWidget {
  final String adId;
  const AdDetailScreen({super.key, required this.adId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل الإعلان')),
      body: Center(child: Text('معرف الإعلان: $adId')),
    );
  }
}