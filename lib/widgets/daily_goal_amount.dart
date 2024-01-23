// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:water_intake/providers/home_provider.dart';

// providers

class DailyGoalAmount extends StatelessWidget {
  const DailyGoalAmount({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          border: Border(left: BorderSide(color: Colors.white, width: 2)),
        ),
        child: Row(
          children: [
            Text(
              'Goal',
              style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 19,
                  fontWeight: FontWeight.w400),
            ),
            SizedBox(
              width: 15,
            ),
            Consumer<HomeProvider>(
              builder: (context, provider, child) {
                return Text(provider.dailyTarget.toString(),
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w700));
              },
            )
          ],
        ),
      ),
    );
  }
}
