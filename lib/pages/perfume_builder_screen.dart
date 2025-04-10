import 'package:flutter/material.dart';

class PerfumeBuilderScreen extends StatefulWidget {
  @override
  _PerfumeBuilderScreenState createState() => _PerfumeBuilderScreenState();
}

class _PerfumeBuilderScreenState extends State<PerfumeBuilderScreen> {
  String shape = 'Round';
  String color = 'Pink';
  String scent = 'Floral';

  final bottleImages = {
    'Round': 'https://i.imgur.com/r7CeA0X.png',
    'Square': 'https://i.imgur.com/OxVBrR8.png',
    'Tall': 'https://i.imgur.com/Fa5Yg2t.png',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Your Perfume')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Image.network(bottleImages[shape]!, height: 150),
            SizedBox(height: 20),
            buildDropdown('Bottle Shape', ['Round', 'Square', 'Tall'], shape, (val) {
              setState(() => shape = val!);
            }),
            buildDropdown('Color', ['Pink', 'Blue', 'Gold'], color, (val) {
              setState(() => color = val!);
            }),
            buildDropdown('Scent', ['Floral', 'Woody', 'Citrus'], scent, (val) {
              setState(() => scent = val!);
            }),
            SizedBox(height: 20),
            Text(
              'You created a $color $scent perfume in a $shape bottle!',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }

  Widget buildDropdown(String label, List<String> options, String selected, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        DropdownButton<String>(
          isExpanded: true,
          value: selected,
          items: options.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
