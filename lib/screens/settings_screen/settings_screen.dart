import 'package:flutter/material.dart';
import 'package:zaitoon/constants/app_constants.dart';
import 'package:zaitoon/constants/color_class.dart';
import 'package:zaitoon/constants/image_class.dart';
import 'package:zaitoon/helper/navigation_helper.dart';
import 'package:zaitoon/helper/url_launcher.dart';
import 'package:zaitoon/screens/language_selection/language_selection.dart';
import 'package:zaitoon/screens/settings_screen/components/parental_gate.dart';
import 'package:zaitoon/screens/user_data_collection_screen/user_data_collection_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  void _showParentalGate(Function action) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ParentalGate(
        onSuccess: () => action(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorClass.black,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Custom App Bar
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              backgroundColor: ColorClass.black,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.purple.withOpacity(0.6),
                        Colors.black,
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: ColorClass.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            ImageClass.appIcon,
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'version ${ApiContants.appVersion}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // leading: IconButton(
              //   icon: const Icon(Icons.arrow_back_ios, color: ColorClass.white),
              //   onPressed: () => navigateBack(context),
              // ),
            ),

            // Settings Items
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildSettingItem(
                    icon: Icons.person_outline,
                    title: 'My Profile',
                    subtitle: 'Manage your personal information',
                    onTap: () {
                      _showParentalGate(() {
                        navigatePR(
                          context: context,
                          screen: const UserDataCollection(),
                        );
                      });
                    },
                  ),
                  _buildSettingItem(
                    icon: Icons.language,
                    title: 'Language',
                    subtitle: 'Change your preferred language',
                    onTap: () {
                      navigatePR(
                        context: context,
                        screen: const LanguageSelection(),
                      );
                    },
                  ),
                  _buildSettingItem(
                    icon: Icons.info_outline,
                    title: 'About Us',
                    subtitle: 'Learn more about Zai Toon',
                    onTap: () {
                      _showAboutUsBottomSheet(context);
                    },
                  ),
                  _buildSettingItem(
                    icon: Icons.feedback_outlined,
                    title: 'Feedback',
                    subtitle: 'Help us improve your experience',
                    onTap: () {
                      _showParentalGate(() {
                        launchEmailFeedback();
                      });
                    },
                  ),
                  _buildSettingItem(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    subtitle: 'Read our privacy policy',
                    onTap: () {
                      _showParentalGate(() {
                        launchURL(ApiContants.privaryPolicyUrl);
                      });
                    },
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[800]!,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.purple[300],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[600],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAboutUsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: ColorClass.black,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'About Us',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: ColorClass.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: ColorClass.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: const [
                    Text(
                      "Zai Toon is an engaging digital platform designed especially for young readers and children, presented by the Malarvadi Children's Organization in Kerala...",
                      style: TextStyle(
                        fontSize: 16,
                        color: ColorClass.white,
                        height: 1.5,
                      ),
                    ),
                    // Add more content...
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
