import 'package:url_launcher/url_launcher.dart';

/// Opens 2GIS app when installed, otherwise 2gis.ru in the browser.
Future<bool> open2GIS(String address) async {
  final query = address.trim();
  if (query.isEmpty) return false;

  final encoded = Uri.encodeComponent(query);
  final appUri = Uri.parse('dgis://2gis.kz/search/$encoded');
  final webUri = Uri.parse('https://2gis.kz/search/$encoded');

  if (await canLaunchUrl(appUri)) {
    return launchUrl(appUri);
  }
  return launchUrl(webUri, mode: LaunchMode.externalApplication);
}
