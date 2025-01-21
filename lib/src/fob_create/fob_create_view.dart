import 'package:flutter/material.dart';

class FobCreateView extends StatelessWidget {
  const FobCreateView({super.key});

  static const routeName = '/fobCreate';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create'),
      ),
      body: Icon(Icons.create)
    );
  }
}
