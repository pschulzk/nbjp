import 'package:flutter/material.dart';
import 'dart:async';
import '../models/training.dart';
import '../models/session.dart';
import '../services/database_service.dart';
import '../services/rep_calculator.dart';
import '../services/health_service.dart';

class SessionScreen extends StatefulWidget {
  final Training training;
  
  const SessionScreen({super.key, required this.training});

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  final _dbService = DatabaseService();
  final _healthService = HealthService();
  late List<int> _plannedReps;
  late List<int> _actualReps;
  int _currentSetIndex = 0;
  int _currentReps = 0;
  bool _isResting = false;
  int _restSeconds = 0;
  Timer? _restTimer;
  DateTime? _sessionStartTime;
  
  @override
  void initState() {
    super.initState();
    _plannedReps = RepCalculator.calculateReps(
      widget.training.maxReps,
      widget.training.setsCount,
    );
    _actualReps = List.filled(_plannedReps.length, 0);
    _sessionStartTime = DateTime.now();
  }
  
  @override
  void dispose() {
    _restTimer?.cancel();
    super.dispose();
  }
  
  void _incrementReps() {
    if (!_isResting) {
      setState(() {
        _currentReps++;
      });
    }
  }
  
  void _decrementReps() {
    if (!_isResting && _currentReps > 0) {
      setState(() {
        _currentReps--;
      });
    }
  }
  
  void _completeSet() {
    setState(() {
      _actualReps[_currentSetIndex] = _currentReps;
      
      if (_currentSetIndex < _plannedReps.length - 1) {
        _isResting = true;
        _restSeconds = RepCalculator.getRestSeconds(
          _currentSetIndex,
          _plannedReps.length,
        );
        _startRestTimer();
      } else {
        _completeSession();
      }
    });
  }
  
  void _startRestTimer() {
    _restTimer?.cancel();
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _restSeconds--;
        if (_restSeconds <= 0) {
          timer.cancel();
          _isResting = false;
          _currentSetIndex++;
          _currentReps = 0;
        }
      });
    });
  }
  
  void _skipRest() {
    _restTimer?.cancel();
    setState(() {
      _isResting = false;
      _currentSetIndex++;
      _currentReps = 0;
      _restSeconds = 0;
    });
  }
  
  void _showCancelConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Workout?'),
        content: const Text('Are you sure you want to cancel this workout? Your progress will not be saved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Continue Workout'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Close session screen
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Cancel Workout'),
          ),
        ],
      ),
    );
  }

  Future<void> _completeSession() async {
    final duration = DateTime.now().difference(_sessionStartTime!).inSeconds;
    
    final session = Session(
      trainingId: widget.training.id!,
      date: DateTime.now(),
      plannedReps: _plannedReps,
      actualReps: _actualReps,
      durationSeconds: duration,
    );
    
    await _dbService.insertSession(session);
    
    // Sync with Apple Health
    try {
      await _healthService.writeWorkoutSession(
        session,
        sessionStart: _sessionStartTime,
      );
      debugPrint('Workout synced with Apple Health');
    } catch (e) {
      debugPrint('Failed to sync with Apple Health: $e');
    }
    
    if (mounted) {
      _showCompletionDialog();
    }
  }
  
  void _showCompletionDialog() {
    final totalPlanned = _plannedReps.fold(0, (sum, reps) => sum + reps);
    final totalActual = _actualReps.fold(0, (sum, reps) => sum + reps);
    final completionRate = (totalActual / totalPlanned * 100).toStringAsFixed(0);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Workout Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'You completed $totalActual/$totalPlanned push-ups',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Completion Rate: $completionRate%',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isResting) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: _showCancelConfirmation,
                    ),
                    const Text(
                      'Rest Time',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
              const Text(
                'Rest',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 32),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      value: _restSeconds / RepCalculator.getRestSeconds(
                        _currentSetIndex,
                        _plannedReps.length,
                      ),
                      strokeWidth: 8,
                      backgroundColor: Colors.blue.shade100,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                  Text(
                    '${_restSeconds}s',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              Text(
                'Next: Set ${_currentSetIndex + 2} of ${_plannedReps.length}',
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Target: ${_plannedReps[_currentSetIndex + 1]} push-ups',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: _skipRest,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue,
                ),
                child: const Text(
                  'Skip Rest',
                  style: TextStyle(fontSize: 18),
                ),
              ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    final isMaxSet = _plannedReps[_currentSetIndex] == widget.training.maxReps;
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Set ${_currentSetIndex + 1} of ${_plannedReps.length}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _showCancelConfirmation,
                  ),
                ],
              ),
            ),
          if (isMaxSet)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.orange.withValues(alpha: 0.2),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star, color: Colors.orange),
                  SizedBox(width: 8),
                  Text(
                    'MAX EFFORT SET',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.star, color: Colors.orange),
                ],
              ),
            ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Target: ${_plannedReps[_currentSetIndex]} push-ups',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 48),
                GestureDetector(
                  onTap: _incrementReps,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isMaxSet ? Colors.orange : Colors.blue,
                      boxShadow: [
                        BoxShadow(
                          color: (isMaxSet ? Colors.orange : Colors.blue)
                              .withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '$_currentReps',
                        style: const TextStyle(
                          fontSize: 72,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Tap circle to count',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 48),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: _decrementReps,
                      icon: const Icon(Icons.remove_circle_outline),
                      iconSize: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(width: 32),
                    IconButton(
                      onPressed: _incrementReps,
                      icon: const Icon(Icons.add_circle_outline),
                      iconSize: 48,
                      color: Colors.green,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_plannedReps.length, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index < _currentSetIndex
                            ? Colors.green
                            : index == _currentSetIndex
                                ? (isMaxSet ? Colors.orange : Colors.blue)
                                : Colors.grey.shade300,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _currentReps > 0 ? _completeSet : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 16,
                    ),
                    backgroundColor: isMaxSet ? Colors.orange : Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    _currentSetIndex == _plannedReps.length - 1
                        ? 'Complete Workout'
                        : 'Complete Set',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            ),
          ],
        ),
      ),
    );
  }
}