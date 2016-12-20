import 'package:egamebook_server/config.dart';
import 'package:shelf/shelf.dart';
import 'package:egamebook_server/src/sessions/session.dart';

///
/// Constructs URL for redirect to Google's oAuth server.
///
Response redirectToGoogleOAuth(Request request) {

  // this server, but different path and no parameters
  String oauthLanding = request.requestedUri.replace(path: "/oauth-landing", queryParameters: null).toString();

  Uri redirect = Uri.parse("https://accounts.google.com/o/oauth2/v2/auth");
  redirect = redirect.replace(queryParameters: {
    "scope": "https://www.googleapis.com/auth/drive.readonly",
    "redirect_uri": oauthLanding,
    "client_id": OAUTH_CLIENT_ID,
    "response_type": "code"
  });

  return new Response.found(redirect.toString());
}

///
/// Read oAuth tokens from Google servers and stores them in the session.
///
Response handleOAuthCode(Request request) {
  Session sess = session(request);
  if (sess["test"] == null) {
    sess["test"] = 0;
  }
  sess["test"] = sess["test"] + 1;

  return new Response.ok("je to tu: "+sess["test"].toString());
}