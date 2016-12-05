library builder;

import 'dart:async';
import 'package:uuid/uuid.dart';

Uuid uuidGenerator = new Uuid();

class BuilderJob {

  String jobId;

  /// If null we take master
  String gitId;

  // If null we take current version
  String driveSnapshot;

  List<String> log;

  BuilderJob(this.gitId, this.driveSnapshot) {
    jobId = uuidGenerator.v1().toString();
    log = [];
  }

  Future<bool> run() async {
    try {
      log.add("Starting job #${jobId}");

      log.add("Fetching source code");
      await new Future.delayed(new Duration(seconds: 5));


      log.add("Fetching text data");
      await new Future.delayed(new Duration(seconds: 5));


      log.add("Creating project");
      await new Future.delayed(new Duration(seconds: 5));


      log.add("Running tool #1");
      await new Future.delayed(new Duration(seconds: 5));


      log.add("Running tool #2");
      await new Future.delayed(new Duration(seconds: 5));


      log.add("Building gamebook");
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