import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';

// Review model
class Review {
  final int rating;
  final String comment;
  int likes;

  Review({required this.rating, required this.comment, this.likes = 0});
}

// Simulated review storage (in-memory for demo)
final reviewsProvider = StateProvider<Map<String, List<Review>>>((ref) => {});

class ProductDetailsPage extends ConsumerWidget {
  final Product product;

  ProductDetailsPage({required this.product});

  void _showReviewDialog(BuildContext context, WidgetRef ref) {
    final _formKey = GlobalKey<FormState>();
    int rating = 5;
    String comment = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add Review"),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                value: rating,
                decoration: InputDecoration(labelText: "Rating"),
                items: List.generate(5, (i) => i + 1)
                    .map((e) => DropdownMenuItem(value: e, child: Text("$e Stars")))
                    .toList(),
                onChanged: (val) => rating = val!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Comment"),
                onChanged: (val) => comment = val,
                validator: (val) => val!.isEmpty ? "Please enter a comment" : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                ref.read(reviewsProvider.notifier).update((state) {
                  final newReview = Review(rating: rating, comment: comment);
                  final productId = product.id.toString();
                  state.putIfAbsent(productId, () => []).add(newReview);
                  return Map.from(state);
                });
                Navigator.pop(context);
              }
            },
            child: Text("Submit"),
          )
        ],
      ),
    );
  }

  double _calculateAverage(List<Review> reviews) {
    if (reviews.isEmpty) return 0.0;
    return reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isInWishlist = ref.watch(wishlistProvider).contains(product);
    final productId = product.id.toString(); // Convert product.id to string
    final reviews = ref.watch(reviewsProvider)[productId] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        backgroundColor: Colors.pink[100],
        actions: [
          IconButton(
            icon: Icon(isInWishlist ? Icons.favorite : Icons.favorite_border, color: Colors.red),
            onPressed: () {
              ref.read(wishlistProvider.notifier).toggleWishlist(product);
            },
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(product.imageUrl, height: 200, fit: BoxFit.cover),
            SizedBox(height: 16),
            Text(product.name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text('\$${product.price}', style: TextStyle(color: Colors.pink[300], fontSize: 18)),
            SizedBox(height: 10),
            Text(product.description),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber),
                Text(
                  reviews.isEmpty
                      ? "No rating"
                      : "${_calculateAverage(reviews).toStringAsFixed(1)} / 5 (${reviews.length} reviews)",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Spacer(),
                ElevatedButton(
                  onPressed: () => _showReviewDialog(context, ref),
                  child: Text("Add Review"),
                )
              ],
            ),
            Divider(height: 30),
            Text("User Reviews", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: reviews.isEmpty
                  ? Text("No reviews yet.")
                  : ListView.builder(
                itemCount: reviews.length,
                itemBuilder: (context, index) {
                  final review = reviews[index];
                  return Card(
                    child: ListTile(
                      leading: Icon(Icons.star, color: Colors.amber),
                      title: Text("${review.rating} Stars"),
                      subtitle: Text(review.comment),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.thumb_up),
                            onPressed: () {
                              ref.read(reviewsProvider.notifier).update((state) {
                                review.likes++;
                                return Map.from(state);
                              });
                            },
                          ),
                          Text("${review.likes}"),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(cartProvider.notifier).addToCart(product);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Added to cart!")),
                );
              },
              child: Text('Add to Cart'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pink[300]),
            )
          ],
        ),
      ),
    );
  }
}
