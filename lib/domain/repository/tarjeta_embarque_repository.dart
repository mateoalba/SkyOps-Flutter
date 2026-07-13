import '../model/tarjeta_embarque.dart';

abstract class TarjetaEmbarqueRepository {
  Future<List<TarjetaEmbarque>> listar();
  Future<TarjetaEmbarque> obtener(int id);
  Future<TarjetaEmbarque> crear(TarjetaEmbarque item);
  Future<TarjetaEmbarque> actualizar(int id, TarjetaEmbarque item);
  Future<void> eliminar(int id);
}
