import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_local_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  const ProductRepositoryImpl(this._dataSource);

  final ProductLocalDataSource _dataSource;

  @override
  Future<Result<List<Product>>> getProducts() async {
    try {
      return Ok(await _dataSource.getProducts());
    } on DataSourceException catch (e) {
      return Err(DataFailure(e.message));
    }
  }
}
