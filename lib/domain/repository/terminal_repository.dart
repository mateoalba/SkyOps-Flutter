import '../model/terminal.dart';

abstract class TerminalRepository {
  Future<List<Terminal>> listar();
  Future<Terminal> obtener(String id);
  Future<Terminal> crear(Terminal item);
  Future<Terminal> actualizar(String id, Terminal item);
  Future<void> eliminar(String id);
}
