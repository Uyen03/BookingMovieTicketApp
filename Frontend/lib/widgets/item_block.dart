import 'package:flutter/material.dart';
import '../models/movie_model.dart';

class ItemBlock extends StatelessWidget {
  final Movie model;
  final double height;
  final double width;
  final Function(Movie model) onTap;

  const ItemBlock({
    Key? key,
    required this.model,
    this.height = 150,
    this.width = 120,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 20.0, right: 10),
      child: GestureDetector(
        onTap: () {
          onTap(model);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                model.bannerUrl ?? 'https://via.placeholder.com/150',
                height: height,
                width: width,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: height,
                    width: width,
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return _errorPlaceholder();
                },
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: width,
              child: Text(
                model.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorPlaceholder() {
    return Container(
      height: height,
      width: width,
      color: Colors.grey,
      alignment: Alignment.center,
      child: const Icon(Icons.error, color: Colors.red, size: 40),
    );
  }
}
