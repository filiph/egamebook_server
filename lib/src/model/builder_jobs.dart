library builder_jobs;

import 'dart:async';

import 'package:archive/archive.dart';
import 'package:egamebook_server/src/gdrive_scraper/scraper.dart';
import 'package:egamebook_server/src/model/builder_model.dart';
import 'package:googleapis_auth/auth_io.dart';

///
/// Scrape the drive and create snapshot
///
class DriveScaperJob extends Job {

  String driveFolderId;
  AuthClient authorizedHttpClient;

  DriveScaperJob(this.driveFolderId, this.authorizedHttpClient);

  Future<bool> run() async {
    try {
      log.add("Starting job #${jobId}");

      DateTime dt = new DateTime.now();
      String dumpName = "drivedump-${dt.year}${_d2(dt.month)}${_d2(dt.day)}-${_d2(dt.hour)}${_d2(dt.minute)}.zip";

      Scraper scraper = new Scraper(authorizedHttpClient);

      log.add("Scraping, please wait ...");
      Archive archive = await scraper.scrapeResourcesArchive(driveFolderId, dumpName);

      log.add("All data downloaded, zipping ...");

      // ... zip them files
      ZipEncoder enc = new ZipEncoder();
      List<int> zipped = enc.encode(archive);
      log.add("Uploading ${zipped.length} bytes to GCS as ${dumpName}...");

      results.add("http://seznam.cz/");

      log.add("Job done!");
      return true;

    } catch (e, stack) {
      log.add("Job didn't finish properly: "+e);
      log.add(stack?.toString());
      return false;
    }
  }
}

///
/// Build an eGameBook based on constructor parameters.
///
class AppBuilderJob extends Job {

  /// If null we take master
  String gitId;

  // If null we take current version
  String driveSnapshot;

  AppBuilderJob(this.gitId, this.driveSnapshot);

  Future<bool> run() async {
    try {
      print("in run 1");
      log.add("Starting job #${jobId}");

      log.add("Fetching source code");
      await new Future.delayed(new Duration(seconds: 3));


      print("in run 2");
      log.add("Fetching text data");
      await new Future.delayed(new Duration(seconds: 3));


      print("in run 3");
      log.add("Creating project");
      await new Future.delayed(new Duration(seconds: 3));


      log.add("Running tool #1");
      await new Future.delayed(new Duration(seconds: 3));

      results.add("http://www.seznam.cz/");

      log.add("Running tool #2");
      await new Future.delayed(new Duration(seconds: 3));


      log.add("Building gamebook");
      await new Future.delayed(new Duration(seconds: 3));

      print("in run - job done");
      log.add("Job done!");
      results.add("http://www.root.cz/");
      return true;

    } catch (e, stack) {
      log.add("Job didn't finish properly: "+e);
      log.add(stack?.toString());
      return false;
    }
  }

}


///
/// Format to double digit.
///
_d2(int number) {
  if (number == null) return "XX";
  return number.toString().padLeft(2, '0');
}