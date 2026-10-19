import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../../../core/error/exceptions.dart';
import '../models/product_model.dart';

abstract interface class ProductLocalDataSource {
  Future<List<ProductModel>> getProducts();
}

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  ProductLocalDataSourceImpl({
    required AssetBundle bundle,
    this.assetPath = defaultAssetPath,
    this.latency = const Duration(milliseconds: 600),
  }) : _bundle = bundle;

  static const String defaultAssetPath = 'assets/data/products.json';

  final AssetBundle _bundle;
  final String assetPath;

  final Duration latency;

  @override
  Future<List<ProductModel>> getProducts() async {
    await Future<void>.delayed(latency);

    try {
      final raw = await _bundle.loadString(assetPath);
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final items = json['products'] as List<dynamic>;
      return items
          .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
          .toList(growable: false);
    } on FlutterError {
      throw const DataSourceException('The product catalogue is unavailable.');
    } on FormatException {
      throw const DataSourceException('The product catalogue is malformed.');
    } on TypeError {
      throw const DataSourceException('The product catalogue is malformed.');
    }
  }
}
