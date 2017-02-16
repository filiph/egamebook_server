/// Example API.
part of server_api;

Response getTest(Request request) {
  return new Response.ok("API is alive!");
}

Future<Response> getTestAsync(Request request) {
  return new Future.delayed(new Duration(seconds: 2), () => new Response.ok("API is alive!"));
}