import Mathlib.NumberTheory.Divisors
import Mathlib.Tactic

namespace Biblioteca.Demonstrations

def Norwegian (n : Nat) : Prop :=
  0 < n ∧ ∃ a b c : Nat,
    0 < a ∧ a ∣ n ∧ b ∣ n ∧ c ∣ n ∧ a < b ∧ b < c ∧ a + b + c = 2022

lemma factor_4044_eq_674 {k : Nat}
    (hkdiv : k ∣ 4044) (hkmod : k % 3 = 2) (hk11 : 11 ≤ k) : k = 674 := by
  have hp3 : Nat.Prime 3 := by norm_num
  have hp337 : Nat.Prime 337 := by norm_num
  have hkcop3 : Nat.Coprime k 3 := by
    refine (hp3.coprime_iff_not_dvd.2 ?_).symm
    intro hk3
    have : k % 3 = 0 := Nat.mod_eq_zero_of_dvd hk3
    omega
  have h4044 : 4044 = 3 * 1348 := by norm_num
  have hkdiv1348 : k ∣ 1348 := by
    have hkdiv' : k ∣ 3 * 1348 := by
      simpa [h4044] using hkdiv
    exact hkcop3.dvd_of_dvd_mul_left hkdiv'
  rcases hkdiv1348 with ⟨u, hu⟩
  have hu_pos : 0 < u := by
    by_contra hu_pos
    have hu0 : u = 0 := by omega
    rw [hu0] at hu
    norm_num at hu
  have hu_lt337 : u < 337 := by
    by_contra hu_ge
    have hu_ge' : 337 ≤ u := by omega
    have h11u : 11 * u ≤ k * u := Nat.mul_le_mul_right u hk11
    have h337u : 11 * 337 ≤ 11 * u := Nat.mul_le_mul_left 11 hu_ge'
    have hku : k * u = 1348 := hu.symm
    have : 11 * 337 ≤ 1348 := le_trans h337u (le_trans h11u (le_of_eq hku))
    norm_num at this
  have h337ku : 337 ∣ k * u := by
    rw [← hu]
    norm_num
  have hnot337u : ¬ 337 ∣ u := by
    intro h337u
    have : 337 ≤ u := Nat.le_of_dvd hu_pos h337u
    omega
  have h337k : 337 ∣ k := (hp337.dvd_mul.mp h337ku).resolve_right hnot337u
  rcases h337k with ⟨ℓ, hk337⟩
  have h337ℓu : 337 * (ℓ * u) = 337 * 4 := by
    calc
      337 * (ℓ * u) = k * u := by
        simp [hk337, Nat.mul_assoc, Nat.mul_comm]
      _ = 1348 := hu.symm
      _ = 337 * 4 := by norm_num
  have hℓu : ℓ * u = 4 := Nat.eq_of_mul_eq_mul_left (by norm_num) h337ℓu
  have hℓdiv4 : ℓ ∣ 4 := by
    refine ⟨u, ?_⟩
    simpa [Nat.mul_comm] using hℓu.symm
  have hℓmod : ℓ % 3 = 2 := by
    have : (337 * ℓ) % 3 = 2 := by simpa [hk337] using hkmod
    omega
  have hℓpos : 0 < ℓ := by
    omega
  have hℓle4 : ℓ ≤ 4 := Nat.le_of_dvd (by norm_num) hℓdiv4
  have hℓeq : ℓ = 2 := by
    omega
  calc
    k = 337 * ℓ := hk337
    _ = 674 := by omega

lemma factor_6066_eq_1011 {k : Nat}
    (hkdiv : k ∣ 6066) (hkmod : k % 4 = 3) (hk19 : 19 ≤ k) : k = 1011 := by
  have hp337 : Nat.Prime 337 := by norm_num
  rcases hkdiv with ⟨u, hu⟩
  have hu_pos : 0 < u := by
    by_contra hu_pos
    have hu0 : u = 0 := by omega
    rw [hu0] at hu
    norm_num at hu
  have hu_lt337 : u < 337 := by
    by_contra hu_ge
    have hu_ge' : 337 ≤ u := by omega
    have h19u : 19 * u ≤ k * u := Nat.mul_le_mul_right u hk19
    have h337u : 19 * 337 ≤ 19 * u := Nat.mul_le_mul_left 19 hu_ge'
    have hku : k * u = 6066 := hu.symm
    have : 19 * 337 ≤ 6066 := le_trans h337u (le_trans h19u (le_of_eq hku))
    norm_num at this
  have h337ku : 337 ∣ k * u := by
    rw [← hu]
    norm_num
  have hnot337u : ¬ 337 ∣ u := by
    intro h337u
    have : 337 ≤ u := Nat.le_of_dvd hu_pos h337u
    omega
  have h337k : 337 ∣ k := (hp337.dvd_mul.mp h337ku).resolve_right hnot337u
  rcases h337k with ⟨ℓ, hk337⟩
  have h337ℓu : 337 * (ℓ * u) = 337 * 18 := by
    calc
      337 * (ℓ * u) = k * u := by
        simp [hk337, Nat.mul_assoc, Nat.mul_comm]
      _ = 6066 := hu.symm
      _ = 337 * 18 := by norm_num
  have hℓu : ℓ * u = 18 := Nat.eq_of_mul_eq_mul_left (by norm_num) h337ℓu
  have hℓdiv18 : ℓ ∣ 18 := by
    refine ⟨u, ?_⟩
    simpa [Nat.mul_comm] using hℓu.symm
  have hℓmod : ℓ % 4 = 3 := by
    have : (337 * ℓ) % 4 = 3 := by simpa [hk337] using hkmod
    omega
  have hℓpos : 0 < ℓ := by
    omega
  have hℓle18 : ℓ ≤ 18 := Nat.le_of_dvd (by norm_num) hℓdiv18
  have hℓne7 : ℓ ≠ 7 := by
    intro hℓ7
    have : 7 ∣ 18 := hℓ7 ▸ hℓdiv18
    norm_num at this
  have hℓne11 : ℓ ≠ 11 := by
    intro hℓ11
    have : 11 ∣ 18 := hℓ11 ▸ hℓdiv18
    norm_num at this
  have hℓne15 : ℓ ≠ 15 := by
    intro hℓ15
    have : 15 ∣ 18 := hℓ15 ▸ hℓdiv18
    norm_num at this
  have hℓeq : ℓ = 3 := by
    omega
  calc
    k = 337 * ℓ := hk337
    _ = 1011 := by omega

lemma case_two_forces_1344 {a b n m : Nat}
    (hab : a < b) (hn2 : n = 2 * b) (hnm : n = a * m)
    (hsum : a + b + n = 2022) : n = 1344 := by
  have hmgt2 : 2 < m := by
    by_contra hmle
    have hmle' : m ≤ 2 := by omega
    have hsmall : n < n := by
      calc
        n = a * m := hnm
        _ ≤ a * 2 := Nat.mul_le_mul_left a hmle'
        _ < b * 2 := by
          exact Nat.mul_lt_mul_of_pos_right hab (by norm_num)
        _ = n := by simpa [Nat.mul_comm] using hn2.symm
    omega
  have hmge11 : 11 ≤ 2 + 3 * m := by
    omega
  have hrel : a * m = 2 * b := by
    calc
      a * m = n := hnm.symm
      _ = 2 * b := hn2
  have hsum' : a + b + a * m = 2022 := by
    simpa [hnm] using hsum
  have hfactor : a * (2 + 3 * m) = 4044 := by
    calc
      a * (2 + 3 * m) = 2 * a + 3 * (a * m) := by ring
      _ = 4044 := by
        nlinarith [hsum', hrel]
  have hdiv : 2 + 3 * m ∣ 4044 := by
    refine ⟨a, ?_⟩
    simpa [Nat.mul_comm] using hfactor.symm
  have hkmod : (2 + 3 * m) % 3 = 2 := by
    omega
  have h674 : 2 + 3 * m = 674 := factor_4044_eq_674 hdiv hkmod hmge11
  have hmval : m = 224 := by
    omega
  have haval : a = 6 := by
    nlinarith [hfactor, hmval]
  calc
    n = a * m := hnm
    _ = 1344 := by omega

lemma case_three_forces_1512 {a b n m : Nat}
    (hab : a < b) (hn3 : n = 3 * b) (hnm : n = a * m)
    (hsum : a + b + n = 2022) : n = 1512 := by
  have hmgt3 : 3 < m := by
    by_contra hmle
    have hmle' : m ≤ 3 := by omega
    have hsmall : n < n := by
      calc
        n = a * m := hnm
        _ ≤ a * 3 := Nat.mul_le_mul_left a hmle'
        _ < b * 3 := by
          exact Nat.mul_lt_mul_of_pos_right hab (by norm_num)
        _ = n := by simpa [Nat.mul_comm] using hn3.symm
    omega
  have hmge19 : 19 ≤ 3 + 4 * m := by
    omega
  have hrel : a * m = 3 * b := by
    calc
      a * m = n := hnm.symm
      _ = 3 * b := hn3
  have hsum' : a + b + a * m = 2022 := by
    simpa [hnm] using hsum
  have hfactor : a * (3 + 4 * m) = 6066 := by
    calc
      a * (3 + 4 * m) = 3 * a + 4 * (a * m) := by ring
      _ = 6066 := by
        nlinarith [hsum', hrel]
  have hdiv : 3 + 4 * m ∣ 6066 := by
    refine ⟨a, ?_⟩
    simpa [Nat.mul_comm] using hfactor.symm
  have hkmod : (3 + 4 * m) % 4 = 3 := by
    omega
  have h1011 : 3 + 4 * m = 1011 := factor_6066_eq_1011 hdiv hkmod hmge19
  have hmval : m = 252 := by
    omega
  have haval : a = 6 := by
    nlinarith [hfactor, hmval]
  calc
    n = a * m := hnm
    _ = 1512 := by omega

theorem norwegian_1344 : Norwegian 1344 := by
  refine ⟨by norm_num, 6, 672, 1344, by norm_num, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · norm_num
  · norm_num
  · norm_num
  · norm_num
  · norm_num
  · norm_num

theorem no_small_norwegian : ¬ ∃ n, n < 1344 ∧ Norwegian n := by
  rintro ⟨n, hnlt, hnor⟩
  rcases hnor with ⟨hnpos, a, b, c, hapos, hadvd, hbdvd, hcdvd, hab, hbc, hsum⟩
  have hbpos : 0 < b := lt_trans hapos hab
  have hcpos : 0 < c := lt_trans hbpos hbc
  have hcle : c ≤ n := Nat.le_of_dvd hnpos hcdvd
  have hc675 : 675 ≤ c := by
    omega
  have hcn : c = n := by
    by_contra hne
    have hclt : c < n := lt_of_le_of_ne hcle hne
    rcases hcdvd with ⟨k, hk⟩
    have hk0 : k ≠ 0 := by
      intro hk0
      have : n = 0 := by simpa [hk0] using hk
      omega
    have hk1 : k ≠ 1 := by
      intro hk1
      have : n = c := by simpa [hk1] using hk
      omega
    have hk2 : 2 ≤ k := by
      omega
    have h2cle : 2 * c ≤ n := by
      nlinarith [hk, hk2, hcpos]
    have hnlarge : 1350 ≤ n := by
      nlinarith [hc675, h2cle]
    omega
  have hblt : b < n := by simpa [hcn] using hbc
  rcases hbdvd with ⟨d, hd⟩
  have hd0 : d ≠ 0 := by
    intro hd0
    have : n = 0 := by simpa [hd0] using hd
    omega
  have hd1 : d ≠ 1 := by
    intro hd1
    have : n = b := by simpa [hd1, Nat.mul_comm] using hd
    omega
  have hd2 : 2 ≤ d := by
    omega
  have hdle3 : d ≤ 3 := by
    by_contra hdgt
    have hd4 : 4 ≤ d := by omega
    have hsum' : a + b + b * d = 2022 := by
      simpa [hcn, hd] using hsum
    have hcontr : 4044 < 3 * n := by
      nlinarith [hab, hsum', hd4, hd, hbpos]
    have : 3 * n < 4044 := by
      nlinarith [hnlt]
    omega
  interval_cases d
  · have hd2eq : n = 2 * b := by
      simpa [Nat.mul_comm] using hd
    rcases hadvd with ⟨m, hm⟩
    have hsum' : a + b + n = 2022 := by
      simpa [hcn] using hsum
    have hneq : n = 1344 := case_two_forces_1344 hab hd2eq hm hsum'
    omega
  · have hd3eq : n = 3 * b := by
      simpa [Nat.mul_comm] using hd
    rcases hadvd with ⟨m, hm⟩
    have hsum' : a + b + n = 2022 := by
      simpa [hcn] using hsum
    have hneq : n = 1512 := case_three_forces_1512 hab hd3eq hm hsum'
    omega

theorem least_norwegian_number : IsLeast {n : Nat | Norwegian n} 1344 := by
  refine ⟨norwegian_1344, ?_⟩
  intro n hn
  exact le_of_not_gt (fun hlt => no_small_norwegian ⟨n, hlt, hn⟩)

end Biblioteca.Demonstrations
