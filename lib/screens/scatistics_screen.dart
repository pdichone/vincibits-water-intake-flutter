import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:water_intake/models/weekly_data.dart';
import 'package:water_intake/providers/auth_provider.dart';
import 'package:water_intake/providers/statistics_provider.dart';
import 'package:water_intake/widgets/custom_app_bar.dart';
import 'package:water_intake/widgets/custom_progress_indicator.dart';
import 'package:water_intake/widgets/three_layer_background.dart';
import 'package:water_intake/widgets/weekly_statistics_graph.dart';

class StatisticsScreen extends StatefulWidget {
  final VoidCallback openDrawer;
  const StatisticsScreen({super.key, required this.openDrawer});

  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  void toggleLoading() {
    setState(() {
      _loading = !_loading;
    });
  }

  void init() async {
    toggleLoading();
    await Provider.of<StatisticsProvider>(context, listen: false).init();
    toggleLoading();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(top: 30),
        child: _loading
            ? Center(
                child: CustomProgressIndicatior(),
              )
            : Column(
                children: [
                  CustomAppBar(
                    openDrawer: widget.openDrawer,
                    trailing: Consumer<AuthProviderr>(
                      builder: (context, authProvider, child) {
                        User? user = authProvider.user;
                        return CircleAvatar(
                          radius: 19,
                          backgroundImage: NetworkImage(user!.photoURL!),
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(30, 25, 30, 30),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Statistics',
                      textAlign: TextAlign.left,
                      style: GoogleFonts.poppins(
                          color: const Color.fromARGB(255, 0, 60, 192),
                          fontSize: 25,
                          letterSpacing: 1,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  //SizedBox(height: 30,),
                  Expanded(
                    child: Stack(
                      children: [
                        ThreeLayerBackground(),
                        Consumer<StatisticsProvider>(
                          builder: (context, statisticsProvider, child) {
                            List<WeeklyData> weeklyData =
                                statisticsProvider.weeklyData;
                            return ListView.separated(
                              padding:
                                  const EdgeInsets.fromLTRB(30, 40, 30, 40),
                              itemCount: weeklyData.length,
                              itemBuilder: (context, index) {
                                return WeeklyStatisticsGraph(weeklyData[index]);
                              },
                              separatorBuilder: (context, index) {
                                return const SizedBox(
                                  height: 20,
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  )
                ],
              ),
      ),
    );
  }
}
