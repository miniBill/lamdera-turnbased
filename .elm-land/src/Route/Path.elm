module Route.Path exposing (Path(..), fromString, fromUrl, href, toString)

import Html
import Html.Attributes
import Url exposing (Url)
import Url.Parser exposing ((</>))


type Path
    = Home_
    | Admin
    | Fate
    | Fate_Id_ { id : String }
    | Wanderhome
    | Wanderhome_Id_ { id : String }
    | NotFound_


fromUrl : Url -> Path
fromUrl url =
    fromString url.path
        |> Maybe.withDefault NotFound_


fromString : String -> Maybe Path
fromString urlPath =
    let
        urlPathSegments : List String
        urlPathSegments =
            urlPath
                |> String.split "/"
                |> List.filter (String.trim >> String.isEmpty >> Basics.not)
    in
    case urlPathSegments of
        [] ->
            Just Home_

        "admin" :: [] ->
            Just Admin

        "fate" :: [] ->
            Just Fate

        "fate" :: id_ :: [] ->
            Fate_Id_
                { id = id_
                }
                |> Just

        "wanderhome" :: [] ->
            Just Wanderhome

        "wanderhome" :: id_ :: [] ->
            Wanderhome_Id_
                { id = id_
                }
                |> Just

        _ ->
            Nothing


href : Path -> Html.Attribute msg
href path =
    Html.Attributes.href (toString path)


toString : Path -> String
toString path =
    let
        pieces : List String
        pieces =
            case path of
                Home_ ->
                    []

                Admin ->
                    [ "admin" ]

                Fate ->
                    [ "fate" ]

                Fate_Id_ params ->
                    [ "fate", params.id ]

                Wanderhome ->
                    [ "wanderhome" ]

                Wanderhome_Id_ params ->
                    [ "wanderhome", params.id ]

                NotFound_ ->
                    [ "404" ]
    in
    pieces
        |> String.join "/"
        |> String.append "/"
