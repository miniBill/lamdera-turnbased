module Theme exposing (Attribute, Element, column, fonts, padding, row, rythm, spacing, wanderhomeOnlineTitle, wrappedRow)

import Element.WithContext as Element exposing (Attribute, Element, el)
import Element.WithContext.Font as Font exposing (Font)
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
        [ Font.size 70
        , Element.below <|
            el
                [ Font.family [ fonts.arnoPro ]
                , Font.size 30
                , Element.moveRight 150
                , Element.moveUp 30
                ]
                (Element.text "Independent Content")
        , Element.paddingEach { top = 28, left = 26, bottom = 26, right = 6 }
        ]
        [ el
            [ Font.family [ fonts.ruritania ]
            , Element.moveDown 10
            ]
            (Element.text "W")
        , el
            [ Font.family [ fonts.luminari ]
            ]
            (Element.text "anderhome Online")
        ]


fonts :
    { arnoPro : Font
    , luminari : Font
    , ruritania : Font
    , garamond : Font
    , gotham : Font
    }
fonts =
    { arnoPro = Font.typeface "Arno Pro"
    , luminari = Font.typeface "Luminari"
    , ruritania = Font.typeface "Ruritania"
    , garamond = Font.typeface "Garamond"
    , gotham = Font.typeface "Gotham"
    }
