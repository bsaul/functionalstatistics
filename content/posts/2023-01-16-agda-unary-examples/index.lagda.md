---
title: Unary Relation Examples
author: "Bradley Saul"
date: 2023-01-16T14:02:14-05:00
tags: ["agda"]
---

Lately I've been learning the dependently typed programming language
[Agda](https://agda.readthedocs.io/en/latest/getting-started/what-is-agda.html).
While it's a joy to learn,
learning materials for the
[Agda standard library](https://github.com/agda/agda-stdlib)
are sparse.
In this post, 
I give examples using of the `stdlib`'s
[`Relation.Unary`](https://agda.github.io/agda-stdlib/Relation.Unary.html)
module to do 
[elementary set theory](https://en.wikipedia.org/wiki/Set_theory).
The logical propositions I prove herein are rather trivial,
but for newbies to
[dependently-typed languages](https://en.wikipedia.org/wiki/Dependent_type)
like me,
even the trivial can seem hard.

## Preliminaries

You can read this post without knowing any Agda.
If nothing else, 
you can get a hint of the kinds of things you can do with 
the concept and an implementation of 
[propositions as types](https://ncatlab.org/nlab/show/propositions+as+types).

I make reference to the
[Programming Language Foundations in Agda](https://plfa.github.io)
(PLFA) online book,
and I highly recommend (at least chapter 1) for learning the basics of Agda.

### Basic Structure

The examples follow this structure:

```text
_ : Proposition 
_ = Proof
```

To the right of the `:` is a claim, a proposition.
To the right of the `=` is a proof of that claim.
The `_` on both lines just means I haven't given this expression a name.

## Predicates

Prior to learning Agda/type theory/etc,
I understood the term predicate to mean a unary function
(function of one argument) 
that returns a boolean (i.e. true or false):
`A → Bool`.
This view of predicates as indicator functions
turns out to be rather limited understanding.
Another, richer, understanding sees predicates
as unary functions to `Set`
(the collection of all types): 
`A → Set`.
Here's a 
[hint at what this is all about](https://www.andrej.com/zapiski/ISRM-LOGRAC-2022/01-first-steps-with-agda.lagda.html#predicates-versus-boolean-functions).
and here's a description from the 
[`Relation.Unary` docs](https://agda.github.io/agda-stdlib/Relation.Unary.html):

```text
-- Unary relations are known as predicates and `Pred A ℓ` can be viewed
-- as some property that elements of type A might satisfy.

-- Consequently `P : Pred A ℓ` can also be seen as a subset of A
-- containing all the elements of A that satisfy property P. This view
-- informs much of the notation used below.
```

## Setup

<details>
<summary>Show module setup and imports.</summary>

First, create a
[module](https://agda.readthedocs.io/en/latest/language/module-system.html#basics).
The name of the top-level module of in a file should match the filename.

```agda
module index where
```

By `import`ing `Relation.Unary` module,
we get access to its contents.
The `open` statement brings the module's content into scope
as if the names were define within the current module.
Without the `open` statement,
we'd have to qualify all the names to use them, 
as in `Relation.Unary._∈_`.

```agda
open import Relation.Unary
```

Other imports we'll need:

```agda
open import Data.Unit using ( tt )
open import Level
open import Relation.Binary.PropositionalEquality using ( refl ) 
open import Relation.Nullary using ( ¬_  )
open import Relation.Nullary.Negation using ( contradiction )
open import Data.Product
open import Data.Sum.Base using (_⊎_; inj₁ ; inj₂ ; [_,_]′ )
```
</details>

## Example Set

Here's the three element set I'll work with in the examples:

$$
\{ Orange, Apple, Banana \}
$$

This set can be defined in adga as a
[simple datatype](https://agda.readthedocs.io/en/latest/language/data-types.html#simple-datatypes):

```agda
data Fruit : Set where 
  Orange Apple Banana : Fruit
```

## Example Propositions/Proofs

In each of the examples below,
I show how to one can prove the proposition in the header.
So for example, the first proposition is that $Orange \in \{ Orange \}$,
i.e. $Orange$ is in the singleton set containing $Orange$.
This should hopefully be easy to prove.

### Set inclusion

#### $Orange \in \{ Orange \}$

Indeed, to prove the proposition,
we state `refl`,
which stands for 
[reflexity](https://en.wikipedia.org/wiki/Reflexive_relation).

```agda
_ : Orange ∈ ｛ Orange ｝
_ = refl
```

Inlining ∈ and  ｛_｝ step by step 
might make it easier to see what's going on:

```text
    Orange ∈ ｛ Orange ｝ 
== ｛ Orange ｝ Orange    ( x ∈ P = P x ) 
==  Orange = Orange      ( ｛ x ｝ = x ≡_) 
```

Proof of the statement `Orange = Orange` is `refl`.

#### $\neg ( Banana \in \{ Orange \} )$

The claim $Banana \in \{ Orange \}$ should not hold; 
i.e., we should be able to construct a proof of the negation of the claim.

```agda
_ : ¬ ( Banana ∈ ｛ Orange ｝ )
_ = λ()
```

In this case, we can use an 
[absurd pattern](https://agda.readthedocs.io/en/latest/language/function-definitions.html#absurd-patterns):

> Absurd patterns can be used when
none of the constructors for a particular argument would be valid.

This is indeed the case here, 
as we cannot construct a proof that `Banana = Orange`.
For more on negation in constructive logic and Agda,
see the 
[negation chapter](https://plfa.github.io/Negation/)
in PLFA.

I'll note that the proposition above is equivalent to the following
by definition of 
[`_∉_`](https://agda.github.io/agda-stdlib/Relation.Unary.html#1563):

```agda
_ :  Banana ∉ ｛ Orange ｝ 
_ = λ()
```

#### $Orange \in \{ Orange, Apple \}$

Now I move beyond singleton sets and
define a subset containing both $Orange$ and $Apple$.
This is straighforward with the union `_∪_` operator:

```agda
O∪A : Pred Fruit _ 
O∪A = ｛ Orange ｝ ∪ ｛ Apple ｝
```

The union operator constructs a
[Sum](https://agda.github.io/agda-stdlib/Data.Sum.Base.html#616)
type,
which I think of as the proposition that either 
the `｛ Orange ｝` claim 
or the `｛ Apple ｝` claim holds.
Hence to prove the claim,
we give a proof of $Orange \in \{ Orange \}$ to 
the first (`inj₁`) position in the sum.

```agda
_ : Orange ∈ O∪A 
_ = inj₁ refl
```

For more on the sum type,
see the
[Disjunction as Sum section](https://plfa.github.io/Connectives/#disjunction-is-sum)
in PLFA.

#### $Orange \in \{ Orange, Apple, Banana \}$

The [`U` symbol](https://agda.github.io/agda-stdlib/Relation.Unary.html#1391) 
represents the univeral set for a type. 
I find that symbol hard to distinguish from the 
union operator and infinitary union,
so I'll give the set $\{ Orange, Apple, Banana \}$ a name.

```agda
allFruit : Pred Fruit _ 
allFruit = U
```

The examples holds trivially because `allFruit` is the universal set of `Fruit`.

```agda
_ :  Orange ∈ allFruit 
_ = tt
```

I'll inline the proposition again to see what is needed of the proof.

```text
    Orange ∈ allFruit
== allFruit Orange  ( by definition )
== U Orange         ( by definition )
== (λ _ → ⊤) Orange ( by definition )
== ⊤                ( function application )
```

So we need a term of type `⊤`,
for which `tt` is the only constructor for the 
[`⊤` (unit) type](https://agda.github.io/agda-stdlib/Agda.Builtin.Unit.html#164).

### Subset relations

I'll switch from proofs about set inclusion to proofs on subset relations.

The subset relation states that a proof `P` is a subset of `Q`
is evidence that for all x in `P`, x is also in `Q`.
Or in agda: 

```text
_⊆_ : Pred A ℓ₁ → Pred A ℓ₂ → Set _
P ⊆ Q = ∀ {x} → x ∈ P → x ∈ Q
```

#### $\{ Orange, Apple \} \subseteq \{ Orange, Apple, Banana \}$

The first one is simple:

```agda
_ : O∪A ⊆ allFruit
_ = λ _  → tt 
```

#### $\{ Orange \} \cap \{ Orange, Apple \} \subseteq \{ Orange \}$

```agda
_ : ( ｛ Orange ｝ ∩ O∪A ) ⊆ ｛ Orange ｝
_ = λ ｛O｝∩O∪A → proj₁ ｛O｝∩O∪A
```

Again inlining the claim might it more clear
why the evidence I provided is proof of the claim.

```text
   ∀ {x} → x ∈ ( ｛ Orange ｝ ∩ O∪A ) → x ∈ ｛ Orange ｝  (definition of _⊆_)
== ∀ {x} → (λ y → y ∈ ｛ Orange ｝ × y ∈ O∪A ) x → x ∈ ｛ Orange ｝ (definition of  _∩_)
== ∀ {x} → x ∈ ｛ Orange ｝ × x ∈ O∪A → x ∈ ｛ Orange ｝      (function application )
```

Ignoring the `∀ {x}`,
the claim states that proof is a function that take the product of
`x ∈ ｛ Orange ｝` and `x ∈ O∪A` and returns `x ∈ ｛ Orange ｝`,
which is exactly what I wrote.
Note that I could just as well have written:
`λ x → proj₁ x`.
The name of lambda variable is irrelevant,
but I used the name `｛O｝∩O∪A` to give a visual cue what type is being passed. 

#### $\{ Banana \} \not\subseteq \{ Orange, Apple \}$

This one is little trickier:

```agda
_ : ｛ Banana ｝ ⊈ O∪A 
_ = λ b⊆O∪A → [ ( λ () ) , ( λ () ) ]′ (b⊆O∪A refl) 
```

I used the [`[_,_]′` function](https://agda.github.io/agda-stdlib/Data.Sum.Base.html#971).
to produce a term of `¬ (｛ Banana ｝ ⊆ O∪A  )`.


### Equality of `Pred`

Now that we have an idea how to prove subset relations;
I'll demonstrate proofs for
equality of predicates.
Predicate equality is defined in recent versions of `Relation.Unary`,
but for some reason, it's not in the version I'm using,
so I define it here:

```agda
_≐_ : ∀ {  ℓ₁ ℓ₂ : Level } { C : Set } → Pred C ℓ₁ → Pred C ℓ₂ → Set _
P ≐ Q = (P ⊆ Q) × (Q ⊆ P)
```

I won't go through these in detail.
I will reiterate that proof in each case involves producing a pair proofs,
one for `P ⊆ Q` and another for `Q ⊆ P`.

#### $\{ Orange \} \cap \{ Orange, Apple, Banana \} = \{ Orange \}$

```agda
_ : ( ｛ Orange ｝ ∩ allFruit ) ≐ ( ｛ Orange ｝ )
_ =   (λ ( o∈O , _ ) → o∈O ) 
    , ( λ o∈O →  o∈O , tt )  
```

#### $\{ Orange \} \cap \{ Apple \} = \emptyset$

```agda
_ :  ( ｛ Orange ｝ ∩ ｛ Apple ｝ ) ≐ ∅
_ =   ( λ { (refl , ())}) 
    , ( λ () )
```

#### $\{ Orange \} \cup \{ Apple \} \cup \{ Banana \} = \bigcup$

```agda
_ :  ( ｛ Orange ｝ ∪ ｛ Apple ｝ ∪ ｛ Banana ｝ ) ≐ allFruit
_ =  ( λ _ → tt ) 
    , λ { {Orange} _ →  inj₁ refl
        ; {Apple} _ → inj₂ (inj₁ refl)
        ; {Banana} _ → inj₂ (inj₂ refl)
        } 
```

## Fin

I hope to share more of my Agda learnings in the coming weeks.