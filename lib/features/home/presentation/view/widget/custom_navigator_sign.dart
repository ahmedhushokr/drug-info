import 'package:flutter/material.dart';


class NavigatorSigninSignup extends StatelessWidget {
  const NavigatorSigninSignup({super.key, required this.account,required this.Sign,required  this.onPressed,this.color = Colors.blue});
  final VoidCallback onPressed;
  final String account ;
  final String Sign ;
  final Color color ;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          account,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ), 
        ),
        TextButton(
          onPressed: onPressed,
          child: Text(
            Sign,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color:color,
            ),
          ),
        ),
      ],
    );
  }
}
