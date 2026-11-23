import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Elevator App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Elevator settings
  int currentFloor = 3;
  int targetFloor = 3;

  final int minFloor = 0;
  final int maxFloor = 5;

  String direction = 'STOP';
  String doorStatus = 'Open';

  Timer? elevatorTimer;

  // Main elevator function
  void moveElevator(int requestedFloor) {
    // Check valid floor
    if (requestedFloor < minFloor ||
        requestedFloor > maxFloor) {
      return;
    }

    // Cancel previous movement if a new target is selected
    elevatorTimer?.cancel();

    setState(() {
      targetFloor = requestedFloor;
      doorStatus = 'Closed';

      if (targetFloor > currentFloor) {
        direction = 'UP';
      } else if (targetFloor < currentFloor) {
        direction = 'DOWN';
      } else {
        direction = 'STOP';
        doorStatus = 'Open';
      }
    });

    // Already at the requested floor
    if (currentFloor == targetFloor) {
      return;
    }

    // Move one floor at a time
    elevatorTimer = Timer.periodic(
      const Duration(milliseconds: 800),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        setState(() {
          if (currentFloor < targetFloor) {
            currentFloor++;
            direction = 'UP';
          } else if (currentFloor > targetFloor) {
            currentFloor--;
            direction = 'DOWN';
          }

          // Stop when reaching target floor
          if (currentFloor == targetFloor) {
            timer.cancel();

            direction = 'STOP';
            doorStatus = 'Open';
          }
        });
      },
    );
  }

  @override
  void dispose() {
    elevatorTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade900,
      appBar: AppBar(
        title: const Text('Elevator Control'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Elevator display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    Icon(
                      direction == 'UP'
                          ? Icons.arrow_upward
                          : direction == 'DOWN'
                              ? Icons.arrow_downward
                              : Icons.pause,
                      color: Colors.greenAccent,
                      size: 40,
                    ),

                    Text(
                      '$currentFloor',
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 55,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Text(
                      'Direction: $direction',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'Door: $doorStatus',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),

                    Text(
                      'Target Floor: $targetFloor',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                'Select Your Floor',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              // Floor buttons
              Expanded(
                child: GridView.builder(
                  itemCount: maxFloor - minFloor + 1,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemBuilder: (context, index) {
                    final floor = maxFloor - index;

                    return ElevatedButton(
                      onPressed: () {
                        moveElevator(floor);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            currentFloor == floor
                                ? Colors.orange
                                : Colors.teal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        '$floor',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
