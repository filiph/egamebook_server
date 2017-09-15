import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:archive/archive.dart';
import 'package:egamebook_server/config.dart';
import 'package:egamebook_server/src/gdrive_scraper/scraper.dart';
import 'package:egamebook_server/src/util.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart';
import 'package:args/args.dart';

const SERIALIZED_ACCESS_CREDENTIALS = ".cli_access_credentials.private";

///
/// Run this script to scrape Drive from command line.
///
Future main(List<String> arguments) async {

  ArgParser parser = setUpArgParser();
  ArgResults res = parser.parse(arguments);
  if (res['help']) {
    print("Usage:");
    print(parser.usage);
    return;
  }

  String output = res['output'];
  io.File outputDir;
  if (output != null) {
    outputDir = new io.File(output);
    io.FileStat stat = outputDir.statSync();
    if (stat.type != io.FileSystemEntityType.DIRECTORY) {
      print("${outputDir.absolute} is not a directory");
      io.exit(1);
      return;
    }
  }

  // Am I zipping, or downloading to a folder?
  bool zipping = outputDir == null;
  
  // folder to scrape, change if you need to
  const folderId = "0BzP0HrbVsp3KRVBQNXBnd0tPNzA";

  ClientId clientId = new ClientId(CLI_CLIENT_ID, CLI_SECRET);
  var SCOPES = ['https://www.googleapis.com/auth/drive.readonly'];

  Client httpClient = new Client();
  AccessCredentials accessCredentials = deserializePreviousCredentials();

  if (accessCredentials == null) {
    // we run for the first time, we need to authorize user
    accessCredentials = await obtainAccessCredentialsViaUserConsentManual(clientId, SCOPES, httpClient, promptForCode);
  } else {
    print("Using previous access credentials from $SERIALIZED_ACCESS_CREDENTIALS");
  }

  AuthClient authorizedHttpClient = autoRefreshingClient(clientId, accessCredentials, httpClient);

  Scraper scraper = new Scraper(authorizedHttpClient);

  String dumpName = zipping ? renderDriveDumpFilename(folderId) : null;

  // let's wait for scraped files
  print("Scraping, please wait ...");
  Archive archive = await scraper.scrapeResourcesArchive(folderId, archiveRootName: dumpName);

  // save credentials
  serializeCredentialsForNextTime(authorizedHttpClient.credentials);

  // close HTTP
  authorizedHttpClient.close();
  httpClient.close();

  if (zipping) {
    // ... zip them files
    ZipEncoder enc = new ZipEncoder();
    List<int> zipped = enc.encode(archive);

    // flush data to a ZIP file
    String zipFileName = "$dumpName.zip";
    io.File f = new io.File(zipFileName);
    f.writeAsBytesSync(zipped, flush: true);
    print("... and here it is: $zipFileName");

  } else {
    archive.forEach((ArchiveFile f) {
      io.File out = new io.File(outputDir.absolute.path+"/"+f.name);
      out.parent.createSync(recursive: true);
      out.writeAsBytesSync(f.content, flush: true);
    });
    print("... and here it is: ${outputDir.absolute.path}");
  }
}

///
/// Prompts user to open a browser and obtain oAuth code.
///
Future<String> promptForCode(String uri) {
  print("Open this in browser: "+uri);
  print("And enter the code:");
  String result = io.stdin.readLineSync();
  return new Future.value(result);
}

/// Saves credentials to JSON file for next time user runs this script.
void serializeCredentialsForNextTime(AccessCredentials accessCredentials) {
  Map data = {};
  data["scopes"] = accessCredentials.scopes;
  data["refreshToken"] = accessCredentials.refreshToken;
  data["accessToken.data"] = accessCredentials.accessToken.data;
  data["accessToken.expiry"] = accessCredentials.accessToken.expiry.toUtc().millisecondsSinceEpoch;
  data["accessToken.type"] = accessCredentials.accessToken.type;

  io.File serialized = new io.File(SERIALIZED_ACCESS_CREDENTIALS);
  serialized.writeAsStringSync(JSON.encode(data));
}

/// Loads saved creadentials or returns null.
AccessCredentials deserializePreviousCredentials() {

  io.File serialized = new io.File(SERIALIZED_ACCESS_CREDENTIALS);
  if (!serialized.existsSync()) return null;

  String jsonData = serialized.readAsStringSync();
  if (jsonData == null || jsonData.isEmpty) return null;

  Map data = JSON.decode(jsonData);
  AccessToken accessToken = new AccessToken(
      data["accessToken.type"],
      data["accessToken.data"],
      new DateTime.fromMillisecondsSinceEpoch(data["accessToken.expiry"]).toUtc()
  );
  AccessCredentials credentials = new AccessCredentials(accessToken, data["refreshToken"], data["scopes"] as List<String>);
  return credentials;

}

ArgParser setUpArgParser() {
  ArgParser p = new ArgParser();
  p.addOption("output", abbr: "o", help: "Directory where to put downloaded files. If not provided, scraper will generate a zip file.");
  p.addFlag("help", abbr: "h", help: "Prints this message", negatable: false);
  return p;
}
