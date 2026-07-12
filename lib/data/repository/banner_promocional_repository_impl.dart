import 'package:dio/dio.dart';
import '../../domain/model/banner_promocional.dart';
import '../../domain/repository/banner_promocional_repository.dart';

class BannerPromocionalRepositoryImpl implements BannerPromocionalRepository {
  final Dio _dio;
  BannerPromocionalRepositoryImpl(this._dio);

  static const String _endpoint = '/banners/';

  @override
  Future<List<BannerPromocional>> listar() async {
    final res = await _dio.get(_endpoint);
    final data = res.data;
    final List<dynamic> lista = data is Map<String, dynamic>
        ? (data['resultados'] ?? data['results'] ?? []) as List<dynamic>
        : data as List<dynamic>;
    return lista.map((j) => BannerPromocional.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<BannerPromocional> guardar(String clave, String imagenUrl) async {
    final res = await _dio.put('$_endpoint$clave/', data: {'imagen_url': imagenUrl});
    return BannerPromocional.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<BannerPromocional> guardarContenido(
    String clave, {
    String? titulo,
    String? texto,
    String? imagenUrl,
  }) async {
    final data = <String, dynamic>{
      if (titulo != null) 'titulo': titulo,
      if (texto != null) 'texto': texto,
      if (imagenUrl != null) 'imagen_url': imagenUrl,
    };
    final res = await _dio.put('$_endpoint$clave/', data: data);
    return BannerPromocional.fromJson(res.data as Map<String, dynamic>);
  }
}
