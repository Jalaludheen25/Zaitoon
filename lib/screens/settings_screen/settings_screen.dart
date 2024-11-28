// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:fluttermoji/fluttermoji.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:zaitoon/constants/app_constants.dart';
import 'package:zaitoon/constants/color_class.dart';
import 'package:zaitoon/constants/image_class.dart';
import 'package:zaitoon/helper/navigation_helper.dart';
import 'package:zaitoon/helper/url_launcher.dart';
import 'package:zaitoon/screens/language_selection/language_selection.dart';
import 'package:zaitoon/screens/login_screen/login_screen.dart';
import 'package:zaitoon/screens/login_screen/provider/auth_provider.dart';
import 'package:zaitoon/screens/settings_screen/components/parental_gate.dart';
import 'package:zaitoon/screens/settings_screen/components/shareapp_selection.dart';
import 'package:zaitoon/screens/user_data_collection_screen/user_data_collection_screen.dart';
import 'package:zaitoon/screens/user_data_collection_screen/provider/user_data_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    // Load user details when screen initializes
    Future.microtask(() {
      context.read<UserDataProvider>().loadUserDetails();
    });
  }

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
        child: Consumer<UserDataProvider>(
          builder: (context, userDataProvider, child) {
            return CustomScrollView(
              slivers: [
                // Custom App Bar with Avatar
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
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.purple.withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: FluttermojiCircleAvatar(
                              radius: 50,
                              backgroundColor: ColorClass.grey,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (userDataProvider.name != null)
                            Text(
                              userDataProvider.name!,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
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
                          AuthProvider authProvider =
                              Provider.of<AuthProvider>(context, listen: false);
                          _showParentalGate(() {
                            if (authProvider.isSignedIn) {
                              navigatePR(
                                context: context,
                                screen: const UserDataCollection(),
                              );
                            } else {
                              navigatePR(
                                context: context,
                                screen: const AuthScreen(),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please sign in to access this feature',
                                  ),
                                ),
                              );
                            }
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
                        icon: Icons.ios_share,
                        title: 'Share App',
                        subtitle: 'Share Zai Toon with your friends',
                        onTap: () async {
                          shareApp(context);
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
                      Consumer<AuthProvider>(
                        builder: (context, value, child) => _buildSettingItem(
                          icon: Icons.logout,
                          title: 'Logout',
                          subtitle: 'Sign out of your account',
                          onTap: () {
                            _showParentalGate(() {
                              value.signOut(context);
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Center(
                        child: Text(
                          'version ${ApiContants.appVersion}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Column(
                        children: [
                          const Text(
                            'Powered by',
                            style: TextStyle(
                              fontSize: 12,
                              color: ColorClass.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                ImageClass.d4Logo,
                                height: 100,
                                fit: BoxFit.contain,
                                color: ColorClass.white,
                              ),
                              Image.asset(
                                ImageClass.d4dxLogo,
                                height: 100,
                                fit: BoxFit.contain,
                                color: ColorClass.white,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ]),
                  ),
                ),
              ],
            );
          },
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
                      '''
📚 Zai Toon is an engaging digital platform crafted for young minds by Malarvadi Children's Organization in Kerala! 🌟

🎨 We transform storytelling into magical adventures with:
• Vibrant animations & delightful sounds
• Stories in multiple languages 🗣️
• Regular updates with new stories ✨
• Educational & fun content for kids 🎯

👨‍👩‍👧‍👦 Perfect for family reading time, bedtime stories, or learning sessions!

🏆 From Malarvadi Children's Organization: Where learning meets imagination.

Join us in making reading fun for every child! 📖✨''',
                      style: TextStyle(
                        fontSize: 16,
                        color: ColorClass.white,
                        height: 1.5,
                      ),
                    ),
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
