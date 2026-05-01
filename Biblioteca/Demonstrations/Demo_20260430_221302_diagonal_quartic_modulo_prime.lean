import Mathlib.Data.ZMod.Basic
import Mathlib.Data.ZMod.Units
import Mathlib.GroupTheory.Coset.Card
import Mathlib.GroupTheory.SpecificGroups.Cyclic
import Mathlib.Tactic

namespace Biblioteca.Demonstrations

/-- The diagonal quartic form from the problem. -/
def diagonalQuarticForm {R : Type*} [Ring R] (x y z t : R) : R :=
  x ^ 4 - 2 * y ^ 4 + 3 * z ^ 4 + 4 * t ^ 4

lemma quotient_isCyclic {G : Type*} [Group G] [IsCyclic G] (H : Subgroup G) [H.Normal] :
    IsCyclic (G ⧸ H) := by
  rcases IsCyclic.exists_zpow_surjective (G := G) with ⟨g, hg⟩
  refine ⟨⟨QuotientGroup.mk g, ?_⟩⟩
  intro q
  refine Quotient.inductionOn' q ?_
  intro x
  rcases hg x with ⟨n, hn⟩
  refine ⟨n, ?_⟩
  rw [← hn]
  simp

lemma zmodSmallClassIntersect {n : ℕ} (hnpos : 0 < n) (hnle : n ≤ 4)
    (a r : ZMod n) (hr : 2 * r = 0) :
    (0 = a) ∨ (0 = r + 2 * a) ∨ (0 = r + a) ∨
    (2 * a = a) ∨ (2 * a = r + 2 * a) ∨ (2 * a = r + a) := by
  interval_cases n <;> decide +revert

lemma cyclic_small_intersect {G : Type*} [CommGroup G] [Fintype G] [IsCyclic G]
    (hcardle : Fintype.card G ≤ 4) (a r : G) (hr : r ^ 2 = 1) :
    (1 = a) ∨ (1 = r * a ^ 2) ∨ (1 = r * a) ∨
    (a ^ 2 = a) ∨ (a ^ 2 = r * a ^ 2) ∨ (a ^ 2 = r * a) := by
  classical
  obtain ⟨g, hg⟩ := IsCyclic.exists_generator (α := G)
  have hgo : orderOf g = Fintype.card G := by
    rw [← Nat.card_eq_fintype_card]
    exact orderOf_eq_card_of_forall_mem_zpowers hg
  rcases (Subgroup.mem_zpowers_iff.mp (hg a)) with ⟨ia, hia⟩
  rcases (Subgroup.mem_zpowers_iff.mp (hg r)) with ⟨ir, hir⟩
  have eq_of_zmod {m n' : ℤ}
      (hmn : (m : ZMod (Fintype.card G)) = (n' : ZMod (Fintype.card G))) :
      g ^ m = g ^ n' := by
    apply zpow_eq_zpow_iff_modEq.mpr
    have hmn' : m ≡ n' [ZMOD (Fintype.card G : ℕ)] :=
      (ZMod.intCast_eq_intCast_iff m n' (Fintype.card G)).mp hmn
    simpa [hgo] using hmn'
  have ha2 : a ^ 2 = g ^ (2 * ia) := by
    rw [← hia]
    calc
      (g ^ ia) ^ (2 : ℕ) = (g ^ ia) ^ (2 : ℤ) := by norm_num [zpow_ofNat]
      _ = g ^ (ia * 2) := (zpow_mul g ia 2).symm
      _ = g ^ (2 * ia) := by ring_nf
  have hleft2 : g ^ (ir + 2 * ia) = r * a ^ 2 := by
    rw [zpow_add, hir]
    rw [ha2]
  have hleft1 : g ^ (ir + ia) = r * a := by
    rw [zpow_add, hir, hia]
  have hrmod : (2 * (ir : ZMod (Fintype.card G)) = 0) := by
    have hpow : g ^ (2 * ir) = g ^ (0 : ℤ) := by
      calc
        g ^ (2 * ir) = g ^ (ir * 2) := by ring_nf
        _ = (g ^ ir) ^ (2 : ℤ) := zpow_mul g ir 2
        _ = r ^ (2 : ℤ) := by rw [hir]
        _ = 1 := by simpa [zpow_ofNat] using hr
        _ = g ^ (0 : ℤ) := by simp
    have hmodInt : (2 * ir) ≡ (0 : ℤ) [ZMOD (orderOf g)] :=
      zpow_eq_zpow_iff_modEq.mp hpow
    have hmodIntn : (2 * ir) ≡ (0 : ℤ) [ZMOD (Fintype.card G : ℕ)] := by
      simpa [hgo] using hmodInt
    rw [← Int.cast_ofNat, ← Int.cast_mul]
    simpa using
      (ZMod.intCast_eq_intCast_iff (2 * ir) 0 (Fintype.card G)).mpr hmodIntn
  have hnpos : 0 < Fintype.card G := Fintype.card_pos_iff.mpr ⟨1⟩
  have hcases := zmodSmallClassIntersect hnpos hcardle
    (ia : ZMod (Fintype.card G)) (ir : ZMod (Fintype.card G)) hrmod
  rcases hcases with h | h | h | h | h | h
  · left
    calc
      1 = g ^ (0 : ℤ) := by simp
      _ = g ^ ia := eq_of_zmod (by simpa using h)
      _ = a := hia
  · right; left
    calc
      1 = g ^ (0 : ℤ) := by simp
      _ = g ^ (ir + 2 * ia) := eq_of_zmod (by simpa using h)
      _ = r * a ^ 2 := hleft2
  · right; right; left
    calc
      1 = g ^ (0 : ℤ) := by simp
      _ = g ^ (ir + ia) := eq_of_zmod (by simpa using h)
      _ = r * a := hleft1
  · right; right; right; left
    calc
      a ^ 2 = g ^ (2 * ia) := ha2
      _ = g ^ ia := eq_of_zmod (by simpa using h)
      _ = a := hia
  · right; right; right; right; left
    calc
      a ^ 2 = g ^ (2 * ia) := ha2
      _ = g ^ (ir + 2 * ia) := eq_of_zmod (by simpa using h)
      _ = r * a ^ 2 := hleft2
  · right; right; right; right; right
    calc
      a ^ 2 = g ^ (2 * ia) := ha2
      _ = g ^ (ir + ia) := eq_of_zmod (by simpa using h)
      _ = r * a := hleft1

lemma fourthPowerQuotient_card_le_four {p : ℕ} [Fact p.Prime] :
    Fintype.card ((ZMod p)ˣ ⧸ (powMonoidHom 4 : (ZMod p)ˣ →* (ZMod p)ˣ).range) ≤ 4 := by
  classical
  let H : Subgroup (ZMod p)ˣ := (powMonoidHom 4 : (ZMod p)ˣ →* (ZMod p)ˣ).range
  let d := (p - 1).gcd 4
  have hGcardF : Fintype.card (ZMod p)ˣ = p - 1 := ZMod.card_units p
  have hHcardF : Fintype.card H = (p - 1) / d := by
    dsimp [H, d]
    rw [← Nat.card_eq_fintype_card, IsCyclic.card_powMonoidHom_range ((ZMod p)ˣ) 4,
      Nat.card_eq_fintype_card, hGcardF]
  have hmul0 := Subgroup.card_eq_card_quotient_mul_card_subgroup H
  have hmul' : p - 1 = Fintype.card ((ZMod p)ˣ ⧸ H) * ((p - 1) / d) := by
    rw [show Nat.card ((ZMod p)ˣ) = Fintype.card (ZMod p)ˣ from
      Nat.card_eq_fintype_card] at hmul0
    rw [show Nat.card ((ZMod p)ˣ ⧸ H) = Fintype.card ((ZMod p)ˣ ⧸ H) from
      Nat.card_eq_fintype_card] at hmul0
    rw [show Nat.card H = Fintype.card H from Nat.card_eq_fintype_card] at hmul0
    rw [hGcardF, hHcardF] at hmul0
    exact hmul0
  have hdvd : d ∣ p - 1 := Nat.gcd_dvd_left _ _
  have hp1pos : 0 < p - 1 := by
    have hpge2 : 2 ≤ p := (Fact.out : Nat.Prime p).two_le
    omega
  have hdpos : 0 < d := Nat.pos_of_dvd_of_pos hdvd hp1pos
  have hdivpos : 0 < (p - 1) / d := Nat.div_pos (Nat.le_of_dvd hp1pos hdvd) hdpos
  have hdeq : Fintype.card ((ZMod p)ˣ ⧸ H) = d := by
    apply Nat.eq_of_mul_eq_mul_right hdivpos
    calc
      Fintype.card ((ZMod p)ˣ ⧸ H) * ((p - 1) / d) = p - 1 := hmul'.symm
      _ = d * ((p - 1) / d) := by
        simpa [Nat.mul_comm] using (Nat.div_mul_cancel hdvd).symm
  have hdle : d ≤ 4 := Nat.gcd_le_right _ (by decide : 0 < 4)
  simpa [H] using (hdeq.trans_le hdle)

lemma scaleOfClassEq {p : ℕ} [Fact p.Prime]
    (L R : (ZMod p)ˣ)
    (h : (QuotientGroup.mk L :
        (ZMod p)ˣ ⧸ (powMonoidHom 4 : (ZMod p)ˣ →* (ZMod p)ˣ).range) =
      QuotientGroup.mk R) :
    ∃ w : ZMod p, (R : ZMod p) = (L : ZMod p) * w ^ 4 := by
  classical
  have hmem : L⁻¹ * R ∈ (powMonoidHom 4 : (ZMod p)ˣ →* (ZMod p)ˣ).range :=
    QuotientGroup.eq.mp h
  rcases hmem with ⟨u, hu⟩
  refine ⟨(u : ZMod p), ?_⟩
  have hunit : R = L * u ^ 4 := by
    have hu' : u ^ 4 = L⁻¹ * R := by simpa using hu
    calc
      R = 1 * R := by simp
      _ = (L * L⁻¹) * R := by simp
      _ = L * (L⁻¹ * R) := by group
      _ = L * u ^ 4 := by rw [← hu']
  exact congrArg (fun q : (ZMod p)ˣ => (q : ZMod p)) hunit

lemma solutionOfClassEq {p : ℕ} [Fact p.Prime]
    (L R : (ZMod p)ˣ) (x₀ z₀ y₀ t₀ : ZMod p)
    (hclass : (QuotientGroup.mk L :
        (ZMod p)ˣ ⧸ (powMonoidHom 4 : (ZMod p)ˣ →* (ZMod p)ˣ).range) =
      QuotientGroup.mk R)
    (hL : (L : ZMod p) = x₀ ^ 4 + 3 * z₀ ^ 4)
    (hR : (R : ZMod p) = 2 * y₀ ^ 4 - 4 * t₀ ^ 4)
    (hnon : y₀ ≠ 0 ∨ t₀ ≠ 0) :
    ∃ x y z t : ZMod p,
      (x ≠ 0 ∨ y ≠ 0 ∨ z ≠ 0 ∨ t ≠ 0) ∧ diagonalQuarticForm x y z t = 0 := by
  rcases scaleOfClassEq L R hclass with ⟨w, hw⟩
  refine ⟨w * x₀, y₀, w * z₀, t₀, ?_, ?_⟩
  · rcases hnon with hy | ht
    · exact Or.inr (Or.inl hy)
    · exact Or.inr (Or.inr (Or.inr ht))
  · dsimp [diagonalQuarticForm]
    have hmain : (w * x₀) ^ 4 + 3 * (w * z₀) ^ 4 = 2 * y₀ ^ 4 - 4 * t₀ ^ 4 := by
      calc
        (w * x₀) ^ 4 + 3 * (w * z₀) ^ 4 =
            (x₀ ^ 4 + 3 * z₀ ^ 4) * w ^ 4 := by ring
        _ = (L : ZMod p) * w ^ 4 := by rw [← hL]
        _ = (R : ZMod p) := hw.symm
        _ = 2 * y₀ ^ 4 - 4 * t₀ ^ 4 := hR
    linear_combination hmain

lemma zmod_ne_zero_of_prime_gt {p n : ℕ} [Fact p.Prime] (hnpos : 0 < n) (hnlt : n < p) :
    (n : ZMod p) ≠ 0 := by
  intro h
  have hdiv : p ∣ n := (ZMod.natCast_eq_zero_iff n p).mp h
  exact (not_le_of_gt hnlt) (Nat.le_of_dvd hnpos hdiv)

theorem exists_zmod_diagonalQuarticForm_zero (p : ℕ) [Fact p.Prime] :
    ∃ x y z t : ZMod p,
      (x ≠ 0 ∨ y ≠ 0 ∨ z ≠ 0 ∨ t ≠ 0) ∧ diagonalQuarticForm x y z t = 0 := by
  classical
  by_cases hp2 : p = 2
  · subst p
    refine ⟨0, 0, 0, 1, ?_, ?_⟩
    · norm_num
    · norm_num [diagonalQuarticForm]
      change ((4 : ℕ) : ZMod 2) = 0
      rw [ZMod.natCast_eq_zero_iff]
      norm_num
  by_cases hp3 : p = 3
  · subst p
    refine ⟨0, 0, 1, 0, ?_, ?_⟩
    · norm_num
    · norm_num [diagonalQuarticForm]
      change ((3 : ℕ) : ZMod 3) = 0
      rw [ZMod.natCast_eq_zero_iff]
  have hpgt3 : 3 < p := by
    have hpge2 : 2 ≤ p := (Fact.out : Nat.Prime p).two_le
    by_contra hle
    have hp_le3 : p ≤ 3 := Nat.le_of_not_gt hle
    interval_cases p <;> simp_all
  have h2 : (2 : ZMod p) ≠ 0 :=
    zmod_ne_zero_of_prime_gt (by decide) (lt_trans (by decide : 2 < 3) hpgt3)
  let u2 : (ZMod p)ˣ := Units.mk0 (2 : ZMod p) h2
  let um1 : (ZMod p)ˣ := -1
  let H : Subgroup (ZMod p)ˣ := (powMonoidHom 4 : (ZMod p)ˣ →* (ZMod p)ˣ).range
  let Q := (ZMod p)ˣ ⧸ H
  haveI : IsCyclic Q := quotient_isCyclic H
  have hQle : Fintype.card Q ≤ 4 := by
    dsimp [Q, H]
    exact fourthPowerQuotient_card_le_four
  have hQpos : 0 < Fintype.card Q := Fintype.card_pos_iff.mpr ⟨1⟩
  have hr : (QuotientGroup.mk um1 : Q) ^ 2 = 1 := by
    change QuotientGroup.mk (um1 ^ 2) = (1 : Q)
    simp [um1]
  have hclasses :
      (1 = (QuotientGroup.mk u2 : Q)) ∨
      (1 = QuotientGroup.mk um1 * (QuotientGroup.mk u2 : Q) ^ 2) ∨
      (1 = QuotientGroup.mk um1 * (QuotientGroup.mk u2 : Q)) ∨
      ((QuotientGroup.mk u2 : Q) ^ 2 = QuotientGroup.mk u2) ∨
      ((QuotientGroup.mk u2 : Q) ^ 2 =
        QuotientGroup.mk um1 * (QuotientGroup.mk u2 : Q) ^ 2) ∨
      ((QuotientGroup.mk u2 : Q) ^ 2 =
        QuotientGroup.mk um1 * (QuotientGroup.mk u2 : Q)) :=
    cyclic_small_intersect hQle (QuotientGroup.mk u2 : Q) (QuotientGroup.mk um1 : Q) hr
  rcases hclasses with h | h | h | h | h | h
  · exact solutionOfClassEq 1 u2 1 0 1 0 (by simpa [Q, H] using h) (by norm_num)
      (by norm_num [u2]) (Or.inl one_ne_zero)
  · exact solutionOfClassEq 1 (um1 * u2 ^ 2) 1 0 0 1 (by simpa [Q, H] using h)
      (by norm_num) (by norm_num [um1, u2]) (Or.inr one_ne_zero)
  · exact solutionOfClassEq 1 (um1 * u2) 1 0 1 1 (by simpa [Q, H] using h)
      (by norm_num) (by norm_num [um1, u2]) (Or.inl one_ne_zero)
  · exact solutionOfClassEq (u2 ^ 2) u2 1 1 1 0 (by simpa [Q, H] using h)
      (by norm_num [u2]) (by norm_num [u2]) (Or.inl one_ne_zero)
  · exact solutionOfClassEq (u2 ^ 2) (um1 * u2 ^ 2) 1 1 0 1
      (by simpa [Q, H] using h) (by norm_num [u2]) (by norm_num [um1, u2])
      (Or.inr one_ne_zero)
  · exact solutionOfClassEq (u2 ^ 2) (um1 * u2) 1 1 1 1
      (by simpa [Q, H] using h) (by norm_num [u2]) (by norm_num [um1, u2])
      (Or.inl one_ne_zero)

theorem prime_dvd_diagonal_quartic_exists (p : ℕ) (hp : p.Prime) :
    ∃ x y z t : ℤ,
      ¬ ((p : ℤ) ∣ x ∧ (p : ℤ) ∣ y ∧ (p : ℤ) ∣ z ∧ (p : ℤ) ∣ t) ∧
      (p : ℤ) ∣ x ^ 4 - 2 * y ^ 4 + 3 * z ^ 4 + 4 * t ^ 4 := by
  classical
  letI : Fact p.Prime := ⟨hp⟩
  rcases exists_zmod_diagonalQuarticForm_zero p with ⟨x, y, z, t, hnon, hzero⟩
  refine ⟨x.val, y.val, z.val, t.val, ?_, ?_⟩
  · intro hall
    rcases hall with ⟨hx, hy, hz, ht⟩
    have hx0 : x = 0 := by
      have hxcast : ((x.val : ℤ) : ZMod p) = 0 :=
        (ZMod.intCast_zmod_eq_zero_iff_dvd (x.val : ℤ) p).2 hx
      simpa using hxcast
    have hy0 : y = 0 := by
      have hycast : ((y.val : ℤ) : ZMod p) = 0 :=
        (ZMod.intCast_zmod_eq_zero_iff_dvd (y.val : ℤ) p).2 hy
      simpa using hycast
    have hz0 : z = 0 := by
      have hzcast : ((z.val : ℤ) : ZMod p) = 0 :=
        (ZMod.intCast_zmod_eq_zero_iff_dvd (z.val : ℤ) p).2 hz
      simpa using hzcast
    have ht0 : t = 0 := by
      have htcast : ((t.val : ℤ) : ZMod p) = 0 :=
        (ZMod.intCast_zmod_eq_zero_iff_dvd (t.val : ℤ) p).2 ht
      simpa using htcast
    rcases hnon with hxne | hyne | hzne | htne
    · exact hxne hx0
    · exact hyne hy0
    · exact hzne hz0
    · exact htne ht0
  · rw [← ZMod.intCast_zmod_eq_zero_iff_dvd]
    simpa [diagonalQuarticForm] using hzero

end Biblioteca.Demonstrations
