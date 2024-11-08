// import 'package:zaitoon/helper/navigation_helper.dart';
// import 'package:zaitoon/screens/language_selection/language_selection.dart';
// import 'package:zaitoon/screens/login_screen/provider/auth_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class AuthScreen extends StatelessWidget {
//   const AuthScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ColorClass.black,
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 24.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               // Mascot character container
//               Container(
//                 decoration: BoxDecoration(
//                   // color: ColorClass.teal[100],
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Center(
//                   child: Image.asset(
//                     'assets/images/tiger1.png',
//                     height: MediaQuery.sizeOf(context).height * 0.4,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 15),

//               // Headline text
//               const Text(
//                 'Welcome to zaitoon',
//                 style: TextStyle(
//                   fontSize: 28,
//                   fontWeight: FontWeight.bold,
//                   color: ColorClass.white,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 16),

//               // Subtitle
//               const Text(
//                 'Interactive stories with sound effects as you read along',
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: ColorClass.white70,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 30),

//               // Sign in buttons
//               Consumer<AuthProvider>(
//                 builder: (context, auth, child) {
//                   return Column(
//                     children: [
//                       ElevatedButton(
//                         onPressed: () {
//                           navigateTo(
//                               context: context,
//                               route: const LanguageSelection());
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: ColorClass.white,
//                           minimumSize: const Size(double.infinity, 50),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(25),
//                           ),
//                         ),
//                         child: const Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(Icons.apple, color: ColorClass.black),
//                             SizedBox(width: 8),
//                             Text(
//                               'Continue with Apple',
//                               style: TextStyle(
//                                 color: ColorClass.black,
//                                 fontSize: 16,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       ElevatedButton(
//                         onPressed: () {
//                           navigateTo(
//                               context: context,
//                               route: const LanguageSelection());
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: ColorClass.white,
//                           minimumSize: const Size(double.infinity, 50),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(25),
//                           ),
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Image.asset(
//                               'assets/icons/google-icon.png', // Add Google logo asset
//                               height: 24,
//                             ),
//                             const SizedBox(width: 8),
//                             const Text(
//                               'Continue with Google',
//                               style: TextStyle(
//                                 color: ColorClass.black,
//                                 fontSize: 16,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   );
//                 },
//               ),
//               const SizedBox(height: 24),

//               // Skip sign in option
//               TextButton(
//                 onPressed: () {
//                   navigateTo(
//                       context: context, route: const LanguageSelection());
//                 },
//                 child: const Text(
//                   'Continue without account',
//                   style: TextStyle(
//                     color: ColorClass.white70,
//                     fontSize: 14,
//                   ),
//                 ),
//               ),

//               // Terms and Privacy
//               Padding(
//                 padding: const EdgeInsets.only(top: 16.0),
//                 child: RichText(
//                   textAlign: TextAlign.center,
//                   text: const TextSpan(
//                     style: TextStyle(color: ColorClass.white60, fontSize: 12),
//                     children: [
//                       TextSpan(text: 'By continuing, you agree to our '),
//                       TextSpan(
//                         text: 'Privacy Policy',
//                         style: TextStyle(
//                           decoration: TextDecoration.underline,
//                         ),
//                       ),
//                       TextSpan(text: ' and '),
//                       TextSpan(
//                         text: 'Terms of Use',
//                         style: TextStyle(
//                           decoration: TextDecoration.underline,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
