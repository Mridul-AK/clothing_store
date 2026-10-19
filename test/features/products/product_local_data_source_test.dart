import 'dart:convert';
import 'dart:io';

import 'package:clothing_store/core/error/exceptions.dart';
import 'package:clothing_store/features/products/data/datasources/product_local_data_source.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Serves a fixed string for any key, or throws like a missing asset.
class _FakeBundle extends CachingAssetBundle {
  _FakeBundle(this._content);

  final String? _content;

  @override
  Future<ByteData> load(String key) async {
    if (_content == null) throw FlutterError('Unable to load asset: $key');
    return ByteData.sublistView(utf8.encode(_content));
  }
}

ProductLocalDataSourceImpl _source(String? content) =>
    ProductLocalDataSourceImpl(
      bundle: _FakeBundle(content),
      latency: Duration.zero,
    );

void main() {
  test(
    'the bundled catalogue parses into at least 10 typed products',
    () async {
      final json = File(
        ProductLocalDataSourceImpl.defaultAssetPath,
      ).readAsStringSync();

      final products = await _source(json).getProducts();

      expect(products.length, greaterThanOrEqualTo(10));
      expect(
        products.map((p) => p.id).toSet().length,
        products.length,
        reason: 'ids must be unique',
      );
      for (final p in products) {
        expect(p.name, isNotEmpty);
        expect(p.price, greaterThan(0));
      }
    },
  );

  test('integer prices are read as doubles', () async {
    const json =
        '{"products":[{"id":1,"name":"A","subtitle":"B",'
        '"price":20,"image_url":"u","category":"c"}]}';

    final products = await _source(json).getProducts();

    expect(products.single.price, 20.0);
  });

  test('a missing field is reported as a DataSourceException', () async {
    const json = '{"products":[{"id":1,"name":"A"}]}';

    expect(_source(json).getProducts(), throwsA(isA<DataSourceException>()));
  });

  test('invalid JSON is reported as a DataSourceException', () async {
    expect(
      _source('{not json').getProducts(),
      throwsA(isA<DataSourceException>()),
    );
  });

  test('a missing asset is reported as a DataSourceException', () async {
    expect(_source(null).getProducts(), throwsA(isA<DataSourceException>()));
  });
}
