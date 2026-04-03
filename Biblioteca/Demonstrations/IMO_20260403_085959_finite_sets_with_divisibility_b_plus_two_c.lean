import Mathlib.Algebra.Group.Nat.Even
import Mathlib.Algebra.Ring.Parity
import Mathlib.Data.Finset.Card
import Mathlib.Data.Finset.Max
import Mathlib.Tactic

namespace Biblioteca.Demonstrations

set_option linter.unnecessarySimpa false
set_option linter.style.cdot false

open Finset

/-- Finite nonempty sets of positive integers such that for every `a, b ∈ S`
there exists `c ∈ S` with `a ∣ b + 2c`. -/
def DivisibilitySet (s : Finset Nat) : Prop :=
  s.Nonempty ∧
  (∀ x ∈ s, 0 < x) ∧
  ∀ ⦃a b : Nat⦄, a ∈ s → b ∈ s → ∃ c ∈ s, a ∣ b + 2 * c

/-- A convenient normal form: the smallest element `d` belongs to the set and
every element is either `d` or `3d`. -/
def HasBaseElement (s : Finset Nat) : Prop :=
  ∃ d ∈ s, 0 < d ∧ ∀ x ∈ s, x = d ∨ x = 3 * d

lemma DivisibilitySet.pos {s : Finset Nat} (hS : DivisibilitySet s) {x : Nat} (hx : x ∈ s) :
    0 < x :=
  hS.2.1 x hx

lemma DivisibilitySet.witness {s : Finset Nat} (hS : DivisibilitySet s) {a b : Nat}
    (ha : a ∈ s) (hb : b ∈ s) : ∃ c ∈ s, a ∣ b + 2 * c :=
  hS.2.2 ha hb

lemma all_even_of_mem_even {s : Finset Nat} (hS : DivisibilitySet s) {a : Nat}
    (ha : a ∈ s) (hae : Even a) : ∀ b ∈ s, Even b := by
  intro b hb
  rcases hS.witness ha hb with ⟨c, hc, hdiv⟩
  have hsum_even : Even (b + 2 * c) := by
    exact even_iff_two_dvd.mpr (hae.two_dvd.trans hdiv)
  have h2c_even : Even (2 * c) := even_two_mul c
  rcases hsum_even with ⟨k, hk⟩
  refine even_iff_two_dvd.mpr ?_
  refine ⟨k - c, ?_⟩
  omega

lemma all_even_or_all_odd {s : Finset Nat} (hS : DivisibilitySet s) :
    (∀ x ∈ s, Even x) ∨ (∀ x ∈ s, Odd x) := by
  by_cases hEven : ∃ a ∈ s, Even a
  · rcases hEven with ⟨a, ha, hae⟩
    exact Or.inl (all_even_of_mem_even hS ha hae)
  · right
    intro x hx
    by_contra hxo
    exact hEven ⟨x, hx, (Nat.not_odd_iff_even.mp hxo)⟩

lemma hasBaseElement_divisibilitySet {s : Finset Nat} (hbase : HasBaseElement s) :
    DivisibilitySet s := by
  rcases hbase with ⟨d, hd, hdpos, hshape⟩
  refine ⟨⟨d, hd⟩, ?_, ?_⟩
  · intro x hx
    rcases hshape x hx with rfl | rfl <;> omega
  · intro a b ha hb
    rcases hshape a ha with ha1 | ha3
    · subst a
      refine ⟨d, hd, ?_⟩
      rcases hshape b hb with hb1 | hb3
      · subst b
        exact ⟨3, by omega⟩
      · subst b
        exact ⟨5, by omega⟩
    · subst a
      refine ⟨b, hb, ?_⟩
      rcases hshape b hb with hb1 | hb3
      · subst b
        exact ⟨1, by omega⟩
      · subst b
        exact ⟨3, by omega⟩

lemma image_div_two_divisibilitySet {s : Finset Nat} (hS : DivisibilitySet s)
    (hEven : ∀ x ∈ s, Even x) : DivisibilitySet (s.image fun x => x / 2) := by
  classical
  refine ⟨?_, ?_, ?_⟩
  · rcases hS.1 with ⟨x, hx⟩
    exact ⟨x / 2, mem_image_of_mem _ hx⟩
  · intro a ha
    rcases mem_image.mp ha with ⟨a0, ha0, rfl⟩
    have ha0_pos : 0 < a0 := hS.pos ha0
    rcases hEven a0 ha0 with ⟨k, hk⟩
    have hkpos : 0 < k := by
      omega
    have hka : a0 / 2 = k := by
      omega
    rw [hka]
    exact hkpos
  · intro a b ha hb
    rcases mem_image.mp ha with ⟨a0, ha0, rfl⟩
    rcases mem_image.mp hb with ⟨b0, hb0, rfl⟩
    rcases hS.witness ha0 hb0 with ⟨c0, hc0, hdiv⟩
    refine ⟨c0 / 2, mem_image_of_mem _ hc0, ?_⟩
    have ha0_even := hEven a0 ha0
    have hb0_even := hEven b0 hb0
    have hc0_even := hEven c0 hc0
    have ha0_eq : 2 * (a0 / 2) = a0 := Nat.two_mul_div_two_of_even ha0_even
    have hb0_eq : 2 * (b0 / 2) = b0 := Nat.two_mul_div_two_of_even hb0_even
    have hc0_eq : 2 * (c0 / 2) = c0 := Nat.two_mul_div_two_of_even hc0_even
    have hdouble :
        2 * (a0 / 2) ∣ 2 * ((b0 / 2) + 2 * (c0 / 2)) := by
      rw [ha0_eq]
      have hcalc : 2 * ((b0 / 2) + 2 * (c0 / 2)) = b0 + 2 * c0 := by
        omega
      simpa [hcalc] using hdiv
    exact Nat.dvd_of_mul_dvd_mul_left (by norm_num : 0 < 2) hdouble

lemma lift_hasBase_from_image_div_two {s : Finset Nat} (hEven : ∀ x ∈ s, Even x)
    (hbase : HasBaseElement (s.image fun x => x / 2)) : HasBaseElement s := by
  classical
  rcases hbase with ⟨d, hd, hdpos, hshape⟩
  rcases mem_image.mp hd with ⟨y, hy, hyd⟩
  refine ⟨2 * d, ?_, ?_, ?_⟩
  · have hy_even := hEven y hy
    have hy_eq : 2 * (y / 2) = y := Nat.two_mul_div_two_of_even hy_even
    have hy' : y = 2 * d := by omega
    simpa [hy'] using hy
  · omega
  · intro x hx
    have hx_half : x / 2 ∈ s.image fun z => z / 2 := mem_image_of_mem _ hx
    rcases hshape (x / 2) hx_half with hxd | hxd
    · left
      have hx_even := hEven x hx
      have hx_eq : 2 * (x / 2) = x := Nat.two_mul_div_two_of_even hx_even
      omega
    · right
      have hx_even := hEven x hx
      have hx_eq : 2 * (x / 2) = x := Nat.two_mul_div_two_of_even hx_even
      omega

lemma hasBaseElement_singleton_or_pair {s : Finset Nat} (hbase : HasBaseElement s) :
    ∃ d > 0, s = ({d} : Finset Nat) ∨ s = ({d, 3 * d} : Finset Nat) := by
  classical
  rcases hbase with ⟨d, hd, hdpos, hshape⟩
  by_cases h3 : 3 * d ∈ s
  · refine ⟨d, hdpos, Or.inr ?_⟩
    apply Subset.antisymm
    · intro x hx
      rcases hshape x hx with rfl | rfl <;> simp
    · intro x hx
      have hx' : x = d ∨ x = 3 * d := by simpa using hx
      rcases hx' with rfl | rfl
      · exact hd
      · exact h3
  · refine ⟨d, hdpos, Or.inl ?_⟩
    apply Subset.antisymm
    · intro x hx
      rcases hshape x hx with rfl | hxd
      · simp
      · exfalso
        exact h3 (hxd ▸ hx)
    · intro x hx
      have hx' : x = d := by simpa using hx
      simpa [hx'] using hd

lemma divisibilitySet_singleton_or_pair_of_hasBase {s : Finset Nat} (hbase : HasBaseElement s) :
    ∃ d > 0, s = ({d} : Finset Nat) ∨ s = ({d, 3 * d} : Finset Nat) :=
  hasBaseElement_singleton_or_pair hbase

theorem divisibilitySet_hasBaseElement :
    ∀ n : Nat, ∀ s : Finset Nat, ∀ hS : DivisibilitySet s, s.max' hS.1 = n → HasBaseElement s := by
  intro n
  refine Nat.strong_induction_on n ?_
  intro n ih s hS hsmax
  classical
  rcases all_even_or_all_odd hS with hEven | hOdd
  · let t : Finset Nat := s.image fun x => x / 2
    have htS : DivisibilitySet t := image_div_two_divisibilitySet hS hEven
    have hmax_mem : n ∈ s := by
      simpa [hsmax] using (max'_mem s hS.1)
    have hn_even : Even n := by
      simpa [hsmax] using hEven (s.max' hS.1) (max'_mem s hS.1)
    have hn_pos : 0 < n := by
      simpa [hsmax] using hS.pos (max'_mem s hS.1)
    have ht_le : t.max' htS.1 ≤ n / 2 := by
      apply max'_le
      intro y hy
      rcases mem_image.mp hy with ⟨x, hx, rfl⟩
      have hx_even := hEven x hx
      have hx_eq : 2 * (x / 2) = x := Nat.two_mul_div_two_of_even hx_even
      have hn_eq : 2 * (n / 2) = n := Nat.two_mul_div_two_of_even hn_even
      have hx_le : x ≤ n := by
        simpa [hsmax] using (Finset.le_max' (s := s) x hx)
      omega
    have ht_lt : t.max' htS.1 < n := by
      exact lt_of_le_of_lt ht_le (Nat.div_lt_self hn_pos (by norm_num))
    have ht_base : HasBaseElement t := ih (t.max' htS.1) ht_lt t htS rfl
    exact lift_hasBase_from_image_div_two hEven ht_base
  · by_cases hT : (s.erase n).Nonempty
    · let t : Finset Nat := s.erase n
      let m : Nat := t.min' hT
      let v : Nat := t.max' hT
      let f : Nat → Nat := fun x => (n - x) / 2
      have hn_mem : n ∈ s := by
        simpa [hsmax] using (max'_mem s hS.1)
      have hn_pos : 0 < n := hS.pos hn_mem
      have hn_odd : Odd n := by
        simpa [hsmax] using hOdd (s.max' hS.1) (max'_mem s hS.1)
      have hm_mem_t : m ∈ t := min'_mem t hT
      have hv_mem_t : v ∈ t := max'_mem t hT
      have hm_mem_s : m ∈ s := (mem_erase.mp hm_mem_t).2
      have hv_mem_s : v ∈ s := (mem_erase.mp hv_mem_t).2
      have hm_odd : Odd m := hOdd m hm_mem_s
      have hv_odd : Odd v := hOdd v hv_mem_s
      have hmap : ∀ x ∈ t, f x ∈ t := by
        intro x hx
        have hx_mem_s : x ∈ s := (mem_erase.mp hx).2
        have hx_ne_n : x ≠ n := (mem_erase.mp hx).1
        have hx_odd : Odd x := hOdd x hx_mem_s
        rcases hS.witness hn_mem hx_mem_s with ⟨c, hc, hdiv⟩
        have hc_ne_n : c ≠ n := by
          intro hc_eq
          have : n ∣ x := by
            have hkx : n ∣ x + 2 * n := by simpa [hc_eq] using hdiv
            have h2n : n ∣ 2 * n := ⟨2, by omega⟩
            simpa [Nat.add_sub_cancel_left] using Nat.dvd_sub hkx h2n
          have hx_le_n : x ≤ n := by
            simpa [hsmax] using (Finset.le_max' (s := s) x hx_mem_s)
          have hx_eq_n : x = n := by
            exact le_antisymm hx_le_n (Nat.le_of_dvd (hS.pos hx_mem_s) this)
          exact hx_ne_n hx_eq_n
        have hc_mem_t : c ∈ t := by
          exact mem_erase.mpr ⟨hc_ne_n, hc⟩
        have hc_mem_s : c ∈ s := (mem_erase.mp hc_mem_t).2
        have hc_odd : Odd c := hOdd c hc_mem_s
        have hx_lt_n : x < n := by
          exact lt_of_le_of_ne (by simpa [hsmax] using (Finset.le_max' (s := s) x hx_mem_s)) hx_ne_n
        have hc_lt_n : c < n := by
          exact lt_of_le_of_ne (by simpa [hsmax] using (Finset.le_max' (s := s) c hc)) hc_ne_n
        have hsum_lt : x + 2 * c < 3 * n := by omega
        have hsum_odd : Odd (x + 2 * c) := by
          exact hx_odd.add_even (even_two_mul c)
        rcases hdiv with ⟨k, hk⟩
        have hx_pos : 0 < x := hS.pos hx_mem_s
        have hc_pos : 0 < c := hS.pos hc_mem_s
        have hk_pos : 0 < k := by
          have hk_ne_zero : k ≠ 0 := by
            intro hk0
            rw [hk0] at hk
            omega
          exact Nat.pos_of_ne_zero hk_ne_zero
        have hk_le_two : k ≤ 2 := by
          by_contra hk_gt
          have hkge : 3 ≤ k := by omega
          have hkn : 3 * n ≤ n * k := by
            simpa [Nat.mul_comm] using Nat.mul_le_mul_left n hkge
          omega
        have hk_cases : k = 1 ∨ k = 2 := by
          omega
        rcases hk_cases with hk1 | hk2
        · have hnx_even : Even (n - x) := Nat.Odd.sub_odd hn_odd hx_odd
          have htwo_fx : 2 * f x = n - x := by
            dsimp [f]
            exact Nat.two_mul_div_two_of_even hnx_even
          have hk1' : x + 2 * c = n := by simpa [hk1] using hk
          have htwo_c : 2 * c = n - x := by omega
          have hc_eq : c = f x := by
            omega
          have hc_mem_t' : f x ∈ t := by simpa [hc_eq] using hc_mem_t
          exact hc_mem_t'
        · have hsum_even : Even (x + 2 * c) := by
            have hk2' : x + 2 * c = n * 2 := by
              simpa [hk2] using hk
            rw [hk2']
            simpa [Nat.mul_comm] using even_two_mul n
          exfalso
          exact (Nat.not_even_iff_odd.mpr hsum_odd) hsum_even
      have hfinj : ∀ ⦃x y : Nat⦄, x ∈ t → y ∈ t → f x = f y → x = y := by
        intro x y hx hy hxy
        have hx_mem_s : x ∈ s := (mem_erase.mp hx).2
        have hy_mem_s : y ∈ s := (mem_erase.mp hy).2
        have hx_even : Even (n - x) := Nat.Odd.sub_odd hn_odd (hOdd x hx_mem_s)
        have hy_even : Even (n - y) := Nat.Odd.sub_odd hn_odd (hOdd y hy_mem_s)
        have hnx : 2 * f x = n - x := by
          dsimp [f]
          exact Nat.two_mul_div_two_of_even hx_even
        have hny : 2 * f y = n - y := by
          dsimp [f]
          exact Nat.two_mul_div_two_of_even hy_even
        have htwo_eq : 2 * f x = 2 * f y := by omega
        have hx_lt_n : x < n := by
          exact lt_of_le_of_ne (by simpa [hsmax] using (Finset.le_max' (s := s) x hx_mem_s))
            (mem_erase.mp hx).1
        have hy_lt_n : y < n := by
          exact lt_of_le_of_ne (by simpa [hsmax] using (Finset.le_max' (s := s) y hy_mem_s))
            (mem_erase.mp hy).1
        have hsub : n - x = n - y := by omega
        omega
      have hsubset : t.image f ⊆ t := by
        intro y hy
        rcases mem_image.mp hy with ⟨x, hx, rfl⟩
        exact hmap x hx
      have himage_eq : t.image f = t := by
        apply eq_of_subset_of_card_le hsubset
        rw [card_image_of_injOn (s := t) (f := f) (fun x hx y hy hxy => hfinj hx hy hxy)]
      have hnm_even : Even (n - m) := Nat.Odd.sub_odd hn_odd hm_odd
      have hnv_even : Even (n - v) := Nat.Odd.sub_odd hn_odd hv_odd
      have htwo_fm : 2 * f m = n - m := by
        dsimp [f]
        exact Nat.two_mul_div_two_of_even hnm_even
      have htwo_fv : 2 * f v = n - v := by
        dsimp [f]
        exact Nat.two_mul_div_two_of_even hnv_even
      have hfm_mem : f m ∈ t := hmap m hm_mem_t
      have hfv_mem : f v ∈ t := hmap v hv_mem_t
      have hfm_eq_v : f m = v := by
        apply le_antisymm
        · exact Finset.le_max' (s := t) (f m) hfm_mem
        · have hupper : ∀ y ∈ t, y ≤ f m := by
            intro y hy
            rcases (mem_image.mp (himage_eq ▸ hy)) with ⟨z, hz, hz_eq⟩
            have hm_le_z : m ≤ z := Finset.min'_le (s := t) z hz
            have hz_mem_s : z ∈ s := (mem_erase.mp hz).2
            have hz_even : Even (n - z) := Nat.Odd.sub_odd hn_odd (hOdd z hz_mem_s)
            have htwo_y : 2 * y = n - z := by
              calc
                2 * y = 2 * f z := by simp [hz_eq]
                _ = n - z := by
                  dsimp [f]
                  exact Nat.two_mul_div_two_of_even hz_even
            omega
          exact hupper v hv_mem_t
      have hfv_eq_m : f v = m := by
        apply le_antisymm
        · have hlower : ∀ y ∈ t, f v ≤ y := by
            intro y hy
            rcases (mem_image.mp (himage_eq ▸ hy)) with ⟨z, hz, hz_eq⟩
            have hz_le_v : z ≤ v := Finset.le_max' (s := t) z hz
            have hz_mem_s : z ∈ s := (mem_erase.mp hz).2
            have hz_even : Even (n - z) := Nat.Odd.sub_odd hn_odd (hOdd z hz_mem_s)
            have htwo_y : 2 * y = n - z := by
              calc
                2 * y = 2 * f z := by simp [hz_eq]
                _ = n - z := by
                  dsimp [f]
                  exact Nat.two_mul_div_two_of_even hz_even
            omega
          exact hlower m hm_mem_t
        · exact Finset.min'_le (s := t) (f v) hfv_mem
      have htwo_v : 2 * v = n - m := by
        calc
          2 * v = 2 * f m := by simp [hfm_eq_v]
          _ = n - m := htwo_fm
      have htwo_m : 2 * m = n - v := by
        calc
          2 * m = 2 * f v := by simp [hfv_eq_m]
          _ = n - v := htwo_fv
      have hv_eq_m : v = m := by omega
      have hn_eq : n = 3 * m := by omega
      refine ⟨m, hm_mem_s, hS.pos hm_mem_s, ?_⟩
      intro x hx
      by_cases hx_n : x = n
      · right
        omega
      · have hx_mem_t : x ∈ t := mem_erase.mpr ⟨hx_n, hx⟩
        have hfx_mem : f x ∈ t := hmap x hx_mem_t
        have hm_le_fx : m ≤ f x := Finset.min'_le (s := t) (f x) hfx_mem
        have hx_odd : Odd x := hOdd x hx
        have hnx_even : Even (n - x) := Nat.Odd.sub_odd hn_odd hx_odd
        have htwo_fx : 2 * f x = n - x := by
          dsimp [f]
          exact Nat.two_mul_div_two_of_even hnx_even
        left
        have hx_le_m : x ≤ m := by omega
        have hm_le_x : m ≤ x := Finset.min'_le (s := t) x hx_mem_t
        omega
    · have hs_singleton : s = ({n} : Finset Nat) := by
        apply Subset.antisymm
        · intro x hx
          have hx_eq : x = n := by
            by_contra hx_ne
            have : x ∈ s.erase n := mem_erase.mpr ⟨hx_ne, hx⟩
            exact hT ⟨x, this⟩
          simp [hx_eq]
        · intro x hx
          have hx' : x = n := by simpa using hx
          simpa [hx'] using (show n ∈ s by simpa [hsmax] using max'_mem s hS.1)
      refine ⟨n, ?_, ?_, ?_⟩
      · simp [hs_singleton]
      · simpa [hsmax] using hS.pos (max'_mem s hS.1)
      · intro x hx
        left
        have : x = n := by
          have hx' : x ∈ ({n} : Finset Nat) := by simpa [hs_singleton] using hx
          simpa using hx'
        simp [this]

theorem divisibilitySet_hasBase {s : Finset Nat} (hS : DivisibilitySet s) :
    HasBaseElement s := by
  exact divisibilitySet_hasBaseElement (s.max' hS.1) s hS rfl

/-- Classification of the finite nonempty sets `S` of positive integers such
that for every `a, b ∈ S` there exists `c ∈ S` with `a ∣ b + 2c`. -/
theorem divisibility_set_classification (s : Finset Nat) :
    DivisibilitySet s ↔ ∃ d > 0, s = ({d} : Finset Nat) ∨ s = ({d, 3 * d} : Finset Nat) := by
  constructor
  · intro hS
    exact divisibilitySet_singleton_or_pair_of_hasBase (divisibilitySet_hasBase hS)
  · intro hs
    rcases hs with ⟨d, hdpos, rfl | rfl⟩
    · exact hasBaseElement_divisibilitySet
        ⟨d, by simp, hdpos, by
          intro x hx
          left
          simpa using hx⟩
    · exact hasBaseElement_divisibilitySet
        ⟨d, by simp, hdpos, by
          intro x hx
          have hx' : x = d ∨ x = 3 * d := by simpa using hx
          rcases hx' with rfl | rfl
          · left
            rfl
          · right
            rfl⟩

end Biblioteca.Demonstrations
