// Copyright (c) 2016, Tomucha. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:html';
import 'package:angular2/core.dart';
import 'package:archive/archive.dart';
import 'package:egamebook_server/src/builder/builder.dart';
import 'package:egamebook_server/src/gdrive_scraper/scraper.dart';
import 'package:fnx_rest/fnx_rest.dart';
import "package:googleapis_auth/auth_browser.dart";

///
/// Renders status of the specified job.
///
@Component(
    selector: 'builder-job-monitor',
    templateUrl: 'builder_job_monitor.html'
)
class BuilderJobMonitor implements OnInit {

  @Input()
  String jobId;

  RestClient apiRoot;
  RestClient jobApi;

  BuilderJobMonitor(this.apiRoot);

  String jobStatus;
  List<String> jobLog;

  @override
  ngOnInit() {
    jobApi = apiRoot.child("/builder/status/${jobId}");
    _readJobStatus();
  }

  Future<Null> _readJobStatus() async {
    RestResult response = await jobApi.get();
    if (!response.success) throw new Exception("Cannot read job info, HTTP status=${response.status}");
    jobStatus = response.data["status"];
    jobLog = response.data["log"] as List<String>;

    if (jobStatus == JobStatus.IN_PROGRESS.toString()) {
      // job still running, wait and pull again
      await new Future.delayed(new Duration(seconds: 1));
      _readJobStatus();
    }
  }
}
