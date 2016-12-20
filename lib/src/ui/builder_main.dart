import 'dart:async';

import 'package:angular2/core.dart';
import 'package:egamebook_server/config.dart';
import 'package:egamebook_server/src/ui/builder_ui.dart';
import 'package:egamebook_server/src/ui/scraper_ui.dart';
import "package:googleapis_auth/auth_browser.dart";

///
/// Root element of this Angular 2 app. Handles authentification which will allow
/// us to read files in users Drive. See ngOnInit method.
///
/// Successful authentification fills `client` variable,
/// which displays AppScraper component.
///
@Component(
    selector: 'builder-main',
    templateUrl: 'builder_main.html',
    directives: const [ScraperUi, BuilderUi]
)
class BuilderMain implements OnInit {

  ///
  /// Authorized client allows us to continue in ScraperUi.
  ///
  AccessCredentials credentials;

  BuilderMain();

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
    credentials = await flow.obtainAccessCredentialsViaUserConsent();

    flow.close();
  }

}
