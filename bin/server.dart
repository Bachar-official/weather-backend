import 'dart:io';

import 'package:logger/logger.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_swagger_ui/shelf_swagger_ui.dart';
import 'package:weather_backend/service/cache/weather_cache.dart';
import 'package:weather_backend/service/network/ws_manager.dart';
import 'package:weather_backend/service/router/weather_router.dart';
import 'package:weather_backend/service/service.dart';
import 'package:weather_backend/service/sync/data_sync_service.dart';

void main() async {
  final env = EnvService().getEnvironment();
  final netRepo = NetRepo(env: env);
  final logger = Logger();

  final cache = WeatherCache();

  final wsManager = WsManager(cache, logger);

  DataSyncService(
    cache: cache,
    netRepo: netRepo,
    env: env,
    logger: logger,
    onDataUpdated: wsManager.broadcast,
    onTimeTick: wsManager.broadcastTime,
  );

  final weatherRouter = WeatherRouter(cache);

  final path = 'docs/swagger.json';
  final swaggerHandler = SwaggerUI.fromFile(File(path), title: 'Weather API');

  final mainRouter = Router()
    ..mount('/', weatherRouter.router.call)
    ..get('/ws', wsManager.handler)
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

  final ip = InternetAddress.anyIPv4;
  final port = env.port;
  final server = await serve(handler, ip, port);
  logger.i('Server listening on port ${server.port}');
  logger.i(
    'Swagger UI available at http://${ip.address}:${server.port}/swagger',
  );
  logger.i('WebSocket: ws://${ip.address}:${server.port}/ws');
}
