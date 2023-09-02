module Theme exposing (Attribute, Context, Element, box, button, colors, column, fateTitle, grid, htmlStyle, onEnter, padding, row, rythm, select, spacing, wanderhomeOnlineTitle, wrappedRow)

import Element.WithContext as Element exposing (Attribute, Color, Column, Element, Length, alignRight, el, image, px, rgb255, shrink, table, text, width)
import Element.WithContext.Background as Background
import Element.WithContext.Border as Border
import Element.WithContext.Font as Font
import Element.WithContext.Input as Input
import Fonts
import Html
import Html.Attributes
import Html.Events
import Images
import Json.Decode
import Shared.Model exposing (LoggedIn, ViewKind)


type alias Element msg =
    Element.Element Context msg


type alias Attribute msg =
    Element.Attribute Context msg


type alias Context =
    { loggedIn : LoggedIn
    , viewKind : ViewKind
    }


row : List (Attribute msg) -> List (Element msg) -> Element msg
row attrs children =
    Element.row (spacing :: attrs) children


column : List (Attribute msg) -> List (Element msg) -> Element msg
column attrs children =
    Element.column (spacing :: attrs) children


wrappedRow : List (Attribute msg) -> List (Element msg) -> Element msg
wrappedRow attrs children =
    Element.wrappedRow (spacing :: attrs) children


spacing : Attribute msg
spacing =
    Element.spacing rythm


padding : Attribute msg
padding =
    Element.padding rythm


rythm : number
rythm =
    10


wanderhomeOnlineTitle : Element msg
wanderhomeOnlineTitle =
    Element.row
        [ Fonts.luminari
        , Font.size 70
        , Element.paddingEach { top = 28, left = 26, bottom = 26, right = 6 }
        ]
        [ el
            [ Fonts.ruritania
            , Element.moveDown 10
            ]
            (Element.text "O")
        , Element.text "nline "
        , el
            [ Fonts.ruritania
            , Element.moveDown 10
            ]
            (Element.text " W")
        , el
            [ Element.below <|
                Element.row
                    [ Fonts.arnoPro
                    , Font.size 30
                    , Element.moveRight 5
                    , Element.moveUp 10
                    ]
                    [ Element.text "Independent Content "
                    , image
                        [ width <| px 30
                        , Element.moveUp 2
                        ]
                        { src = Images.wanderhomeFlower
                        , description = "A flowery glyph"
                        }
                    ]
            ]
            (Element.text "anderhome")
        ]


colors :
    { fate : Color
    , fateBackground : Color
    , wanderhome : Color
    , wanderhomeBackground : Color
    }
colors =
    { fate = rgb255 0xFF 0xFF 0xFF
    , fateBackground = rgb255 0 0x55 0x88
    , wanderhome = rgb255 0x1C 0x54 0x49
    , wanderhomeBackground = rgb255 0xFB 0xEB 0xBA
    }


fateTitle : List (Attribute msg) -> Element msg
fateTitle attrs =
    row attrs
        [ el
            [ Fonts.gotham
            , Font.size 60
            , Element.moveDown 14
            ]
            (text "FATE ONLINE")
        , image
            [ width <| px 300
            , alignRight
            ]
            { src = Images.poweredByFateDark
            , description = "Powered by Fate logo"
            }
        ]


button :
    List (Attribute msg)
    ->
        { onPress : Maybe msg
        , label : Element msg
        }
    -> Element msg
button attrs config =
    if config.onPress == Nothing then
        el
            ([ Border.width 1
             , Border.rounded rythm
             , padding
             , Background.color <| rgb255 0xC0 0xC0 0xC0
             ]
                ++ attrs
            )
            config.label

    else
        Input.button
            ([ Border.width 1
             , Border.rounded rythm
             , padding
             , Background.color <| rgb255 0x9D 0xB7 0xD6
             ]
                ++ attrs
            )
            config


onEnter : msg -> Attribute msg
onEnter msg =
    Element.htmlAttribute <|
        Html.Events.on "keyup" <|
            (Json.Decode.string
                |> Json.Decode.field "key"
                |> Json.Decode.andThen
                    (\key ->
                        if key == "Enter" then
                            Json.Decode.succeed msg

                        else
                            Json.Decode.fail "Not the enter key"
                    )
            )


box :
    List (Attribute msg)
    ->
        { label : Element msg
        , children : List (Element msg)
        }
    -> Element msg
box attrs config =
    column attrs
        [ config.label
        , column
            [ padding
            , Border.width 1
            , Border.rounded rythm
            ]
            config.children
        ]


htmlStyle : String -> String -> Attribute msg
htmlStyle key value =
    Element.htmlAttribute <| Html.Attributes.style key value


grid : List (Attribute msg) -> List Length -> List (List (Element msg)) -> Element msg
grid attrs lengths children =
    let
        gridCol : Int -> Column Context (List (Element msg)) msg
        gridCol col =
            { header = Element.none
            , width = lengths |> List.drop col |> List.head |> Maybe.withDefault shrink
            , view =
                \l ->
                    l
                        |> List.drop col
                        |> List.head
                        |> Maybe.withDefault Element.none
            }
    in
    table (spacing :: attrs)
        { data = children
        , columns =
            let
                colCount =
                    children
                        |> List.map List.length
                        |> List.maximum
                        |> Maybe.withDefault 0
            in
            List.range 0 (colCount - 1)
                |> List.map gridCol
        }


select :
    List (Attribute msg)
    ->
        { items : List item
        , view : item -> String
        , selected : Maybe item
        , onChange : Maybe item -> msg
        }
    -> Element msg
select attrs { items, view, selected, onChange } =
    let
        options =
            List.map itemToOption items

        selectedView =
            Maybe.map view selected

        itemToOption item =
            let
                label =
                    view item
            in
            Html.option
                [ Html.Attributes.value label
                , Html.Attributes.selected <| Just label == selectedView
                ]
                [ Html.text label ]

        emptyOption =
            Html.option
                [ Html.Attributes.value ""
                , Html.Attributes.selected <| selected == Nothing
                ]
                [ Html.text "" ]
    in
    el attrs <|
        Element.html <|
            Html.select
                [ Html.Attributes.style "padding" <| String.fromInt (rythm // 2) ++ "px"
                , Html.Events.onInput
                    (\i ->
                        items
                            |> List.filter (\item -> view item == i)
                            |> List.head
                            |> onChange
                    )
                ]
                (emptyOption :: options)
