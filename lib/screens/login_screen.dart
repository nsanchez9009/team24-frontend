import 'package:baseapp/screens/signup_screen.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';




class LoginState extends StatefulWidget{
  @override
  Login createState() => Login();
}


class Login extends State<SignupScreenState>  {
   String _email = "";
   String _password="";

   GlobalKey<FormState> _formKey = GlobalKey<FormState>();

   final _emailController = TextEditingController();
   final _passwordController = TextEditingController();

    String? validateEmail(String? value) {
    const emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    final regex = RegExp(emailPattern);

    if (value == null || value.isEmpty) {
      return 'Email is required';
    } else if (!regex.hasMatch(value)) {
      return 'Enter a valid email';
    }
    _email = value;
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    } 
    _password = value;
    return null;
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        SingleChildScrollView( // Added SingleChildScrollView here
          child: Stack(
            children: [
              Positioned(
                top: 40,
                right: 16,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginState()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFB0C4DE), // Light blue color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // Rounded corners
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Button padding
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.home, // Home icon
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 100),
                  Text(
                    'STUDY BUDDY',
                    style: TextStyle(
                      fontFamily: 'Akatab-Bold.ttf',
                      fontWeight: FontWeight.w900,
                      fontSize: 48,
                    ),
                  ),
                  SizedBox(height: 70),
                  Center(
                    child: Container(
                      width: 350,
                      height: 420,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xff9abdcd),
                            spreadRadius: 0.5,
                            offset: Offset(15, 15),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 40),
                          Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 20),
                          Container(
                            width: 300,
                            height: 60,
                            child: const TextField(
                              obscureText: true,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.email),
                                labelText: 'email',
                                filled: true,
                                fillColor: Color(0xfff2f3f5),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          SizedBox(height: 15),
                          Container(
                            width: 300,
                            height: 60,
                            child: const TextField(
                              obscureText: true,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.lock),
                                labelText: 'password',
                                filled: true,
                                fillColor: Color(0xfff2f3f5),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HomeScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 5),
                              backgroundColor: Color(0xff6193a8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(color: Colors.black, width: 1),
                              ),
                              shadowColor: Colors.black,
                              elevation: 5,
                            ),
                            child: Text(
                              'login',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(height: 8.2),
                          Image.asset(
                            'assets/images/cat_login.png',
                            scale: 5,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SignupScreenState(),
                        ),
                      );
                    },
                    child: const Text(
                      "Register a new user",
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.black,
                        fontFamily: 'Karla-VariableFont_wght.ttf',
                        fontWeight: FontWeight.w400,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

}