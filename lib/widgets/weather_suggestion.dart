import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:water_intake/providers/home_provider.dart';
import 'package:water_intake/values/weather_icons.dart';

class WeatherSuggestion extends StatelessWidget {
  const WeatherSuggestion({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weather',
          style: GoogleFonts.poppins(fontSize: 20),
        ),
        const SizedBox(
          height: 18,
        ),
        Consumer<HomeProvider>(
          builder: (context, value, child) {
            Map<String, dynamic>? weather = value.weather;
            print("WEATHER ==> $weather");
            return Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 37, 90, 210),
                      borderRadius: BorderRadius.circular(8)),
                  child: Image.asset(
                    weatherIcons[weather!['icon'].toString().split('')[0] +
                        weather['icon'].toString().split('')[1]]!,
                    width: 40,
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                SizedBox(
                  width: 140,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 17,
                            ),
                            children: [
                              TextSpan(
                                  text: 'It\'s ',
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w300)),
                              TextSpan(
                                  text: weather['description'],
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w700)),
                              TextSpan(
                                  text: ' today!',
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w300)),
                            ]),
                      ),
                      const SizedBox(
                        height: 11,
                      ),
                      Text(
                        'Dont\'t forget to take the water bottle with you.',
                        style: GoogleFonts.poppins(
                            height: 1.5,
                            color: Colors.black.withOpacity(0.6),
                            fontSize: 12),
                      )
                    ],
                  ),
                )
              ],
            );
          },
        ),
      ],
    );
  }
}
