import 'package:flutter/material.dart';

/// Modal Khusus Quest "Cardio Shake" berbasis Sensor Accelerometer (Boilerplate)
class QuestSensorScreen extends StatefulWidget {
  const QuestSensorScreen({super.key});

  @override
  State<QuestSensorScreen> createState() => _QuestSensorScreenState();
}

class _QuestSensorScreenState extends State<QuestSensorScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Text('Quest Sensor: Cardio Shake Screen'),
        ),
      ),
    );
  }
}
