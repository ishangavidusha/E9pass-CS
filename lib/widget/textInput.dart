import 'package:flutter/material.dart';

class KTextInput extends StatelessWidget {
  final String lable;
  final TextInputType textInputType;
  final Function onSubmit;

  KTextInput({Key key, this.lable, this.textInputType, this.onSubmit}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        labelText: lable,
        labelStyle: TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.bold
        )
      ),
      keyboardType: textInputType,
      textCapitalization: lable == 'Name' ? TextCapitalization.characters : TextCapitalization.none,
      style: TextStyle(
        color: Colors.black,
        fontSize: 18,
        fontWeight: FontWeight.bold
      ),
      onChanged: onSubmit,
    );
  }
}