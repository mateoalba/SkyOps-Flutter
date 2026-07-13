import '../model/tipo_aeronave.dart';

abstract class TipoAeronaveRepository {
  Future<List<TipoAeronave>> listar();
  Future<TipoAeronave> obtener(int id);
  Future<TipoAeronave> crear(TipoAeronave item);
  Future<TipoAeronave> actualizar(int id, TipoAeronave item);
  Future<void> eliminar(int id);
}
