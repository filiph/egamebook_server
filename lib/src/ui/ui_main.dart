import 'package:angular2/core.dart';
import 'package:egamebook_server/src/ui/builder_ui.dart';
import 'package:egamebook_server/src/ui/scraper_ui.dart';

///
/// Root element of this Angular 2 app.
///
@Component(
    selector: 'ui-main',
    templateUrl: 'ui_main.html',
    directives: const [ScraperUi, BuilderUi]
)
class UiMain {

  UiMain();

}
