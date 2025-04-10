import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiService {
  final String baseUrl = 'http://192.168.56.1/prjt/'; // Assure-toi que c'est bien le chemin correct vers ton projet

  Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse('${baseUrl}get_products.php')); // Correction ici
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Échec du chargement des produits');
    }
  }
}
