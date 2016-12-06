// Copyright (c) 2016, Tomucha. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:html';
import 'package:angular2/core.dart';
import 'package:archive/archive.dart';
import 'package:egamebook_server/src/gdrive_scraper/scraper.dart';
import 'package:egamebook_server/src/ui/builder_job_monitor.dart';
import "package:googleapis_auth/auth_browser.dart";

///
/// Form with folderId input and the "start" button.
///
@Component(
    selector: 'builder-ui',
    templateUrl: 'builder_ui.html',
    directives: const [BuilderJobMonitor]
)
class BuilderUi {

  /// Default folder id, change to the folder ID
  /// you want to scrape most frequently.
  String folderId = "0BzP0HrbVsp3KWFBOV1lZOU5FUEk";

  @Input()
  AuthClient client;

  @ViewChild("output")
  ElementRef output;

  BuilderUi();

  bool working = false;

  String jobId;

  Future<Null> runScraper() async {
    try {
      if (working) return null;
      working = true;
      DateTime dt = new DateTime.now();
      String dumpName = "drivedump-${dt.year}${_d2(dt.month)}${_d2(dt.day)}-${_d2(dt.hour)}${_d2(dt.minute)}";
      Scraper scraper = new Scraper(client);

      // let's wait for scraped files
      Archive archive = await scraper.scrapeResourcesArchive(folderId, dumpName);

      // ... zip them
      ZipEncoder enc = new ZipEncoder();
      List<int> zipped = enc.encode(archive);

      // ... and force download
      Blob blob = new Blob([zipped], "application/zip");
      AnchorElement anchor = new AnchorElement(href: Url.createObjectUrl(blob));
      anchor.append(new Text("Download: ${dumpName}"));
      anchor.download = dumpName;
      output.nativeElement.append(anchor);
      anchor.click();

      return null;
    } finally {
      working = false;
    }
  }

  ///
  /// Format to double digit.
  ///
  _d2(int number) {
    if (number == null) return "XX";
    return number.toString().padLeft(2, '0');
  }

}
