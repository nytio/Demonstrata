import Mathlib.Data.ZMod.Basic

namespace Mimate

def hello : String := "world"

theorem two_add_two : (2 : Nat) + 2 = 4 := by
  decide

theorem zmod_example : (2 : ZMod 5) + 3 = 0 := by
  decide

theorem zmod_three_mul_five : (3 : ZMod 7) * 5 = 1 := by
  decide

end Mimate
