import 'package:flutter/material.dart';

class InsightsWidget extends StatelessWidget {
  const InsightsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'Sem dados suficientes para gerar insights.',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
