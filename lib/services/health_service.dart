import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import '../models/session.dart';

class HealthService {
  static final HealthService _instance = HealthService._internal();
  factory HealthService() => _instance;
  HealthService._internal();

  final _health = Health();
  bool _isInitialized = false;
  bool _isAvailable = false;

  /// Initialize HealthKit (iOS only)
  Future<void> initialize() async {
    if (!Platform.isIOS) {
      debugPrint('HealthKit is only available on iOS');
      return;
    }

    try {
      _isInitialized = true;
      _isAvailable = await _checkAvailability();
      debugPrint('HealthKit initialized: $_isAvailable');
    } catch (e) {
      debugPrint('Failed to initialize HealthKit: $e');
      _isAvailable = false;
    }
  }

  /// Check if HealthKit is available
  Future<bool> _checkAvailability() async {
    if (!_isInitialized || !Platform.isIOS) return false;
    
    try {
      // Request authorization to check availability
      final types = [HealthDataType.WORKOUT];
      final permissions = [HealthDataAccess.WRITE];
      
      final requested = await _health.requestAuthorization(
        types,
        permissions: permissions,
      );
      
      return requested;
    } catch (e) {
      debugPrint('HealthKit availability check failed: $e');
      return false;
    }
  }

  /// Request permissions for workout data
  Future<bool> requestPermissions() async {
    if (!_isInitialized || !Platform.isIOS) return false;

    try {
      final types = [
        HealthDataType.WORKOUT,
        HealthDataType.ACTIVE_ENERGY_BURNED,
      ];
      
      final permissions = [
        HealthDataAccess.WRITE,
        HealthDataAccess.WRITE,
      ];

      final authorized = await _health.requestAuthorization(
        types,
        permissions: permissions,
      );

      _isAvailable = authorized;
      return authorized;
    } catch (e) {
      debugPrint('Failed to request HealthKit permissions: $e');
      return false;
    }
  }

  /// Write a push-up workout session to HealthKit
  Future<bool> writeWorkoutSession(Session session, {DateTime? sessionStart}) async {
    if (!_isAvailable) {
      debugPrint('HealthKit not available');
      return false;
    }

    try {
      // Calculate workout duration
      final endTime = session.date;
      final startTime = sessionStart ?? 
        endTime.subtract(Duration(seconds: session.durationSeconds));

      // Estimate calories burned (rough estimate: 0.3-0.5 calories per push-up)
      final caloriesBurned = session.totalActualReps * 0.4;

      // Create workout data
      final workout = HealthWorkoutActivityType.TRADITIONAL_STRENGTH_TRAINING;
      
      // Write the workout
      final success = await _health.writeWorkoutData(
        activityType: workout,
        start: startTime,
        end: endTime,
        totalEnergyBurned: caloriesBurned.round(),
        totalEnergyBurnedUnit: HealthDataUnit.KILOCALORIE,
      );

      if (success) {
        debugPrint('Successfully wrote workout to HealthKit');
        
        // Also write active energy burned as a separate data point
        await _health.writeHealthData(
          value: caloriesBurned,
          type: HealthDataType.ACTIVE_ENERGY_BURNED,
          startTime: startTime,
          endTime: endTime,
          unit: HealthDataUnit.KILOCALORIE,
        );
      }

      return success;
    } catch (e) {
      debugPrint('Failed to write workout to HealthKit: $e');
      return false;
    }
  }

  /// Check if HealthKit is available and authorized
  bool get isAvailable => _isAvailable;
}