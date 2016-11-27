import 'dart:async';
import 'package:angular2/core.dart';
import 'package:gdrive_scraper/scraper_ui.dart';
import 'package:gdrive_scraper/config.dart';
import "package:googleapis_auth/auth_browser.dart";

///
/// Root element of this Angular 2 app. Handles authentification which will allow
/// us to read files in users Drive. See ngOnInit method.
///
/// Successful authentification fills `client` variable,
/// which displays AppScraper component.
///
@Component(
    selector: 'scraper-main',
    templateUrl: 'scraper_main.html',
    directives: const [ScraperUi]
)
class ScraperMain implements OnInit {

  ///
  /// Authorized client allows us to continue in ScraperUi.
  ///
  AuthClient client;

  ScraperMain();

  ///
  /// Automatically launches OAuth login window.
  ///
  @override
  Future ngOnInit() async {
    var id = new ClientId(OAUTH_CLIENT_ID, null);
    var scopes = ["https://www.googleapis.com/auth/drive.readonly"];

    // Initialize the browser oauth2 flow functionality.
    BrowserOAuth2Flow flow = await createImplicitBrowserFlow(id, scopes);

    // we have the authorized client!
    client = await flow.clientViaUserConsent();

    flow.close();
  }
}
