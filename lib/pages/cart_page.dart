import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cart_provider.dart';
import '../models/product.dart';
import '../pages/payment_page.dart'; // Import the payment page

class CartPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
        backgroundColor: Colors.pink[100],
      ),
      body: cartItems.isEmpty
          ? Center(child: Text('No items in the cart'))
          : ListView.builder(
        itemCount: cartItems.length,
        itemBuilder: (context, index) {
          final product = cartItems[index];
          return ListTile(
            title: Text(product.name),
            subtitle: Text('\$${product.price}'),
            leading: Image.network(product.imageUrl, width: 50),
            trailing: IconButton(
              icon: Icon(Icons.remove_circle),
              onPressed: () {
                ref.read(cartProvider.notifier).removeFromCart(product);
              },
            ),
          );
        },
      ),
      bottomNavigationBar: cartItems.isEmpty
          ? null
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PaymentPage()),
                  );
                },
                child: Text('Buy'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  ref.read(cartProvider.notifier).clearCart();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Your cart has been cleared!"),
                  ));
                },
                child: Text('Clear Cart'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink[300],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
