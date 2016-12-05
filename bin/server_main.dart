import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_rest/shelf_rest.dart';
import 'package:shelf_static/shelf_static.dart';

import 'package:egamebook_server/src/api/test_api.dart' as testApi;
import 'package:egamebook_server/src/api/builder_api.dart' as builderApi;


void main() {


  Router root = router();

  // ignore: strong_mode_down_cast_composite
  Router api = root.child("/api/v1");

  // API endpoints
  api.get("/test", testApi.getTest);

  api.post("/builder/run", builderApi.postJob);
  api.get("/builder/status/{jobId}", builderApi.getJobStatus);

  // static content
  var staticHandler = createStaticHandler('build/web', defaultDocument: 'index.html');
  root.add('/', ['GET'], staticHandler, exactMatch: false);

  printRoutes(root);

  io.serve(root.handler, 'localhost', 8080);
}