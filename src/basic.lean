/-
Copyright (c) 2020 Markus Himmel. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Markus Himmel
-/
import data.set.function
import tactic

open set

def row (i : fin 9) : set (fin 9 × fin 9) := { p | p.1 = i }
def col (i : fin 9) : set (fin 9 × fin 9) := { p | p.2 = i }
def box (i j : fin 3) : set (fin 9 × fin 9) := { p | p.1.1 / 3 = i.1 ∧ p.2.1 / 3 = j.1 }

lemma mem_row (i j k : fin 9) : (j, k) ∈ row i ↔ j = i := iff.rfl
lemma mem_col (i j k : fin 9) : (j, k) ∈ col i ↔ k = i := iff.rfl
lemma mem_box (i j : fin 9) (k l : fin 3) : (i, j) ∈ box k l ↔ i.1 / 3 = k.1 ∧ j.1 / 3 = l.1 := iff.rfl

structure sudoku :=
(f : fin 9 × fin 9 → fin 9)
(h_row : ∀ i : fin 9, set.bij_on f (row i) set.univ)
(h_col : ∀ i : fin 9, set.bij_on f (col i) set.univ)
(h_box : ∀ i j : fin 3, set.bij_on f (box i j) set.univ)

namespace sudoku

lemma cell_cases (s : sudoku) (i j : fin 9) :
  s.f (i, j) = 9 ∨ s.f (i, j) = 1 ∨ s.f (i, j) = 2 ∨ s.f (i, j) = 3 ∨ s.f (i, j) = 4 ∨ s.f (i, j) = 5 ∨ s.f (i, j) = 6 ∨ s.f (i, j) = 7 ∨ s.f (i, j) = 8 :=
begin
  cases s.f (i, j) with v hv,
  interval_cases v; tauto
end

lemma row_cases (s : sudoku) (i j : fin 9) :
  s.f (i, 0) = j ∨ s.f (i, 1) = j ∨ s.f (i, 2) = j ∨ s.f (i, 3) = j ∨ s.f (i, 4) = j ∨ s.f (i, 5) = j ∨ s.f (i, 6) = j ∨ s.f (i, 7) = j ∨ s.f (i, 8) = j :=
begin
  obtain ⟨⟨x, ⟨y, hy⟩⟩, ⟨h, h'⟩⟩ : j ∈ s.f '' row i := (s.h_row i).surj_on trivial,
  rw mem_row at h,
  subst h,
  interval_cases y; tauto
end

lemma col_cases (s : sudoku) (i j : fin 9) :
  s.f (0, i) = j ∨ s.f (1, i) = j ∨ s.f (2, i) = j ∨ s.f (3, i) = j ∨ s.f (4, i) = j ∨ s.f (5, i) = j ∨ s.f (6, i) = j ∨ s.f (7, i) = j ∨ s.f (8, i) = j :=
begin
  obtain ⟨⟨⟨x, hx⟩, y⟩, ⟨h, h'⟩⟩ : j ∈ s.f '' col i := (s.h_col i).surj_on trivial,
  rw mem_col at h,
  subst h,
  interval_cases x; tauto
end

lemma box_cases (s : sudoku) (i j : fin 3) (k : fin 9) :
  s.f ((3 * i.1 : ℕ), (3 * j.1 : ℕ)) = k ∨
  s.f ((3 * i.1 : ℕ), (3 * j.1 + 1 : ℕ)) = k ∨
  s.f ((3 * i.1 : ℕ), (3 * j.1 + 2 : ℕ)) = k ∨
  s.f ((3 * i.1 + 1 : ℕ), (3 * j.1 : ℕ)) = k ∨
  s.f ((3 * i.1 + 1 : ℕ), (3 * j.1 + 1 : ℕ)) = k ∨
  s.f ((3 * i.1 + 1 : ℕ), (3 * j.1 + 2 : ℕ)) = k ∨
  s.f ((3 * i.1 + 2 : ℕ), (3 * j.1 : ℕ)) = k ∨
  s.f ((3 * i.1 + 2 : ℕ), (3 * j.1 + 1 : ℕ)) = k ∨
  s.f ((3 * i.1 + 2 : ℕ), (3 * j.1 + 2 : ℕ)) = k :=
begin
  obtain ⟨⟨x, y⟩, ⟨h, h'⟩⟩ : k ∈ s.f '' box i j := (s.h_box i j).surj_on trivial,
  rw mem_box at h,
  cases h with h₀ h₁,
  have hx : x.1 = 3 * i.val + (x.1 % 3),
  { rw [add_comm, ←h₀, nat.mod_add_div] },
  have hy : y.1 = 3 * j.val + (y.1 % 3),
  { rw [add_comm, ←h₁, nat.mod_add_div] },
  have := nat.mod_lt x.val (show 3 > 0, from dec_trivial),
  have := nat.mod_lt y.val (show 3 > 0, from dec_trivial),
  interval_cases (x.val % 3);
  rw h at hx;
  try { rw add_zero at hx };
  rw ←hx;
  interval_cases (y.val % 3);
  rw h_1 at hy;
  try { rw add_zero at hy };
  simp only [←hy, fin.coe_val_eq_self];
  tauto
end

lemma cell_conflict (s : sudoku) {i j k l : fin 9} (h₀ : s.f (i, j) = k) (h₁ : s.f (i, j) = l)
  (h₂ : k ≠ l) : false :=
begin
  apply h₂,
  rw [←h₀, ←h₁]
end

lemma row_conflict (s : sudoku) {i j k l : fin 9} (h₀ : s.f (i, j) = l) (h₁ : s.f (i, k) = l)
  (h₂ : j ≠ k) : false :=
begin
  apply h₂,
  suffices : (i, j) = (i, k),
  { cases this, refl },
  refine (s.h_row i).inj_on _ _ (h₀.trans h₁.symm);
  rw mem_row
end

lemma col_conflict (s : sudoku) {i j k l : fin 9} (h₀ : s.f (i, k) = l) (h₁ : s.f (j, k) = l)
  (h₂ : i ≠ j) : false :=
begin
  apply h₂,
  suffices : (i, k) = (j, k),
  { cases this, refl },
  refine (s.h_col k).inj_on _ _ (h₀.trans h₁.symm);
  rw mem_col
end

lemma bloop {i : ℕ} (hi : i < 9) : i / 3 < 3 :=
by interval_cases i; exact dec_trivial

lemma box_conflict (s : sudoku) {i j k l m : fin 9} (h₀ : s.f (i, j) = m) (h₁ : s.f (k, l) = m)
  (h₂ : i.1 / 3 = k.1 / 3) (h₃ : j.1 / 3 = l.1 / 3) (h₄ : i ≠ k ∨ j ≠ l) : false :=
begin
  contrapose h₄,
  push_neg,
  clear h₄,
  suffices : (i, j) = (k, l),
  { cases this, exact ⟨rfl, rfl⟩ },
  refine (s.h_box (i.1 / 3 : ℕ) (j.1 / 3 : ℕ)).inj_on _ _ (h₀.trans h₁.symm),
  { rw mem_box,
    split,
    { rw fin.coe_val_of_lt,
      exact bloop i.2 },
    { rw fin.coe_val_of_lt,
      exact bloop j.2 } },
  { rw mem_box,
    split,
    { rw fin.coe_val_of_lt,
      { exact h₂.symm },
      { exact bloop i.2 } },
    { rw fin.coe_val_of_lt,
      { exact h₃.symm },
      { exact bloop j.2 } } }
end

/-- Outer pencil marks capture the fact that a certain number appears in one of two places. -/
def snyder (s : sudoku) (i j k l m : fin 9) : Prop :=
s.f (i, j) = m ∨ s.f (k, l) = m

/-- Inner pencil marks capture the fact that a certain cell contains one of two numbers. -/
def double (s : sudoku) (i j k l : fin 9) : Prop :=
s.f (i, j) = k ∨ s.f (i, j) = l

/-- Inner pencil marks capture the fact that a certain cell contains one of three numbers. -/
def triple (s : sudoku) (i j k l m : fin 9) : Prop :=
s.f (i, j) = k ∨ s.f (i, j) = l ∨ s.f (i, j) = m

/-- The first (trivial) piece of sudoku theory: If there are two outer pencil marks relating two
    cells, then we get an inner pencil mark for those two numbers in both cells. -/
lemma double_left_of_snyder {s : sudoku} {i j k l m n : fin 9} (h₀ : snyder s i j k l m)
  (h₁ : snyder s i j k l n) (h₂ : m ≠ n) : double s i j m n :=
by { unfold double, tidy }

/-- The first (trivial) piece of sudoku theory: If there are two outer pencil marks relating two
    cells, then we get an inner pencil mark for those two numbers in both cells. -/
lemma double_right_of_snyder {s : sudoku} {i j k l m n : fin 9} (h₀ : snyder s i j k l m)
  (h₁ : snyder s i j k l n) (h₂ : m ≠ n) : double s k l m n :=
by { unfold double, tidy }

end sudoku
