import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/training.dart';
import '../services/database_service.dart';
import '../services/rep_calculator.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _maxRepsController = TextEditingController();
  final _dbService = DatabaseService();
  
  int _setsCount = 3;
  List<int> _calculatedReps = [];
  
  @override
  void dispose() {
    _maxRepsController.dispose();
    super.dispose();
  }
  
  void _calculateReps() {
    if (_maxRepsController.text.isNotEmpty) {
      final maxReps = int.tryParse(_maxRepsController.text) ?? 0;
      
      setState(() {
        _calculatedReps = RepCalculator.calculateReps(maxReps, _setsCount);
      });
    }
  }
  
  Future<void> _saveAndContinue() async {
    if (_formKey.currentState!.validate()) {
      final training = Training(
        maxReps: int.parse(_maxRepsController.text),
        setsCount: _setsCount,
        updatedAt: DateTime.now(),
      );
      
      await _dbService.insertTraining(training);
      
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                const SizedBox(height: 40),
                const Text(
                  'Welcome to NBJP',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Let\'s set up your training',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                TextFormField(
                  controller: _maxRepsController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: false, signed: false),
                  textInputAction: TextInputAction.done,
                  autocorrect: false,
                  enableSuggestions: false,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: 'Maximum Push-ups',
                    hintText: 'How many can you do in one set?',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.fitness_center),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.check_circle, color: Colors.blue),
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your maximum push-ups';
                    }
                    final num = int.tryParse(value);
                    if (num == null || num <= 0) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                  onChanged: (_) => _calculateReps(),
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).unfocus();
                  },
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.repeat, color: Colors.grey.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Number of Sets',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: _setsCount > 1
                                ? () {
                                    setState(() {
                                      _setsCount--;
                                      _calculateReps();
                                    });
                                  }
                                : null,
                            icon: const Icon(Icons.remove_circle_outline),
                            color: Colors.blue,
                            disabledColor: Colors.grey.shade400,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '$_setsCount',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: _setsCount < 10
                                ? () {
                                    setState(() {
                                      _setsCount++;
                                      _calculateReps();
                                    });
                                  }
                                : null,
                            icon: const Icon(Icons.add_circle_outline),
                            color: Colors.blue,
                            disabledColor: Colors.grey.shade400,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (_calculatedReps.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your calculated workout:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...List.generate(_calculatedReps.length, (index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.blue,
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '${_calculatedReps[index]} push-ups',
                                  style: const TextStyle(fontSize: 15),
                                ),
                                if (index == _calculatedReps.indexOf(_calculatedReps.reduce((a, b) => a > b ? a : b)))
                                  const Text(
                                    ' (MAX)',
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 8),
                        Text(
                          'Total: ${_calculatedReps.fold(0, (sum, reps) => sum + reps)} push-ups',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _saveAndContinue,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Start Training',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}