
import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/common/no_internet.dart';
import 'package:cbook_dt/feature/authentication/presentation/comapny_login.dart';
import 'package:cbook_dt/feature/authentication/provider/login_provider.dart';
import 'package:cbook_dt/feature/home/presentation/home_view.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
 
  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.white),
    );
    _checkInternetAndNavigate();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

   Future<void> _checkInternetAndNavigate() async {
    await Future.delayed(const Duration(seconds: 2)); // Show splash for 2 sec

    // Check internet connectivity with retry approach
    ConnectivityResult connectivityResult;
    bool isInternetAvailable = false;

    // Keep checking the connectivity for a few seconds before proceeding
    for (int i = 0; i < 5; i++) {
      connectivityResult = (await Connectivity().checkConnectivity())[0]; // Get the first item from the list
      debugPrint("Connectivity Status: $connectivityResult");

      if (connectivityResult != ConnectivityResult.none) {
        isInternetAvailable = true;
        break; // Stop checking if internet is available
      }
      await Future.delayed(const Duration(seconds: 1)); // Wait for 1 second before rechecking
    }

    // If no internet, show the no internet screen
    if (!isInternetAvailable) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const NoInternetScreen()),
      );
      return;
    }

    // Check login status if internet is available
    final isLoggedIn =
        Provider.of<LoginProvider>(context, listen: false).isLoggedIn;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => isLoggedIn ? const HomeView() : const ComapnyLogin(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: AppColors.primaryColor,
        statusBarIconBrightness: Brightness.light, // for Android
        statusBarBrightness: Brightness.dark, // for iOS
      ),
      child: Container(
        color: AppColors.secondaryColor,
        child: SafeArea(
          child: Scaffold(
            backgroundColor: AppColors.secondaryColor,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/image/splash_screen_nobg.png', width: 150, height: 150), //assets\image\splash_screen_nobg.png
                  const SizedBox(height: 20),
                  const CircularProgressIndicator(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


