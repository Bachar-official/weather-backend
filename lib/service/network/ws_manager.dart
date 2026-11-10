import 'dart:async';
import 'dart:convert';

import 'package:logger/web.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:weather_backend/service/cache/weather_cache.dart';

class WsManager {
  final WeatherCache _cache;
  final Logger _logger;
  final Set<WebSocketChannel> _clients = {};

  WsManager(this._cache, this._logger);

  FutureOr<Response> Function(Request) get handler =>
      webSocketHandler((webSocket, _) {
        _clients.add(webSocket);
        _logger.d('WS connected. Clients: ${_clients.length}');
        webSocket.sink.add(_cache.buildUpdatePayload());
        webSocket.sink.add(timePayload);
        webSocket.stream.listen(
          (_) {},
          onDone: () {
            _clients.remove(webSocket);
            _logger.d('WS disconnected. Clients: ${_clients.length}');
          },
          onError: (error) {
            _logger.e('WS Error', error: error);
            _clients.remove(webSocket);
          },
        );
      });

  void broadcast() {
    if (_clients.isEmpty) return;
    final payload = _cache.buildUpdatePayload();
    for (final client in _clients) {
      client.sink.add(payload);
    }
  }

  final timePayload = jsonEncode({
    'type': 'time',
    'timestamp': DateTime.now().toIso8601String(),
  });

  void broadcastTime() {
    if (_clients.isEmpty) return;

    for (final client in _clients) {
      client.sink.add(timePayload);
    }
  }
}
