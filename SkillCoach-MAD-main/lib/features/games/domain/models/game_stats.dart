class GameStats {
  final int totalGamesPlayed;
  final int gamesWon;
  final int bestTimeSeconds;
  final String lastDifficultyPlayed;

  const GameStats({
    this.totalGamesPlayed = 0,
    this.gamesWon = 0,
    this.bestTimeSeconds = 0,
    this.lastDifficultyPlayed = 'easy',
  });

  GameStats copyWith({
    int? totalGamesPlayed,
    int? gamesWon,
    int? bestTimeSeconds,
    String? lastDifficultyPlayed,
  }) {
    return GameStats(
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      gamesWon: gamesWon ?? this.gamesWon,
      bestTimeSeconds: bestTimeSeconds ?? this.bestTimeSeconds,
      lastDifficultyPlayed: lastDifficultyPlayed ?? this.lastDifficultyPlayed,
    );
  }
}
