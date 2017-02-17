// Copyright (c) 2016, Tomucha. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:angular2/core.dart';
import 'package:angular2/platform/browser.dart';
import 'package:egamebook_server/src/ui/exception_handler.dart';
import 'package:egamebook_server/src/ui/ui_main.dart';
import 'package:fnx_rest/fnx_rest.dart';
import 'package:fnx_config/fnx_config_read.dart';
import 'dart:html';
import 'dart:js' as js;

///
/// This starts the builder UI.
///
main() {

  // sessionId (a.k.a. auth-key) is rendered into the index.html page
  // by server as a global JS variable (after successful oAuth)
  String sessionId = (js.context['sessionId'] as String);

  if (sessionId == 'SESSION_ID') {
    // we are developing in Chromium, index.html wasn't served by the server
    // ... in such case, let's look into URL
    Uri u = Uri.parse(window.location.toString());
    sessionId = u.queryParameters["debugSessionId"];
  }

  if (sessionId == null) {
    window.alert("Your sessionId is empty, I cannot continue. See main.dart for more info.");

  } else {
    // connection to builder server
    RestClient apiRoot = new HttpRestClient.root(fnxConfig()["apiRoot"]);
    apiRoot.setHeader("Authorization", sessionId);

    // start Angular UI!
    bootstrap(UiMain, [
      provide(RestClient, useValue: apiRoot),
      provide(ExceptionHandler, useValue: new CustomExceptionHandler())
    ]);
  }

}
