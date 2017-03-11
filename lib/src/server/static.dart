library server_static;

import 'dart:io';

import 'package:egamebook_server/src/server/oauth.dart';
import 'package:egamebook_server/src/server/util/session.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_rest/shelf_rest.dart';
import 'package:shelf_static/shelf_static.dart';

///
/// Define handlers for static content a.k.a. Angular app.
///
void buildRoutesForStaticContent(Router<Router> rootRouter) {

  Response sessionKeyRenderer(Request request) {
    Session sess = session(request);
    String sessionId = sess.id;
    Map<String,String> headers = {};
    headers[HttpHeaders.CONTENT_TYPE] = "text/html";

    String indexHtmlContent = new File("build/web/index.html").readAsStringSync();
    indexHtmlContent = indexHtmlContent.replaceAll("SESSION_ID", sessionId);
    return new Response.ok(indexHtmlContent, headers: headers);
  }

  // static content = fallback
  rootRouter.add("/", ['GET'], sessionKeyRenderer, middleware: createOAuthGuardMiddleware());
  var staticHandler = createStaticHandler('build/web');
  rootRouter.add('/', ['GET'], staticHandler, exactMatch: false, middleware: createOAuthGuardMiddleware());
}
