import 'package:dio/dio.dart';
import '../../domain/model/certificacion.dart';
import '../../domain/repository/certificacion_repository.dart';

class CertificacionRepositoryImpl implements CertificacionRepository {
  final Dio _dio;
  CertificacionRepositoryImpl(this._dio);

  static const String _endpoint = '/certificaciones/';

  @override
  Future<List<Certificacion>> listar() async {
    final res = await _dio.get(_endpoint);
    final data = res.data;
    final List<dynamic> lista = data is Map<String, dynamic>
        ? (data['resultados'] ?? data['results'] ?? []) as List<dynamic>
        : data as List<dynamic>;
    return lista.map((j) => Certificacion.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<Certificacion> obtener(String id) async {
    final res = await _dio.get('$_endpoint$id/');
    return Certificacion.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<Certificacion> crear(Certificacion item) async {
    final res = await _dio.post(_endpoint, data: item.toJson());
    return Certificacion.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<Certificacion> actualizar(String id, Certificacion item) async {
    final res = await _dio.put('$_endpoint$id/', data: item.toJson());
    return Certificacion.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<void> eliminar(String id) async {
    await _dio.delete('$_endpoint$id/');
  }
}
