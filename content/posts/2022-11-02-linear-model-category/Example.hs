
-- necessary to write infix notionate for morphism `k`
{-# LANGUAGE TypeOperators #-}
-- necessary for KnownNat matrix sizes
{-# LANGUAGE DataKinds #-}
-- necessary for i quasiquoter
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}

module Example where

import qualified Prelude as P hiding ( zipWith )
import qualified Data.Bifunctor as B
import qualified Data.Text as T
import qualified Data.Text.IO as T
import Data.String.Interpolate ( i )
import GHC.TypeLits (KnownNat)
import qualified Numeric.LinearAlgebra as LA
import Numeric.LinearAlgebra.Static hiding (dot, mean, R)


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

--- category Hask

instance Category (->) where
  id = P.id
  (>>>) = P.flip (P..)

instance Cartesian (->) where
  exl = P.fst
  exr = P.snd
  (△) f g x =  (f x, g x)

instance Strong (->) where
  first = B.first
  second = B.second

instance MatrixPrimitives (->) where
  compose = P.uncurry (<>)
  transpose = tr
  invert = inv

--- R 

newtype R a b = MkR T.Text deriving (P.Eq)

instance P.Show (R a b) where
  show (MkR x) = P.show x

genRcode :: R a b -> P.IO ()
genRcode (MkR x )= T.writeFile "test.R" ("catf <-" P.<> x P.<> "\n")

instance Category R where
  id = MkR "\\(x) x"
  (>>>) (MkR f) (MkR g) = MkR [i|
  function(x) {
    f <- #{f}
    g <- #{g}
    g(f(x)) 
  }|]

instance Cartesian R where
  exl = MkR "\\(x) x[[1]]"
  exr = MkR "\\(x) x[[2]]"
  (△) (MkR f) (MkR g)  = MkR [i|
  function(x) {
    f <- #{f}
    g <- #{g}
    list(f(x), g(x))
  }|]


instance Strong R where
  first (MkR f) = MkR [i|
    function(x) {
      f <- #{f}
      x[[1]] <- f(x[[1]])
      x
    }
    |]
  second (MkR g) = MkR [i|
    function(x) {
      g <- #{g}
      x[[2]] <- g(x[[2]])
      x
    }
    |]


instance MatrixPrimitives R where
  transpose = MkR "function(x) { t(x) }"
  compose = MkR "function(x) { x[[1]] %*% x[[2]] }"
  invert = MkR "function(x) { solve(x) }"


---- linear regression

lmFit :: (Cartesian k, Strong k, MatrixPrimitives k
        , KnownNat p, KnownNat n, KnownNat m) =>
    (L n p, L n m) `k` L p m
lmFit = 
  first (copy
        >>> second ( transpose >>> copy)
        >>> ((exr >>> exl) △ exl) △ (exr >>> exl)
        >>> first (compose >>> invert)
        >>> compose)
  >>> compose

  -- first (copy
  --       >>> second ( transpose >>> copy)
  --       >>> ((exr >>> exl) △ exl) △ (exr >>> exl)
  --       >>> first (compose >>> invert)
  --       >>> compose)
  -- >>> compose


--- example

a = matrix
    [ 2, 0,-1
    , 1, 1, 7
    , 5, 3, 1
    , 5, 1, 1] :: L 4 3

x = matrix [1, 1, 1, 1] :: L 4 1

y = matrix
    [ 2
    , 1
    , 0
    , 2] :: L 4 1

test = lmFit (x, y)

r :: (L 4 1, L 4 1) `R` L 1 1
r = lmFit