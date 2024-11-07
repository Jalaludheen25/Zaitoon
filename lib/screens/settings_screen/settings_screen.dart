// ignore_for_file: deprecated_member_use

import 'package:zaitoon/constants/app_constants.dart';
import 'package:zaitoon/constants/image_class.dart';
import 'package:zaitoon/constants/textstyle_class.dart';
import 'package:zaitoon/helper/navigation_helper.dart';
import 'package:zaitoon/helper/url_launcher.dart';
import 'package:zaitoon/screens/home_screen/home_screen.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        navigatePRTo(context, const HomeScreen());
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.black,
          title: Text(
            'Settings',
            style: TextStyleClass.primaryFont600(16, Colors.white),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () {
              navigatePRTo(context, const HomeScreen());
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage(ImageClass.appIcon),
                      fit: BoxFit.contain,
                    ),
                  ),
                  height: 150,
                ),
              ),
              const SizedBox(height: 12.0),
              const Center(
                child: Text(
                  'version ${ApiContants.appVersion}',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              InkWell(
                  onTap: () {
                    // show a bottom sheet with the a title and description border radius

                    showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return Container(
                            decoration: const BoxDecoration(
                              color: Colors.black,
                              border: Border(
                                top: BorderSide(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                            ),
                            child: Column(
                              children: [
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceBetween, // This spreads out the children
                                  children: [
                                    const Expanded(
                                      child: Center(
                                        // Centers the text
                                        child: Text(
                                          'About Us',
                                          style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        // Add your close functionality here
                                        Navigator.pop(
                                            context); // This will close the current screen/dialog
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Expanded(
                                  child: ListView(
                                    children: const [
                                      SizedBox(height: 20),
                                      Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 20),
                                          child: Text(
                                            "Zai Toon is an engaging digital platform designed especially for young readers and children, presented by the Malarvadi Children’s Organization in Kerala. This vibrant initiative is inspired by the popular webtoon format, offering stories that are visually captivating, relatable, and full of valuable life lessons. Zai Toon provides a space where young minds can dive into stories that not only entertain but also inspire and instill meaningful values. By embracing a digital storytelling approach, Zai Toon makes reading accessible, interactive, and enjoyable for today’s tech-savvy youth.\n\nThe Malarvadi Children’s Organization, known for its many projects and programs aimed at enhancing young minds, has developed Zai Toon to encourage personal growth and integrity in children. Through thoughtfully crafted stories, the platform emphasizes themes of kindness, resilience, and empathy, encouraging children to make positive choices and develop a sense of purpose. Zai Toon’s mission goes beyond storytelling; it seeks to nurture young readers into responsible and value-driven individuals who are well-equipped to navigate their future.",
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white,
                                            ),
                                          )),
                                      SizedBox(height: 20),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        });
                  },
                  child: _buildSectionTitle(
                    'About Us',
                  )),
              InkWell(
                onTap: () {
                  launchEmailFeedback();
                },
                child: _buildSectionTitle(
                  'Feedback',
                ),
              ),
              InkWell(
                onTap: () {
                  launchURL(ApiContants.privaryPolicyUrl);
                },
                child: _buildSectionTitle(
                  'Privacy Policy',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_right,
                color: Colors.white,
              )
            ],
          ),
          const Divider(
            color: Colors.white38,
          )
        ],
      ),
    );
  }
}
