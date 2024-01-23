import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:water_intake/models/app_user.dart';
import 'package:water_intake/providers/auth_provider.dart';
import 'package:water_intake/providers/home_provider.dart';
import 'package:water_intake/widgets/custom_app_bar.dart';
import 'package:water_intake/widgets/custom_form_field.dart';
import 'package:water_intake/widgets/custom_progress_indicator.dart';
import 'package:water_intake/widgets/goal_and_add.dart';
import 'package:water_intake/widgets/loading_screen.dart';
import 'package:water_intake/widgets/weather_suggestion.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback openDrawer;
  HomeScreen({required this.openDrawer});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    init();
  }

  void toggleLoading() {
    setState(() {
      _isLoading = !_isLoading;
    });
  }

  void init() async {
    toggleLoading();
    await Provider.of<HomeProvider>(context, listen: false).init();
    toggleLoading();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? LoadingScreen()
        : Scaffold(
            body: Container(
              padding: const EdgeInsets.only(top: 30),
              child: SingleChildScrollView(
                child: Column(
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
                    const SizedBox(
                      height: 40,
                    ),
                    GoalAndAdd(),
                    const SizedBox(
                      height: 15,
                    ),
                    const Padding(
                        padding: EdgeInsets.fromLTRB(30, 0, 30, 20),
                        child: WeatherSuggestion())
                  ],
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
                elevation: 3,
                backgroundColor: const Color.fromARGB(255, 0, 60, 192),
                child: const Icon(
                  Icons.add,
                  size: 30,
                ),
                onPressed: () {
                  //Navigator.of(context).pushNamed(AddWaterScreen.routeName);
                  showDialog(
                      context: context,
                      builder: (BuildContext ctx) {
                        return AddWaterWidget();
                      });
                }),
          );
  }
}

class AddWaterWidget extends StatefulWidget {
  const AddWaterWidget({super.key});

  @override
  _AddWaterWidgetState createState() => _AddWaterWidgetState();
}

class _AddWaterWidgetState extends State<AddWaterWidget> {
  bool _loading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // data
  DateTime? _time = DateTime.now();
  double? _water; // Update the type to double

  void toggleLoading() {
    setState(() {
      _loading = !_loading;
    });
  }

  void submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState?.save();
    toggleLoading();
    try {
      await Provider.of<HomeProvider>(context, listen: false)
          .addWater(_water!, _time!);
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
      return;
    } catch (e) {
      print(e);
    }
    toggleLoading();
  }

  @override
  Widget build(BuildContext context) {
    AppUser? appUser = Provider.of<HomeProvider>(context).appUser;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(
            height: 15,
          ),
          Text(
            'Add Water',
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          const SizedBox(
            height: 20,
          ),
          Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () async {
                    DateTime? date = await showDatePicker(
                      context: context,
                      initialDate: _time ??
                          DateTime
                              .now(), // Provide a fallback initial value if _time is null
                      firstDate: DateTime(1960),
                      lastDate: DateTime.now(),
                    );
                    if (date != null && date.isBefore(DateTime.now())) {
                      setState(() {
                        _time = date;
                      });
                    }
                  },
                  child: CustomFormField(
                      label: 'Date',
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat.yMMMd('en_US').format(_time!),
                            style: GoogleFonts.poppins(
                                fontSize: 15, fontWeight: FontWeight.w500),
                          ),
                          const Icon(Icons.arrow_drop_down)
                        ],
                      )),
                ),
                const SizedBox(
                  height: 10,
                ),
                CustomFormField(
                  label: 'Water',
                  child: TextFormField(
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: '240 mL',
                      suffixText: 'mL',
                    ),
                    style: GoogleFonts.poppins(
                        fontSize: 15, fontWeight: FontWeight.w500),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter water amount';
                      }
                      final doubleValue = double.tryParse(value);
                      if (doubleValue == null || doubleValue <= 0) {
                        return 'Wrong value';
                      }
                      if (appUser != null &&
                          doubleValue > appUser.dailyTarget) {
                        return 'Daily limit exceed';
                      }
                      return null;
                    },
                    onSaved: (String? value) {
                      if (value != null) {
                        setState(() {
                          print("Converted value: $value");
                          _water = double.parse(value);
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      actions: <Widget>[
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: const Color.fromARGB(255, 0, 60, 192),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            'Cancel',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 0, 60, 192),
          ),
          onPressed: submit,
          child: _loading
              ? SizedBox(
                  height: 22,
                  width: 22,
                  child: CustomProgressIndicatior(),
                )
              : Text(
                  'Add',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
        ),
      ],
    );
  }
}
