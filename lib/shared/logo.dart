import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Logo extends StatelessWidget {
  final double fontSize;

  const Logo({Key? key, this.fontSize = 50}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var textStyle = TextStyle(
      color: Theme.of(context).colorScheme.onPrimaryContainer,
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      fontFamily: GoogleFonts.balooPaaji2().fontFamily,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "DietDesigner",
          style: textStyle,
        ),
        Text(
          "®",
          style: textStyle.copyWith(
            fontSize: fontSize * 0.6,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
