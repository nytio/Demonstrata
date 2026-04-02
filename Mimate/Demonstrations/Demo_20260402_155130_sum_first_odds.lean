import Mathlib.Algebra.BigOperators.Ring.Finset
import Mathlib.Tactic

open scoped BigOperators

namespace Mimate.Demonstrations

theorem sum_first_odds (n : Nat) :
    Finset.sum (Finset.range n) (fun i => 2 * i + 1) = n ^ 2 := by
  induction n with
  | zero =>
      simp
  | succ n ih =>
      simp [Finset.sum_range_succ, ih]
      ring

end Mimate.Demonstrations
