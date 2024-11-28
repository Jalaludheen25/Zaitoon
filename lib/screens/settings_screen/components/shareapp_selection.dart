// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

Future<void> shareApp(context) async {
  const String appStoreLink =
      'https://apps.apple.com/in/app/zai-toon-kids/id6737912105';
  const String playStoreLink =
      'https://play.google.com/store/apps/details?id=co.d4dx.zaitoon';

  String textToShare = '''📚 Zai Toon Kids - Where Stories Come Alive!

🌟 Make storytime magical with interactive children's stories that engage and inspire young minds.

📱 Download Now:
- iOS: $appStoreLink
- Android: $playStoreLink

✨ Why Choose Zai Toon Kids?
- Interactive storytelling experience
- Kid-friendly interface
- Regular updates with new stories
- Educational and entertaining content

Join thousands of families making reading time special! 🎉

Download Zai Toon Kids today and start a magical reading journey with your child. 📖✨

#ZaiToonKids #ChildrenStories #InteractiveReading''';

  try {
    final result = await Share.share(
      textToShare,
      subject: '📚 Join the magical world of Zai Toon Kids!',
    );

    if (result.status == ShareResultStatus.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('App shared successfully')),
      );
    } else if (result.status == ShareResultStatus.dismissed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Share action dismissed')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Share action failed')),
      );
    }
  } catch (e) {
    print('Error sharing app: $e');
  }
}
