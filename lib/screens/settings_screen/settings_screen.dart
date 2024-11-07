import 'package:d4tales/constants/image_class.dart';
import 'package:d4tales/constants/textstyle_class.dart';
import 'package:d4tales/helper/navigation_helper.dart';
import 'package:d4tales/screens/home_screen/home_screen.dart';
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
          backgroundColor: Colors.black,
          title:   Text('Settings',style: TextStyleClass.primaryFont600(16, Colors.white),),
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
                child: SizedBox(
                  height: 150,
                  child: Image.asset(ImageClass.appIcon))
              ),
              const SizedBox(height: 8.0),
              const Center(
                child: Text(
                  'version 1.12.0 (277)',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              _buildSectionTitle('Terms of Use'),
              _buildSectionTitle('Open Source Libraries'),
              _buildSectionTitle('Privacy Notice'),
              _buildSectionTitle('Contributors'),
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
              const Icon(Icons.keyboard_arrow_right,color: Colors.white,)
            ],
          ),
          const Divider(color: Colors.white38,)
        ],
      ),
    );
  }
}