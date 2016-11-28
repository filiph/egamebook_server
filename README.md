Server side, tooling, etc.

### gDrive scraper

    cd gdrive_scraper
      
Angular 2 app which generates ZIP of txt files from specified Drive folder.

Before you do anything else copy `gdrive_scraper/lib/config.dart-example`
to `gdrive_scraper/lib/config.dart` and fill it with values obtained from
https://console.cloud.google.com/apis/credentials

You need to enable Drive API for your project and create "OAuth client ID"
credentials. And then:

    pub get
    pub serve

## Source codes
- start here: gdrive_scraper/web/main.dart
- but the most important part is: gdrive_scraper/lib/gdrive_scraper/scraper.dart