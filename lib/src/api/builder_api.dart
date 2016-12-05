import 'dart:async';
import 'dart:convert';
import 'package:egamebook_server/src/builder/builder.dart';
import 'package:shelf/shelf.dart';

Map<String, BuilderJob> JOB_REPOSITORY = {};

Response postJob(Request request) {
  BuilderJob builderJob = new BuilderJob(null, null);
  JOB_REPOSITORY[builderJob.jobId] = builderJob;
  builderJob.run();
  return new Response.ok(builderJob.jobId);
}


Response getJobStatus(String jobId) {
  BuilderJob job = JOB_REPOSITORY[jobId];
  if (job == null) {
    return new Response.notFound(jobId);
  }
  return new Response.ok(JSON.encode(job.log));
}