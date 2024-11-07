// ignore_for_file: avoid_print

import 'package:url_launcher/url_launcher.dart';

Future<void> launchURL(String url) async {
  final Uri uri = Uri.parse(url);

  try {
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw 'Could not launch $url';
    }
  } catch (e) {
    print('Error launching URL: $e');
    // Handle the error appropriately for your app
    rethrow;
  }
}

Future<void> launchEmailFeedback({
  String subject = 'Feedback - Zai Toon',
  String body = '',
}) async {
  final Uri emailUri = Uri(
    scheme: 'mailto',
    path: 'mail@d4dx.co',
    query: encodeQueryParameters({
      'subject': subject,
      'body': body,
    }),
  );

  try {
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      throw 'Could not launch email client';
    }
  } catch (e) {
    print('Error launching email: $e');
    // Handle the error appropriately for your app
    rethrow;
  }
}

// Helper function to encode the query parameters
String? encodeQueryParameters(Map<String, String> params) {
  return params.entries
      .map((e) =>
          '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
      .join('&');
}

// Example usage:
// await launchEmailFeedback(
//   email: 'support@example.com',
//   subject: 'App Feedback',
//   body: 'I would like to provide feedback about...'
// );
