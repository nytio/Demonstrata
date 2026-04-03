import Mathlib.Data.Nat.Choose.Sum

namespace Biblioteca.Demonstrations

/--
The first binomial moment, written in a shifted form that avoids a truncated
exponent in the final expression.
-/
theorem weighted_binomial_sum (n : Nat) :
    Finset.sum (Finset.range (n + 2)) (fun i => i * ((n + 1).choose i)) =
      (n + 1) * 2 ^ n := by
  simpa using Nat.sum_range_mul_choose (n + 1)

end Biblioteca.Demonstrations
