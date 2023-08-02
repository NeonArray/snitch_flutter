/// Note: This isn't currently used. In the future this whole application
/// might work better as a REST API server. The way Ray works is through
/// that method. The weird thing is that they defer all the processing
/// work and formatting to the client libs. They then send that data
/// to this server and is executed in a webview. This is likely ok
/// for this case since the server wouldn't be exposed externally
/// and would only be used for local development.
import 'dart:io';

import 'package:flutter/foundation.dart';

// listen for a GET request on the /_availability_check route
// and respond with a 200 OK
void handleAvailabilityCheck(HttpRequest request) {
  if (kDebugMode) {
    print("${DateTime.now()}Availability check received: ${request.uri}");
  }
  request.response
    ..statusCode = HttpStatus.ok
    ..close();
}

// create a server and listen for requests
Future<void> serve() async {
  final server = await HttpServer.bind("proxyman.local", 23517);
  if (kDebugMode) {
    print("Server started");
  }
  await for (final request in server) {
    if (kDebugMode) {
      print("Request received: ${request.uri}");
    }
    if (request.uri.path == '/_availability_check') {
      handleAvailabilityCheck(request);
    } else {
      request.response
        ..statusCode = HttpStatus.notFound
        ..close();
    }
  }
}
