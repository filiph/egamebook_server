Server side, tooling, etc.

Before you do anything else copy `gdrive_scraper/lib/config.dart-example`
to `gdrive_scraper/lib/config.dart` and fill it with values obtained from
https://console.cloud.google.com/apis/credentials

You will need two client ID's - for web client and for CLI client (Other).

# CLI scraper

Run:

    dart bin/scraper_main.dart
        
...when running for the first time, you will need to open your browser and obtain oAuth code.
This code is then used to obtain access credentials for your gDrive. Access credentials
are stored in ".cli_access_credentials.private" file. Keep it secret, keep it safe!

Just follow instructions on the screen.

# Build server

Download dependencies:

    pub get
    
Build web client:
    
    pub build
    
Run server:
    
    dart bin/server_main.dart
    
... then go to

    http://localhost:8080/test.html
    http://localhost:8080/api/v1/test
    
You should see a reasonable test content there.

## Server routing

Server is based on [shelf](https://pub.dartlang.org/packages/shelf)
and is using [shelf_static](https://pub.dartlang.org/packages/shelf_static) for serving
static content (Angular2 Dart UI) and [shelf_rest](https://pub.dartlang.org/packages/shelf_rest)
for handling API calls.

All routing is defined in:

     bin/server_main.dart
     
_Note: Please make sure to define all API calls first and then
the default routing (= static content)._     

---
# Obsolete: ###

Source codes have been already moved to the server itself.

## gDrive scraper

    cd gdrive_scraper
      
Angular 2 app which generates ZIP of txt files from specified Drive folder.

Before you do anything else copy `gdrive_scraper/lib/config.dart-example`
to `gdrive_scraper/lib/config.dart` and fill it with values obtained from
https://console.cloud.google.com/apis/credentials

You need to enable Drive API for your project and create "OAuth client ID"
credentials. And then:

    pub get
    pub serve

### Source codes
- start here: gdrive_scraper/web/main.dart
- but the most important part is: gdrive_scraper/lib/gdrive_scraper/scraper.dart