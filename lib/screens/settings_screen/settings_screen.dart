// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:fluttermoji/fluttermoji.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zaitoon/constants/color_class.dart';
import 'package:zaitoon/constants/image_class.dart';
import 'package:zaitoon/constants/textstyle_class.dart';
import 'package:zaitoon/helper/navigation_helper.dart';
import 'package:zaitoon/helper/url_launcher.dart';
import 'package:zaitoon/screens/language_selection/language_selection.dart';
import 'package:zaitoon/screens/login_screen/login_screen.dart';
import 'package:zaitoon/screens/login_screen/provider/auth_provider.dart';
import 'package:zaitoon/screens/settings_screen/components/contact_us.dart';
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
  final Uri d4dxUrl = Uri.parse('https://d4dx.co/');

  @override
  void initState() {
    super.initState();
    // Load user details when screen initializes
    Future.microtask(() {
      // context.read<UserDataProvider>().loadUserDetails();
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

  Future<void> _websiteD4dx() async {
    if (!await launchUrl(d4dxUrl, mode: LaunchMode.externalApplication)) {
      throw 'Could not open ${d4dxUrl.toString()}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorClass.white,
      body: SafeArea(
        child: Consumer2<UserDataProvider, AuthProvider>(
          builder: (context, userDataProvider, authProvider, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Profile Title
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            ColorClass.grad1,
                            ColorClass.grad2,
                            ColorClass.grad3,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: Text(
                          'Profile',
                          style: TextStyleClass.fredoka(
                            fontSize: 28,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Profile Avatar and Name
                      Center(
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: FluttermojiCircleAvatar(
                                radius: 50,
                                backgroundColor: ColorClass.grey,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              userDataProvider.name ?? 'Rosy Mery',
                              style: TextStyleClass.fredoka(
                                fontSize: 20,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Settings Items
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ListView(
                      children: [
                        _buildSettingItem(
                          icon: LucideIcons.user,
                          title: 'My Profile',
                          subtitle: 'Manage your personal information',
                          onTap: () {
                            _showParentalGate(() {
                              // ignore: unrelated_type_equality_checks
                              if (authProvider.isSignedIn) {
                                navigatePR(
                                  context: context,
                                  screen: const UserDataCollection(
                                    isFromOnboarding: false,
                                  ),
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
                        // _buildSettingItem(
                        //   icon: Icons.golf_course_rounded,
                        //   title: 'Reward',
                        //   subtitle: 'View your reading progress',
                        //   onTap: () {
                        //     navigatePR(
                        //         context: context,
                        //         screen: const RewardScreen(
                        //           storiesCompleted:
                        //               15, // Number of completed stories
                        //           totalReadingMinutes:
                        //               240, // Total reading time in minutes
                        //           currentStreak: 5, // Current daily streak
                        //           longestStreak: 7, // Longest streak achieved
                        //           completionRate: 75.5, // Completion percentage
                        //         ));
                        //   },
                        // ),
                        _buildSettingItem(
                          icon: LucideIcons.globe,
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
                          icon: LucideIcons.share2,
                          title: 'Share App',
                          subtitle: 'Share Zai Toon with your friends',
                          onTap: () async {
                            _showParentalGate(() {
                              shareApp(context);
                            });
                          },
                        ),
                        _buildSettingItem(
                          icon: LucideIcons.alertCircle,
                          title: 'About Us',
                          subtitle: 'Learn more about zaitoon',
                          onTap: () {
                            _websiteD4dx();
                          },
                        ),
                        _buildSettingItem(
                          icon: LucideIcons.messageCircle,
                          title: 'Raise bug / Feedback',
                          subtitle: 'Help us improve your experience',
                          onTap: () {
                            _showParentalGate(() {
                              launchEmailFeedback();
                            });
                          },
                        ),
                        Consumer<AuthProvider>(
                          builder: (context, value, child) => _buildSettingItem(
                            icon: !authProvider.isSignedIn
                                ? LucideIcons.user
                                : LucideIcons.userMinus,
                            title: !authProvider.isSignedIn
                                ? 'Create Account'
                                : 'Delete Account',
                            subtitle: !authProvider.isSignedIn
                                ? 'Sign in to your account'
                                : 'Permanently delete your account',
                            onTap: () {
                              _showParentalGate(() {
                                !authProvider.isSignedIn
                                    ? navigatePR(
                                        context: context,
                                        screen: const AuthScreen(),
                                      )
                                    : showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            backgroundColor: ColorClass.white,
                                            title: const Text(
                                              'Delete Account',
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                            content: const Text(
                                              'Are you sure you want to delete your account? This action cannot be undone.',
                                              style: TextStyle(
                                                  color: Colors.black87),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context).pop(),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                  value.signOut(context);
                                                  navigatePR(
                                                    context: context,
                                                    screen: const AuthScreen(),
                                                  );
                                                },
                                                child: const Text(
                                                  'Delete',
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                              });
                            },
                          ),
                        ),
                        Consumer<AuthProvider>(
                          builder: (context, value, child) => _buildSettingItem(
                            icon: !authProvider.isSignedIn
                                ? LucideIcons.user
                                : LucideIcons.logOut,
                            title: !authProvider.isSignedIn
                                ? 'Sign In'
                                : 'Sign Out',
                            subtitle: !authProvider.isSignedIn
                                ? 'Sign in to your account'
                                : 'Sign out of account',
                            onTap: () {
                              _showParentalGate(() {
                                !authProvider.isSignedIn
                                    ? navigatePR(
                                        context: context,
                                        screen: const AuthScreen(),
                                      )
                                    : value.signOut(context);
                              });
                            },
                          ),
                        ),
                        _buildSettingItem(
                          icon: LucideIcons.phone,
                          title: 'Contact Us',
                          subtitle: 'Contact us for any support',
                          onTap: () {
                            _showParentalGate(() {
                              navigatePR(
                                context: context,
                                screen: const ContactUs(),
                              );
                            });
                          },
                        ),
                        const SizedBox(height: 30),
                        const Center(
                          child: Text(
                            'Version 1.0.15',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Column(
                          children: [
                            const Text(
                              'Powered By',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  ImageClass.d4Logo,
                                  height: 60,
                                  fit: BoxFit.contain,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
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
        color: ColorClass.containerBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
                    gradient: LinearGradient(
                      colors: [
                        ColorClass.grad1,
                        ColorClass.grad2,
                        ColorClass.grad3,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
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
                        style: TextStyleClass.fredoka(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

/*  void _showAboutUsBottomSheet(BuildContext context) {
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
  } */
}
