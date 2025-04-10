import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home_page.dart';
import '../../main.dart';
// 1. Définir le Provider pour le rôle de l'utilisateur
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

// 2. AdminHomePage adaptée pour Riverpod
class AdminHomePage extends ConsumerStatefulWidget {
  @override
  ConsumerState<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends ConsumerState<AdminHomePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  List<Map<String, dynamic>> products = [];
  int? editingId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    setState(() => _isLoading = true);
    try {
      // Récupérer l'ID admin depuis le provider
      final adminId = ref.read(userRoleProvider.notifier).state;

      final response = await http.get(
        Uri.parse('http://192.168.56.1/prjt/get_products.php?admin_id=$adminId'),
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() => products = List<Map<String, dynamic>>.from(data));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final adminId = ref.read(userRoleProvider.notifier).state;
      final url = editingId == null
          ? 'http://192.168.56.1/prjt/add_product.php'
          : 'http://192.168.56.1/prjt/update_product.php';

      final response = await http.post(Uri.parse(url), body: {
        'id': editingId?.toString() ?? '',
        'admin_id': adminId.toString(),
        'name': _nameController.text,
        'description': _descriptionController.text,
        'price': _priceController.text,
        'category': _categoryController.text,
        'size': _sizeController.text,
        'image_url': _imageUrlController.text,
      });

      if (response.statusCode == 200) {
        await fetchProducts();
        _resetForm();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Produit sauvegardé avec succès')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _logout() {
    ref.read(userRoleProvider.notifier).state = null;
    // Optionnel: Naviguer vers MainPage
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => MainPage()),
          (route) => false,
    );
  }

  // ... (keep all other methods from previous implementation: deleteProduct, _resetForm, _editProduct)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading && products.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ... (keep the same form UI from previous implementation)
            Expanded(
              child: _buildProductList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductList() {
    if (_isLoading) return Center(child: CircularProgressIndicator());
    if (products.isEmpty) return Center(child: Text('Aucun produit disponible'));

    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          child: ListTile(
            leading: _buildProductImage(product['image_url']),
            title: Text(product['name']),
            subtitle: _buildProductSubtitle(product),
            trailing: _buildProductActions(product),
          ),
        );
      },
    );
  }

  Widget _buildProductImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return Icon(Icons.image);
    return Image.network(
      imageUrl,
      width: 50,
      height: 50,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Icon(Icons.broken_image),
    );
  }

  Widget _buildProductSubtitle(Map<String, dynamic> product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Catégorie: ${product['category']}'),
        Text('Prix: \$${product['price']}'),
        if (product['size'] != null && product['size'].isNotEmpty)
          Text('Taille: ${product['size']}'),
      ],
    );
  }

  Widget _buildProductActions(Map<String, dynamic> product) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.edit),
          onPressed: _isLoading ? null : () => _editProduct(product),
        ),
        IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: _isLoading ? null : () => deleteProduct(product['id']),
        ),
      ],
    );
  }
}

// 3. Page de connexion modifiée pour mettre à jour le provider
class ConnexionPage extends ConsumerWidget {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) => value!.isEmpty ? 'Champ requis' : null,
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Mot de passe'),
                validator: (value) => value!.isEmpty ? 'Champ requis' : null,
              ),
              ElevatedButton(
                onPressed: () => _login(ref),
                child: Text('Connexion'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _login(WidgetRef ref) async {
    if (_formKey.currentState!.validate()) {
      // Simuler une connexion réussie
      // En production, vous ferez une requête API ici
      final response = await http.post(
        Uri.parse('http://192.168.56.1/prjt/login.php'),
        body: {
          'email': _emailController.text,
          'password': _passwordController.text,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          // Mettre à jour le provider avec le rôle de l'utilisateur
          ref.read(userRoleProvider.notifier).state = data['role'];
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'Erreur de connexion')),
          );
        }
      }
    }
  }
}