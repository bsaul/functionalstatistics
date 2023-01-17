---
title: The unit interval for ℚ
---


Herein we define the unit ($[0, 1]$) interval for rational numbers.
The module structures follows that of the Agda standard library:
one module for unnormalised rationals
and one for normalized rationals.


```agda
module unit-rational where
open import Relation.Unary
open import Level
```


```agda
module 0-1-Rational-Unnormalised where 

  open import Data.Rational.Unnormalised.Base as ℚᵘ
  open import Data.Rational.Unnormalised.Properties using ( p≤q⇒p-q≤0 )
  
  LtEq1ℚᵘ : Pred ℚᵘ 0ℓ
  LtEq1ℚᵘ p = ℚᵘ.NonPositive ( p - 1ℚᵘ )

  ≤-1ℚᵘ : ∀ {p} →  p ≤ 1ℚᵘ → LtEq1ℚᵘ p
  ≤-1ℚᵘ p = ℚᵘ.nonPositive (p≤q⇒p-q≤0 p)

  [0,1]ℚᵘ : Pred ℚᵘ 0ℓ
  [0,1]ℚᵘ = ℚᵘ.NonNegative ∩ LtEq1ℚᵘ

open 0-1-Rational-Unnormalised
```

```agda
module 0-1-Rational where 

  open import Data.Rational.Base as ℚ
  open import Data.Rational.Unnormalised.Base as ℚᵘ using ( *≤* )
  
  LtEq1ℚ : Pred ℚ 0ℓ
  LtEq1ℚ p = LtEq1ℚᵘ (toℚᵘ p)
  
  ≤-1ℚ : ∀ {p} → p ≤ 1ℚ → LtEq1ℚ p
  ≤-1ℚ {p@(mkℚ _ _ _)} (*≤* p≤q) = ≤-1ℚᵘ {toℚᵘ p} (ℚᵘ.*≤* p≤q)

  [0,1]ℚ : Pred ℚ 0ℓ
  [0,1]ℚ = ℚ.NonNegative ∩ LtEq1ℚ 

open 0-1-Rational
```

## Examples 

The following examples serve as sanity checks,
demonstrating the `[0,1]ℚ` predicate.

```agda
module examples where 
  
  open import Data.Unit using ( tt )
  open import Data.Rational
  open import Data.Product using ( _,_ )

  ex1 : ½ ∈ [0,1]ℚ
  ex1 = tt , tt

  ex2 : 0ℚ ∈ [0,1]ℚ
  ex2 = tt , tt

  ex3 : 1ℚ ∈ [0,1]ℚ
  ex3 = tt , tt

  ex4 : ( normalize 3 4 ) ∈ [0,1]ℚ
  ex4 = tt , tt

  ex5 : ( normalize 1 10000 ) ∈ [0,1]ℚ
  ex5 = tt , tt

  ex6 : ( normalize 5 4 ) ∉ [0,1]ℚ
  ex6 ()

  ex7 : -½ ∉ [0,1]ℚ
  ex7 () 
```