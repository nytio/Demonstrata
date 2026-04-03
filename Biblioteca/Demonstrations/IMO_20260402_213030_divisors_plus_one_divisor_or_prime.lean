import Mathlib.Data.Nat.Factorization.Basic
import Mathlib.Tactic

namespace Biblioteca.Demonstrations

/-- Positive integers `n` such that every positive divisor `d` of `n` satisfies
`d + 1 ∣ n` or `d + 1` is prime. -/
def SuccessorDivisorOrPrime (n : Nat) : Prop :=
  0 < n ∧ ∀ ⦃d : Nat⦄, 0 < d → d ∣ n → d + 1 ∣ n ∨ Nat.Prime (d + 1)

lemma odd_dvd_odd_part {k m u : Nat} (hu : Odd u) (hudvd : u ∣ 2 ^ k * m) : u ∣ m := by
  exact (hu.coprime_two_right.pow_right k).dvd_of_dvd_mul_left hudvd

lemma odd_dvd_le_odd_part {k m u : Nat} (hm : Odd m) (hu : Odd u)
    (hudvd : u ∣ 2 ^ k * m) : u ≤ m := by
  exact Nat.le_of_dvd hm.pos (odd_dvd_odd_part hu hudvd)

lemma odd_not_dvd_of_lt_odd_part {k m u : Nat} (hm : Odd m) (hu : Odd u)
    (hmu : m < u) : ¬ u ∣ 2 ^ k * m := by
  intro hudvd
  exact (not_le_of_gt hmu) (odd_dvd_le_odd_part hm hu hudvd)

lemma not_prime_of_even_gt_two {n : Nat} (heven : Even n) (htwo : 2 < n) : ¬ Nat.Prime n := by
  intro hprime
  rcases hprime.eq_two_or_odd' with rfl | hodd
  · omega
  · exact (show ¬ Odd n by simpa [Nat.not_odd_iff_even] using heven) hodd

lemma succ_of_odd_not_prime {d : Nat} (hdodd : Odd d) (hdgt : 1 < d) :
    ¬ Nat.Prime (d + 1) := by
  have heven : Even (d + 1) := by
    simpa [Nat.add_comm] using hdodd.add_odd (by decide : Odd 1)
  have htwo : 2 < d + 1 := by omega
  exact not_prime_of_even_gt_two heven htwo

lemma three_dvd_two_pow_even_sub_one (t : Nat) : 3 ∣ 2 ^ (2 * t) - 1 := by
  induction t with
  | zero =>
      norm_num
  | succ t ih =>
      have hexp : 2 * Nat.succ t = 2 * t + 2 := by omega
      have hrepr : 2 ^ (2 * Nat.succ t) - 1 = 3 * 2 ^ (2 * t) + (2 ^ (2 * t) - 1) := by
        rw [hexp, pow_add]
        norm_num
        omega
      rw [hrepr]
      exact dvd_add (dvd_mul_of_dvd_left (by norm_num : 3 ∣ 3) _) ih

lemma three_dvd_two_pow_odd_add_one (t : Nat) : 3 ∣ 2 ^ (2 * t + 1) + 1 := by
  induction t with
  | zero =>
      norm_num
  | succ t ih =>
      have hexp : 2 * Nat.succ t + 1 = (2 * t + 1) + 2 := by omega
      have hrepr : 2 ^ (2 * Nat.succ t + 1) + 1 =
          3 * 2 ^ (2 * t + 1) + (2 ^ (2 * t + 1) + 1) := by
        rw [hexp, pow_add]
        norm_num
        omega
      rw [hrepr]
      exact dvd_add (dvd_mul_of_dvd_left (by norm_num : 3 ∣ 3) _) ih

lemma succ_prop {n d : Nat} (h : SuccessorDivisorOrPrime n) (hd : 0 < d)
    (hdvd : d ∣ n) : d + 1 ∣ n ∨ Nat.Prime (d + 1) :=
  h.2 hd hdvd

lemma not_eight_dvd_of_odd_part_lt_nine {k m : Nat}
    (h : SuccessorDivisorOrPrime (2 ^ k * m)) (hm : Odd m) (hsmall : m < 9) :
    ¬ 8 ∣ 2 ^ k * m := by
  intro h8dvd
  have hcase := succ_prop h (d := 8) (by norm_num) h8dvd
  have h9odd : Odd 9 := by decide
  have h9notprime : ¬ Nat.Prime 9 := by norm_num
  rcases hcase with h9dvd | h9prime
  · exact odd_not_dvd_of_lt_odd_part hm h9odd hsmall h9dvd
  · exact h9notprime h9prime

lemma power_of_two_case {k : Nat} (h : SuccessorDivisorOrPrime (2 ^ k)) : k ≤ 2 := by
  by_contra hk
  have hk3 : 3 ≤ k := by omega
  have h8pow : 8 ∣ 2 ^ k := by
    have hpow : 2 ^ 3 ∣ 2 ^ k :=
      (Nat.pow_dvd_pow_iff_le_right (by norm_num : 1 < 2)).2 hk3
    simpa using hpow
  have h8dvd : 8 ∣ 2 ^ k * 1 := by
    simpa using dvd_mul_of_dvd_right h8pow 1
  have hsmall : 1 < 9 := by norm_num
  exact not_eight_dvd_of_odd_part_lt_nine (k := k) (m := 1) (by simpa using h)
    (by simp : Odd 1) hsmall h8dvd

lemma odd_part_succ_is_two_pow {k m : Nat} (h : SuccessorDivisorOrPrime (2 ^ k * m))
    (hm : Odd m) (hm1 : m ≠ 1) : ∃ b ≤ k, m + 1 = 2 ^ b := by
  have hmpos : 0 < m := hm.pos
  have hmgt1 : 1 < m := by omega
  have hmdiv : m ∣ 2 ^ k * m := by
    exact dvd_mul_of_dvd_right dvd_rfl (2 ^ k)
  have hm1dvd_or_prime := succ_prop h hmpos hmdiv
  have hm1dvd : m + 1 ∣ 2 ^ k * m := by
    exact hm1dvd_or_prime.resolve_right (succ_of_odd_not_prime hm hmgt1)
  have hcop : Nat.Coprime (m + 1) m := by
    exact (Nat.coprime_self_add_left (m := m) (n := 1)).2 (by simp)
  have hm1dvdpow : m + 1 ∣ 2 ^ k := by
    exact hcop.dvd_of_dvd_mul_right hm1dvd
  exact (Nat.dvd_prime_pow Nat.prime_two).1 hm1dvdpow

lemma odd_part_three_case {k : Nat} (h : SuccessorDivisorOrPrime (2 ^ k * 3)) : k = 2 := by
  have hfour := succ_prop h (d := 3) (by norm_num) (by
    exact dvd_mul_of_dvd_right (by norm_num : 3 ∣ 3) (2 ^ k))
  have hfourprime : ¬ Nat.Prime 4 := by norm_num
  have hfourdvd : 4 ∣ 2 ^ k * 3 := hfour.resolve_right hfourprime
  have hkge2 : 2 ≤ k := by
    have hpow : 4 ∣ 2 ^ k := by
      exact (by simpa using (by
        exact (by
          have hcop : Nat.Coprime 4 3 := by norm_num
          exact hcop.dvd_of_dvd_mul_right hfourdvd) : 4 ∣ 2 ^ k))
    simpa [show 4 = 2 ^ 2 by norm_num] using
      (Nat.pow_dvd_pow_iff_le_right (by norm_num : 1 < 2)).1 hpow
  have hkle2 : k ≤ 2 := by
    by_contra hk
    have hk3 : 3 ≤ k := by omega
    have h8pow : 8 ∣ 2 ^ k := by
      have hpow : 2 ^ 3 ∣ 2 ^ k :=
        (Nat.pow_dvd_pow_iff_le_right (by norm_num : 1 < 2)).2 hk3
      simpa using hpow
    have h8dvd : 8 ∣ 2 ^ k * 3 := by
      simpa [Nat.mul_comm] using dvd_mul_of_dvd_right h8pow 3
    have hsmall : 3 < 9 := by norm_num
    exact not_eight_dvd_of_odd_part_lt_nine (k := k) (m := 3) h (by decide) hsmall h8dvd
  omega

lemma odd_exponent_case_impossible {k m t : Nat}
    (h : SuccessorDivisorOrPrime (2 ^ k * m)) (hm : Odd m) (hm1 : m ≠ 1)
    (hpow : m + 1 = 2 ^ (2 * t + 1)) (hble : 2 * t + 1 ≤ k) : False := by
  have hmgt1 : 1 < m := by omega
  have htpos : 0 < t := by
    by_contra ht
    have ht0 : t = 0 := by omega
    rw [ht0] at hpow
    omega
  have hdivpow : 2 ^ (2 * t + 1) ∣ 2 ^ k := by
    exact (Nat.pow_dvd_pow_iff_le_right (by norm_num : 1 < 2)).2 hble
  have hdvd : 2 ^ (2 * t + 1) ∣ 2 ^ k * m := by
    simpa [Nat.mul_comm] using dvd_mul_of_dvd_right hdivpow m
  have hcase := succ_prop h (d := 2 ^ (2 * t + 1)) (pow_pos (by norm_num) _) hdvd
  have huodd : Odd (2 ^ (2 * t + 1) + 1) := by
    have heven : Even (2 ^ (2 * t + 1)) := by
      exact (by decide : Even 2).pow_of_ne_zero (by omega)
    simpa [Nat.add_comm] using heven.add_odd (by decide : Odd 1)
  have hnotdvd : ¬ 2 ^ (2 * t + 1) + 1 ∣ 2 ^ k * m := by
    have hlt : m < 2 ^ (2 * t + 1) + 1 := by omega
    exact odd_not_dvd_of_lt_odd_part hm huodd hlt
  have hnotprime : ¬ Nat.Prime (2 ^ (2 * t + 1) + 1) := by
    intro hprime
    have h3dvd : 3 ∣ 2 ^ (2 * t + 1) + 1 := three_dvd_two_pow_odd_add_one t
    have h3eq : 3 = 2 ^ (2 * t + 1) + 1 :=
      (Nat.prime_dvd_prime_iff_eq (by norm_num : Nat.Prime 3) hprime).1 h3dvd
    omega
  exact hnotprime (hcase.resolve_left hnotdvd)

lemma odd_factor_of_even_successor {c : Nat} (hc : 0 < c) :
    2 ^ (c - 1) + 1 ∣ 2 ^ c + 2 := by
  refine ⟨2, ?_⟩
  have hc' : (c - 1) + 1 = c := by omega
  calc
    2 ^ c + 2 = 2 ^ c + 2 := rfl
    _ = 2 ^ ((c - 1) + 1) + 2 := by rw [hc']
    _ = 2 ^ (c - 1) * 2 + 2 := by rw [pow_succ]
    _ = 2 * (2 ^ (c - 1) + 1) := by nlinarith
    _ = (2 ^ (c - 1) + 1) * 2 := by ring

lemma succ_mersenne_divisor {c m : Nat} (hpow : m + 1 = 2 ^ (2 * c)) :
    2 ^ c + 1 ∣ m := by
  let u := 2 ^ c - 1
  refine ⟨u, ?_⟩
  have hpos : 0 < 2 ^ c := by exact pow_pos (by norm_num) c
  have hu : u + 1 = 2 ^ c := by
    dsimp [u]
    exact Nat.sub_add_cancel (Nat.succ_le_of_lt hpos)
  exact Nat.add_right_cancel <| calc
    m + 1 = 2 ^ (2 * c) := hpow
    _ = 2 ^ (c + c) := by simp [two_mul]
    _ = 2 ^ c * 2 ^ c := by rw [pow_add]
    _ = (2 ^ c + 1) * u + 1 := by nlinarith [hu]

lemma mersenne_mod_three_repr {c m : Nat} (hc : 0 < c) (hpow : m + 1 = 2 ^ (2 * c)) :
    m = (2 ^ (c - 1) + 1) * (2 ^ (c + 1) - 4) + 3 := by
  let a := 2 ^ (c - 1)
  let v := 2 ^ (c + 1) - 4
  have hc' : (c - 1) + 1 = c := by omega
  have ha : 2 ^ c = 2 * a := by
    calc
      2 ^ c = 2 ^ c := rfl
      _ = 2 ^ ((c - 1) + 1) := by rw [hc']
      _ = 2 ^ (c - 1) * 2 := by rw [pow_succ]
      _ = 2 * a := by dsimp [a]; ring
  have h4le : 4 ≤ 2 ^ (c + 1) := by
    calc
      4 = 2 ^ 2 := by norm_num
      _ ≤ 2 ^ (c + 1) := by
        exact Nat.pow_le_pow_right (by decide : 1 ≤ 2) (by omega)
  have hv : v + 4 = 4 * a := by
    calc
      v + 4 = 2 ^ (c + 1) := by
        dsimp [v]
        exact Nat.sub_add_cancel h4le
      _ = 2 ^ (c + 1) := rfl
      _ = 2 ^ ((c - 1) + 2) := by
        congr 1
        omega
      _ = 2 ^ (c - 1) * 2 ^ 2 := by rw [pow_add]
      _ = 4 * a := by dsimp [a]; ring
  exact Nat.add_right_cancel <| calc
    m + 1 = 2 ^ (2 * c) := hpow
    _ = 2 ^ (c + c) := by simp [two_mul]
    _ = 2 ^ c * 2 ^ c := by rw [pow_add]
    _ = (2 * a) * (2 * a) := by rw [ha]
    _ = ((a + 1) * v + 3) + 1 := by nlinarith [hv]
    _ = ((2 ^ (c - 1) + 1) * (2 ^ (c + 1) - 4) + 3) + 1 := by
      dsimp [a, v]

lemma even_exponent_reduction {k m c : Nat}
    (h : SuccessorDivisorOrPrime (2 ^ k * m)) (_hm : Odd m) (hc2 : 2 ≤ c)
    (hpow : m + 1 = 2 ^ (2 * c)) (_hcle : 2 * c ≤ k) : c = 2 := by
  have hcpos : 0 < c := by omega
  have hdvdm : 2 ^ c + 1 ∣ m := succ_mersenne_divisor hpow
  have hdvdn : 2 ^ c + 1 ∣ 2 ^ k * m := by
    exact dvd_mul_of_dvd_right hdvdm (2 ^ k)
  have hcase := succ_prop h (d := 2 ^ c + 1) (by positivity) hdvdn
  have hnotprime : ¬ Nat.Prime (2 ^ c + 2) := by
    have heven : Even (2 ^ c + 2) := by
      have hpoweven : Even (2 ^ c) := by
        exact (by decide : Even 2).pow_of_ne_zero (by omega)
      exact hpoweven.add (by decide : Even 2)
    have hgt2 : 2 < 2 ^ c + 2 := by
      have hc1 : 1 ≤ c := by omega
      have : 4 ≤ 2 ^ c + 2 := by
        have hpowge : 2 ≤ 2 ^ c := by
          calc
            2 = 2 ^ 1 := by norm_num
            _ ≤ 2 ^ c := by
              exact Nat.pow_le_pow_right (by decide : 1 ≤ 2) hc1
        omega
      omega
    exact not_prime_of_even_gt_two heven hgt2
  have hsuccdvd : 2 ^ c + 2 ∣ 2 ^ k * m := hcase.resolve_right hnotprime
  have huodd : Odd (2 ^ (c - 1) + 1) := by
    have heven : Even (2 ^ (c - 1)) := by
      exact (by decide : Even 2).pow_of_ne_zero (by omega)
    simpa [Nat.add_comm] using heven.add_odd (by decide : Odd 1)
  have hudvdn : 2 ^ (c - 1) + 1 ∣ 2 ^ k * m := by
    exact dvd_trans (odd_factor_of_even_successor hcpos) hsuccdvd
  have hudvdm : 2 ^ (c - 1) + 1 ∣ m := odd_dvd_odd_part huodd hudvdn
  have hu3 : 2 ^ (c - 1) + 1 ∣ 3 := by
    rw [mersenne_mod_three_repr hcpos hpow] at hudvdm
    have humul : 2 ^ (c - 1) + 1 ∣ (2 ^ (c - 1) + 1) * (2 ^ (c + 1) - 4) :=
      dvd_mul_of_dvd_left dvd_rfl _
    have hu3' :
        2 ^ (c - 1) + 1 ∣
          ((2 ^ (c - 1) + 1) * (2 ^ (c + 1) - 4) + 3) -
            ((2 ^ (c - 1) + 1) * (2 ^ (c + 1) - 4)) := Nat.dvd_sub hudvdm humul
    simpa using hu3'
  have hu_le_3 : 2 ^ (c - 1) + 1 ≤ 3 := Nat.le_of_dvd (by norm_num) hu3
  have hc_le_2 : c ≤ 2 := by
    by_contra hcgt
    have hc3 : 3 ≤ c := by omega
    have hpowge : 4 ≤ 2 ^ (c - 1) := by
      calc
        4 = 2 ^ 2 := by norm_num
        _ ≤ 2 ^ (c - 1) := by
          exact Nat.pow_le_pow_right (by decide : 1 ≤ 2) (by omega)
    have hu_ge_5 : 5 ≤ 2 ^ (c - 1) + 1 := by omega
    omega
  omega

lemma fourth_power_odd_part_impossible {k : Nat}
    (h : SuccessorDivisorOrPrime (2 ^ k * 15)) (hk4 : 4 ≤ k) : False := by
  have h24dvd : 24 ∣ 2 ^ k * 15 := by
    refine ⟨5 * 2 ^ (k - 3), ?_⟩
    have hk' : (k - 3) + 3 = k := by omega
    calc
      2 ^ k * 15 = 2 ^ k * 15 := rfl
      _ = 2 ^ ((k - 3) + 3) * 15 := by rw [hk']
      _ = (2 ^ (k - 3) * 2 ^ 3) * 15 := by rw [pow_add]
      _ = (2 ^ (k - 3) * 8) * 15 := by norm_num
      _ = 24 * (5 * 2 ^ (k - 3)) := by ring
  have h25dvd : 25 ∣ 2 ^ k * 15 := by
    have hcase := succ_prop h (d := 24) (by norm_num) h24dvd
    exact hcase.resolve_right (by norm_num)
  exact odd_not_dvd_of_lt_odd_part (k := k) (m := 15) (by decide : Odd 15)
    (by decide : Odd 25) (by norm_num) h25dvd

theorem successor_divisor_or_prime_classification {n : Nat} :
    SuccessorDivisorOrPrime n ↔ n = 1 ∨ n = 2 ∨ n = 4 ∨ n = 12 := by
  refine ⟨?_, ?_⟩
  · intro h
    have hn0 : n ≠ 0 := by exact Nat.ne_of_gt h.1
    rcases Nat.exists_eq_two_pow_mul_odd hn0 with ⟨k, m, hm, rfl⟩
    by_cases hm1 : m = 1
    · have hk : k ≤ 2 := power_of_two_case (by simpa [hm1] using h)
      subst m
      have hk_cases : k = 0 ∨ k = 1 ∨ k = 2 := by omega
      rcases hk_cases with rfl | rfl | rfl <;> simp
    · rcases odd_part_succ_is_two_pow h hm hm1 with ⟨b, hble, hbpow⟩
      have hbeven : Even b := by
        by_contra hbodd
        rcases Nat.not_even_iff_odd.mp hbodd with ⟨t, rfl⟩
        exact odd_exponent_case_impossible h hm hm1 hbpow hble
      rcases hbeven with ⟨c, rfl⟩
      by_cases hc1 : c = 1
      · subst hc1
        have hmthree : m = 3 := by
          have := hbpow
          omega
        have hk : k = 2 := by
          simpa [hmthree] using odd_part_three_case (k := k) (by simpa [hmthree] using h)
        subst m
        subst hk
        simp
      · have hcne0 : c ≠ 0 := by
          intro hc0
          rw [hc0] at hbpow
          have hmpos : 0 < m := hm.pos
          omega
        have hc2 : 2 ≤ c := by omega
        have hbpow' : m + 1 = 2 ^ (2 * c) := by simpa [two_mul] using hbpow
        have hc_eq_two : c = 2 := even_exponent_reduction h hm hc2 hbpow' (by omega)
        subst hc_eq_two
        have hmfifteen : m = 15 := by
          have := hbpow
          omega
        have hk4 : 4 ≤ k := by omega
        exact False.elim <| fourth_power_odd_part_impossible
          (k := k) (by simpa [hmfifteen] using h) hk4
  · rintro (rfl | rfl | rfl | rfl)
    · refine ⟨by norm_num, ?_⟩
      intro d hd hdvd
      have hd1 : d = 1 := by
        have hdle : d ≤ 1 := Nat.le_of_dvd (by norm_num) hdvd
        omega
      subst hd1
      right
      norm_num
    · refine ⟨by norm_num, ?_⟩
      intro d hd hdvd
      have hdle : d ≤ 2 := Nat.le_of_dvd (by norm_num) hdvd
      have hd_cases : d = 1 ∨ d = 2 := by omega
      rcases hd_cases with rfl | rfl
      · left
        norm_num
      · right
        norm_num
    · refine ⟨by norm_num, ?_⟩
      intro d hd hdvd
      have hdle : d ≤ 4 := Nat.le_of_dvd (by norm_num) hdvd
      have hd_cases : d = 1 ∨ d = 2 ∨ d = 3 ∨ d = 4 := by omega
      rcases hd_cases with rfl | rfl | rfl | rfl
      · left
        norm_num
      · right
        norm_num
      · exfalso
        norm_num at hdvd
      · right
        norm_num
    · refine ⟨by norm_num, ?_⟩
      intro d hd hdvd
      have hdle : d ≤ 12 := Nat.le_of_dvd (by norm_num) hdvd
      have hd_cases :
          d = 1 ∨ d = 2 ∨ d = 3 ∨ d = 4 ∨ d = 5 ∨ d = 6 ∨
            d = 7 ∨ d = 8 ∨ d = 9 ∨ d = 10 ∨ d = 11 ∨ d = 12 := by
        omega
      rcases hd_cases with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl
      · left
        norm_num
      · right
        norm_num
      · left
        norm_num
      · right
        norm_num
      · exfalso
        norm_num at hdvd
      · right
        norm_num
      · exfalso
        norm_num at hdvd
      · exfalso
        norm_num at hdvd
      · exfalso
        norm_num at hdvd
      · exfalso
        norm_num at hdvd
      · exfalso
        norm_num at hdvd
      · right
        norm_num

end Biblioteca.Demonstrations
