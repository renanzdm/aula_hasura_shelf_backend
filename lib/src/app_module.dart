import 'package:aula_hasura_shelf_backend/src/auth/auth_resource.dart';
import 'package:hasura_connect/hasura_connect.dart' as hasura;
import 'package:shelf/shelf.dart';
import 'package:shelf_modular/shelf_modular.dart';

class AppModule extends Module {
  @override
  List<Bind<Object>> get binds => [
        Bind.singleton((i) => hasura.HasuraConnect(
            'http://localhost:8080/v1/graphql',
            headers: {'x-hasura-admin-secret': 'renan'}))
      ];

  @override
  List<ModularRoute> get routes => [
        Route.get('/', () => Response.ok('Logado')),
        Route.resource('/auth', resource: AuthResource())
      ];
}
