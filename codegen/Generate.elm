module Generate exposing (main)

{-| -}

import Dict
import Elm
import Elm.Annotation as Annotation
import Gen.CodeGen.Generate as Generate exposing (Directory(..))
import Gen.Element.WithContext.Font as Font
import Gen.Types.GameId
import Gen.Types.Token
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
                            , Ok tokenDictFile
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
                            url : String
                            url =
                                "/fonts/" ++ filename

                            find : List ( String, String ) -> String
                            find options =
                                options
                                    |> List.Extra.findMap
                                        (\( option, mapsTo ) ->
                                            if String.contains (String.toLower option) (String.toLower filename) then
                                                Just mapsTo

                                            else
                                                Nothing
                                        )
                                    |> Maybe.withDefault "normal"

                            style : String
                            style =
                                find
                                    [ ( "Italic", "italic" )
                                    ]

                            weight : String
                            weight =
                                find
                                    [ ( "Medium", "500" )
                                    , ( "SemiBold", "600" )
                                    , ( "Black", "900" )
                                    , ( "Ultra", "950" )
                                    ]

                            rawName : String
                            rawName =
                                filename
                                    |> String.split "."
                                    |> List.head
                                    |> Maybe.withDefault ""
                                    |> String.split "-"
                                    |> List.head
                                    |> Maybe.withDefault ""

                            varName : String
                            varName =
                                String.Extra.decapitalize rawName

                            name : String
                            name =
                                rawName
                                    |> String.Extra.humanize
                                    |> String.Extra.toTitleCase
                        in
                        { url = url
                        , name = name
                        , varName = varName
                        , style = style
                        , weight = weight
                        }
                    )
                |> List.sortBy (\{ name, weight } -> ( name, weight ))
                |> List.Extra.gatherEqualsBy .varName
                |> List.concatMap
                    (\( { name, varName } as head, others ) ->
                        [ Font.family [ Font.typeface name ]
                            |> Elm.declaration varName
                            |> Elm.exposeWith
                                { exposeConstructor = False
                                , group = Just "Attributes"
                                }
                        , (head :: others)
                            |> List.map
                                (\{ url, style, weight } ->
                                    Elm.record
                                        [ ( "url", Elm.string url )
                                        , ( "name", Elm.string name )
                                        , ( "style", Elm.string style )
                                        , ( "weight", Elm.string weight )
                                        ]
                                        |> Elm.withType (Annotation.named [] "Font")
                                )
                            |> Elm.list
                            |> Elm.declaration (varName ++ "Fonts")
                            |> Elm.exposeWith
                                { exposeConstructor = False
                                , group = Just "Fonts"
                                }
                        ]
                    )
                |> (::)
                    (Annotation.record
                        [ ( "url", Annotation.string )
                        , ( "name", Annotation.string )
                        , ( "style", Annotation.string )
                        , ( "weight", Annotation.string )
                        ]
                        |> Elm.alias "Font"
                        |> Elm.exposeWith
                            { exposeConstructor = False
                            , group = Just "Fonts"
                            }
                    )
                |> Elm.file [ "Fonts" ]
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
                                    |> String.split "."
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


tokenDictFile : Elm.File
tokenDictFile =
    GenericDict.init
        { keyType = Gen.Types.Token.annotation_.token
        , namespace = [ "Types" ]
        , toComparable =
            \v ->
                Gen.Types.Token.toString v
                    |> Elm.withType Annotation.string
        }
        |> GenericDict.withTypeName "TokenDict"
        |> GenericDict.generateFile
