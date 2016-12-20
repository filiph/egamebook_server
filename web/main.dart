// Copyright (c) 2016, Tomucha. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:angular2/core.dart';
import 'package:angular2/platform/browser.dart';
import 'package:egamebook_server/src/ui/builder_main.dart';
import 'package:fnx_rest/fnx_rest.dart';
import 'package:fnx_config/fnx_config_read.dart';

///
/// This starts the builder UI.
///
main() {

  // connection to builder server
  RestClient apiRoot = new HttpRestClient.root(fnxConfig()["apiRoot"]);

  // start UI!
  bootstrap(BuilderMain, [provide(RestClient, useValue: apiRoot)]);

}
