library server_api;

import 'dart:async';
import 'dart:convert';

import 'package:egamebook_server/src/model/builder_jobs.dart';
import 'package:egamebook_server/src/model/builder_model.dart';

import 'package:egamebook_server/src/server/constants.dart';
import 'package:egamebook_server/src/server/util/session.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_rest/shelf_rest.dart';

part 'package:egamebook_server/src/server/api_builder.dart';
part 'package:egamebook_server/src/server/api_test.dart';

///
/// Define routes and handlers for API calls.
///
void buildRoutesForApi(Router<Router> rootRouter) {

  // ignore: strong_mode_down_cast_composite
  Router api = rootRouter.child("/api/v1", middleware: _createCorsHeadersMiddleware());

  // test API
  api.get("/test", getTest);

  // builder API
  api.post("/builder/build-app", buildAppApiMethod);
  api.post("/builder/scrape-drive", scrapeDriveApiMethod);
  api.get("/builder/status/{jobId}", getJobStatusApiMethod);

}

Handler catchAll(Handler handler) {
  return (Request r) {
    try {
      return handler(r);
    } catch (e, stack) {
      return new Response.internalServerError(body:e.toString());
    }
  };
}

///
/// Handles OPTIONS requests, handles CORS headers.
///
Middleware _createCorsHeadersMiddleware() {

  // FIXME: Origin * nebude to prave orechove!
  const CORS_HEADERS = const {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'Accept, Authorization, Content-Type'
  };

  // Handle preflight (OPTIONS) requests by just adding headers and an empty
  // response.
  Response handleOptionsRequest(Request request) {
    if (request.method == 'OPTIONS') {
      // this is workaround - shelf_cors package returns ok(null, ...) which
      // leads to server never committing the response and
      // browser waits endlessly. Let's return 'something':
      return new Response.ok("OK", headers: CORS_HEADERS);
    } else {
      return null;
    }
  }

  Response addCorsHeaders(Response response) => response.change(headers: CORS_HEADERS);

  return createMiddleware(requestHandler: handleOptionsRequest, responseHandler: addCorsHeaders);

}
