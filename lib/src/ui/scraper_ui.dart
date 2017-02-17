// Copyright (c) 2016, Tomucha. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:angular2/core.dart';
import 'package:egamebook_server/src/ui/builder_job_monitor.dart';
import 'package:fnx_rest/fnx_rest.dart';

///
/// Form with folderId input and the "start" button.
///
@Component(
    selector: 'scraper-ui',
    templateUrl: 'scraper_ui.html',
    directives: const [BuilderJobMonitor]
)
class ScraperUi {

  RestClient rest;

  String jobId;

  /// Default folder id, change to the folder ID
  /// you want to scrape most frequently.
  String folderId = "0BzP0HrbVsp3KWFBOV1lZOU5FUEk";

  @ViewChild("output")
  ElementRef output;

  ScraperUi(RestClient root) {
    rest = root.child("/builder/scrape-drive");
  }

  Future<Null> runScraper() async {
    if (jobId == null) {
      // let's schedule scraper job and receive jobId
      RestResult resp = await rest.post({
        "folderId":folderId
      });
      jobId = resp.data;
    }
  }

  void reset() {
    jobId = null;
  }

}
