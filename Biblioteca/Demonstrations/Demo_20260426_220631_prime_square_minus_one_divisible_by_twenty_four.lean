import Mathlib.Tactic

namespace Biblioteca.Demonstrations

/-- The square of an odd natural number is congruent to `1` modulo `8`. -/
lemma eight_dvd_square_sub_one_of_odd {n : Nat} (hn : Odd n) :
    8 ∣ n ^ 2 - 1 := by
  rcases hn with ⟨k, rfl⟩
  rcases Nat.even_mul_succ_self k with ⟨t, ht⟩
  refine ⟨t, ?_⟩
  have hsq : (2 * k + 1) ^ 2 = 8 * t + 1 := by
    calc
      (2 * k + 1) ^ 2 = 4 * (k * (k + 1)) + 1 := by ring
      _ = 8 * t + 1 := by
        rw [ht]
        ring
  rw [hsq]
  simp

/-- If a natural number is not divisible by `3`, its square is congruent to
`1` modulo `3`. -/
lemma three_dvd_square_sub_one_of_not_dvd {n : Nat} (hn : ¬ 3 ∣ n) :
    3 ∣ n ^ 2 - 1 := by
  have hnmod_ne_zero : n % 3 ≠ 0 := by
    intro hmod
    exact hn (Nat.dvd_iff_mod_eq_zero.mpr hmod)
  have hnmod_lt : n % 3 < 3 := Nat.mod_lt n (by norm_num)
  have hnmod : n % 3 = 1 ∨ n % 3 = 2 := by omega
  rcases hnmod with hmod | hmod
  · let q := n / 3
    refine ⟨q * (3 * q + 2), ?_⟩
    have hnrepr : n = 3 * q + 1 := by
      calc
        n = 3 * (n / 3) + n % 3 := (Nat.div_add_mod n 3).symm
        _ = 3 * q + 1 := by
          simp [q, hmod]
    rw [hnrepr]
    have hsq : (3 * q + 1) ^ 2 = 3 * (q * (3 * q + 2)) + 1 := by ring
    rw [hsq]
    simp
  · let q := n / 3
    refine ⟨3 * q ^ 2 + 4 * q + 1, ?_⟩
    have hnrepr : n = 3 * q + 2 := by
      calc
        n = 3 * (n / 3) + n % 3 := (Nat.div_add_mod n 3).symm
        _ = 3 * q + 2 := by
          simp [q, hmod]
    rw [hnrepr]
    have hsq : (3 * q + 2) ^ 2 = 3 * (3 * q ^ 2 + 4 * q + 1) + 1 := by ring
    rw [hsq]
    simp

/-- For every prime `p > 3`, the number `p ^ 2 - 1` is divisible by `24`. -/
theorem prime_square_sub_one_dvd_twenty_four {p : Nat} (hp : Nat.Prime p) (hpgt : 3 < p) :
    24 ∣ p ^ 2 - 1 := by
  have hp_ne_two : p ≠ 2 := by omega
  have hp_ne_three : p ≠ 3 := by omega
  have hodd : Odd p := hp.odd_of_ne_two hp_ne_two
  have h8 : 8 ∣ p ^ 2 - 1 := eight_dvd_square_sub_one_of_odd hodd
  have hnot3 : ¬ 3 ∣ p := by
    intro h3
    have hEq : 3 = p := (Nat.prime_dvd_prime_iff_eq (by norm_num : Nat.Prime 3) hp).1 h3
    exact hp_ne_three hEq.symm
  have h3 : 3 ∣ p ^ 2 - 1 := three_dvd_square_sub_one_of_not_dvd hnot3
  have hcop : Nat.Coprime 8 3 := by norm_num
  have h24 : 8 * 3 ∣ p ^ 2 - 1 := hcop.mul_dvd_of_dvd_of_dvd h8 h3
  simpa using h24

end Biblioteca.Demonstrations
