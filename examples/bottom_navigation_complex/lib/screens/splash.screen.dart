import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final Widget? screen;

  const SplashScreen({Key? key, this.screen}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool loading = true;

  @override
  void initState() {
    // Simulate fetching data from server or async load of preferences
    Future.delayed(const Duration(seconds: 2)).then((_) => setState(() => loading = false));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!loading && widget.screen != null) return widget.screen!;
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: const Center(
        child: Text(
          'Splash',
          style: TextStyle(color: Colors.white, fontSize: 30),
        ),
      ),
    );
  }
}
