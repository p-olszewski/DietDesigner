import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Logo extends StatelessWidget {
  const Logo({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      "DietDesigner",
      style: TextStyle(color: Colors.white, fontSize: 50, fontFamily: GoogleFonts.indieFlower().fontFamily),
    );
  }
}
