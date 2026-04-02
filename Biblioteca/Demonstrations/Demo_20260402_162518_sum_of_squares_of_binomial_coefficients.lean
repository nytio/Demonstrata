import Mathlib.Data.Nat.Choose.Vandermonde

namespace Biblioteca.Demonstrations

/--
A classical corollary of Vandermonde's identity: the sum of the squared entries
in the `n`th row of Pascal's triangle is the central binomial coefficient.
-/
theorem sum_of_squares_of_binomial_coefficients (n : Nat) :
    Finset.sum (Finset.range (n + 1)) (fun i => (n.choose i) ^ 2) =
      (2 * n).choose n := by
  simpa using Nat.sum_range_choose_sq n

end Biblioteca.Demonstrations
