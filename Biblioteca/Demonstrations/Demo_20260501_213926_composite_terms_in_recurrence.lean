import Mathlib.RingTheory.Polynomial.Chebyshev
import Mathlib.Tactic

namespace Biblioteca.Demonstrations

open Polynomial

namespace CompositeTermsInRecurrence

noncomputable section

abbrev S (n : ℤ) : ℤ[X] := Polynomial.Chebyshev.S ℤ n

/-- The even-indexed Vieta--Fibonacci polynomial, evaluated at `y`. -/
def evenVietaTerm (y : ℤ) (n : ℕ) : ℤ :=
  (S (2 * (n : ℤ))).eval y

/-- The original recurrence with parameter `y ^ 2 - 2`, written through its
even Vieta--Fibonacci parametrization. -/
lemma evenVietaTerm_recurrence (y : ℤ) (n : ℕ) :
    evenVietaTerm y (n + 2) =
      (y ^ 2 - 2) * evenVietaTerm y (n + 1) - evenVietaTerm y n := by
  unfold evenVietaTerm
  have h₁ := Polynomial.Chebyshev.S_add_two ℤ (2 * (n : ℤ) + 2)
  have h₂ := Polynomial.Chebyshev.S_add_two ℤ (2 * (n : ℤ) + 1)
  have h₃ := Polynomial.Chebyshev.S_add_two ℤ (2 * (n : ℤ))
  have h₄ :
      S (2 * (n : ℤ) + 4) =
        ((X : ℤ[X]) ^ 2 - 2) * S (2 * (n : ℤ) + 2) -
          S (2 * (n : ℤ)) := by
    linear_combination (norm := ring_nf) h₁ + (X : ℤ[X]) * h₂ + h₃
  simpa [eval_sub, eval_mul, eval_pow, eval_X, Nat.cast_add, Nat.cast_ofNat,
    add_comm, add_left_comm, add_assoc, mul_add, two_mul] using
      congr_arg (fun p : ℤ[X] => p.eval y) h₄

lemma evenVietaTerm_zero (y : ℤ) : evenVietaTerm y 0 = 1 := by
  simp [evenVietaTerm]

lemma evenVietaTerm_one (y : ℤ) : evenVietaTerm y 1 = y ^ 2 - 1 := by
  simp [evenVietaTerm, Polynomial.Chebyshev.S_two]

set_option linter.unnecessarySimpa false in
lemma vieta_eval_recurrence (y : ℤ) (n : ℕ) :
    (S (↑(n + 2 : ℕ))).eval y =
      y * (S (↑(n + 1 : ℕ))).eval y - (S (↑n)).eval y := by
  have h := Polynomial.Chebyshev.S_add_two ℤ (n : ℤ)
  simpa [eval_sub, eval_mul, eval_X] using congr_arg (fun p : ℤ[X] => p.eval y) h

/-- For `y >= 3`, the evaluated Vieta--Fibonacci sequence is positive, and
successive terms differ by more than one. -/
lemma vieta_eval_pos_and_gap {y : ℤ} (hy : 3 ≤ y) :
    ∀ n : ℕ,
      0 < (S (n : ℤ)).eval y ∧
        1 < (S ((n + 1 : ℕ) : ℤ)).eval y - (S (n : ℤ)).eval y := by
  intro n
  induction n with
  | zero =>
      simp
      omega
  | succ n ih =>
      have hrec := vieta_eval_recurrence y n
      constructor
      · nlinarith [ih.1, ih.2]
      · nlinarith [hy, ih.1, ih.2, hrec]

/-- Addition law for the rescaled Chebyshev polynomials of the second kind. -/
lemma S_add_nat (m : ℤ) :
    ∀ n : ℕ,
      S (m + n) =
        S m * S (n : ℤ) - S (m - 1) * S ((n : ℤ) - 1) := by
  intro n
  induction n using Nat.twoStepInduction with
  | zero =>
      simp
  | one =>
      simpa [mul_comm] using Polynomial.Chebyshev.S_add_one ℤ m
  | more n ih0 ih1 =>
      have hm := Polynomial.Chebyshev.S_add_two ℤ (m + n)
      have hn := Polynomial.Chebyshev.S_add_two ℤ (n : ℤ)
      have hnprev := Polynomial.Chebyshev.S_add_two ℤ ((n : ℤ) - 1)
      linear_combination (norm := (push_cast; ring_nf)) hm - (S m) * hn + (S (m - 1)) * hnprev +
        (X : ℤ[X]) * ih1 - ih0

lemma S_two_mul_nat (n : ℕ) :
    S (2 * (n : ℤ)) = S (n : ℤ) ^ 2 - S ((n : ℤ) - 1) ^ 2 := by
  simpa [pow_two, two_mul] using S_add_nat (m := (n : ℤ)) n

lemma evenVietaTerm_factor (y : ℤ) (n : ℕ) :
    evenVietaTerm y n =
      ((S (n : ℤ)).eval y + (S ((n : ℤ) - 1)).eval y) *
        ((S (n : ℤ)).eval y - (S ((n : ℤ) - 1)).eval y) := by
  unfold evenVietaTerm
  have h := S_two_mul_nat n
  have heval := congr_arg (fun p : ℤ[X] => p.eval y) h
  calc
    (S (2 * (n : ℤ))).eval y =
        (S (n : ℤ)).eval y ^ 2 - (S ((n : ℤ) - 1)).eval y ^ 2 := by
      simpa [eval_sub, eval_mul, eval_pow] using heval
    _ =
        ((S (n : ℤ)).eval y + (S ((n : ℤ) - 1)).eval y) *
          ((S (n : ℤ)).eval y - (S ((n : ℤ) - 1)).eval y) := by
      ring

lemma natAbs_mul_not_prime {b c z : ℤ} (hz : z = b * c)
    (hb : 1 < b.natAbs) (hc : 1 < c.natAbs) :
    ¬ Nat.Prime z.natAbs := by
  have hmul : b.natAbs * c.natAbs = z.natAbs := by
    rw [hz, Int.natAbs_mul]
  exact Nat.not_prime_of_mul_eq hmul (by omega) (by omega)

lemma evenVietaTerm_not_prime {y : ℤ} (hy : 3 ≤ y) (n : ℕ) :
    ¬ Nat.Prime (evenVietaTerm y n).natAbs := by
  cases n with
  | zero =>
      norm_num [evenVietaTerm_zero]
  | succ n =>
      let p : ℤ := (S ((n + 1 : ℕ) : ℤ)).eval y
      let q : ℤ := (S (n : ℤ)).eval y
      have hfac : evenVietaTerm y (n + 1) = (p + q) * (p - q) := by
        simpa [p, q] using evenVietaTerm_factor y (n + 1)
      have hprev := vieta_eval_pos_and_gap (y := y) hy n
      have hbint : 1 < p - q := by
        simpa [p, q] using hprev.2
      have hcint : 1 < p + q := by
        nlinarith [hprev.1, hprev.2]
      have hb : 1 < (p - q).natAbs := by
        have : (1 : ℤ) < ((p - q).natAbs : ℤ) := by
          rw [Int.natAbs_of_nonneg (by nlinarith [hbint])]
          exact hbint
        exact_mod_cast this
      have hc : 1 < (p + q).natAbs := by
        have : (1 : ℤ) < ((p + q).natAbs : ℤ) := by
          rw [Int.natAbs_of_nonneg (by nlinarith [hcint])]
          exact hcint
        exact_mod_cast this
      exact natAbs_mul_not_prime hfac hc hb

/-- There are arbitrarily large positive parameters for which the recurrence
has no prime term. The sequence is represented over `ℤ`; for the constructed
parameters all its values are positive, and `natAbs` records the usual natural
number value. -/
theorem infinitely_many_positive_parameters_without_prime_terms :
    ∀ B : ℕ, ∃ x : ℤ, 0 < x ∧ (B : ℤ) < x ∧
      ∃ a : ℕ → ℤ,
        a 0 = 1 ∧
        a 1 = x + 1 ∧
        (∀ n : ℕ, a (n + 2) = x * a (n + 1) - a n) ∧
        (∀ n : ℕ, ¬ Nat.Prime (a n).natAbs) := by
  intro B
  let y : ℕ := B + 3
  let x : ℤ := (y : ℤ) ^ 2 - 2
  refine ⟨x, ?_, ?_, ?_⟩
  · dsimp [x, y]
    have hB : 0 ≤ (B : ℤ) := by exact_mod_cast Nat.zero_le B
    nlinarith
  · dsimp [x, y]
    have hB : 0 ≤ (B : ℤ) := by exact_mod_cast Nat.zero_le B
    nlinarith
  · refine ⟨evenVietaTerm (y : ℤ), ?_, ?_, ?_, ?_⟩
    · simp [evenVietaTerm_zero]
    · rw [evenVietaTerm_one]
      dsimp [x]
      ring
    · intro n
      dsimp [x]
      exact evenVietaTerm_recurrence (y : ℤ) n
    · intro n
      exact evenVietaTerm_not_prime (y := (y : ℤ)) (by dsimp [y]; norm_num) n

end

end CompositeTermsInRecurrence

end Biblioteca.Demonstrations
