/// Build server API, get's called from Angular UI.
part of server_api;

Map<String, AppBuilderJob> _JOB_REPOSITORY = {};

///
/// Api method, starts a new job.
///
Response buildAppApiMethod(Request request) {
  AppBuilderJob builderJob = new AppBuilderJob(null, null);
  return _runJobImpl(builderJob);
}

///
/// Api method, starts a new job.
///
Future<Response> scrapeDriveApiMethod(Request request) async {
  Map<String, Object> requestPayload = (JSON.decode(await request.readAsString()) as Map<String,Object>);
  String folderId = requestPayload["folderId"] as String;
  AuthClient client = _getClientBySessionId(request);
  DriveScaperJob builderJob = new DriveScaperJob(folderId, client);
  return _runJobImpl(builderJob);
}

AuthClient _getClientBySessionId(Request request) {
  String sessionId = request.headers["Authorization"];
  Session sess = SESSION_STORE.getSessionById(sessionId);
  if (sess == null) throw "Session was not found, refresh your web page";
  return sess["authorizedHttpClient"];
}

///
/// Api method, returns job status by it's id.
///
Response getJobStatusApiMethod(String jobId) {
  Job job = _JOB_REPOSITORY[jobId];
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