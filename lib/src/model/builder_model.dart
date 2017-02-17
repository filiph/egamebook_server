library builder_model;

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