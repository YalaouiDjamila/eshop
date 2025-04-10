import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class GiftPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Gift a Perfume"), backgroundColor: Colors.pink[100]),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/animations/mist.json', height: 200), // Add file to assets
            SizedBox(height: 20),
            Text("Surprise your loved one! 🎁", style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}
