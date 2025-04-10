import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'pages/home_page.dart';
import 'pages/admin_home_page.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

final userRoleProvider = StateProvider<int?>((ref) => null);

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userRole = ref.watch(userRoleProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: userRole == null
          ? MainPage()
          : userRole == 1
          ? HomePage()
          : AdminHomePage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/video5.mp4')
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
        _controller.setLooping(true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _controller.value.isInitialized
              ? Positioned.fill(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            ),
          )
              : Container(),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        minimumSize: Size(double.infinity, 50),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ConnexionPage()),
                        );
                      },
                      child: Text('Connexion', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        minimumSize: Size(double.infinity, 50),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => InscriptionPage()),
                        );
                      },
                      child: Text('Inscription', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ConnexionPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<ConnexionPage> createState() => _ConnexionPageState();
}

class _ConnexionPageState extends ConsumerState<ConnexionPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;

  Future<void> login() async {
    final response = await http.post(
      Uri.parse('http://192.168.56.1/prjt/login.php'),
      body: {
        'email': _emailController.text,
        'password': _passwordController.text,
      },
    );
    final data = json.decode(response.body);
    if (data['success']) {
      int role = int.parse(data['role'].toString());
      ref.read(userRoleProvider.notifier).state = role;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => role == 1 ? HomePage() : AdminHomePage(),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(title: Text('Erreur'), content: Text(data['message'])),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('RETOUR', style: TextStyle(color: Colors.black, fontSize: 14)),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Adresse email'),
                validator: (value) => value!.isEmpty ? 'Veuillez entrer votre email' : null,
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscureText,
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  suffixIcon: IconButton(
                    icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscureText = !_obscureText),
                  ),
                ),
                validator: (value) => value!.isEmpty ? 'Veuillez entrer votre mot de passe' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    login();
                  }
                },
                child: Text('CONNEXION'),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class InscriptionPage extends StatefulWidget {
  @override
  _InscriptionPageState createState() => _InscriptionPageState();
}

class _InscriptionPageState extends State<InscriptionPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureText = true;

  Future<void> register() async {
    final response = await http.post(
      Uri.parse('http://192.168.56.1/prjt/enregistre.php'),
      body: {
        'name': _nameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
      },
    );
    final data = json.decode(response.body);
    if (data['success']) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'])));
      Navigator.pop(context);
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(title: Text('Erreur'), content: Text(data['message'])),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Inscription', style: TextStyle(color: Colors.black, fontSize: 14)),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              SizedBox(height: 30),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nom complet'),
                validator: (value) => value!.isEmpty ? 'Entrez votre nom' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Adresse email'),
                validator: (value) => value!.isEmpty ? 'Entrez un email valide' : null,
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscureText,
                decoration: InputDecoration(labelText: 'Mot de passe'),
                validator: (value) => value!.isEmpty ? 'Entrez un mot de passe' : null,
              ),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureText,
                decoration: InputDecoration(labelText: 'Confirmer le mot de passe'),
                validator: (value) =>
                value != _passwordController.text ? 'Les mots de passe ne correspondent pas' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    register();
                  }
                },
                child: Text('INSCRIPTION'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
