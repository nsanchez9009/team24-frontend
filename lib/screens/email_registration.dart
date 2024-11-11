import 'package:flutter/material.dart';
import 'login_screen.dart';

class EmailRegistration extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Email Verification"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.home, size:30),
            onPressed: (){
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Login()
              ),
              );
            }
          )
        ],
      ),
      body: const Center(
        child: Text("Welcome to the Home Screen!"),
      ),
    );
  }
}