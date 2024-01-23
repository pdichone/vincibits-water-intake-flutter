import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:water_intake/providers/auth_provider.dart';
import 'package:water_intake/utils/time_converter.dart';
import 'package:water_intake/widgets/custom_form_field.dart';
import 'package:water_intake/widgets/custom_progress_indicator.dart';

class DataEntryScreen extends StatelessWidget {
  static const routeName = 'data-entry-screen';

  const DataEntryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.fromLTRB(30, 30, 30, 0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: const Icon(Icons.arrow_back_ios))
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Column(
                children: [
                  const Icon(Icons.date_range),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    'About you',
                    style: GoogleFonts.poppins(
                        fontSize: 22, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    constraints: const BoxConstraints(maxWidth: 270),
                    child: Text(
                      'This information will let us help to calculate your daily recommended water intake amount and remind you to drink water in intervals.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.black.withOpacity(0.60),
                          height: 1.4,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Consumer<AuthProviderr>(
                    builder: (context, authProvider, child) {
                      GoogleSignInAccount? googleAccount =
                          authProvider.googleAcount;
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            backgroundImage:
                                NetworkImage(googleAccount!.photoUrl!),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Text(
                            googleAccount.email,
                            style: GoogleFonts.poppins(fontSize: 13),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(
                height: 50,
              ),
              const DataEntryForm(),
            ],
          ),
        ),
      ),
    );
  }
}

class DataEntryForm extends StatefulWidget {
  const DataEntryForm({super.key});

  @override
  _DataEntryFormState createState() => _DataEntryFormState();
}

class _DataEntryFormState extends State<DataEntryForm> {
  bool _loading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void toggleLoading() {
    setState(() {
      _loading = !_loading;
    });
  }

  // data
  String _gender = 'male';
  DateTime _birthday = DateTime(1997, 4, 1);
  // late double _weight;
  double _weight = 60; // Change the type to double?

  TimeOfDay _wakeUpTime = const TimeOfDay(hour: 8, minute: 0);
  double _water = 3200.0;

  void submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState?.save();
    toggleLoading();
    try {
      print("STTTuf ${_weight}");
      await Provider.of<AuthProviderr>(context, listen: false)
          .signUp(_gender, _birthday, _weight, _wakeUpTime, _water);
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
      return;
    } catch (e) {
      print("ERRRor: $e");
    }
    toggleLoading();
  }

  void setWater({required double weight}) {
    double calWater = weight * 2.205;
    calWater /= 2.2;
    int age = DateTime.now().year - _birthday.year;
    if (age < 30) {
      calWater *= 40;
    } else if (age >= 30 && age <= 55) {
      calWater *= 35;
    } else {
      calWater *= 30;
    }
    calWater /= 28.3;
    calWater *= 29.574;

    setState(() {
      _water = double.parse(calWater.toStringAsFixed(2));
      _weight = weight;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                  flex: 47,
                  child: CustomFormField(
                    label: 'Gender',
                    child: DropdownButtonFormField<String>(
                      value: _gender,
                      items: <DropdownMenuItem<String>>[
                        DropdownMenuItem(
                          value: 'male',
                          child: Text(
                            'Male',
                            style: GoogleFonts.poppins(
                                fontSize: 15, fontWeight: FontWeight.w500),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'female',
                          child: Text(
                            'Female',
                            style: GoogleFonts.poppins(
                                fontSize: 15, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                      decoration:
                          const InputDecoration(border: InputBorder.none),
                      onChanged: (String? gender) {
                        // Update the type of the gender parameter
                        setState(() {
                          _gender = gender ??
                              ''; // Assign the selected gender value to _gender
                        });
                      },
                    ),
                  )),
              const Expanded(
                  flex: 6,
                  child: SizedBox(
                    width: 20,
                  )),
              Expanded(
                  flex: 47,
                  child: GestureDetector(
                    onTap: () async {
                      DateTime? date = await showDatePicker(
                        context: context,
                        initialDate: DateTime(1997, 4, 1),
                        firstDate: DateTime(1960),
                        lastDate: DateTime(DateTime.now().year - 12, 12, 31),
                      );
                      if (date != null) {
                        setState(() {
                          _birthday = date;
                        });
                        setWater(
                            weight:
                                _weight); // Pass the weight value as an argument
                      }
                    },
                    child: CustomFormField(
                        label: 'Birthday',
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat.yMMMd('en_US').format(_birthday),
                              style: GoogleFonts.poppins(
                                  fontSize: 15, fontWeight: FontWeight.w500),
                            ),
                            const Icon(Icons.arrow_drop_down)
                          ],
                        )),
                  )),
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          Row(
            children: [
              Expanded(
                  flex: 47,
                  child: CustomFormField(
                    label: 'Weight',
                    child: TextFormField(
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: '60 kg',
                        suffixText: 'kg',
                      ),
                      style: GoogleFonts.poppins(
                          fontSize: 15, fontWeight: FontWeight.w500),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter weight';
                        }
                        try {
                          double weight = double.parse(value);
                          if (weight < 40) {
                            return 'You are underweight';
                          }
                        } catch (e) {
                          return 'Invalid weight';
                        }
                        return null;
                      },
                      onChanged: (String value) {
                        if (value.isNotEmpty) {
                          try {
                            final weightValue = double.parse(value);
                            setWater(weight: weightValue);
                          } catch (e) {
                            // Handle parse error or ignore
                          }
                        }
                      },
                      onSaved: (String? value) {
                        _water = value != null && value.isNotEmpty
                            ? double.parse(value)
                            : _water;
                      },
                    ),
                  )),
              const Expanded(
                flex: 6,
                child: SizedBox(
                  width: 20,
                ),
              ),
              Expanded(
                  flex: 47,
                  child: GestureDetector(
                    onTap: () async {
                      TimeOfDay? time = await showTimePicker(
                        context: context,
                        initialTime: const TimeOfDay(hour: 8, minute: 0),
                      );
                      if (time != null) {
                        setState(() {
                          _wakeUpTime = time;
                        });
                      }
                    },
                    child: CustomFormField(
                        label: 'Wakes Up',
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              timeConverter(_wakeUpTime),
                              style: GoogleFonts.poppins(
                                  fontSize: 15, fontWeight: FontWeight.w500),
                            ),
                            const Icon(Icons.arrow_drop_down)
                          ],
                        )),
                  )),
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                  flex: 2,
                  child: CustomFormField(
                    label: 'Water',
                    child: TextFormField(
                      controller: TextEditingController(text: '$_water'),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: '3200 mL',
                        suffixText: 'mL',
                      ),
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      validator: (String? value) {
                        // Update the parameter type to String?
                        if (value == null || value.isEmpty) {
                          return 'Enter water amount';
                        }
                        if (double.parse(value) < 1600) {
                          return 'Less than min water';
                        }
                        return null;
                      },
                      onSaved: (String? value) {
                        // Update the parameter type to String?
                        setState(() {
                          _water = double.parse(value ??
                              '0.0'); // Update to double.parse and handle null value
                        });
                      },
                    ),
                  )),
              const Expanded(
                child: SizedBox(
                  width: 0,
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 1,
                  backgroundColor: const Color.fromARGB(255, 0, 60, 192),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3)),
                ),
                onPressed: () {
                  // toggleLoading();
                  submit();
                },
                child: _loading
                    ? SizedBox(
                        height: 22,
                        width: 22,
                        child: CustomProgressIndicatior(),
                      )
                    : Text(
                        'Let\'s go',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
              )
            ],
          )
        ],
      ),
    );
  }
}
