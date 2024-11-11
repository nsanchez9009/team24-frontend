import 'package:baseapp/screens/email_registration.dart';
import 'package:baseapp/screens/login_screen.dart';
import 'package:flutter/material.dart';




class SignupScreenState extends StatefulWidget{
  @override
  SignupScreen createState() => SignupScreen();

}





class SignupScreen extends State<SignupScreenState> {

  String _name = "";
  String _email = "";
  String _phoneNumber = "";
  String _password = "";


  GlobalKey<FormState> _formKey = GlobalKey<FormState>();


  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  // final _formKey = GlobalKey<FormState>(); // Key to manage form state
  // final _emailController = TextEditingController();
  // final _passwordController = TextEditingController();
  // final _nameController = TextEditingController();
  // final _phoneController = TextEditingController();
 
 String? validatePhoneNumber(String? value){
    if(value == null || value.isEmpty){
      return 'Phone number is required';
    }
    else{
      _phoneNumber = value;
    }
  }




  String? validateName(String? value){
    if(value == null || value.isEmpty){
      return 'Name is required';
    }
    else{
      _name = value;
    }
  }


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
    resizeToAvoidBottomInset: true,
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
        SingleChildScrollView( 
          child: Stack(
            children: [
              Positioned(
                top: 40.2,
                right: 16,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginState()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFB0C4DE),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.home,
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
                      height: 490,
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
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 40),
                            Text(
                              'Sign up',
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 20),
                            Container(
                              width: 300,
                              height: 60,
                              child: TextFormField(
                                controller: _nameController,
                                validator: validateName,
                                obscureText: false,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.person),
                                  labelText: 'full name',
                                  filled: true,
                                  fillColor: Color(0xfff2f3f5),
                                  border: OutlineInputBorder(),
                                  errorStyle: TextStyle(
                                    color: Colors.black
                                  )
                                ),
                              ),
                            ),
                            SizedBox(height: 15),
                            Container(
                              width: 300,
                              height: 60,
                              child: TextFormField(
                                controller: _phoneController,
                                validator: validatePhoneNumber,
                                obscureText: true,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.phone),
                                  labelText: 'phone number',
                                  filled: true,
                                  fillColor: Color(0xfff2f3f5),
                                  border: OutlineInputBorder(),
                                  errorStyle: TextStyle(
                                    color: Colors.black
                                  )
                                ),
                              ),
                            ),
                            SizedBox(height: 15),
                            Container(
                              width: 300,
                              height: 60,
                              child: TextFormField(
                                controller: _emailController,
                                validator: validateEmail,
                                obscureText: true,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.email),
                                  labelText: 'email',
                                  filled: true,
                                  fillColor: Color(0xfff2f3f5),
                                  border: OutlineInputBorder(),
                                  errorStyle: TextStyle(
                                    color: Colors.black
                                  )
                                ),
                              ),
                            ),
                            SizedBox(height: 15),
                            Container(
                              width: 300,
                              height: 60,
                              child: TextFormField(
                                controller: _passwordController,
                                validator: validatePassword,
                                obscureText: false,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.lock),
                                  labelText: 'password',
                                  filled: true,
                                  fillColor: Color(0xfff2f3f5),
                                  border: OutlineInputBorder(),
                                  errorStyle: TextStyle(
                                    color: Colors.black
                                  )
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => EmailRegistration()),
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
                                'register',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginState(),
                        ),
                      );
                    },
                    child: const Text(
                      "Already have an account? Login",
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