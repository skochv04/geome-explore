import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTextStyles {
  static final TextStyle heading = GoogleFonts.montserrat(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static final TextStyle body = GoogleFonts.montserrat(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static final TextStyle bodySemiBold = GoogleFonts.montserrat(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static final TextStyle button = GoogleFonts.montserrat(
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );

  static final TextStyle buttonLarge = GoogleFonts.montserrat(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static final TextStyle caption = GoogleFonts.montserrat(
    fontSize: 11,
    fontWeight: FontWeight.w400,
  );

  static final TextStyle cardText = GoogleFonts.montserrat(
    fontSize: 10,
    fontWeight: FontWeight.w500,
  );
}