/// Implements the SM‑2 spaced repetition algorithm.

class Sm2Result {
  final int nextIntervalDays;
  final double nextEf;
  final int nextReps;
  Sm2Result(this.nextIntervalDays, this.nextEf, this.nextReps);
}

/// Update SM‑2 parameters based on the user’s quality rating.
///
/// `quality` must be between 0 and 5. If quality is less than 3,
/// repetitions reset and the card will be scheduled for the next day.
Sm2Result sm2Update({
  required int quality,
  required int reps,
  required int intervalDays,
  required double ef,
}) {
  var r = reps;
  var i = intervalDays;
  var e = ef;
  if (quality < 3) {
    r = 0;
    i = 1;
  } else {
    if (r == 0) {
      i = 1;
    } else if (r == 1) {
      i = 6;
    } else {
      i = (i * e).round();
    }
    e = e + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
    if (e < 1.3) e = 1.3;
    r += 1;
  }
  return Sm2Result(i, e, r);
}