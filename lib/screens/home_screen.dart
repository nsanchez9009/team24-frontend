
import 'package:baseapp/screens/login_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  //const HomeScreen({Key?key}) : super(key:key)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
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
