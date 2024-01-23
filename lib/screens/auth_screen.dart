import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:water_intake/providers/auth_provider.dart';
import 'package:water_intake/screens/data_entry_screen.dart';
import 'package:water_intake/widgets/custom_progress_indicator.dart';

class AuthScreen extends StatefulWidget {
  static const routeName = 'auth-screen';

  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
  }

  void toggleLoading() {
    setState(() {
      _loading = !_loading;
    });
  }

  void selectAccount(BuildContext ctx) async {
    toggleLoading();
    bool newuser = await Provider.of<AuthProviderr>(ctx, listen: false)
        .selectGoogleAcount();
    if (!newuser) {
      await Provider.of<AuthProviderr>(ctx, listen: false).signIn();
    } else {
      toggleLoading();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/big_logo.png',
                      height: 90,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      'drinkable',
                      style: GoogleFonts.pacifico(
                        fontWeight: FontWeight.w500,
                        fontSize: 26,
                        color: const Color.fromARGB(255, 0, 60, 192),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 250),
                      child: Text(
                          'Drinkable keeps track your daily water intake and reminds you to drink water by sending notification in intervals',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.black.withOpacity(0.60))),
                    ),
                  ],
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _loading
                    ? CustomProgressIndicatior()
                    : Consumer<AuthProviderr>(
                        builder: (ctx, authProvider, child) {
                          GoogleSignInAccount? googleAccount =
                              authProvider.googleAcount;
                          return googleAccount != null
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    CircleAvatar(
                                      backgroundImage:
                                          NetworkImage(googleAccount.photoUrl!),
                                    ),
                                    TextButton(
                                      child: Text(
                                          'Continue as ${googleAccount.displayName}'),
                                      onPressed: () {
                                        Navigator.of(context).pushNamed(
                                            DataEntryScreen.routeName);
                                      },
                                    ),
                                    InkWell(
                                      splashColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () {
                                        Provider.of<AuthProviderr>(ctx,
                                                listen: false)
                                            .clearGoogleAccount();
                                      },
                                      child: const Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(10, 10, 0, 10),
                                        child: Icon(Icons.clear),
                                      ),
                                    ),
                                  ],
                                )
                              : GestureDetector(
                                  onTap: () {
                                    selectAccount(context);
                                  },
                                  child: Card(
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    color: Colors.blueAccent,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Container(
                                              padding: const EdgeInsets.all(3),
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                              child: Image.asset(
                                                'assets/icons/google.png',
                                                height: 20,
                                              )),
                                          Text(
                                            'Continue with Google',
                                            style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                        },
                      ),
                Container(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                          style: GoogleFonts.poppins(
                              color: Colors.black, fontSize: 11),
                          children: [
                            const TextSpan(
                              text: 'By signing up you accept the ',
                            ),
                            TextSpan(
                                text: 'Terms of Service and Privacy Policy.',
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500))
                          ]),
                    ))
              ],
            )
          ],
        ),
      ),
    );
  }
}
