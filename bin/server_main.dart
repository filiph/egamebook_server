import 'dart:io';
import 'package:egamebook_server/src/server-util/oauth.dart' as oauth;
import 'package:egamebook_server/src/sessions/session.dart';
import 'package:egamebook_server/src/sessions/shelf_simple_session.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_rest/shelf_rest.dart';
import 'package:shelf_static/shelf_static.dart';
import 'package:shelf/shelf.dart';

import 'package:egamebook_server/src/api/test_api.dart' as testApi;
import 'package:egamebook_server/src/api/builder_api.dart' as builderApi;

///
/// This starts the builder server.
///
void main() {

  Router rootRouter = router();

  buildApiRoutes(rootRouter);

  // oAuth routes
  rootRouter.get("/oauth-landing", oauth.handleOAuthCode);

  // static content = fallback
  var staticHandler = createStaticHandler('build/web', defaultDocument: 'index.html');
  rootRouter.add('/', ['GET'], staticHandler, exactMatch: false, middleware: oauth.createOAuthGuardMiddleware());

  // debug
  printRoutes(rootRouter);

  // and this is the server - universal middlewares and rootRouter
  var server = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(sessionMiddleware(new SimpleSessionStore()))
      .addHandler(rootRouter.handler);

  io.serve(server, 'localhost', 8080);
}

///
/// Define routes and handlers for API calls.
///
void buildApiRoutes(Router<Router> rootRouter) {

  // ignore: strong_mode_down_cast_composite
  Router api = rootRouter.child("/api/v1", middleware: createCorsHeadersMiddleware());

  // API endpoints
  api.get("/test", testApi.getTest);

  api.post("/builder/build-app", builderApi.buildApp);
  api.post("/builder/scrape-drive", builderApi.scrapeDrive);
  api.get("/builder/status/{jobId}", builderApi.getJobStatus);

}

///
/// Handles OPTIONS requests, handles CORS headers.
///
Middleware createCorsHeadersMiddleware() {

  const CORS_HEADERS = const {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'Content-Type'
  };

  // Handle preflight (OPTIONS) requests by just adding headers and an empty
  // response.
  Response handleOptionsRequest(Request request) {
    if (request.method == 'OPTIONS') {
      // this is workaround - shelf_cors package returns ok(null, ...) which
      // leads to server never committing the response and
      // browser waits endlessly
      return new Response.ok("OK", headers: CORS_HEADERS);
    } else {
      return null;
    }
  }

  Response addCorsHeaders(Response response) => response.change(headers: CORS_HEADERS);

  return createMiddleware(requestHandler: handleOptionsRequest, responseHandler: addCorsHeaders);

}