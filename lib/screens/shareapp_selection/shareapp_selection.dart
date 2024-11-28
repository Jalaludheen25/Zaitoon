import 'package:share_plus/share_plus.dart';

Future<void> shareApp() async {
    // App store links
    const String appStoreLink =
        'https://apps.apple.com/in/app/zai-toon-kids/id6737912105'; // Replace with your App Store ID
    const String playStoreLink =
        'https://play.google.com/store/apps/details?id=co.d4dx.zaitoon'; // Replace with your app's package name

    // Format the text to be shared
    String textToShare =
        'Welcome to Zai Toon Kids - Where Children\'s Stories Come Alive\n\n'
        'Download for iOS: $appStoreLink\n\n'
        'Download for Android: $playStoreLink\n\n'
        'Make story time special for your child Download Zai Toon Kids today and start a magical reading journey together\n'
'Updates bring new kid-friendly stories regularly to keep your child engaged and excited about reading.';

    try {
      final result = await Share.share(
        textToShare,
        subject: 'Download Zai Toon App',
      );

      // Optional: Handle the share result
      if (result.status == ShareResultStatus.success) {
        print('Thank you for sharing!');
      } else if (result.status == ShareResultStatus.dismissed) {
        print('Share action dismissed.');
      } else {
        print('Share action failed.');
      }
    } catch (e) {
      print('Error sharing app: $e');
    }
  }