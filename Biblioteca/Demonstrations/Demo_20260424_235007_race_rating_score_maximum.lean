import Mathlib.Algebra.BigOperators.Fin
import Mathlib.Algebra.BigOperators.Intervals
import Mathlib.Tactic

namespace Biblioteca.Demonstrations

set_option linter.unnecessarySimpa false

/-- The extremal value in the race-rating problem. -/
def raceRatingMaximum (n : ℕ) : ℕ :=
  n * (n - 1) / 2

/-- The product of two consecutive natural numbers is even, in the form needed
for the closed form of the maximum. -/
lemma two_mul_raceRatingMaximum (n : ℕ) :
    2 * raceRatingMaximum n = n * (n - 1) := by
  unfold raceRatingMaximum
  rw [← Finset.sum_range_id n]
  simpa [mul_comm] using Finset.sum_range_id_mul_two n

/-- In the fixed-order construction the scores may be indexed as `0,1,...,n-1`,
and their sum is the claimed maximum. -/
lemma fixedOrderRaceScores_sum (n : ℕ) :
    (∑ i : Fin n, (i : ℕ)) = raceRatingMaximum n := by
  rw [← Finset.sum_range (fun i : ℕ => i), Finset.sum_range_id]
  rfl

/-- If each student's score `score i` and total zero-based rank sum `rankSum i`
satisfy the per-student inequality coming from the rating definition, and if
the total rank sum is the one forced by `n` races with no ties, then the total
score is at most the claimed maximum.

The olympiad argument proves the first hypothesis by choosing a rating
witnessing the score: if a student is in the top `b` places in `b+s` races, then
their total zero-based rank sum is at most `n*(n-1)-n*s`. -/
theorem raceRatingScoreSum_le_maximum {n : ℕ} (hn : 0 < n)
    (score rankSum : Fin n → ℕ)
    (hstudent : ∀ i, n * score i + rankSum i ≤ n * (n - 1))
    (hrank : (∑ i : Fin n, rankSum i) = n * raceRatingMaximum n) :
    (∑ i : Fin n, score i) ≤ raceRatingMaximum n := by
  let totalScore : ℕ := ∑ i : Fin n, score i
  let totalRank : ℕ := ∑ i : Fin n, rankSum i
  have hsum :
      (∑ i : Fin n, (n * score i + rankSum i)) ≤
        ∑ _i : Fin n, n * (n - 1) :=
    Finset.sum_le_sum fun i _hi => hstudent i
  have hleft :
      (∑ i : Fin n, (n * score i + rankSum i)) =
        n * totalScore + totalRank := by
    simp [totalScore, totalRank, Finset.sum_add_distrib, Finset.mul_sum]
  have hright :
      (∑ _i : Fin n, n * (n - 1)) = n * (n * (n - 1)) := by
    simp
  have hbound :
      n * totalScore + n * raceRatingMaximum n ≤ n * (n * (n - 1)) := by
    simpa [hleft, hright, totalRank, hrank] using hsum
  have htwice : 2 * raceRatingMaximum n = n * (n - 1) :=
    two_mul_raceRatingMaximum n
  have hcancel :
      totalScore + raceRatingMaximum n ≤ n * (n - 1) := by
    have hfact :
        n * (totalScore + raceRatingMaximum n) ≤ n * (n * (n - 1)) := by
      simpa [Nat.mul_add, mul_assoc, mul_comm, mul_left_comm] using hbound
    exact Nat.le_of_mul_le_mul_left hfact hn
  have hmain : totalScore ≤ raceRatingMaximum n := by
    omega
  simpa [totalScore] using hmain

/-- The maximum possible sum of the final scores is `n*(n-1)/2`: the upper
bound is `raceRatingScoreSum_le_maximum`, while the fixed-order construction
attains equality. -/
theorem raceRatingMaximum_value (n : ℕ) :
    (∃ score : Fin n → ℕ, (∑ i : Fin n, score i) = raceRatingMaximum n) ∧
      ∀ (score rankSum : Fin n → ℕ),
        0 < n →
        (∀ i, n * score i + rankSum i ≤ n * (n - 1)) →
        (∑ i : Fin n, rankSum i) = n * raceRatingMaximum n →
        (∑ i : Fin n, score i) ≤ raceRatingMaximum n := by
  constructor
  · exact ⟨fun i => (i : ℕ), fixedOrderRaceScores_sum n⟩
  · intro score rankSum hn hstudent hrank
    exact raceRatingScoreSum_le_maximum hn score rankSum hstudent hrank

end Biblioteca.Demonstrations
