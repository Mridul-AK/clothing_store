import 'package:equatable/equatable.dart';

class Product extends Equatable {
  const Product({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.price,
    required this.imageUrl,
    required this.category,
  });

  final int id;
  final String name;
  final String subtitle;
  final double price;
  final String imageUrl;
  final String category;

  @override
  List<Object?> get props => [id, name, subtitle, price, imageUrl, category];
}
