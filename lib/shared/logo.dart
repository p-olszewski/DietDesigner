import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Logo extends StatelessWidget {
  final double fontSize;

  const Logo({Key? key, this.fontSize = 50}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      "DietDesigner",
      style: TextStyle(
        color: Theme.of(context).colorScheme.onPrimaryContainer,
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        fontFamily: GoogleFonts.indieFlower().fontFamily,
      ),
    );
  }
}
