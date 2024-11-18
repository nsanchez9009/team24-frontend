import 'package:flutter/material.dart';
import 'land_page.dart';

class EmailVerification extends StatelessWidget {
  const EmailVerification({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'STUDY BUDDY',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Verify your email.',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Check your email for verification link!',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 225, // Set a fixed width for the buttons
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'LOGIN NAV BUTTON PRESSED') //just for debuging
                            ),
                      );
                      // code that goes to login page, delete above scaffold messenger
                      /*
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NAMEOFLOGINPAGE()), waiting on name of the class
                      ); */
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
                      'Back to Login',
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Karla',
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Logic to ask backend to send another email
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('New link sent, check your email!')),
                    );
                  },
                  child: Container(
                    child: const Text(
                      "Didn't get a link? Resend",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontFamily: 'Kameron',
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
          Positioned(
            top: 40,
            right: 16,
            child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LandPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFB0C4DE),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.home,
                      color: Colors.white,
                    ),
                  ],
                )),
          ),
        ],
      ),
    );
  }

  void verifyCode(String code) {
    print('Verifying code: $code');
  }
}
