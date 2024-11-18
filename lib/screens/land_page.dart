import 'package:baseapp/screens/login_screen.dart';
import 'package:baseapp/screens/signup_screen.dart';
import 'package:flutter/material.dart';

class LandPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double responsivePadding =
        (screenWidth < screenHeight ? screenWidth : screenHeight) * 0.1;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Content on top of the background
          Padding(
            padding: EdgeInsets.all(responsivePadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'STUDY BUDDY',
                  style: TextStyle(
                    fontSize: 48.0,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Akatab',
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 50),
                const Text(
                  'GET STARTED...',
                  style: TextStyle(
                    fontSize: 25.0,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Kameron',
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 175, // Set a fixed width for the buttons
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignupScreenState()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF6193A9),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'register',
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Karla',
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 175, // Ensure the same fixed width for both buttons
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginState()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF6193A9),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'login',
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Karla',
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '• ',
                          style: TextStyle(
                            fontSize: 25,
                            fontFamily: 'Karla',
                            color: Colors.black,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Add your courses',
                            style: TextStyle(
                              fontSize: 25,
                              fontFamily: 'Karla',
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '• ',
                          style: TextStyle(
                            fontSize: 25,
                            fontFamily: 'Karla',
                            color: Colors.black,
                          ),
                        ),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 25,
                                fontFamily: 'Karla',
                                color: Colors.black,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Connect and ',
                                ),
                                TextSpan(
                                  text: 'live chat ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: 'with other ',
      
                                ),
                                TextSpan(
                                  text: 'highly-rated scholars',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),

                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '• ',
                          style: TextStyle(
                            fontSize: 25,
                            fontFamily: 'Karla',
                            color: Colors.black,
                          ),
                        ),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 25,
                                fontFamily: 'Karla',
                                color: Colors.black,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Study and ',
                                ),
                                TextSpan(
                                  text: 'improve your grades!',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
