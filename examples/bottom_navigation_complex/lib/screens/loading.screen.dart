import 'package:flutter/material.dart';

class LoadingScreen extends StatefulWidget {
  final Widget? child;

  const LoadingScreen({super.key, required this.child});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  bool loading = true;

  @override
  void initState() {
    Future.delayed(const Duration(seconds: 2)).then((_) => setState(() => loading = false));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!loading && widget.child != null) return widget.child!;

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }
}
