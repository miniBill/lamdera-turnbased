module Generate exposing (main)

{-| -}

import Elm
import Elm.Annotation as Annotation
import Gen.CodeGen.Generate as Generate
import Gen.Types.GameId
import GenericDict


main : Program {} () ()
main =
    Generate.run
        [ gameIdDictFile
        ]


gameIdDictFile : Elm.File
gameIdDictFile =
    GenericDict.init
        { keyType = Gen.Types.GameId.annotation_.gameId
        , namespace = [ "Types" ]
        , toComparable =
            \v ->
                Gen.Types.GameId.toString v
                    |> Elm.withType Annotation.string
        }
        |> GenericDict.withTypeName "GameIdDict"
        |> GenericDict.generateFile
