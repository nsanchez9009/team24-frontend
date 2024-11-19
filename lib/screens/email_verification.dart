import 'package:baseapp/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'land_page.dart';

class EmailVerification extends StatelessWidget {
  const EmailVerification({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 100),
                const Text(
                    'STUDY BUDDY',
                    style: TextStyle(
                      fontFamily: 'Akatab-Bold.ttf',
                      fontWeight: FontWeight.w900,
                      fontSize: 48,
                    ),
                  ),
                const SizedBox(height: 100),
                const Text(
                  'Verify your email.',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(20), // Rounded edges
    color: Colors.white,
  ),
  padding: const EdgeInsets.all(20), // Padding inside the container
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Text(
        'Check your email for verification link!',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        textAlign: TextAlign.center, // Center the text
      ),
      const SizedBox(height: 20),
      SizedBox(
        width: 225, // Set a fixed width for the buttons
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginState()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6193A9),
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
    ],
  ),
)
,
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
