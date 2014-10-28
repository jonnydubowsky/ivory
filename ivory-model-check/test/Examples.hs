module Examples where

import qualified AddrOfRegression
import qualified Alloc
import qualified Area
import qualified Array
-- import qualified BitData
import qualified Bits
import qualified ClassHierarchy
-- import qualified ConcreteFile
import qualified Cond
-- import qualified ConstRef
import qualified Extern
import qualified Factorial
import qualified FibLoop
-- import qualified FibTutorial
import qualified Float
import qualified Forever
import qualified FunPtr
import qualified Overflow
import qualified PID
import qualified PublicPrivate
-- import qualified QC
import qualified SizeOf
import qualified String
-- import qualified TestClang


modules = [ AddrOfRegression.cmodule
          , Alloc.cmodule
          , Area.cmodule
          , Array.cmodule
          -- , BitData.cmodule
          , Bits.cmodule
          -- , ClassHierarchy.cmodule
          -- , ConcreteFile.examplesFile
          , Cond.cmodule
          -- , ConstRef.cmodule
          , Extern.cmodule
          , Factorial.cmodule
          , FibLoop.cmodule
          -- , FibTutorial.fib_tutorial_module
          , Float.cmodule
          -- , Forever.cmodule
          , FunPtr.cmodule
          , Overflow.cmodule
          , PID.cmodule
          , PublicPrivate.cmodule
          -- , QC.cmodule
          , SizeOf.cmodule
          , String.cmodule
          -- , TestClang.cmodule
          ]