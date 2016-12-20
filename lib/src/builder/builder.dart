library builder;

import 'dart:async';

import 'package:uuid/uuid.dart';

enum JobStatus {
  IN_PROGRESS,
  DONE,
  FAILED
}

///
/// Long term job running on the server.
///
abstract class Job {

  static final Uuid uuidGenerator = new Uuid();

  String jobId = uuidGenerator.v1().toString();

  List<String> log = [];

  JobStatus status;

  Future<bool> run();

  List<String> results = [];

}

///
/// Scrape the drive and create snapshot
///
class DriveScaperJob extends Job {

  String driveFolderId;
  String authToken;

  DriveScaperJob(this.driveFolderId, this.authToken);

  Future<bool> run() async {
    try {
      log.add("Starting job #${jobId}");

      DateTime dt = new DateTime.now();
      String dumpName = "drivedump-${dt.year}${_d2(dt.month)}${_d2(dt.day)}-${_d2(dt.hour)}${_d2(dt.minute)}";
/*
      GoogleClient

      AuthClient client = new AuthClient()

      auth.




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
      */








      log.add("Doing stuff");
      await new Future.delayed(new Duration(seconds: 5));

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