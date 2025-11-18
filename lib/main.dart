import 'dart:async';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChronoPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ChronoPage extends StatefulWidget {
  @override
  _ChronoPageState createState() => _ChronoPageState();
}

enum ChronoState { stopped, running, paused }

class _ChronoPageState extends State<ChronoPage> {
  final _tickController = StreamController<int>.broadcast();
  final _secondsController = StreamController<int>.broadcast();

  Stream<int> get secondsStream => _secondsController.stream;

  Timer? _tickTimer;
  int _tickCount = 0;
  int _seconds = 0;
  ChronoState state = ChronoState.stopped;

  @override
  void initState() {
    super.initState();

    _tickController.stream.listen((tick) {
      if (state == ChronoState.running) {
        if (tick % 10 == 0) {
          _seconds++;
          _secondsController.add(_seconds);
        }
      }
    });
  }

  void start() {
    if (state == ChronoState.running) return;

    resetInternal();
    state = ChronoState.running;

    _tickTimer = Timer.periodic(Duration(milliseconds: 100), (_) {
      _tickCount++;
      _tickController.add(_tickCount);
    });
  }


  void stop() {
    state = ChronoState.stopped;
    _tickTimer?.cancel();
    resetInternal();
    _secondsController.add(0);
  }


  void reset() {
    stop();
  }

  void resetInternal() {
    _tickCount = 0;
    _seconds = 0;
  }


  void pause() {
    if (state != ChronoState.running) return;
    state = ChronoState.paused;
    _tickTimer?.cancel();
  }


  void resume() {
    if (state != ChronoState.paused) return;

    state = ChronoState.running;
    _tickTimer = Timer.periodic(Duration(milliseconds: 100), (_) {
      _tickCount++;
      _tickController.add(_tickCount);
    });
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    _tickController.close();
    _secondsController.close();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Cronometrino")),
      body: Center(
        child: StreamBuilder<int>(
          stream: secondsStream,
          initialData: 0,
          builder: (context, snapshot) {
            final sec = snapshot.data!;
            final minutes = sec ~/ 60;
            final seconds = sec % 60;

            return Text(
              "$minutes:${seconds.toString().padLeft(2, '0')}",
              style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
            );
          },
        ),
      ),


      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [


            ElevatedButton(
              onPressed: () {
                if (state == ChronoState.stopped) {
                  start();
                } else {
                  stop();
                }
                setState(() {});
              },
              child: Text(
                state == ChronoState.stopped ? "START" : "STOP/RESET",
              ),
            ),

            ElevatedButton(
              onPressed: () {
                if (state == ChronoState.running) {
                  pause();
                } else if (state == ChronoState.paused) {
                  resume();
                }
                setState(() {});
              },
              child: Text(
                state == ChronoState.running
                    ? "PAUSE"
                    : state == ChronoState.paused
                    ? "RESUME"
                    : "PAUSE",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
