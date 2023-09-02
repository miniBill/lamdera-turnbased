module Theme.Fate exposing (button, colors, titledBox)

import Element.WithContext as Element exposing (Color, alignBottom, alignTop, centerX, centerY, el, fill, height, padding, px, rgb, rgb255, shrink, width)
import Element.WithContext.Background as Background
import Element.WithContext.Border as Border
import Element.WithContext.Font as Font
import Element.WithContext.Input as Input
import Theme exposing (Attribute, Element)


colors :
    { active : Color
    , dark : Color
    , disabled : Color
    }
colors =
    { active = rgb255 0x22 0x77 0xAA
    , dark = rgb255 0 0x00 0x22
    , disabled = rgb 0.6 0.6 0.6
    }


button : List (Attribute msg) -> { onPress : Maybe msg, label : Element msg } -> Element msg
button attrs { onPress, label } =
    let
        lbl =
            el [ centerX, centerY ] <|
                label

        withAttrs a =
            List.concat
                [ [ padding <| Theme.rythm // 2
                  , Border.width 1
                  , width <| Element.minimum 42 shrink
                  , height <| Element.minimum 42 shrink
                  , Font.center
                  ]
                , a
                , attrs
                ]
    in
    case onPress of
        Nothing ->
            el
                (withAttrs
                    [ Border.color colors.disabled
                    , Background.color colors.disabled
                    ]
                )
                lbl

        Just _ ->
            Input.button
                (withAttrs
                    [ Background.color colors.active
                    ]
                )
                { onPress = onPress
                , label = lbl
                }


titledBox : Element msg -> List (Attribute msg) -> Element msg -> Element msg
titledBox title attrs elem =
    let
        notchSize =
            px 20

        children =
            [ [ el
                    [ width fill
                    , Background.color colors.dark
                    , Theme.padding
                    ]
                    title
              , Theme.column
                    [ alignTop
                    , height fill
                    , width shrink
                    , Background.color colors.dark
                    ]
                    [ el
                        [ alignBottom
                        , width notchSize
                        , height notchSize
                        , Theme.htmlStyle "background-image" "linear-gradient(135deg, #002 50%, #058 50.5%)"
                        ]
                        Element.none
                    ]
              ]
            , [ Element.el
                    [ width fill
                    , height fill
                    , Border.color colors.dark
                    , Border.widthEach
                        { top = 0
                        , left = 1
                        , bottom = 1
                        , right = 1
                        }
                    ]
                    elem
              , Element.none
              ]
            ]
    in
    Theme.grid (Element.spacing 0 :: attrs) [ fill, shrink ] children
