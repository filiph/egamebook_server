library server_oauth;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:egamebook_server/config.dart';
import 'package:egamebook_server/src/server/util/session.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:shelf/shelf.dart';
import 'package:shelf_rest/shelf_rest.dart';

void buildRoutesForOAuth(Router<Router> rootRouter) {
  rootRouter.get("/oauth-landing", handleOAuthCode);
}

///
/// Guards static (Angular) content, user must be "logged in".
/// If not logged in, we will redirect him to Google oAuth.
///
/// See https://developers.google.com/identity/protocols/OAuth2WebServer?hl=fr
///
Middleware createOAuthGuardMiddleware() {

  Response enforceOAuth(Request request) {
    Map<String, Cookie> cookies = request.context["cookies"] as Map<String, Cookie>;
    if (cookies == null || cookies["session"] == null) {
      Session sess = session(request);
      if (sess["accessCredentials"] == null) {
        print("Redirecting to google ...");
        return _createRedirectToGoogleOAuthResponse(request);
      } else {
        print(sess["accessCredentials"]);
        return null;
      }
    }
    return null;
  }
  return createMiddleware(requestHandler: enforceOAuth);
}

///
/// Constructs URL for redirect to Google's oAuth server.
///
Response _createRedirectToGoogleOAuthResponse(Request request) {

  Uri redirectResponse = Uri.parse("https://accounts.google.com/o/oauth2/v2/auth");

  redirectResponse = redirectResponse.replace(queryParameters: {
    "scope": "https://www.googleapis.com/auth/drive.readonly https://www.googleapis.com/auth/devstorage.read_write",
    "redirect_uri": _renderOauthLandingUriFromRequest(request),
    "client_id": OAUTH_CLIENT_ID,
    "response_type": "code"
  });

  return new Response.found(redirectResponse.toString());
}

///
/// Read oAuth tokens from Google servers and stores them in the session.
///
Future<Response> handleOAuthCode(Request request) async {

  // this is oAuth code we received from Google oAuth provider
  String code = request.url.queryParameters["code"];

  var url = "https://www.googleapis.com/oauth2/v4/token";

  Map tokenRetreivePayload = {
    "code": code,
    "client_id": OAUTH_CLIENT_ID,
    "client_secret": OAUTH_SECRET,
    "redirect_uri": _renderOauthLandingUriFromRequest(request),
    "grant_type": "authorization_code",
    "access_type": "offline"
  };

  http.Response response = await http.post(url, body: tokenRetreivePayload);
  //print("Response status: ${response.statusCode}");
  //print("Response body: ${response.body}");

  Session sess = session(request);

  Map respParsed = JSON.decode(response.body);

  if (respParsed["error"] != null) {
    return new Response.internalServerError(body: "Something went wrong: ${respParsed}");
  }

  DateTime expires = new DateTime.now().toUtc().add(new Duration(seconds: respParsed["expires_in"]));
  AccessToken token = new AccessToken(respParsed["token_type"], respParsed["access_token"], expires);
  AccessCredentials accessCredentials = new AccessCredentials(token, respParsed["refresh_token"], []);
  sess["accessCredentials"] = accessCredentials;

  ClientId clientId = new ClientId(OAUTH_CLIENT_ID, OAUTH_SECRET);
  http.Client client = new http.Client();
  AuthClient authorizedHttpClient = autoRefreshingClient(clientId, accessCredentials, client);

  print("sessionId="+sess.id);

  sess["authorizedHttpClient"] = authorizedHttpClient;

  // ... and redirect to index.html
  return new Response.found("/");
}

String _renderOauthLandingUriFromRequest(Request request) {
  return request.requestedUri.replace(path: "/oauth-landing", queryParameters: {}).toString().replaceFirst("?", "");
}
