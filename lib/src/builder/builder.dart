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
}

///
/// Scrape the drive and create snapshot
///
class DriveScaperJob extends Job {

  String driveFolderId;

  DriveScaperJob(this.driveFolderId);

  Future<bool> run() async {
    try {
      log.add("Starting job #${jobId}");

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


      log.add("Running tool #2");
      await new Future.delayed(new Duration(seconds: 3));


      log.add("Building gamebook");
      await new Future.delayed(new Duration(seconds: 3));

      print("in run - job done");
      log.add("Job done!");
      return true;

    } catch (e, stack) {
      log.add("Job didn't finish properly: "+e);
      log.add(stack?.toString());
      return false;
    }
  }

}