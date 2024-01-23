// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:water_intake/models/app_user.dart';
import 'package:water_intake/models/weekly_data.dart';
import 'package:water_intake/utils/get_week.dart';
import 'package:water_intake/utils/notification_utils.dart';

class HomeProvider extends ChangeNotifier {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final Location _location = Location();
  bool _isInited = false;
  final DateTime _today = DateTime.now();
  WeeklyData? _weeklyData;

  String? _uid;

  AppUser? _appUser;

  CollectionReference<Object?>? _weekColRef;

  DocumentReference<Object?>? _userRef;

  DocumentReference<Object?>? _currentWeek;
  Map<String, dynamic>? _weather;
  LocationData? _locationData;

  void update(User user) {
    if (user != null) {
      _uid = user.uid;
      _weekColRef =
          _firebaseFirestore.collection('users').doc(_uid).collection('weeks');
      _userRef = _firebaseFirestore.collection('users').doc(_uid);
    } else {
      _isInited = false;
      _uid = null;
      _weeklyData = null;
      _appUser = null;
      _weekColRef = null;
      _userRef = null;
      _currentWeek = null;
      _weather = null;
      _locationData = null;
    }
    notifyListeners();
  }

  Map<String, dynamic>? get weather => _weather;

  AppUser? get appUser => _appUser;

  String get dailyTarget {
    if (_appUser == null) {
      // Handle the case when _appUser is null
      return 'N/A'; // Or some default value
    }

    double target = _appUser!.dailyTarget;
    if (target < 1000.0) {
      return '$target mL';
    } else {
      return '${(target / 1000.0).toStringAsFixed(1)} L';
    }
  }

  double get leftAmount {
    // Check if _appUser or _weeklyData is null
    if (_appUser == null || _weeklyData == null) {
      return 0.0; // Return a default value such as 0.0
    }

    double target = _appUser!.dailyTarget;
    // Safely access the amounts and handle the case where it might be null
    double consumed =
        _weeklyData!.amounts[_today.weekday.toString()]?.toDouble() ?? 0.0;

    double left = target - consumed;
    return left;
  }

  double get targetReached {
    // Check if _appUser or _weeklyData is null
    if (_appUser == null || _weeklyData == null) {
      return 0.0; // Return a default value such as 0.0
    }

    double target = _appUser!.dailyTarget;
    // Safely handle the case where _weeklyData.amounts might not have an entry for the weekday
    int consumed =
        _weeklyData!.amounts[_today.weekday.toString()]?.toInt() ?? 0;

    // Prevent division by zero
    if (target == 0) {
      return 0.0;
    }

    return consumed / target;
  }

  Future<void> init() async {
    if (!_isInited) {
      try {
        int week = getWeek(_today);
        String docId = '${_today.year}_$week';
        _currentWeek = _weekColRef!.doc(docId);
        DocumentSnapshot<Object?> userSnapshot = await _userRef!.get();
        _appUser = AppUser.fromDoc(userSnapshot.data() as Map<String, dynamic>);
        DocumentSnapshot<Object?> snapshot = await _currentWeek!.get();
        if (!snapshot.exists) {
          Map<String, dynamic> newWeek = WeeklyData(
            id: '',
            year: _today.year,
            month: _today.month,
            week: week,
            amounts: {},
            dailyTarget: _appUser!.dailyTarget,
          ).createNewWeek(
            docId,
            _today.year,
            _today.month,
            week,
            _appUser!.dailyTarget,
          );

          await _currentWeek?.set(newWeek);
          _weeklyData = WeeklyData.fromDoc(newWeek);
        } else {
          _weeklyData =
              WeeklyData.fromDoc(snapshot.data() as Map<String, dynamic>);
        }
        _isInited = true;
        bool canGetLocation = await getLocationService();
        if (canGetLocation) {
          _locationData = await _location.getLocation();
          String apiKey = dotenv.env['WEATHER_API_KEY']!;

          String url =
              'https://api.openweathermap.org/data/2.5/weather?lat=${_locationData?.latitude}&lon=${_locationData?.longitude}&appid=$apiKey&units=metric';
          http.Response response = await http.get(Uri.parse(url));
          if (response.statusCode == 200) {
            final weatherInfo = jsonDecode(response.body);
            _weather = weatherInfo['weather'][0] as Map<String, dynamic>;
          }
        }
        notifyListeners();
      } catch (e) {
        print(e);
      }
    } else {
      print('Data already initialized');
    }
  }

  Future<void> addWater(double amount, DateTime time) async {
    try {
      int weekday = time.weekday;
      int week = getWeek(time);
      String weekId = '${time.year}_$week';
      await _firebaseFirestore.runTransaction((transaction) async {
        DocumentReference weekDocRef = _firebaseFirestore
            .collection('users')
            .doc(_uid)
            .collection('weeks')
            .doc(weekId);
        DocumentReference yearDocRef = _firebaseFirestore
            .collection('users')
            .doc(_uid)
            .collection('years')
            .doc('${time.year}');
        DocumentReference monthDocRef = _firebaseFirestore
            .collection('users')
            .doc(_uid)
            .collection('months')
            .doc('${time.year}_${time.month}');
        DocumentSnapshot yearDocSnap = await transaction.get(yearDocRef);
        DocumentSnapshot monthDocSnap = await transaction.get(monthDocRef);
        DocumentSnapshot weekDocSnap = await transaction.get(weekDocRef);

        if (!yearDocSnap.exists) {
          transaction.set(
              yearDocRef, {'year': time.year}, SetOptions(merge: true));
        }

        if (!monthDocSnap.exists) {
          transaction.set(monthDocRef, {'year': time.year, 'month': time.month},
              SetOptions(merge: true));
        }

        if (!weekDocSnap.exists) {
          transaction.set(
              weekDocRef,
              {
                'daily_target': _appUser?.dailyTarget,
                'year': time.year,
                'month': time.month,
                'week': week,
                'id': weekId,
              },
              SetOptions(merge: true));
        }

        transaction.update(yearDocRef,
            {'amounts.${time.month}': FieldValue.increment(amount)});

        transaction.update(
            monthDocRef, {'amounts.${time.day}': FieldValue.increment(amount)});
        transaction.update(
            weekDocRef, {'amounts.$weekday': FieldValue.increment(amount)});
      });
      if (_weeklyData?.id == weekId) {
        _weeklyData?.amounts[weekday.toString()] += amount;
        if (weekday == DateTime.now().weekday) {
          if (leftAmount > 0) {
            await waterNotification(leftAmount);
          }
        }
        notifyListeners();
      }
    } catch (e) {
      print(e);
    }
  }

  Future<bool> getLocationService() async {
    bool isServiceEnabled = await _location.serviceEnabled();

    if (!isServiceEnabled) {
      bool _enabled = await _location.requestService();
      if (_enabled) {
      } else {
        return false;
      }
    }

    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      PermissionStatus _isGranted = await _location.requestPermission();
      if (_isGranted != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }

  Future<void> updateUser(AppUser appUser) async {
    try {
      await _firebaseFirestore.runTransaction((transaction) async {
        transaction
            .update(_currentWeek!, {'daily_target': appUser.dailyTarget});
        transaction.update(_userRef!, appUser.toDoc());
      });
      await setDailyStartNotification(appUser.wakeUpTime, appUser.name);
      _appUser = appUser;
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }
}
