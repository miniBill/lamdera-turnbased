module Theme exposing (Attribute, Element, colors, column, fateTitle, fonts, padding, row, rythm, spacing, wanderhomeOnlineTitle, wrappedRow)

import Element.WithContext as Element exposing (Attribute, Color, Element, alignRight, el, fill, image, px, rgb255, text, width)
import Element.WithContext.Font as Font
import Shared.Model exposing (Context)


type alias Element msg =
    Element.Element Context msg


type alias Attribute msg =
    Element.Attribute Context msg


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
        [ fonts.luminari
        , Font.size 70
        , Element.paddingEach { top = 28, left = 26, bottom = 26, right = 6 }
        ]
        [ el
            [ fonts.ruritania
            , Element.moveDown 10
            ]
            (Element.text "O")
        , Element.text "nline "
        , el
            [ fonts.ruritania
            , Element.moveDown 10
            ]
            (Element.text " W")
        , el
            [ Element.below <|
                Element.row
                    [ fonts.arnoPro
                    , Font.size 30
                    , Element.moveRight 5
                    , Element.moveUp 10
                    ]
                    [ Element.text "Independent Content "
                    , image
                        [ width <| px 30
                        , Element.moveUp 2
                        ]
                        { src = "/wanderhome-flower.png"
                        , description = "A flowery glyph"
                        }
                    ]
            ]
            (Element.text "anderhome")
        ]


colors :
    { wanderhome : Color
    , wanderhomeBackground : Color
    , fate : Color
    , fateBackground : Color
    }
colors =
    { wanderhome = rgb255 0x1C 0x54 0x49
    , wanderhomeBackground = rgb255 0xFB 0xEB 0xBA
    , fate = rgb255 0xFF 0xFF 0xFF
    , fateBackground = rgb255 0 0x55 0x88
    }


fonts :
    { arnoPro : Attribute msg
    , luminari : Attribute msg
    , ruritania : Attribute msg
    , garamond : Attribute msg
    , gotham : Attribute msg
    }
fonts =
    { arnoPro = Font.family [ Font.typeface "Arno Pro" ]
    , luminari = Font.family [ Font.typeface "Luminari" ]
    , ruritania = Font.family [ Font.typeface "Ruritania" ]
    , garamond = Font.family [ Font.typeface "Garamond" ]
    , gotham = Font.family [ Font.typeface "Gotham" ]
    }


fateTitle : Element msg
fateTitle =
    row [ width fill ]
        [ el
            [ fonts.gotham
            , Font.size 60
            , Element.moveDown 14
            ]
            (text "FATE ONLINE")
        , image
            [ width <| px 300
            , alignRight
            ]
            { src = "/powered-by-fate-dark.png"
            , description = "Powered by Fate logo"
            }
        ]
