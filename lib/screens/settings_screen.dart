import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/training.dart';
import '../services/database_service.dart';
import '../services/rep_calculator.dart';

class SettingsScreen extends StatefulWidget {
  final Training training;
  
  const SettingsScreen({super.key, required this.training});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _maxRepsController;
  late int _setsCount;
  final _dbService = DatabaseService();
  List<int> _calculatedReps = [];
  
  @override
  void initState() {
    super.initState();
    _maxRepsController = TextEditingController(
      text: widget.training.maxReps.toString(),
    );
    _setsCount = widget.training.setsCount;
    _calculateReps();
  }
  
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
  
  Future<void> _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      final updatedTraining = widget.training.copyWith(
        maxReps: int.parse(_maxRepsController.text),
        setsCount: _setsCount,
        updatedAt: DateTime.now(),
      );
      
      await _dbService.updateTraining(updatedTraining);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Training updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Text(
                        'Training Settings',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Training Configuration',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _maxRepsController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: false, signed: false),
                        textInputAction: TextInputAction.done,
                        autocorrect: false,
                        enableSuggestions: false,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          labelText: 'Maximum Push-ups',
                          hintText: 'Your current max in one set',
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
                                    color: Colors.blue.withValues(alpha: 0.2),
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
                    ],
                  ),
                ),
              ),
              if (_calculatedReps.isNotEmpty) ...[
                const SizedBox(height: 20),
                Card(
                  color: Colors.blue.withValues(alpha: 0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Updated Workout Preview',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...List.generate(_calculatedReps.length, (index) {
                          final maxReps = int.tryParse(_maxRepsController.text) ?? 0;
                          final isMax = _calculatedReps[index] == maxReps;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: isMax ? Colors.orange : Colors.blue,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '${_calculatedReps[index]} push-ups',
                                  style: const TextStyle(fontSize: 15),
                                ),
                                if (isMax) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text(
                                      'MAX',
                                      style: TextStyle(
                                        color: Colors.orange,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total push-ups:',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '${_calculatedReps.fold(0, (sum, reps) => sum + reps)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontSize: 16),
                ),
              ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}