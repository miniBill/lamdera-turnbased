module Generate exposing (main)

{-| -}

import Dict
import Elm
import Elm.Annotation as Annotation
import Gen.CodeGen.Generate as Generate exposing (Directory(..))
import Gen.Element.WithContext.Font as Font
import Gen.Types.GameId
import Gen.Types.UserId
import GenericDict
import Json.Decode exposing (Decoder, Value)
import List.Extra
import Result.Extra
import String.Extra


main : Program Value () ()
main =
    Platform.worker
        { init =
            \flags ->
                ( ()
                , flags
                    |> Json.Decode.decodeValue directoryDecoder
                    |> Result.mapError Json.Decode.errorToString
                    |> Result.andThen
                        (\input ->
                            [ Ok gameIdDictFile
                            , Ok userIdDictFile
                            , fontsFile input
                            , imagesFile input
                            ]
                                |> Result.Extra.combine
                        )
                    |> Result.map Generate.files
                    |> Result.mapError
                        (\e ->
                            Generate.error
                                [ { title = "Error generating file"
                                  , description = e
                                  }
                                ]
                        )
                    |> Result.Extra.merge
                )
        , update =
            \_ model ->
                ( model, Cmd.none )
        , subscriptions = \_ -> Sub.none
        }


directoryDecoder : Decoder Directory
directoryDecoder =
    Json.Decode.lazy
        (\_ ->
            Json.Decode.oneOf
                [ Json.Decode.map Ok Json.Decode.string
                , Json.Decode.map Err directoryDecoder
                ]
                |> Json.Decode.dict
                |> Json.Decode.map
                    (\entries ->
                        entries
                            |> Dict.toList
                            |> List.foldl
                                (\( name, entry ) ( dirAcc, fileAcc ) ->
                                    case entry of
                                        Ok file ->
                                            ( dirAcc, ( name, file ) :: fileAcc )

                                        Err directory ->
                                            ( ( name, directory ) :: dirAcc, fileAcc )
                                )
                                ( [], [] )
                            |> (\( dirAcc, fileAcc ) ->
                                    Directory
                                        { directories = Dict.fromList dirAcc
                                        , files = Dict.fromList fileAcc
                                        }
                               )
                    )
        )


fontsFile : Directory -> Result String Elm.File
fontsFile (Directory { directories }) =
    case Dict.get "fonts" directories of
        Nothing ->
            Err "Fonts folder not found"

        Just (Directory fonts) ->
            fonts.files
                |> Dict.keys
                |> List.map
                    (\filename ->
                        let
                            path =
                                "/fonts/" ++ filename

                            rawName =
                                filename
                                    |> String.split "-"
                                    |> List.head
                                    |> Maybe.withDefault ""
                                    |> String.split "."
                                    |> List.head
                                    |> Maybe.withDefault ""

                            varName =
                                String.Extra.decapitalize rawName

                            fontName =
                                rawName
                                    |> String.Extra.humanize
                                    |> String.Extra.toTitleCase
                        in
                        { path = path
                        , fontName = fontName
                        , varName = varName
                        }
                    )
                |> List.Extra.uniqueBy .varName
                |> List.concatMap
                    (\{ path, fontName, varName } ->
                        [ Font.family [ Font.typeface fontName ]
                            |> Elm.declaration varName
                            |> Elm.exposeWith
                                { exposeConstructor = False
                                , group = Just "Attributes"
                                }
                        , path
                            |> Elm.string
                            |> Elm.declaration (varName ++ "Path")
                            |> Elm.exposeWith
                                { exposeConstructor = False
                                , group = Just "Paths"
                                }
                        ]
                    )
                |> Elm.file
                    [ "Fonts" ]
                |> Ok


imagesFile : Directory -> Result String Elm.File
imagesFile (Directory { directories }) =
    case Dict.get "images" directories of
        Nothing ->
            Err "Images folder not found"

        Just (Directory images) ->
            images.files
                |> Dict.keys
                |> List.concatMap
                    (\filename ->
                        let
                            path =
                                "/images/" ++ filename

                            varName =
                                filename
                                    |> String.split "-"
                                    |> List.head
                                    |> Maybe.withDefault ""
                                    |> String.Extra.camelize
                                    |> String.Extra.decapitalize
                        in
                        [ path
                            |> Elm.string
                            |> Elm.declaration varName
                            |> Elm.expose
                        ]
                    )
                |> Elm.file [ "Images" ]
                |> Ok


userIdDictFile : Elm.File
userIdDictFile =
    GenericDict.init
        { keyType = Gen.Types.UserId.annotation_.userId
        , namespace = [ "Types" ]
        , toComparable =
            \v ->
                Gen.Types.UserId.toString v
                    |> Elm.withType Annotation.string
        }
        |> GenericDict.withTypeName "UserIdDict"
        |> GenericDict.generateFile


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
