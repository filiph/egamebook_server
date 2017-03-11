import 'dart:async';
import 'dart:io';
import 'package:egamebook_server/src/server/api.dart';
import 'package:egamebook_server/src/server/constants.dart';
import 'package:egamebook_server/src/server/oauth.dart';
import 'package:egamebook_server/src/server/static.dart';
import 'package:egamebook_server/src/server/util/session.dart';
import 'package:egamebook_server/src/server/util/shelf_simple_session.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_rest/shelf_rest.dart';
import 'package:shelf/shelf.dart';

///
/// This starts the builder server.
///
void main() {

  Router rootRouter = router();

  // routing
  buildRoutesForApi(rootRouter);
  buildRoutesForOAuth(rootRouter);
  buildRoutesForStaticContent(rootRouter);

  // debug
  printRoutes(rootRouter);

  // and this is the server - universal middlewares and rootRouter
  var server = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(sessionMiddleware(SESSION_STORE))
      .addHandler(rootRouter.handler);

  io.serve(server, 'localhost', 8080);
}


