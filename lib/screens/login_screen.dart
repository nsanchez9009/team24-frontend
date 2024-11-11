import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'signup_screen.dart';
import 'home_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> saveToken(String token) async{
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('jwt_token',token);
}

Future<bool> loginUser(String username, String password) async {
  final url = Uri.parse('https://studybuddy.ddns.net/api/auth/login'); // Replace with your login endpoint

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body:jsonEncode( {
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      // Successful login
      final responseBody = json.decode(response.body);
      final token = responseBody['token'];  // Assuming the response contains the token

      // Store the token securely (e.g., using shared preferences)
      await saveToken(token);

      return true;
      // Navigate to the home page or next screen
    } else if (response.statusCode == 400) {
      return false;
    } else if (response.statusCode == 500) {
      print("yikes");
      // Server error
      return false;

    } else {
      return false;
    }
  } catch (e) {
    return false;
  }
}


Future<String?> getToken() async{
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('jwt_token');
}




class Login extends StatelessWidget  {
   

   GlobalKey<FormState> _formKey = GlobalKey<FormState>();

   TextEditingController _nameController = TextEditingController();
   TextEditingController _passwordController = TextEditingController();

   String _name = "";
   String _password="";

    String? validateName(String? value) {

    if (value == null || value.isEmpty) {
      return 'Username is required';
    } 
     _name = value;
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
          decoration: const BoxDecoration(
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
                      MaterialPageRoute(builder: (context) => Login()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB0C4DE), // Light blue color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // Rounded corners
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Button padding
                  ),
                  child: const Row(
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
                  const SizedBox(height: 100),
                  const Text(
                    'STUDY BUDDY',
                    style: TextStyle(
                      fontFamily: 'Akatab-Bold.ttf',
                      fontWeight: FontWeight.w900,
                      fontSize: 48,
                    ),
                  ),
                  const SizedBox(height: 70),
                  Center(
                    child: Container(
                      width: 350,
                      height: 420,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                        boxShadow: [
                          const BoxShadow(
                            color: const Color(0xff9abdcd),
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
                            child:  TextField(
                              controller: _nameController,
                              obscureText: true,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.person),
                                labelText: 'username',
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
                            child: TextField(
                              controller: _passwordController,
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
                            onPressed: () async {
                              // Validate input (check if username and password are not empty)
                              if (_name.isEmpty || _password.isEmpty) {
                                // Show an error message if either field is empty
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Please enter both username and password')),
                                );
                                return; // Exit the function if inputs are invalid
                              }
                              _name = _nameController.text;
                              print(_name);
                              _password = _passwordController.text;
                              

                              // Call the login function and await the response
                              bool isLoggedIn = await loginUser(_name, _password);

                              if (isLoggedIn) {
                                // If login is successful, navigate to the HomeScreen
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HomeScreen(),
                                  ),
                                );
                              } else {
                                // Show an error message if login fails
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Invalid username or password')),
                                );
                              }
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
                              'Login',
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