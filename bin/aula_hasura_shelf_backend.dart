import 'package:aula_hasura_shelf_backend/src/app_module.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_modular/shelf_modular.dart';

void main(List<String> arguments) async {
  var server = await io.serve(Modular(module: AppModule()), '0.0.0.0', 3000);
  print(server);
}
