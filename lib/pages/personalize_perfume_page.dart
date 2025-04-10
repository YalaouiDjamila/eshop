import 'package:flutter/material.dart';

class PersonalizePerfumePage extends StatefulWidget {
  @override
  _PersonalizePerfumePageState createState() => _PersonalizePerfumePageState();
}

class _PersonalizePerfumePageState extends State<PersonalizePerfumePage> {
  List<String> selectedNotes = [];
  final List<String> notes = ['Rose', 'Vanilla', 'Citrus', 'Musk', 'Jasmine', 'Sandalwood'];
  final Map<String, String> noteImages = {
    'Rose': 'assets/rose.jpg',
    'Vanilla': 'assets/vanilla.jpg',
    'Citrus': 'assets/citrus.jpg',
    'Musk': 'assets/musk.jpg',
    'Jasmine': 'assets/jasmine.jpg',
    'Sandalwood': 'assets/sandalwood.jpg',
  };

  String perfumeName = '';
  PageController _pageController = PageController();

  void _showNamePerfumeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Name Your Perfume"),
        content: TextField(
          decoration: InputDecoration(hintText: "Enter Perfume Name"),
          onChanged: (value) {
            setState(() {
              perfumeName = value;
            });
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (perfumeName.isNotEmpty) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Perfume '$perfumeName' is created!")),
                );
              }
            },
            child: Text("Create"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Your Perfume'),
        backgroundColor: Colors.pink[100],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Choose Notes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Container(
              height: 180,
              child: PageView.builder(
                controller: _pageController,
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  String note = notes[index];
                  bool isSelected = selectedNotes.contains(note);

                  return GestureDetector(
                    onHorizontalDragUpdate: (details) {
                      if (details.primaryDelta! > 0) {
                        // Swiped right - add note
                        if (!isSelected) {
                          setState(() {
                            selectedNotes.add(note);
                          });
                        }
                      } else {
                        // Swiped left - remove note
                        if (isSelected) {
                          setState(() {
                            selectedNotes.remove(note);
                          });
                        }
                      }
                    },
                    child: Card(
                      margin: EdgeInsets.only(right: 12),
                      child: Column(
                        children: [
                          Image.asset(noteImages[note]!, height: 100, width: 100, fit: BoxFit.cover),
                          SizedBox(height: 8),
                          Text(note),
                          if (isSelected) Icon(Icons.check_circle, color: Colors.green),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Text("Statistics", style: TextStyle(fontWeight: FontWeight.bold)),
            if (selectedNotes.isEmpty)
              Text("No notes selected.")
            else
              Column(
                children: selectedNotes.map((note) => Text("✓ $note selected")).toList(),
              ),
            Spacer(),
            ElevatedButton(
              onPressed: selectedNotes.isEmpty
                  ? null
                  : () {
                // Ask user to name the perfume after selecting notes
                _showNamePerfumeDialog();
              },
              child: Text("Create Perfume"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pink[300]),
            ),
          ],
        ),
      ),
    );
  }
}
