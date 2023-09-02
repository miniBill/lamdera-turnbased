module Theme.Fate exposing (button)

import Element.WithContext exposing (Color, centerX, centerY, el, height, padding, px, rgb, rgb255, width)
import Element.WithContext.Background as Background
import Element.WithContext.Border as Border
import Element.WithContext.Font as Font
import Element.WithContext.Input as Input
import Theme exposing (Attribute, Element)


colors :
    { active : Color
    , disabled : Color
    }
colors =
    { active = rgb255 0x22 0x77 0xAA
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
                  , width <| px 42
                  , height <| px 42
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
