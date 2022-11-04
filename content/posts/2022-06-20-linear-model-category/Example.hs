
-- necessary to write infix notionate for morphism `k`
{-# LANGUAGE TypeOperators #-}
module Example where

import qualified Prelude as P hiding ( zipWith )
import GHC.TypeLits (KnownNat)
import qualified Numeric.LinearAlgebra as LA
import Numeric.LinearAlgebra.Static hiding (dot, mean)


infixr 1 >>>
infixr 3 △
infixr 3 ***

{-
A category in mathematics is comprised of a set of objects 
and a set of arrow (morphisms) between objects subject to certain laws. 
In Haskell, a category can be represented by he typeclass `Category`
where the category is parameterized the type of its arrows.
-}
class Category k where
  -- The identity morphism takes an object A and returns A
  id :: a `k` a
  -- The composition rule says that for any two morphisms A --> B and B --> C,
  -- there exists a morphism A --> C. 
  -- This is encoded by a Haskell function that transforms the morphisms.
  (>>>) :: a `k` b -> b `k` c -> a `k` c

{-
A cartesian categories comes equipped with products:
a way to stick two things together and get them back out.
-}
class Category k => Cartesian k where
  exl :: (l, r) `k` l
  exr :: (l, r) `k` r
  (△) :: a `k` c -> a `k` d -> a `k` (c, d)



{-
It's useful to copy data sometimes.
-}
copy :: (Cartesian k) => a `k` (a, a)
copy = id △ id

{-
Swap the objects around
-}
swap :: (Cartesian k) => (a, b) `k` (b, a)
swap = exr △ exl

{-
The Strong class gives one a way of lifting a mapping into a mapping on pairs.
-}
class Category k => Strong k where
  first :: a `k` b -> (a, other) `k` (b, other)
  second :: a `k` b -> (other, a) `k` (other, b)

(***) :: (Category k, Strong k)
      => l `k` l'
      -> r `k` r'
      -> (l, r) `k` (l', r')
(***) l r = first l >>> second r

(&&&) :: (Cartesian k, Strong k)
      => k a l
      -> k a r
      -> k a (l, r)
(&&&) l r = copy >>> (l *** r )


class MatrixPrimitives k where
  transpose :: (LA.Transposable m mt) => m `k` mt
  invert :: (KnownNat n, Domain f v m) => m n n `k` m n n
  compose :: (KnownNat n, KnownNat p, KnownNat m) => (L m p, L p n) `k` L m n



lmFit :: (Cartesian k, Strong k, MatrixPrimitives k
        , KnownNat p, KnownNat n, KnownNat m) =>
    (L n p, L n m) `k` L p m
lmFit = ((copy
        >>> id *** ( transpose >>> copy)
        >>> ((exr >>> exl) △ exl) △ (exr >>> exl)
        >>> (compose >>> invert) *** id
        >>> compose)
      *** id)
  >>> compose