import 'dart:async';
import 'dart:convert';

import 'package:hasura_connect/hasura_connect.dart' as hasura;
import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_modular/shelf_modular.dart';

class AuthResource extends Resource {
  @override
  List<Route> get routes => [Route.post('/login', _login)];

  FutureOr<Response> _login(
      Request request, Injector injector, ModularArguments arguments) async {
    final hasuraConnect = injector.get<hasura.HasuraConnect>();
    final response = await hasuraConnect.query(_loginDocument,
        variables: arguments.data['input']);

    final userLists = response['data']['users'] as List;
    if (userLists.isEmpty) {
      final responseError = {'message': 'Falha ao realizar login'};
      return Response.forbidden(jsonEncode(responseError));
    }

    final user = userLists.first;

    final key =
        '3EK6FD+o0+c7tzBNVfjpMkNDi2yARAAKzQlk8O2IKoxQu4nF7EdAh8s3TwpHwrdWT6R';
    final claimSet = JwtClaim(otherClaims: <String, dynamic>{
      "https://hasura.io/jwt/claims": {
        "x-hasura-allowed-roles": ["editor", "user", "mod"],
        "x-hasura-default-role": user['default_role'],
        "x-hasura-user-id": user['id'].toString(),
        "x-hasura-org-id": user['id_company'].toString(),
      }
    }, maxAge: const Duration(minutes: 3));

    String token = issueJwtHS256(claimSet, key);

    final result = {
      'accessToken': token.toString(),
      'refreshToken': 'asasas',
      'expireIn': 1
    };

    return Response.ok(jsonEncode(result));
  }
}

const _loginDocument = r'''
query Login($email: String!, $password: String!, $idCompany: Int!) {
  users(where: {email: {_eq: $email}, password: {_eq: $password}, id_company: {_eq: $idCompany}}) {
    name
    id
    id_company
    default_role
  }
}
''';
