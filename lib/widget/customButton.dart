import 'package:e9pass_cs/widget/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class KButton extends StatelessWidget {
  final String text;
  final Function onPressed;
  final LinearGradient linearGradient;
  final Icon icon;

  const KButton(
      {Key key,
      this.text,
      this.onPressed,
      this.linearGradient,
      this.icon,})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    double devWidth = MediaQuery.of(context).size.width;
    return Container(
      width: devWidth * 0.8,
      height: 50.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        gradient: AppColors.linearGradient, 
        boxShadow: [
          BoxShadow(
            color: Color(0xFF438AFE).withOpacity(0.4),
            offset: Offset(0.0, 10),
            blurRadius: 15,
          ),
        ]
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
            onTap: onPressed,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  icon,
                  Text(
                    text,
                    style: GoogleFonts.roboto(
                      textStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                ],
              ),
            ),
          ),
      ),
    );
  }
}
