import           Control.Applicative ((<$>))
import qualified Data.ByteString.Lazy as L
import qualified Data.Foldable as F
import           Data.Int (Int32, Int64)
import           Data.Monoid ((<>))
import           Data.Text (Text)

import qualified Data.Vector as V
import qualified Data.Vector.Unboxed as U

import           Data.Hadoop.SequenceFile

main :: IO ()
main = do
    printKeys "./tests/long-double.seq"
    recordCount "./tests/text-int.seq"

-- | Print all the keys in a sequence file.
printKeys :: FilePath -> IO ()
printKeys path = do
    bs <- L.readFile path
    let records = failOnError (decode bs) :: Stream (RecordBlock Int64 Double)
    F.for_ records $ \rb -> do
        print (U.take 10 $ rbKeys rb)
    F.for_ records $ \rb -> do
        print (U.take 10 $ rbValues rb)

-- | Count the number of records in a sequence file.
recordCount :: FilePath -> IO ()
recordCount path = do
    bs <- L.readFile path
    let records = decode bs :: Stream (RecordBlock Text Int32)
    putStrLn $ "Records = " <> show (F.sum $ rbCount <$> records)

failOnError :: Stream a -> Stream a
failOnError (Error err) = error err
failOnError x           = x
