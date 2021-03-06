library gdrive_scraper;

import 'dart:async';
import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:googleapis/drive/v3.dart' as d;
import 'package:googleapis_auth/auth.dart';

const MIMETYPE_FOLDER = "application/vnd.google-apps.folder";
const MIMETYPE_DOC = "application/vnd.google-apps.document";
//const MIMETYPE_DOCX = "application/vnd.openxmlformats-officedocument.wordprocessingml.document";

///
/// Scrapes does all Drive reading. Starts in specified folder
/// and then recursively dives into all it's children.
///
class Scraper {
  /// Authorized Drive oAuth client.
  AuthClient client;

  Scraper(this.client);

  Future<Archive> scrapeResourcesArchive(String folderId, {String archiveRootName: null}) async {
    // result archive
    Archive archive = new Archive();

    // Drive API connection authorized by client
    d.DriveApi api = new d.DriveApi(client);

    // recursion start
    await _scrapeFolder(api, archive, folderId, archiveRootName);

    return archive;
  }

  ///
  /// Recursive method for fetching a folder and its contents.
  ///
  Future<Null> _scrapeFolder(d.DriveApi api, Archive archive, String folderId, String context) async {
    // query folder contents
    d.FileList l = await api.files.list(pageSize: 1000, q: "'$folderId' in parents");
    // AND (mimeType='$MIMETYPE_FOLDER' or mimeType='$MIMETYPE_DOC')"); <-- this worked, but not anymore, now it returns only doc files and no folders

    // context is not empty, we are creating
    // files in current directory
    if (context == null) {
      context = "";
    } else {
      context = context + "/";
    }

    for (var i = 0; i < l.files.length; ++i) {
      var f = l.files[i];

      // ignore: literal_only_boolean_expressions
      if ((f.trashed ?? false) || (f.explicitlyTrashed ?? false)) {
        // this one is GONE

      } else if (f.mimeType == MIMETYPE_FOLDER) {
        // let's dive deeper and wait for result
        await _scrapeFolder(api, archive, f.id, context + f.name);

      } else if (f.mimeType == MIMETYPE_DOC) {
        // export to TXT and add to archive
        d.Media downloaded = await api.files.export(f.id, "text/plain", downloadOptions: d.DownloadOptions.FullMedia);
        List<List<int>> chunks = await downloaded.stream.toList();
        List<int> data = [];
        chunks.forEach((List<int> chunk) {
          data.addAll(chunk);
        });
        var text = UTF8.decode(data);
        // Convert to UNIX newlines.
        text = text.replaceAll('\r\n', '\n');
        // Remove extra newlines.
        text = text.replaceAll('\n\n', '\n');
        // Google Docs eats one leading space. Add it back.
        text = text.replaceAllMapped(new RegExp(r'^([ ]+)(\S)', multiLine: true), (m) {
          return '${m.group(1)} ${m.group(2)}';
        });
        // Add newline at end of file.
        text = '$text\n';
        final newData = UTF8.encode(text);

        var extension = f.name.endsWith(".txt") ? '' : '.txt';
        archive.addFile(new ArchiveFile(context + f.name + extension, newData.length, newData));
      } else {
        // not interesting
      }
    }
    return null;
  }
}
