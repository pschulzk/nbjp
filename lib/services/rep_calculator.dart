class RepCalculator {
  static List<int> calculateReps(int maxReps, int setsCount) {
    if (setsCount <= 0 || maxReps <= 0) return [];
    
    switch (setsCount) {
      case 1:
        // Single set: go for max
        return [maxReps];
        
      case 2:
        // 2 sets: warm-up (50%) + max effort
        return [
          (maxReps * 0.5).round(),
          maxReps,
        ];
        
      case 3:
        // 3 sets: warm-up (40%) + max + endurance (60%)
        return [
          (maxReps * 0.4).round(),
          maxReps,
          (maxReps * 0.6).round(),
        ];
        
      case 4:
        // 4 sets: warm-up (40%) + build (70%) + max + cooldown (50%)
        return [
          (maxReps * 0.4).round(),
          (maxReps * 0.7).round(),
          maxReps,
          (maxReps * 0.5).round(),
        ];
        
      case 5:
        // 5 sets: pyramid up
        return [
          (maxReps * 0.3).round(),
          (maxReps * 0.5).round(),
          (maxReps * 0.7).round(),
          maxReps,
          (maxReps * 0.6).round(),
        ];
        
      default:
        // 6+ sets: wave pattern
        return _generateWavePattern(maxReps, setsCount);
    }
  }
  
  static List<int> _generateWavePattern(int maxReps, int setsCount) {
    List<int> reps = [];
    
    // Create waves: each wave has 3 sets (low, medium, high)
    int waves = (setsCount / 3).ceil();
    
    for (int wave = 0; wave < waves; wave++) {
      // Each wave gets progressively harder
      double waveMultiplier = 0.7 + (wave * 0.1);
      if (waveMultiplier > 1.0) waveMultiplier = 1.0;
      
      // Add sets for this wave
      if (reps.length < setsCount) {
        reps.add((maxReps * 0.4 * waveMultiplier).round());
      }
      if (reps.length < setsCount) {
        reps.add((maxReps * 0.6 * waveMultiplier).round());
      }
      if (reps.length < setsCount) {
        reps.add((maxReps * 0.8 * waveMultiplier).round());
      }
    }
    
    // Ensure at least one max set
    if (reps.length > 2) {
      reps[reps.length - 2] = maxReps;
    }
    
    return reps.take(setsCount).toList();
  }
  
  static int getRestSeconds(int setNumber, int totalSets) {
    // Rest periods based on set position
    if (setNumber == totalSets - 1) {
      // Before last set (usually max effort)
      return 120; // 2 minutes
    } else if (setNumber < totalSets ~/ 2) {
      // Early sets: shorter rest
      return 60; // 1 minute
    } else {
      // Middle sets: moderate rest
      return 90; // 1.5 minutes
    }
  }
}