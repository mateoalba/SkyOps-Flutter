import 'package:dio/dio.dart';
import '../../domain/model/vuelo.dart';
import '../../domain/repository/vuelo_repository.dart';

class VueloRepositoryImpl implements VueloRepository {
  final Dio _dio;
  VueloRepositoryImpl(this._dio);

  static const String _endpoint = '/vuelos/';

  List<Vuelo> _parsear(dynamic data) {
    final List<dynamic> lista = data is Map<String, dynamic>
        ? (data['resultados'] ?? data['results'] ?? []) as List<dynamic>
        : data as List<dynamic>;
    return lista.map((j) => Vuelo.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<Vuelo>> listar() async {
    final res = await _dio.get(_endpoint);
    return _parsear(res.data);
  }

  @override
  Future<Vuelo> obtener(String id) async {
    final res = await _dio.get('$_endpoint$id/');
    return Vuelo.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<Vuelo> crear(Vuelo item) async {
    final res = await _dio.post(_endpoint, data: item.toJson());
    return Vuelo.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<Vuelo> actualizar(String id, Vuelo item) async {
    final res = await _dio.put('$_endpoint$id/', data: item.toJson());
    return Vuelo.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<void> eliminar(String id) async {
    await _dio.delete('$_endpoint$id/');
  }

  @override
  Future<List<Vuelo>> buscar({
    String? origenCodigo,
    String? destinoCodigo,
    DateTime? fecha,
  }) async {
    final query = <String, dynamic>{};
    if (origenCodigo != null && origenCodigo.isNotEmpty) {
      query['origen_codigo'] = origenCodigo;
    }
    if (destinoCodigo != null && destinoCodigo.isNotEmpty) {
      query['destino_codigo'] = destinoCodigo;
    }
    if (fecha != null) {
      final y = fecha.year.toString().padLeft(4, '0');
      final m = fecha.month.toString().padLeft(2, '0');
      final d = fecha.day.toString().padLeft(2, '0');
      query['fecha'] = '$y-$m-$d';
    }
    final res = await _dio.get(_endpoint, queryParameters: query);
    return _parsear(res.data);
  }

  @override
  Future<List<String>> asientosOcupados(String vueloId) async {
    final res = await _dio.get('$_endpoint$vueloId/asientos-ocupados/');
    final data = res.data;
    final List<dynamic> lista = (data is Map<String, dynamic> ? data['asientos_ocupados'] : null) ?? [];
    return lista.map((e) => e.toString()).toList();
  }
}
