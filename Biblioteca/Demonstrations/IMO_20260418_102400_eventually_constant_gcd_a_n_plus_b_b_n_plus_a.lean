import Mathlib.Data.Nat.Totient
import Mathlib.Data.Nat.Factorization.Basic
import Mathlib.FieldTheory.Finite.Basic
import Mathlib.Tactic

namespace Biblioteca.Demonstrations

/-- The olympiad property from IMO 2024 Shortlist N4. -/
def EventuallyConstantGCD (a b : Nat) : Prop :=
  0 < a ∧ 0 < b ∧ ∃ g N : Nat, 0 < g ∧
    ∀ n ≥ N, Nat.gcd (a ^ n + b) (b ^ n + a) = g

lemma pow_succ_modEq_self {a g : Nat} (h : a ^ 2 ≡ a [MOD g]) :
    ∀ m : Nat, a ^ (m + 1) ≡ a [MOD g]
  | 0 => by simpa using (Nat.ModEq.refl a : a ≡ a [MOD g])
  | m + 1 => by
      have hm := pow_succ_modEq_self h m
      have hmul : a ^ (m + 1) * a ≡ a * a [MOD g] := by
        simpa [pow_succ, Nat.mul_comm, Nat.mul_left_comm, Nat.mul_assoc] using
          hm.mul (Nat.ModEq.refl a)
      have hsquare : a * a ≡ a [MOD g] := by simpa [pow_two] using h
      simpa [pow_two] using hmul.trans hsquare

lemma dvd_right_mul_pred_of_dvd_pow_add {a b g n : Nat}
    (h₁ : g ∣ a ^ n + b) (h₂ : g ∣ a ^ (n + 1) + b) :
    g ∣ b * (a - 1) := by
  rcases h₁ with ⟨u, hu⟩
  rcases h₂ with ⟨v, hv⟩
  refine ⟨a * u - v, ?_⟩
  have hcomb1 : b * (a - 1) = a * (a ^ n + b) - (a ^ (n + 1) + b) := by
    calc
      b * (a - 1) = a * b - b := by
        rw [Nat.mul_comm, Nat.mul_sub_right_distrib, one_mul]
      _ = (a ^ (n + 1) + a * b) - (a ^ (n + 1) + b) := by
        rw [Nat.add_sub_add_left]
      _ = a * (a ^ n + b) - (a ^ (n + 1) + b) := by
        rw [pow_succ, Nat.mul_add, Nat.mul_comm a (a ^ n), Nat.add_comm]
  have hcomb2 : a * (a ^ n + b) - (a ^ (n + 1) + b) = g * (a * u - v) := by
    rw [hu, hv]
    have hagu : a * (g * u) = g * (a * u) := by ac_rfl
    rw [hagu, Nat.mul_sub_left_distrib]
  exact hcomb1.trans hcomb2

lemma mul_pred_add_eq_mul {a b : Nat} (hb : 0 < b) : a * (b - 1) + a = a * b := by
  calc
    a * (b - 1) + a = a * (b - 1) + a * 1 := by simp
    _ = a * ((b - 1) + 1) := by rw [← Nat.left_distrib]
    _ = a * b := by rw [Nat.sub_add_cancel hb]

lemma eventually_constant_gcd_eq_one_one {a b : Nat} (h : EventuallyConstantGCD a b) :
    a = 1 ∧ b = 1 := by
  rcases h with ⟨ha, hb, g, N, hg, hconst⟩
  let N₀ := max N 1
  have hN₀ : N ≤ N₀ := le_max_left _ _
  have hN₀one : 1 ≤ N₀ := le_max_right _ _
  have hgN₀ : Nat.gcd (a ^ N₀ + b) (b ^ N₀ + a) = g := hconst N₀ hN₀
  have hgN₀s : Nat.gcd (a ^ (N₀ + 1) + b) (b ^ (N₀ + 1) + a) = g := hconst (N₀ + 1) (by omega)
  have hgaN₀ : g ∣ a ^ N₀ + b := by simpa [hgN₀] using Nat.gcd_dvd_left (a ^ N₀ + b) (b ^ N₀ + a)
  have hgbN₀ : g ∣ b ^ N₀ + a := by simpa [hgN₀] using Nat.gcd_dvd_right (a ^ N₀ + b) (b ^ N₀ + a)
  have hgaN₀s : g ∣ a ^ (N₀ + 1) + b := by
    simpa [hgN₀s] using Nat.gcd_dvd_left (a ^ (N₀ + 1) + b) (b ^ (N₀ + 1) + a)
  have hgbN₀s : g ∣ b ^ (N₀ + 1) + a := by
    simpa [hgN₀s] using Nat.gcd_dvd_right (a ^ (N₀ + 1) + b) (b ^ (N₀ + 1) + a)
  have hgbpred : g ∣ b * (a - 1) := dvd_right_mul_pred_of_dvd_pow_add hgaN₀ hgaN₀s
  have hgapred : g ∣ a * (b - 1) := dvd_right_mul_pred_of_dvd_pow_add hgbN₀ hgbN₀s
  have hab_mod : a ≡ b [MOD g] := by
    have hab_to_a : a * b ≡ a [MOD g] := by
      have hmod : a * (b - 1) ≡ 0 [MOD g] := Nat.modEq_zero_iff_dvd.mpr hgapred
      have := hmod.add_right a
      simpa [mul_pred_add_eq_mul hb, Nat.add_comm] using this
    have hab_to_b : a * b ≡ b [MOD g] := by
      have hmod : b * (a - 1) ≡ 0 [MOD g] := Nat.modEq_zero_iff_dvd.mpr hgbpred
      have := hmod.add_right b
      simpa [Nat.mul_comm, mul_pred_add_eq_mul ha, Nat.add_comm] using this
    exact hab_to_a.symm.trans hab_to_b
  have haa_mod : a ^ 2 ≡ a [MOD g] := by
    have : a * a ≡ a * b [MOD g] := hab_mod.mul_left a
    have hab_to_a : a * b ≡ a [MOD g] := by
      have hmod : a * (b - 1) ≡ 0 [MOD g] := Nat.modEq_zero_iff_dvd.mpr hgapred
      have := hmod.add_right a
      simpa [mul_pred_add_eq_mul hb, Nat.add_comm] using this
    simpa [pow_two] using this.trans hab_to_a
  have hpowN₀ : a ^ N₀ ≡ a [MOD g] := by
    have hN₀eq : (N₀ - 1) + 1 = N₀ := by omega
    simpa [hN₀eq] using pow_succ_modEq_self haa_mod (N₀ - 1)
  have hsum_mod : a + b ≡ 0 [MOD g] := by
    have hmod : a ^ N₀ + b ≡ 0 [MOD g] := Nat.modEq_zero_iff_dvd.mpr hgaN₀
    exact (hpowN₀.add_right b).symm.trans hmod
  have htwoa : g ∣ a + a := by
    have hmod : a + a ≡ 0 [MOD g] := ((Nat.ModEq.refl a).add hab_mod).trans hsum_mod
    exact Nat.modEq_zero_iff_dvd.mp hmod
  have htwob : g ∣ b + b := by
    have hmod : b + b ≡ 0 [MOD g] := ((hab_mod.symm).add (Nat.ModEq.refl b)).trans hsum_mod
    exact Nat.modEq_zero_iff_dvd.mp hmod
  let d := Nat.gcd a b
  have hdpos : 0 < d := Nat.gcd_pos_of_pos_left b ha
  have hg_dvd_two_d : g ∣ 2 * d := by
    have : g ∣ Nat.gcd (a + a) (b + b) := Nat.dvd_gcd htwoa htwob
    have h' : g ∣ Nat.gcd (2 * a) (2 * b) := by simpa [two_mul] using this
    have h'' : g ∣ 2 * Nat.gcd a b := by simpa [Nat.gcd_mul_left] using h'
    simpa [d] using h''
  have hd_dvd_g : d ∣ g := by
    have hda : d ∣ a := Nat.gcd_dvd_left a b
    have hdb : d ∣ b := Nat.gcd_dvd_right a b
    have hN₀ne : N₀ ≠ 0 := by omega
    have hleft : d ∣ a ^ N₀ + b := dvd_add (dvd_pow hda hN₀ne) hdb
    have hright : d ∣ b ^ N₀ + a := dvd_add (dvd_pow hdb hN₀ne) hda
    have : d ∣ Nat.gcd (a ^ N₀ + b) (b ^ N₀ + a) := Nat.dvd_gcd hleft hright
    simpa [hgN₀] using this
  obtain ⟨e, he0⟩ := exists_eq_mul_left_of_dvd hd_dvd_g
  have he : g = d * e := by simpa [Nat.mul_comm] using he0
  have he_dvd_two : e ∣ 2 := by
    have : d * e ∣ d * 2 := by
      simpa [he, Nat.mul_comm, Nat.mul_left_comm, Nat.mul_assoc] using hg_dvd_two_d
    exact Nat.dvd_of_mul_dvd_mul_left hdpos this
  have he_le_two : e ≤ 2 := Nat.le_of_dvd (by norm_num) he_dvd_two
  let x := a / d
  let y := b / d
  have hax : a = d * x := by
    dsimp [x]
    rw [Nat.mul_comm, Nat.div_mul_cancel (Nat.gcd_dvd_left a b)]
  have hby : b = d * y := by
    dsimp [y]
    rw [Nat.mul_comm, Nat.div_mul_cancel (Nat.gcd_dvd_right a b)]
  have hxpos : 0 < x := by
    apply Nat.pos_of_ne_zero
    intro hx0
    have : a = 0 := by simp [hax, hx0]
    omega
  have hypos : 0 < y := by
    apply Nat.pos_of_ne_zero
    intro hy0
    have : b = 0 := by simp [hby, hy0]
    omega
  have hxy : Nat.Coprime x y := by
    rw [Nat.coprime_iff_gcd_eq_one]
    symm
    apply Nat.gcd_greatest
    · simp
    · simp
    · intro c hcx hcy
      have hca : d * c ∣ a := by
        rw [hax]
        rcases hcx with ⟨t, ht⟩
        rw [ht]
        simpa [Nat.mul_assoc, Nat.mul_left_comm, Nat.mul_comm] using
          (dvd_mul_right (d * c) t)
      have hcb : d * c ∣ b := by
        rw [hby]
        rcases hcy with ⟨t, ht⟩
        rw [ht]
        simpa [Nat.mul_assoc, Nat.mul_left_comm, Nat.mul_comm] using
          (dvd_mul_right (d * c) t)
      have hcd : d * c ∣ d := by
        simpa [d] using Nat.dvd_gcd hca hcb
      exact Nat.dvd_of_mul_dvd_mul_left hdpos <|
        by simpa [Nat.mul_comm, Nat.mul_left_comm, Nat.mul_assoc] using hcd
  have hnorm_eq :
      ∀ n ≥ N₀, Nat.gcd (d ^ (n - 1) * x ^ n + y) (d ^ (n - 1) * y ^ n + x) = e := by
    intro n hn
    have hnpos : 0 < n := lt_of_lt_of_le hN₀one hn
    have hn_pred : n - 1 + 1 = n := Nat.sub_add_cancel (Nat.succ_le_of_lt hnpos)
    have hleft :
        a ^ n + b = d * (d ^ (n - 1) * x ^ n + y) := by
      calc
        a ^ n + b = d ^ n * x ^ n + d * y := by rw [hax, hby, mul_pow]
        _ = d ^ (n - 1 + 1) * x ^ n + d * y := by rw [hn_pred]
        _ = d ^ (n - 1) * d * x ^ n + d * y := by rw [pow_succ]
        _ = d * d ^ (n - 1) * x ^ n + d * y := by ring
        _ = d * (d ^ (n - 1) * x ^ n) + d * y := by ring
        _ = d * (d ^ (n - 1) * x ^ n + y) := by rw [Nat.mul_add]
    have hright :
        b ^ n + a = d * (d ^ (n - 1) * y ^ n + x) := by
      calc
        b ^ n + a = d ^ n * y ^ n + d * x := by rw [hax, hby, mul_pow]
        _ = d ^ (n - 1 + 1) * y ^ n + d * x := by rw [hn_pred]
        _ = d ^ (n - 1) * d * y ^ n + d * x := by rw [pow_succ]
        _ = d * d ^ (n - 1) * y ^ n + d * x := by ring
        _ = d * (d ^ (n - 1) * y ^ n) + d * x := by ring
        _ = d * (d ^ (n - 1) * y ^ n + x) := by rw [Nat.mul_add]
    have hgcd :
        Nat.gcd (a ^ n + b) (b ^ n + a) =
          d * Nat.gcd (d ^ (n - 1) * x ^ n + y) (d ^ (n - 1) * y ^ n + x) := by
      rw [hleft, hright, Nat.gcd_mul_left]
    have hconstn := hconst n (le_trans hN₀ hn)
    exact Nat.eq_of_mul_eq_mul_left hdpos (hgcd.symm.trans (hconstn.trans he))
  let K := d * d * x * y + 1
  have hKpos : 0 < K := by
    dsimp [K]
    positivity
  have hdK : Nat.Coprime d K := by
    rw [Nat.coprime_comm]
    have htmp : Nat.Coprime (1 + d * (d * x * y)) d :=
      (Nat.coprime_add_mul_left_left 1 d (d * x * y)).2 (by simp)
    dsimp [K]
    convert htmp using 1
    ac_rfl
  have hxK : Nat.Coprime x K := by
    dsimp [K]
    have htmp : Nat.Coprime (1 + x * (d * d * y)) x :=
      (Nat.coprime_add_mul_left_left 1 x (d * d * y)).2 (by simp)
    simpa [Nat.mul_assoc, Nat.mul_left_comm, Nat.mul_comm, Nat.add_comm] using htmp.symm
  let n := K.totient * (N₀ + 1) - 1
  have htotpos : 0 < K.totient := Nat.totient_pos.mpr hKpos
  have hn_ge : N₀ ≤ n := by
    dsimp [n]
    have : N₀ + 1 ≤ K.totient * (N₀ + 1) := by
      exact Nat.le_mul_of_pos_left (N₀ + 1) htotpos
    omega
  have hn1 : n + 1 = K.totient * (N₀ + 1) := by
    dsimp [n]
    omega
  have hdpow : d ^ (n + 1) ≡ 1 [MOD K] := by
    have h := (Nat.ModEq.pow_totient hdK).pow (N₀ + 1)
    simpa [hn1, pow_mul] using h
  have hxpow : x ^ (n + 1) ≡ 1 [MOD K] := by
    have h := (Nat.ModEq.pow_totient hxK).pow (N₀ + 1)
    simpa [hn1, pow_mul] using h
  have hKdvd_left : K ∣ d ^ (n - 1) * x ^ n + y := by
    have hnpos : 0 < n := by omega
    have hdn2 : d ^ (n + 1) = d * d * d ^ (n - 1) := by
      have hn2 : n + 1 = (n - 1) + 2 := by omega
      calc
        d ^ (n + 1) = d ^ ((n - 1) + 2) := by rw [hn2]
        _ = d ^ (n - 1) * d ^ 2 := by rw [pow_add]
        _ = d * d * d ^ (n - 1) := by rw [pow_two]; ring
    have hxn : x ^ (n + 1) = x * x ^ n := by rw [pow_succ, Nat.mul_comm]
    have hcalc :
        d * d * x * (d ^ (n - 1) * x ^ n + y) =
          d ^ (n + 1) * x ^ (n + 1) + d * d * x * y := by
      calc
        d * d * x * (d ^ (n - 1) * x ^ n + y) =
            d * d * x * (d ^ (n - 1) * x ^ n) + d * d * x * y := by rw [Nat.mul_add]
        _ = d * d * d ^ (n - 1) * (x * x ^ n) + d * d * x * y := by ring
        _ = d ^ (n + 1) * x ^ (n + 1) + d * d * x * y := by rw [hdn2, hxn]
    have hmod0 : d ^ (n + 1) * x ^ (n + 1) + d * d * x * y ≡ 0 [MOD K] := by
      have hprod : d ^ (n + 1) * x ^ (n + 1) ≡ 1 [MOD K] := hdpow.mul hxpow
      have hadd := hprod.add_right (d * d * x * y)
      exact hadd.trans <|
        Nat.modEq_zero_iff_dvd.mpr <|
          by simp [K, Nat.add_comm]
    have hmul : K ∣ d * d * x * (d ^ (n - 1) * x ^ n + y) := by
      rw [hcalc]
      exact Nat.modEq_zero_iff_dvd.mp hmod0
    have h1 : K ∣ d * (d * (x * (d ^ (n - 1) * x ^ n + y))) := by
      simpa [Nat.mul_assoc, Nat.mul_left_comm, Nat.mul_comm] using hmul
    have h2 : K ∣ d * (x * (d ^ (n - 1) * x ^ n + y)) := (hdK.symm.dvd_mul_left).mp h1
    have h3 : K ∣ x * (d ^ (n - 1) * x ^ n + y) := (hdK.symm.dvd_mul_left).mp h2
    exact (hxK.symm.dvd_mul_left).mp h3
  have hKdvd_right : K ∣ d ^ (n - 1) * y ^ n + x := by
    have hnpos : 0 < n := by omega
    have hyK : Nat.Coprime y K := by
      dsimp [K]
      have htmp : Nat.Coprime (1 + y * (d * d * x)) y :=
        (Nat.coprime_add_mul_left_left 1 y (d * d * x)).2 (by simp)
      simpa [Nat.mul_assoc, Nat.mul_left_comm, Nat.mul_comm, Nat.add_comm] using htmp.symm
    have hdn2 : d ^ (n + 1) = d * d * d ^ (n - 1) := by
      have hn2 : n + 1 = (n - 1) + 2 := by omega
      calc
        d ^ (n + 1) = d ^ ((n - 1) + 2) := by rw [hn2]
        _ = d ^ (n - 1) * d ^ 2 := by rw [pow_add]
        _ = d * d * d ^ (n - 1) := by rw [pow_two]; ring
    have hyn : y ^ (n + 1) = y * y ^ n := by rw [pow_succ, Nat.mul_comm]
    have hypow : y ^ (n + 1) ≡ 1 [MOD K] := by
      have h := (Nat.ModEq.pow_totient hyK).pow (N₀ + 1)
      simpa [hn1, pow_mul] using h
    have hcalc :
        d * d * y * (d ^ (n - 1) * y ^ n + x) =
          d ^ (n + 1) * y ^ (n + 1) + d * d * x * y := by
      calc
        d * d * y * (d ^ (n - 1) * y ^ n + x) =
            d * d * y * (d ^ (n - 1) * y ^ n) + d * d * y * x := by rw [Nat.mul_add]
        _ = d * d * d ^ (n - 1) * (y * y ^ n) + d * d * x * y := by ring
        _ = d ^ (n + 1) * y ^ (n + 1) + d * d * x * y := by rw [hdn2, hyn]
    have hmod0 : d ^ (n + 1) * y ^ (n + 1) + d * d * x * y ≡ 0 [MOD K] := by
      have hprod : d ^ (n + 1) * y ^ (n + 1) ≡ 1 [MOD K] := hdpow.mul hypow
      have hadd := hprod.add_right (d * d * x * y)
      exact hadd.trans <|
        Nat.modEq_zero_iff_dvd.mpr <|
          by simp [K, Nat.add_comm]
    have hmul : K ∣ d * d * y * (d ^ (n - 1) * y ^ n + x) := by
      rw [hcalc]
      exact Nat.modEq_zero_iff_dvd.mp hmod0
    have h1 : K ∣ d * (d * (y * (d ^ (n - 1) * y ^ n + x))) := by
      simpa [Nat.mul_assoc, Nat.mul_left_comm, Nat.mul_comm] using hmul
    have h2 : K ∣ d * (y * (d ^ (n - 1) * y ^ n + x)) := (hdK.symm.dvd_mul_left).mp h1
    have h3 : K ∣ y * (d ^ (n - 1) * y ^ n + x) := (hdK.symm.dvd_mul_left).mp h2
    exact (hyK.symm.dvd_mul_left).mp h3
  have hnorm_at_n : Nat.gcd (d ^ (n - 1) * x ^ n + y) (d ^ (n - 1) * y ^ n + x) = e :=
    hnorm_eq n hn_ge
  have hKdvd_e : K ∣ e := by
    have : K ∣ Nat.gcd (d ^ (n - 1) * x ^ n + y) (d ^ (n - 1) * y ^ n + x) :=
      Nat.dvd_gcd hKdvd_left hKdvd_right
    simpa [hnorm_at_n] using this
  have hKle_two : K ≤ 2 := Nat.le_of_dvd (by norm_num) (dvd_trans hKdvd_e he_dvd_two)
  have hprod_eq_one : d * d * x * y = 1 := by
    have hprod_pos : 0 < d * d * x * y := by positivity
    dsimp [K] at hKle_two
    omega
  have hd_one : d = 1 := by
    apply Nat.dvd_one.mp
    refine ⟨d * x * y, ?_⟩
    simpa [Nat.mul_assoc, Nat.mul_left_comm, Nat.mul_comm] using hprod_eq_one.symm
  have hxy_eq_one : x * y = 1 := by
    simpa [hd_one] using hprod_eq_one
  have hx_one : x = 1 := by
    apply Nat.dvd_one.mp
    refine ⟨y, ?_⟩
    simpa [Nat.mul_comm] using hxy_eq_one.symm
  have hy_one : y = 1 := by
    apply Nat.dvd_one.mp
    refine ⟨x, ?_⟩
    simpa [Nat.mul_comm] using hxy_eq_one.symm
  constructor
  · rw [hax, hd_one, hx_one]
  · rw [hby, hd_one, hy_one]

theorem one_one_eventually_constant_gcd : EventuallyConstantGCD 1 1 := by
  refine ⟨by norm_num, by norm_num, 2, 1, by norm_num, ?_⟩
  intro n hn
  simp

theorem eventually_constant_gcd_classification {a b : Nat} :
    EventuallyConstantGCD a b ↔ a = 1 ∧ b = 1 := by
  constructor
  · exact eventually_constant_gcd_eq_one_one
  · rintro ⟨rfl, rfl⟩
    exact one_one_eventually_constant_gcd

end Biblioteca.Demonstrations
