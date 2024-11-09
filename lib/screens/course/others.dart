import 'package:flutter/material.dart';

class OthersCos extends StatelessWidget {
  const OthersCos({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: 200.0,
        color: Colors.grey[300],
        child: const Center(
          child: Text('지도'),
        ),
      ),
    );
  }
}
