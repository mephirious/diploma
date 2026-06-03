import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

/// Routes HTTP traffic directly to the host, bypassing system proxies
/// (iOS/macOS/Android) that often break LAN dev servers.
void configureDioHttpClient(Dio dio) {
  dio.httpClientAdapter = IOHttpClientAdapter(
    createHttpClient: () {
      final client = HttpClient();
      client.findProxy = (_) => 'DIRECT';
      return client;
    },
  );
}
