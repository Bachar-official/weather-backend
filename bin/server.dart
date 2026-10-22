import 'dart:io';

import 'package:logger/logger.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:weather_backend/service/service.dart';

void main() async {
  final env = EnvService().getEnvironment();
  final netRepo = NetRepo(env: env);
  final logger = Logger();
  final updateService = UpdateService(netRepo: netRepo, environment: env, logger: logger);
  final ip = InternetAddress.anyIPv4;

  final handler = Pipeline()
      .addMiddleware(corsHeaders())
      .addMiddleware(logRequests(logger: (message, isError) {
        if (isError) {
          logger.e(message);
        } else {
          logger.i(message);
        }
      }))
      .addHandler(updateService.router.call);

  final port = env.port;
  final server = await serve(handler, ip, port);
  logger.i('Server listening on port ${server.port}');
}
