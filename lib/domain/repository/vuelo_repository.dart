import '../model/vuelo.dart';

abstract class VueloRepository {
  Future<List<Vuelo>> listar();
  Future<Vuelo> obtener(String id);
  Future<Vuelo> crear(Vuelo item);
  Future<Vuelo> actualizar(String id, Vuelo item);
  Future<void> eliminar(String id);
  Future<List<Vuelo>> buscar({
    String? origenCodigo,
    String? destinoCodigo,
    DateTime? fecha,
  });
  Future<List<String>> asientosOcupados(String vueloId);
}
