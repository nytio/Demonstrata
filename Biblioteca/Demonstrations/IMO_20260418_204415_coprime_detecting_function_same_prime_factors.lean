import Mathlib.Data.Nat.Factorization.Basic
import Mathlib.Data.Nat.Find
import Mathlib.Data.Nat.MaxPowDiv
import Mathlib.NumberTheory.Padics.PadicVal.Basic
import Mathlib.Tactic

namespace Biblioteca.Demonstrations

open scoped BigOperators

/-- The olympiad property from IMO 2024 Shortlist N7. -/
def CoprimeDetectingFunction (f : Nat → Nat) : Prop :=
  (∀ ⦃n : Nat⦄, 0 < n → 0 < f n) ∧
    ∀ ⦃m n : Nat⦄, 0 < m → 0 < n →
      ((f (m * n)) ^ 2 = f (m ^ 2) * f (f n) * f (m * f n) ↔ Nat.Coprime m n)

lemma sq_eq_sq_of_pos {a b : Nat} (ha : 0 < a) (hb : 0 < b) (h : a ^ 2 = b ^ 2) : a = b := by
  have h' : ((a : Int) ^ 2) = (b : Int) ^ 2 := by exact_mod_cast h
  have ha' : 0 ≤ (a : Int) := by exact_mod_cast ha.le
  have hb' : 0 ≤ (b : Int) := by exact_mod_cast hb.le
  nlinarith

lemma sq_eq_mul_right_of_pos {a b : Nat} (ha : 0 < a) :
    a ^ 2 = b * a ↔ a = b := by
  rw [pow_two, Nat.mul_comm b a]
  constructor
  · intro h
    exact Nat.eq_of_mul_eq_mul_left ha h
  · intro h
    simp [h]

lemma sq_eq_mul_left_of_pos {a b : Nat} (ha : 0 < a) :
    a ^ 2 = a * b ↔ a = b := by
  rw [pow_two]
  constructor
  · intro h
    exact Nat.eq_of_mul_eq_mul_left ha h
  · intro h
    simp [h]

lemma coprimeDetecting_pos {f : Nat → Nat} (hf : CoprimeDetectingFunction f) {n : Nat}
    (hn : 0 < n) : 0 < f n :=
  hf.1 hn

lemma coprimeDetecting_eq {f : Nat → Nat} (hf : CoprimeDetectingFunction f) {m n : Nat}
    (hm : 0 < m) (hn : 0 < n) :
    (f (m * n)) ^ 2 = f (m ^ 2) * f (f n) * f (m * f n) ↔ Nat.Coprime m n :=
  hf.2 hm hn

lemma coprimeDetecting_one_eq_one {f : Nat → Nat} (hf : CoprimeDetectingFunction f) : f 1 = 1 := by
  have h1pos : 0 < f 1 := coprimeDetecting_pos hf (by norm_num)
  have h11 := (coprimeDetecting_eq (m := 1) (n := 1) hf (by norm_num) (by norm_num)).2
    (by decide : Nat.Coprime 1 1)
  have hbase : f 1 = f (f 1) ^ 2 := by
    have h11' : f 1 * f 1 = f 1 * (f (f 1) ^ 2) := by
      simpa [one_pow, pow_two, Nat.mul_assoc, Nat.mul_left_comm, Nat.mul_comm] using h11
    exact Nat.eq_of_mul_eq_mul_left h1pos h11'
  let c := f (f 1)
  have hcpos : 0 < c := coprimeDetecting_pos hf h1pos
  have hrewrite {n : Nat} (hn : 0 < n) : f n = c * f (f n) := by
    have h1n := (coprimeDetecting_eq (m := 1) (n := n) hf (by norm_num) hn).2
      (Nat.coprime_one_left n)
    have h1n' : f n ^ 2 = c ^ 2 * f (f n) ^ 2 := by
      calc
        f n ^ 2 = f 1 * f (f n) * f (f n) := by
          simpa [one_pow, Nat.mul_one, Nat.one_mul, Nat.mul_assoc, Nat.mul_left_comm,
            Nat.mul_comm] using h1n
        _ = c ^ 2 * f (f n) ^ 2 := by
          rw [hbase]
          ring
    exact sq_eq_sq_of_pos (coprimeDetecting_pos hf hn)
      (Nat.mul_pos hcpos (coprimeDetecting_pos hf (coprimeDetecting_pos hf hn))) <|
      by simpa [pow_two, Nat.mul_assoc, Nat.mul_left_comm, Nat.mul_comm] using h1n'
  have hfc_one : f c = 1 := by
    have h1' : c = c * f c := by simpa [c] using hrewrite h1pos
    have h1'' : c * 1 = c * f c := by simpa using h1'
    exact (Nat.eq_of_mul_eq_mul_left hcpos h1'').symm
  have hc_one : c = 1 := by
    have hc' : 1 = c * f 1 := by simpa [hfc_one, c] using hrewrite hcpos
    exact Nat.dvd_one.mp ⟨f 1, hc'⟩
  simpa [c, hc_one] using hbase

lemma coprimeDetecting_idem {f : Nat → Nat} (hf : CoprimeDetectingFunction f) {n : Nat}
    (hn : 0 < n) : f (f n) = f n := by
  have h := (coprimeDetecting_eq (m := 1) (n := n) hf (by norm_num) hn).2
    (Nat.coprime_one_left n)
  have h' : f n ^ 2 = f (f n) ^ 2 := by
    simpa [coprimeDetecting_one_eq_one hf, one_pow, pow_two, Nat.mul_assoc,
      Nat.mul_left_comm, Nat.mul_comm] using h
  exact sq_eq_sq_of_pos (a := f n) (b := f (f n))
    (coprimeDetecting_pos (n := n) hf hn)
    (coprimeDetecting_pos (n := f n) hf (coprimeDetecting_pos hf hn)) h' |>.symm

lemma coprimeDetecting_sq {f : Nat → Nat} (hf : CoprimeDetectingFunction f) {n : Nat}
    (hn : 0 < n) : f (n ^ 2) = f n := by
  have h := (coprimeDetecting_eq (m := n) (n := 1) hf hn (by norm_num)).2
    (Nat.coprime_one_right n)
  have h' : f n ^ 2 = f (n ^ 2) * f n := by
    simpa [coprimeDetecting_one_eq_one hf, one_pow, Nat.mul_one, Nat.mul_assoc,
      coprimeDetecting_idem (n := 1) hf (by norm_num)] using h
  exact ((sq_eq_mul_right_of_pos (coprimeDetecting_pos hf hn)).1 h').symm

lemma coprimeDetecting_Q {f : Nat → Nat} (hf : CoprimeDetectingFunction f) {m n : Nat}
    (hm : 0 < m) (hn : 0 < n) :
    ((f (m * n)) ^ 2 = f m * f n * f (m * f n) ↔ Nat.Coprime m n) := by
  simpa [coprimeDetecting_sq hf hm, coprimeDetecting_idem hf hn, Nat.mul_assoc]
    using coprimeDetecting_eq hf hm hn

lemma coprimeDetecting_R {f : Nat → Nat} (hf : CoprimeDetectingFunction f) {m n : Nat}
    (hm : 0 < m) (hn : 0 < n) :
    (f (m * f n) = f m * f n ↔ Nat.Coprime m (f n)) := by
  have hq := coprimeDetecting_Q (m := m) (n := f n) hf hm (coprimeDetecting_pos hf hn)
  have hq' :
      (f (m * f n)) ^ 2 = f m * f n * f (m * f n) ↔ Nat.Coprime m (f n) := by
    simpa [coprimeDetecting_idem hf hn, Nat.mul_assoc, Nat.mul_left_comm, Nat.mul_comm]
      using hq
  have hmfpos : 0 < f (m * f n) :=
    coprimeDetecting_pos hf (Nat.mul_pos hm (coprimeDetecting_pos hf hn))
  constructor
  · intro hEq
    exact hq'.1 <| by
      simp [hEq, pow_two, Nat.mul_left_comm, Nat.mul_comm]
  · intro hcop
    exact (sq_eq_mul_right_of_pos hmfpos).1 <|
      (hq'.2 hcop)

lemma coprimeDetecting_preimage_one {f : Nat → Nat} (hf : CoprimeDetectingFunction f) {a : Nat}
    (ha : 0 < a) (hfa : f a = 1) : a = 1 := by
  by_contra hane1
  have hnot : ¬ Nat.Coprime a a := by
    simpa [Nat.coprime_self] using hane1
  have hq := coprimeDetecting_Q (m := a) (n := a) hf ha ha
  have hEq : (f (a * a)) ^ 2 = f a * f a * f (a * f a) := by
    have ha2 : f (a * a) = 1 := by simpa [pow_two, hfa] using coprimeDetecting_sq hf ha
    simp [hfa, ha2]
  exact hnot (hq.1 hEq)

lemma coprimeDetecting_not_coprime_self_image {f : Nat → Nat} (hf : CoprimeDetectingFunction f)
    {n : Nat} (hn : 0 < n) (hne1 : n ≠ 1) : ¬ Nat.Coprime n (f n) := by
  intro hcop
  have h1 := (coprimeDetecting_Q (m := f n) (n := n) hf (coprimeDetecting_pos hf hn) hn).2 hcop.symm
  have h2 := (coprimeDetecting_Q (m := n) (n := f n) hf hn (coprimeDetecting_pos hf hn)).2 hcop
  have hsqimg : f (f n * f n) = f n := by
    calc
      f (f n * f n) = f (f n) := by
        simpa [pow_two] using
          coprimeDetecting_sq (n := f n) hf (coprimeDetecting_pos hf hn)
      _ = f n := coprimeDetecting_idem hf hn
  have h1' : (f (n * f n)) ^ 2 = f n * f n * f n := by
    simpa [Nat.mul_comm, Nat.mul_left_comm, Nat.mul_assoc, coprimeDetecting_idem hf hn,
      hsqimg] using h1
  have h2' : (f (n * f n)) ^ 2 = f n * f n * f (n * f n) := by
    simpa [Nat.mul_comm, Nat.mul_left_comm, Nat.mul_assoc, coprimeDetecting_idem hf hn] using h2
  have himageOne : f n = 1 := by
    have hnfpos : 0 < f (n * f n) :=
      coprimeDetecting_pos hf (Nat.mul_pos hn (coprimeDetecting_pos hf hn))
    have hsame : f n * f n * f n = f n * f n * f (n * f n) := h1'.symm.trans h2'
    have hsqpos : 0 < f n * f n :=
      Nat.mul_pos (coprimeDetecting_pos hf hn) (coprimeDetecting_pos hf hn)
    have hsame' : (f n * f n) * f n = (f n * f n) * f (n * f n) := by
      simpa [Nat.mul_assoc] using hsame
    have hnf : f n = f (n * f n) := Nat.eq_of_mul_eq_mul_left hsqpos hsame'
    have hpow : (f (n * f n)) ^ 2 = f n * f n := by
      rw [pow_two, ← hnf]
    have hlast : f n * f n * f (n * f n) = (f n * f n) * f n := by
      calc
        f n * f n * f (n * f n) = f n * f n * f n := by rw [← hnf]
        _ = (f n * f n) * f n := by rw [Nat.mul_assoc]
    have hcube : (f n * f n) * 1 = (f n * f n) * f n := by
      calc
        (f n * f n) * 1 = f n * f n := by simp
        _ = (f (n * f n)) ^ 2 := hpow.symm
        _ = f n * f n * f (n * f n) := h2'
        _ = (f n * f n) * f n := hlast
    have : 1 = f n := Nat.eq_of_mul_eq_mul_left hsqpos hcube
    exact this.symm
  exact hne1 (coprimeDetecting_preimage_one hf hn himageOne)

/-- Every prime divisor of `n` also divides `f n`. -/
lemma coprimeDetecting_prime_dvd_image {f : Nat → Nat} (hf : CoprimeDetectingFunction f)
    {p n : Nat} (hp : p.Prime) (hn : 0 < n) (hpn : p ∣ n) : p ∣ f n := by
  letI : Fact p.Prime := ⟨hp⟩
  let v := padicValNat p n
  let t := n.divMaxPow p
  have hdecomp : p ^ v * t = n := by
    dsimp [v, t]
    exact Nat.pow_padicValNat_mul_divMaxPow p n
  have hvpos : 0 < v := by
    have : 1 ≤ padicValNat p n :=
      one_le_padicValNat_of_dvd (n := n) hn.ne' hpn
    simpa [v] using this
  have htpos : 0 < t := by
    apply Nat.pos_of_ne_zero
    intro ht0
    have : p ^ v * 0 = n := by
      simpa [t, ht0] using hdecomp
    exact hn.ne' <| by simpa using this.symm
  have hpnot : ¬ p ∣ t := by
    simpa [t] using Nat.not_dvd_divMaxPow (p := p) (n := n) hp.one_lt hn.ne'
  have hcop : Nat.Coprime (p ^ v) t := by
    rw [Nat.coprime_pow_left_iff hvpos]
    exact hp.coprime_iff_not_dvd.2 hpnot
  have hpv_ne_one : p ^ v ≠ 1 := by
    intro hpv_one
    exact hp.not_dvd_one <| hpv_one ▸ dvd_pow_self p hvpos.ne'
  have hpv_notcop : ¬ Nat.Coprime (p ^ v) (f (p ^ v)) :=
    coprimeDetecting_not_coprime_self_image hf (pow_pos hp.pos v) hpv_ne_one
  have hpv_dvd : p ∣ f (p ^ v) := by
    by_contra hpfd
    have hcop' : Nat.Coprime (p ^ v) (f (p ^ v)) := by
      rw [Nat.coprime_pow_left_iff hvpos]
      exact hp.coprime_iff_not_dvd.2 hpfd
    exact hpv_notcop hcop'
  have hq := (coprimeDetecting_Q (m := p ^ v) (n := t) hf (pow_pos hp.pos v) htpos).2 hcop
  have hq' : (f n) ^ 2 = f (p ^ v) * f t * f (p ^ v * f t) := by
    simpa [hdecomp, Nat.mul_assoc, Nat.mul_left_comm, Nat.mul_comm] using hq
  have hpdvdpow : p ∣ (f n) ^ 2 := by
    rw [hq']
    simpa [Nat.mul_assoc] using
      dvd_mul_of_dvd_left hpv_dvd (f t * f (p ^ v * f t))
  exact hp.dvd_of_dvd_pow hpdvdpow

/-- Coprimality with an image value is preserved after applying `f`. -/
lemma coprimeDetecting_image_coprime {f : Nat → Nat} (hf : CoprimeDetectingFunction f)
    {n k : Nat} (hn : 0 < n) (hk : 0 < k) (hcop : Nat.Coprime n (f k)) :
    Nat.Coprime (f n) (f k) := by
  have hmul : f (n * f k) = f n * f k :=
    (coprimeDetecting_R (m := n) (n := k) hf hn hk).2 hcop
  have hq := (coprimeDetecting_Q (m := f k) (n := n) hf (coprimeDetecting_pos hf hk) hn).2
    hcop.symm
  have hq' : (f n * f k) ^ 2 = f k * f n * f (f k * f n) := by
    simpa [hmul, Nat.mul_assoc, Nat.mul_left_comm, Nat.mul_comm,
      coprimeDetecting_idem hf hk] using hq
  have hprodPos : 0 < f n * f k :=
    Nat.mul_pos (coprimeDetecting_pos hf hn) (coprimeDetecting_pos hf hk)
  have hmul' : f n * f k = f (f k * f n) :=
    (sq_eq_mul_left_of_pos hprodPos).1 <|
      by simpa [pow_two, Nat.mul_assoc, Nat.mul_left_comm, Nat.mul_comm] using hq'
  have hR := coprimeDetecting_R (m := f n) (n := k) hf (coprimeDetecting_pos hf hn) hk
  exact hR.1 <| by
    simpa [Nat.mul_comm, coprimeDetecting_idem hf hn, Nat.mul_left_comm, Nat.mul_assoc]
      using hmul'.symm

/-- For coprime arguments, coprimality with the corresponding image value is symmetric. -/
lemma coprimeDetecting_coprime_image_transfer {f : Nat → Nat} (hf : CoprimeDetectingFunction f)
    {m n : Nat} (hm : 0 < m) (hn : 0 < n) (hcop : Nat.Coprime m n) :
    Nat.Coprime m (f n) → Nat.Coprime n (f m) := by
  intro hmfn
  have hmn := (coprimeDetecting_Q (m := m) (n := n) hf hm hn).2 hcop
  have hnm := (coprimeDetecting_Q (m := n) (n := m) hf hn hm).2 hcop.symm
  have hsame : f m * f n * f (m * f n) = f n * f m * f (n * f m) := by
    calc
      f m * f n * f (m * f n) = (f (m * n)) ^ 2 := hmn.symm
      _ = (f (n * m)) ^ 2 := by simp [Nat.mul_comm]
      _ = f n * f m * f (n * f m) := hnm
  have hpos : 0 < f m * f n :=
    Nat.mul_pos (coprimeDetecting_pos hf hm) (coprimeDetecting_pos hf hn)
  have hcancel : f (m * f n) = f (n * f m) := by
    apply Nat.eq_of_mul_eq_mul_left hpos
    simpa [Nat.mul_assoc, Nat.mul_left_comm, Nat.mul_comm] using hsame
  have hmul : f (m * f n) = f m * f n :=
    (coprimeDetecting_R (m := m) (n := n) hf hm hn).2 hmfn
  have hmul' : f (n * f m) = f n * f m := by
    calc
      f (n * f m) = f (m * f n) := hcancel.symm
      _ = f m * f n := hmul
      _ = f n * f m := by simp [Nat.mul_comm]
  exact (coprimeDetecting_R (m := n) (n := m) hf hn hm).1 <| by
    simpa [Nat.mul_comm] using hmul'

/-- If `p ∤ n`, then `p ∣ f n` exactly when `n` is not coprime to `f p`. -/
lemma coprimeDetecting_prime_dvd_iff_not_coprime_prime_image {f : Nat → Nat}
    (hf : CoprimeDetectingFunction f) {p n : Nat} (hp : p.Prime) (hn : 0 < n)
    (hpn : ¬ p ∣ n) : p ∣ f n ↔ ¬ Nat.Coprime n (f p) := by
  have hcop : Nat.Coprime p n := hp.coprime_iff_not_dvd.2 hpn
  have hiff : Nat.Coprime p (f n) ↔ Nat.Coprime n (f p) := by
    constructor
    · intro h
      exact coprimeDetecting_coprime_image_transfer hf hp.pos hn hcop h
    · intro h
      have h' :=
        coprimeDetecting_coprime_image_transfer hf hn hp.pos hcop.symm h
      simpa [Nat.coprime_comm] using h'
  exact hp.dvd_iff_not_coprime.trans <| by
    simpa [Nat.coprime_comm] using not_congr hiff

/-- No prime different from `p` can divide `f p`. -/
lemma coprimeDetecting_prime_image_unique {f : Nat → Nat} (hf : CoprimeDetectingFunction f)
    {p q : Nat} (hp : p.Prime) (hq : q.Prime) (hqp : q ∣ f p) : q = p := by
  classical
  by_contra hneq
  letI : Fact p.Prime := ⟨hp⟩
  have hpp : p ∣ f p :=
    coprimeDetecting_prime_dvd_image hf hp hp.pos (dvd_rfl : p ∣ p)
  have hpq_dvd_fp : p * q ∣ f p :=
    Nat.Prime.dvd_mul_of_dvd_ne (fun h => hneq h.symm) hp hq hpp hqp
  have hpq : Nat.Coprime p q := (Nat.coprime_primes hp hq).2 (fun h => hneq h.symm)
  have hpfq : p ∣ f q := by
    have hnot : ¬ Nat.Coprime p (f q) := by
      exact
        (coprimeDetecting_prime_dvd_iff_not_coprime_prime_image hf hq hp.pos <| by
          intro h
          exact hneq ((Nat.prime_dvd_prime_iff_eq hq hp).1 h)).1 hqp
    exact (hp.dvd_iff_not_coprime).2 hnot
  have hqq : q ∣ f q :=
    coprimeDetecting_prime_dvd_image hf hq hq.pos (dvd_rfl : q ∣ q)
  have hpq_dvd_fq : p * q ∣ f q := by
    simpa [Nat.mul_comm] using Nat.Prime.dvd_mul_of_dvd_ne hneq hq hp hqq hpfq
  have hex :
      ∃ m, ∃ x, 0 < x ∧ ¬ Nat.Coprime x (p * q) ∧ padicValNat p (f x) = m := by
    refine ⟨padicValNat p (f p), p, hp.pos, ?_, rfl⟩
    exact Nat.not_coprime_of_dvd_of_dvd hp.one_lt
      (dvd_rfl : p ∣ p) (dvd_mul_of_dvd_left (dvd_rfl : p ∣ p) q)
  let m := Nat.find hex
  have hm_spec : ∃ x, 0 < x ∧ ¬ Nat.Coprime x (p * q) ∧ padicValNat p (f x) = m := by
    exact Nat.find_spec hex
  obtain ⟨X, hXpos, hXbad, hXm⟩ := hm_spec
  have hm_min {x : Nat} (hxpos : 0 < x) (hxbad : ¬ Nat.Coprime x (p * q)) :
      m ≤ padicValNat p (f x) :=
    Nat.find_min' hex ⟨x, hxpos, hxbad, rfl⟩
  have hbad_pdiv {x : Nat} (hxpos : 0 < x) (hxbad : ¬ Nat.Coprime x (p * q)) :
      p ∣ f x := by
    by_cases hpx : p ∣ x
    · exact coprimeDetecting_prime_dvd_image hf hp hxpos hpx
    · have hnotcop_fp : ¬ Nat.Coprime x (f p) := by
        intro hcopxfp
        exact hxbad <| Nat.Coprime.of_dvd_right hpq_dvd_fp hcopxfp
      exact
        (coprimeDetecting_prime_dvd_iff_not_coprime_prime_image hf hp hxpos hpx).2
          hnotcop_fp
  have hbad_qdiv {x : Nat} (hxpos : 0 < x) (hxbad : ¬ Nat.Coprime x (p * q)) :
      q ∣ f x := by
    by_cases hqx : q ∣ x
    · exact coprimeDetecting_prime_dvd_image hf hq hxpos hqx
    · have hnotcop_fq : ¬ Nat.Coprime x (f q) := by
        intro hcopxfq
        exact hxbad <| Nat.Coprime.of_dvd_right hpq_dvd_fq <| by
          simpa [Nat.mul_comm] using hcopxfq
      exact
        (coprimeDetecting_prime_dvd_iff_not_coprime_prime_image hf hq hxpos hqx).2
          hnotcop_fq
  have hm_pos : 0 < m := by
    have h1 : 1 ≤ padicValNat p (f X) :=
      one_le_padicValNat_of_dvd (n := f X) (coprimeDetecting_pos hf hXpos).ne'
        (hbad_pdiv hXpos hXbad)
    simpa [hXm] using h1
  let u := (f X).divMaxPow p
  have hfu : p ^ m * u = f X := by
    simpa [u, hXm] using Nat.pow_padicValNat_mul_divMaxPow p (f X)
  have hu_not_dvd : ¬ p ∣ u := by
    simpa [u] using
      Nat.not_dvd_divMaxPow (p := p) (n := f X) hp.one_lt
        (coprimeDetecting_pos hf hXpos).ne'
  have hqu : q ∣ u := by
    have hqfx : q ∣ f X := hbad_qdiv hXpos hXbad
    have hqpow : Nat.Coprime q (p ^ m) := by
      rw [Nat.coprime_pow_right_iff hm_pos]
      exact (hq.coprime_iff_not_dvd.2 <| by
        intro h
        exact hneq <| (Nat.prime_dvd_prime_iff_eq hq hp).1 h)
    exact hqpow.dvd_of_dvd_mul_left <| by simpa [hfu] using hqfx
  have hu_pos : 0 < u := by
    apply Nat.pos_of_ne_zero
    intro hu0
    have : p ^ m * 0 = f X := by simpa [u, hu0] using hfu
    exact (coprimeDetecting_pos hf hXpos).ne' <| by simpa using this.symm
  have hubad : ¬ Nat.Coprime u (p * q) := by
    exact Nat.not_coprime_of_dvd_of_dvd hq.one_lt hqu <| by
      exact dvd_mul_of_dvd_right (dvd_rfl : q ∣ q) p
  have hcop_pu : Nat.Coprime (p ^ m) u := by
    rw [Nat.coprime_pow_left_iff hm_pos]
    exact hp.coprime_iff_not_dvd.2 hu_not_dvd
  have hQ : (f (p ^ m * u)) ^ 2 = f (p ^ m) * f u * f (p ^ m * f u) := by
    exact (coprimeDetecting_Q (m := p ^ m) (n := u) hf (pow_pos hp.pos m) hu_pos).2 hcop_pu
  have hQ' : (f X) ^ 2 = f (p ^ m) * f u * f (p ^ m * f u) := by
    have hffX : f (f X) = f X :=
      coprimeDetecting_idem (n := X) hf hXpos
    have : (f (f X)) ^ 2 = f (p ^ m) * f u * f (p ^ m * f u) := by
      simpa [hfu] using hQ
    simpa [hffX] using this
  have hbad_pm : ¬ Nat.Coprime (p ^ m) (p * q) := by
    exact Nat.not_coprime_of_dvd_of_dvd hp.one_lt
      (dvd_pow_self p hm_pos.ne') (dvd_mul_of_dvd_left (dvd_rfl : p ∣ p) q)
  have hdiv1 : p ^ m ∣ f (p ^ m) := by
    refine (padicValNat_dvd_iff_le (p := p) (a := f (p ^ m)) ?_).2 ?_
    · exact (coprimeDetecting_pos hf (pow_pos hp.pos m)).ne'
    · exact hm_min (pow_pos hp.pos m) hbad_pm
  have hdiv2 : p ^ m ∣ f u := by
    refine (padicValNat_dvd_iff_le (p := p) (a := f u) ?_).2 ?_
    · exact (coprimeDetecting_pos hf hu_pos).ne'
    · exact hm_min hu_pos hubad
  have hdiv3 : p ^ m ∣ f (p ^ m * f u) := by
    refine (padicValNat_dvd_iff_le (p := p) (a := f (p ^ m * f u)) ?_).2 ?_
    · exact (coprimeDetecting_pos hf <|
        Nat.mul_pos (pow_pos hp.pos m) (coprimeDetecting_pos hf hu_pos)).ne'
    · exact hm_min (Nat.mul_pos (pow_pos hp.pos m) (coprimeDetecting_pos hf hu_pos)) <|
        Nat.not_coprime_of_dvd_of_dvd hp.one_lt
          (dvd_mul_of_dvd_left (dvd_pow_self p hm_pos.ne') (f u))
          (dvd_mul_of_dvd_left (dvd_rfl : p ∣ p) q)
  have hdiv12 : p ^ (m + m) ∣ f (p ^ m) * f u := by
    simpa [Nat.pow_add] using Nat.mul_dvd_mul hdiv1 hdiv2
  have hdiv123 : p ^ ((m + m) + m) ∣ (f (p ^ m) * f u) * f (p ^ m * f u) := by
    simpa [Nat.pow_add] using Nat.mul_dvd_mul hdiv12 hdiv3
  have hdivLHS : p ^ (m + m + m) ∣ (f X) ^ 2 := by
    simpa [Nat.add_assoc, Nat.mul_assoc, hQ'] using hdiv123
  have hnotLHS : ¬ p ^ (m + m + m) ∣ (f X) ^ 2 := by
    rw [padicValNat_dvd_iff_le (p := p) (a := (f X) ^ 2)
      (pow_ne_zero 2 (coprimeDetecting_pos hf hXpos).ne')]
    rw [padicValNat.pow 2 (coprimeDetecting_pos hf hXpos).ne', hXm]
    omega
  exact hnotLHS hdivLHS

/-- Every image has exactly the same prime support as its argument. -/
lemma coprimeDetecting_primeFactors_image {f : Nat → Nat} (hf : CoprimeDetectingFunction f)
    {n : Nat} (hn : 0 < n) : (f n).primeFactors = n.primeFactors := by
  ext p
  constructor
  · intro hpfn
    have hp : p.Prime := Nat.prime_of_mem_primeFactors hpfn
    by_contra hpn
    have hpn_dvd : ¬ p ∣ n := by
      intro hpdn
      exact hpn (hp.mem_primeFactors hpdn hn.ne')
    have hnot : ¬ Nat.Coprime n (f p) := by
      exact
        (coprimeDetecting_prime_dvd_iff_not_coprime_prime_image hf hp hn hpn_dvd).1
          (Nat.dvd_of_mem_primeFactors hpfn)
    have hcop : Nat.Coprime n (f p) := by
      refine Nat.coprime_of_dvd ?_
      intro r hr hrdn hrdfp
      have hreq : r = p :=
        coprimeDetecting_prime_image_unique hf hp (by simpa using hr) hrdfp
      exact hpn_dvd (hreq ▸ hrdn)
    exact hnot hcop
  · intro hpn
    have hp : p.Prime := Nat.prime_of_mem_primeFactors hpn
    exact hp.mem_primeFactors
      (coprimeDetecting_prime_dvd_image hf hp hn (Nat.dvd_of_mem_primeFactors hpn))
      (coprimeDetecting_pos hf hn).ne'

/-- A weighted radical: the prime support of `n`, with a fixed positive exponent for each prime. -/
def weightedRad (w : Nat → Nat) (n : Nat) : Nat :=
  ∏ p ∈ n.primeFactors, p ^ w p

/-- The model family realising all admissible values for the problem. -/
def primeSupportWeight (k p : Nat) : Nat :=
  if p ∈ k.primeFactors then k.factorization p else 1

/-- The model family realising all admissible values for the problem. -/
def primeSupportModel (k n : Nat) : Nat :=
  weightedRad (primeSupportWeight k) n

lemma weightedRad_pos {w : Nat → Nat} {n : Nat} : 0 < weightedRad w n := by
  unfold weightedRad
  refine Finset.prod_pos ?_
  intro p hp
  exact pow_pos (Nat.pos_of_mem_primeFactors hp) (w p)

lemma weightedRad_prime_dvd_iff {w : Nat → Nat} (hw : ∀ p, 0 < w p) {p n : Nat}
    (hp : p.Prime) : p ∣ weightedRad w n ↔ p ∈ n.primeFactors := by
  unfold weightedRad
  constructor
  · intro hdiv
    rcases (hp.prime.dvd_finset_prod_iff fun q => q ^ w q).1 hdiv with ⟨q, hqmem, hqdiv⟩
    have hqprime : q.Prime := Nat.prime_of_mem_primeFactors hqmem
    have hpq : p = q := Nat.prime_eq_prime_of_dvd_pow (m := w q) hp hqprime hqdiv
    simpa [hpq] using hqmem
  · intro hmem
    exact dvd_trans (dvd_pow_self p (hw p).ne') <|
      Finset.dvd_prod_of_mem (f := fun q => q ^ w q) hmem

lemma weightedRad_primeFactors {w : Nat → Nat} (hw : ∀ p, 0 < w p) {n : Nat}
    (_hn : 0 < n) : (weightedRad w n).primeFactors = n.primeFactors := by
  ext p
  constructor
  · intro hpw
    have hp : p.Prime := Nat.prime_of_mem_primeFactors hpw
    exact (weightedRad_prime_dvd_iff (w := w) hw hp).1 <|
      Nat.dvd_of_mem_primeFactors hpw
  · intro hpn
    have hp : p.Prime := Nat.prime_of_mem_primeFactors hpn
    exact hp.mem_primeFactors
      ((weightedRad_prime_dvd_iff (w := w) hw hp).2 hpn)
      (weightedRad_pos (w := w)).ne'

lemma weightedRad_eq_of_primeFactors_eq {w : Nat → Nat} {a b : Nat}
    (h : a.primeFactors = b.primeFactors) : weightedRad w a = weightedRad w b := by
  simp [weightedRad, h]

lemma weightedRad_sq {w : Nat → Nat} {n : Nat} : weightedRad w (n ^ 2) = weightedRad w n := by
  apply weightedRad_eq_of_primeFactors_eq
  exact Nat.primeFactors_pow n (by norm_num)

lemma weightedRad_idem {w : Nat → Nat} (hw : ∀ p, 0 < w p) {n : Nat} (hn : 0 < n) :
    weightedRad w (weightedRad w n) = weightedRad w n := by
  exact weightedRad_eq_of_primeFactors_eq (weightedRad_primeFactors hw hn)

lemma weightedRad_mul_image {w : Nat → Nat} (hw : ∀ p, 0 < w p) {m n : Nat}
    (hm : 0 < m) (hn : 0 < n) :
    weightedRad w (m * weightedRad w n) = weightedRad w (m * n) := by
  apply weightedRad_eq_of_primeFactors_eq
  rw [Nat.primeFactors_mul (Nat.ne_of_gt hm) (weightedRad_pos (w := w)).ne']
  rw [Nat.primeFactors_mul (Nat.ne_of_gt hm) hn.ne']
  rw [weightedRad_primeFactors hw hn]

lemma weightedRad_eq_one_iff {w : Nat → Nat} (hw : ∀ p, 0 < w p) {n : Nat} (hn : 0 < n) :
    weightedRad w n = 1 ↔ n = 1 := by
  constructor
  · intro h
    have hpf : (weightedRad w n).primeFactors = ∅ := by simp [h]
    rw [weightedRad_primeFactors hw hn] at hpf
    exact (Nat.primeFactors_eq_empty.mp hpf).resolve_left hn.ne'
  · intro h
    simp [weightedRad, h]

lemma weightedRad_mul_eq_iff_coprime {w : Nat → Nat} (hw : ∀ p, 0 < w p) {m n : Nat}
    (_hm : 0 < m) (hn : 0 < n) :
    weightedRad w (m * n) = weightedRad w m * weightedRad w n ↔ Nat.Coprime m n := by
  have hprod :
      weightedRad w (m.gcd n) * weightedRad w (m * n) = weightedRad w m * weightedRad w n := by
    simpa [weightedRad] using
      Nat.prod_primeFactors_gcd_mul_prod_primeFactors_mul m n (fun p => p ^ w p)
  constructor
  · intro hEq
    have hOne : weightedRad w (m.gcd n) = 1 := by
      apply Nat.eq_of_mul_eq_mul_right (weightedRad_pos (w := w))
      calc
        weightedRad w (m.gcd n) * weightedRad w (m * n) = weightedRad w m * weightedRad w n := hprod
        _ = weightedRad w (m * n) := hEq.symm
        _ = 1 * weightedRad w (m * n) := by simp
    have hgpos : 0 < m.gcd n := Nat.gcd_pos_of_pos_right m hn
    exact Nat.coprime_iff_gcd_eq_one.2 <| (weightedRad_eq_one_iff hw hgpos).1 hOne
  · intro hcop
    calc
      weightedRad w (m * n) = weightedRad w (m.gcd n) * weightedRad w (m * n) := by
        rw [Nat.coprime_iff_gcd_eq_one.mp hcop]
        simp [weightedRad]
      _ = weightedRad w m * weightedRad w n := hprod

lemma weightedRad_isSolution {w : Nat → Nat} (hw : ∀ p, 0 < w p) :
    CoprimeDetectingFunction (weightedRad w) := by
  constructor
  · intro n hn
    exact weightedRad_pos (w := w)
  · intro m n hm hn
    constructor
    · intro hEq
      have hsq : weightedRad w (m ^ 2) = weightedRad w m := weightedRad_sq (w := w)
      have hidem : weightedRad w (weightedRad w n) = weightedRad w n :=
        weightedRad_idem hw hn
      have hmul :
          weightedRad w (m * weightedRad w n) = weightedRad w (m * n) :=
        weightedRad_mul_image hw hm hn
      have hmnpos : 0 < weightedRad w (m * n) :=
        weightedRad_pos (w := w)
      have hEq'' :
          weightedRad w (m * n) ^ 2 =
            weightedRad w m * weightedRad w n * weightedRad w (m * n) := by
        simpa [hsq, hidem, hmul, Nat.mul_assoc, Nat.mul_left_comm, Nat.mul_comm] using hEq
      have hEq' : weightedRad w (m * n) = weightedRad w m * weightedRad w n :=
        (sq_eq_mul_right_of_pos hmnpos).1 hEq''
      exact (weightedRad_mul_eq_iff_coprime hw hm hn).1 hEq'
    · intro hcop
      have hsq : weightedRad w (m ^ 2) = weightedRad w m := weightedRad_sq (w := w)
      have hidem : weightedRad w (weightedRad w n) = weightedRad w n :=
        weightedRad_idem hw hn
      have hmul :
          weightedRad w (m * weightedRad w n) = weightedRad w (m * n) :=
        weightedRad_mul_image hw hm hn
      have hEq' : weightedRad w (m * n) = weightedRad w m * weightedRad w n :=
        (weightedRad_mul_eq_iff_coprime hw hm hn).2 hcop
      have hEq'' :
          weightedRad w (m * n) ^ 2 =
            weightedRad w m * weightedRad w n * weightedRad w (m * n) := by
        rw [hEq']
        simp [pow_two, Nat.mul_left_comm, Nat.mul_comm]
      simpa [hsq, hidem, hmul, Nat.mul_assoc, Nat.mul_left_comm, Nat.mul_comm] using hEq''

lemma primeSupportWeight_pos (k p : Nat) : 0 < primeSupportWeight k p := by
  by_cases hp : p ∈ k.primeFactors
  · unfold primeSupportWeight
    rw [if_pos hp]
    exact Nat.Prime.factorization_pos_of_dvd (Nat.prime_of_mem_primeFactors hp)
      ((Nat.mem_primeFactors.mp hp).2.2) (Nat.dvd_of_mem_primeFactors hp)
  · unfold primeSupportWeight
    rw [if_neg hp]
    exact Nat.succ_pos 0

lemma primeSupportModel_isSolution (k : Nat) : CoprimeDetectingFunction (primeSupportModel k) := by
  simpa [primeSupportModel] using
    weightedRad_isSolution (w := primeSupportWeight k) (primeSupportWeight_pos k)

lemma primeSupportModel_eq_of_primeFactors_eq {k n : Nat} (hk : 0 < k)
    (hkn : k.primeFactors = n.primeFactors) : primeSupportModel k n = k := by
  unfold primeSupportModel weightedRad primeSupportWeight
  rw [← hkn]
  calc
    ∏ p ∈ k.primeFactors, p ^ (if p ∈ k.primeFactors then k.factorization p else 1)
        = ∏ p ∈ k.primeFactors, p ^ k.factorization p := by
          refine Finset.prod_congr rfl ?_
          intro p hp
          rw [if_pos hp]
    _ = ∏ p : k.primeFactors, (p : ℕ) ^ k.factorization p := by
          exact (Finset.prod_attach k.primeFactors (fun p => p ^ k.factorization p)).symm
    _ = k := (Nat.prod_pow_primeFactors_factorization hk.ne').symm

/-- For a fixed positive `n`, the admissible values of `f n` are exactly the positive integers
with the same prime support as `n`. -/
theorem imo2024_sl_n7_values {n k : Nat} (hn : 0 < n) (hk : 0 < k) :
    (∃ f, CoprimeDetectingFunction f ∧ f n = k) ↔ k.primeFactors = n.primeFactors := by
  constructor
  · rintro ⟨f, hf, rfl⟩
    simpa using coprimeDetecting_primeFactors_image hf hn
  · intro hkn
    exact ⟨primeSupportModel k, primeSupportModel_isSolution k,
      primeSupportModel_eq_of_primeFactors_eq hk hkn⟩

end Biblioteca.Demonstrations
