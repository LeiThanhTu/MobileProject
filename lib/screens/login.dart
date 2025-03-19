import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      body: Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
      Image.asset("assets/images/logo-quiz 1.png"),
       SizedBox(height: 35,),
       Text("Welcome, To Quiz App", style: TextStyle(fontSize: 25, color: Colors.white, fontWeight: FontWeight.bold),),
       SizedBox(height: 12, ),
       ElevatedButton(onPressed: (){}, child: Text("Continue With Google")),
       SizedBox(height: 10,),
       Text("By Continuing, You Are Agree With Our TnC")
       
        ]
      ))
      
    );
  }
}
