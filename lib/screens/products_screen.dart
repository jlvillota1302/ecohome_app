import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';
import 'chat_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List products = [];
  bool loading = true;
  String usernameLabel = '';

  @override
  void initState() {
    super.initState();
    loadProducts();
    loadStats();
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> loadProducts() async {
    final token = await getToken();

    final res = await http.get(
      Uri.parse('$baseUrl/products'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      setState(() {
        products = jsonDecode(res.body);
        loading = false;
      });
    }
  }

  Future<void> loadStats() async {
    final token = await getToken();

    final res = await http.get(
      Uri.parse('$baseUrl/users/me/stats'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      setState(() {
        usernameLabel = '${data['username']} (${data['productsCount']})';
      });
    }
  }

  Future<void> createProduct() async {
    final token = await getToken();

    final res = await http.post(
      Uri.parse('$baseUrl/products'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode({
        'name': 'Nuevo producto Flutter',
        'price': 99.9
      }),
    );

    if (res.statusCode == 201) {
      await loadProducts();
      await loadStats();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(usernameLabel.isEmpty ? 'Catálogo' : usernameLabel),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChatScreen()),
              );
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createProduct,
        child: const Icon(Icons.add),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: products.length,
        itemBuilder: (_, i) {
          final p = products[i];
          return ListTile(
            title: Text(p['name']),
            subtitle: Text('Creador: ${p['creator_username'] ?? 'N/D'}'),
            trailing: Text('\$${p['price']}'),
          );
        },
      ),
    );
  }
}