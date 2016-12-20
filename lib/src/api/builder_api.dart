/// Build server API, get's called from Angular UI.
library api;

import 'dart:convert';

import 'package:egamebook_server/src/builder/builder.dart';
import 'package:shelf/shelf.dart';

Map<String, AppBuilderJob> _JOB_REPOSITORY = {};


///
/// Api method, starts a new job.
///
Response buildApp(Request request) {
  AppBuilderJob builderJob = new AppBuilderJob(null, null);
  return _runJobImpl(builderJob);
}

///
/// Api method, starts a new job.
///
Response scrapeDrive(Request request) {
  DriveScaperJob builderJob = new DriveScaperJob(null, null);
  return _runJobImpl(builderJob);
}

///
/// Api method, returns job status by it's id.
///
Response getJobStatus(String jobId) {
  AppBuilderJob job = _JOB_REPOSITORY[jobId];
  if (job == null) {
    return new Response.notFound(jobId);
  }
  return new Response.ok(JSON.encode({
    "status":job.status.toString(),
    "log":job.log,
    "results": job.results
  }));
}

///
/// Actual job management. Very straightforward at this point.
/// Returns jobId to the client, so it can pull for job status.
///
Response _runJobImpl(Job job) {
  print("Running job");
  _JOB_REPOSITORY[job.jobId] = job;
  job.status = JobStatus.IN_PROGRESS;
  print("run");
  job.run().then((bool jobResult) {
    if (jobResult) {
      job.status = JobStatus.DONE;
    } else {
      job.status = JobStatus.FAILED;
    }
  });
  print("return");
  return new Response.ok(JSON.encode(job.jobId));
}