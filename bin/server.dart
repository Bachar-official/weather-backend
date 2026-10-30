import 'dart:io';

import 'package:logger/logger.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_swagger_ui/shelf_swagger_ui.dart';
import 'package:weather_backend/service/service.dart';

void main() async {
  final env = EnvService().getEnvironment();
  final netRepo = NetRepo(env: env);
  final logger = Logger();
  final updateService = UpdateService(
    netRepo: netRepo,
    environment: env,
    logger: logger,
  );
  final ip = InternetAddress.anyIPv4;
  final path = 'docs/swagger.json';
  final swaggerHandler = SwaggerUI.fromFile(File(path), title: 'Swagger Test');

  final mainRouter = Router()
    ..mount('/', updateService.router.call)
    ..mount('/swagger', swaggerHandler.call);

  final handler = Pipeline()
      .addMiddleware(corsHeaders())
      .addMiddleware(
        logRequests(
          logger: (message, isError) {
            if (isError) {
              logger.e(message);
            } else {
              logger.i(message);
            }
          },
        ),
      )
      .addHandler(mainRouter.call);

  final port = env.port;
  final server = await serve(handler, ip, port);
  logger.i('Server listening on port ${server.port}');
  logger.i(
    'Swagger UI available at http://${ip.address}:${server.port}/swagger',
  );
}
