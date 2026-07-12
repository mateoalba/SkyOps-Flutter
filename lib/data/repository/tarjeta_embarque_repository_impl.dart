import 'package:dio/dio.dart';
import '../../domain/model/tarjeta_embarque.dart';
import '../../domain/repository/tarjeta_embarque_repository.dart';

class TarjetaEmbarqueRepositoryImpl implements TarjetaEmbarqueRepository {
  final Dio _dio;
  TarjetaEmbarqueRepositoryImpl(this._dio);

  static const String _endpoint = '/tarjetas-embarque/';

  @override
  Future<List<TarjetaEmbarque>> listar() async {
    final res = await _dio.get(_endpoint);
    final data = res.data;
    final List<dynamic> lista = data is Map<String, dynamic>
        ? (data['resultados'] ?? data['results'] ?? []) as List<dynamic>
        : data as List<dynamic>;
    return lista.map((j) => TarjetaEmbarque.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<TarjetaEmbarque> obtener(int id) async {
    final res = await _dio.get('$_endpoint$id/');
    return TarjetaEmbarque.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<TarjetaEmbarque> crear(TarjetaEmbarque item) async {
    final res = await _dio.post(_endpoint, data: item.toJson());
    return TarjetaEmbarque.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<TarjetaEmbarque> actualizar(int id, TarjetaEmbarque item) async {
    final res = await _dio.put('$_endpoint$id/', data: item.toJson());
    return TarjetaEmbarque.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<void> eliminar(int id) async {
    await _dio.delete('$_endpoint$id/');
  }
}
