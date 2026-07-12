import 'package:dio/dio.dart';
import '../../domain/model/audit_log.dart';
import '../../domain/repository/audit_log_repository.dart';

class AuditLogRepositoryImpl implements AuditLogRepository {
  final Dio _dio;
  AuditLogRepositoryImpl(this._dio);

  static const String _endpoint = '/audit-log/';

  @override
  Future<List<AuditLog>> listar() async {
    final res = await _dio.get(_endpoint);
    final data = res.data;
    final List<dynamic> lista = data is Map<String, dynamic>
        ? (data['resultados'] ?? data['results'] ?? []) as List<dynamic>
        : data as List<dynamic>;
    return lista.map((j) => AuditLog.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<AuditLog> obtener(String id) async {
    final res = await _dio.get('$_endpoint$id/');
    return AuditLog.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<AuditLog> crear(AuditLog item) async {
    final res = await _dio.post(_endpoint, data: item.toJson());
    return AuditLog.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<AuditLog> actualizar(String id, AuditLog item) async {
    final res = await _dio.put('$_endpoint$id/', data: item.toJson());
    return AuditLog.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<void> eliminar(String id) async {
    await _dio.delete('$_endpoint$id/');
  }
}
