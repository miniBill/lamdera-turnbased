module View exposing
    ( View, map
    , none, fromString
    , toBrowserDocument
    , ViewKind(..)
    )

{-|

@docs View, map
@docs none, fromString
@docs toBrowserDocument

-}

import Browser
import Element.WithContext as Element exposing (alignBottom, el, fill, height, link, paragraph, text, width)
import Element.WithContext.Font as Font
import Html
import Route exposing (Route)
import Shared.Model
import Theme exposing (Element)


type alias View msg =
    { kind : ViewKind
    , body : Element msg
    }


type ViewKind
    = Home
    | Wanderhome
    | FateCore


{-| Used internally by Elm Land to create your application
so it works with Elm's expected `Browser.Document msg` type.
-}
toBrowserDocument :
    { shared : Shared.Model.Model
    , route : Route ()
    , view : View msg
    }
    -> Browser.Document msg
toBrowserDocument { shared, view } =
    let
        data : { title : String, font : Font.Font, footer : List (Element msg) }
        data =
            case view.kind of
                Home ->
                    { title = "TurnBased"
                    , font = Font.sansSerif
                    , footer =
                        footer Theme.fonts.arnoPro wanderhomeFooter
                            ++ el [] (text " ")
                            :: footer Theme.fonts.garamond fateCoreFooter
                    }

                Wanderhome ->
                    { title = "Wanderhome - TurnBased"
                    , font = Theme.fonts.arnoPro
                    , footer = footer Theme.fonts.arnoPro wanderhomeFooter
                    }

                FateCore ->
                    { title = "Fate Core - TurnBased"
                    , font = Theme.fonts.garamond
                    , footer = footer Theme.fonts.garamond fateCoreFooter
                    }
    in
    { title = data.title
    , body =
        [ Html.node "style" [] [ Html.text (fontsCss view.kind) ]
        , Element.layout shared.context
            [ width fill
            , height fill
            , Font.family [ data.font ]
            ]
            (Theme.column
                [ width fill
                , height fill
                , Theme.padding
                ]
                [ view.body
                , Theme.column
                    [ alignBottom
                    , Font.size 14
                    ]
                    data.footer
                ]
            )
        ]
    }


footer : Font.Font -> List (List (Element msg)) -> List (Element msg)
footer font content =
    [ Theme.column
        [ Font.family [ font ] ]
        (List.map (paragraph []) content)
    ]


wanderhomeFooter : List (List (Element msg))
wanderhomeFooter =
    [ [ link [ Font.underline ]
            { url = "https://possumcreekgames.com/pages/wanderhome"
            , label = text "Wanderhome"
            }
      , text " is copyright of "
      , link [ Font.underline ]
            { url = "https://possumcreekgames.com/"
            , label = text "Possum Creek Games Inc."
            }
      ]
    , [ text "Wanderhome Online is an independent production by Leonardo Taglialegne and is not affiliated with Possum Creek Games Inc. It is published under the "
      , link [ Font.underline ]
            { url = "https://possumcreekgames.com/pages/wanderhome-3rd-party-license"
            , label = text "Wanderhome Third Party License"
            }
      , text "."
      ]
    ]


fateCoreFooter : List (List (Element msg))
fateCoreFooter =
    [ [ text "This work is based on "
      , link [ Font.underline ]
            { label = text "Fate Core System"
            , url = "http://www.faterpg.com/"
            }
      , text " and Fate Accelerated Edition, products of Evil Hat Productions, LLC, developed, authored, and edited by Leonard Balsera, Brian Engard, Jeremy Keller, Ryan Macklin, Mike Olson, Clark Valentine, Amanda Valentine, Fred Hicks, and Rob Donoghue, and licensed for our use under the "
      , link [ Font.underline ]
            { label = text "Creative Commons Attribution 3.0 Unported license"
            , url = "http://creativecommons.org/licenses/by/3.0/"
            }
      , text "."
      ]
    , [ text "Fate™ is a trademark of Evil Hat Productions, LLC. The Powered by Fate logo is © Evil Hat Productions, LLC and is used with permission."
      ]
    ]


fontsCss : ViewKind -> String
fontsCss viewKind =
    let
        fonts : List Font
        fonts =
            case viewKind of
                Wanderhome ->
                    wanderhomeFonts

                Home ->
                    wanderhomeFonts ++ fateCoreFonts

                FateCore ->
                    fateCoreFonts
    in
    fonts
        |> List.map
            (\{ url, name, fontStyle, fontWeight } ->
                let
                    quote : String -> String
                    quote value =
                        "\"" ++ value ++ "\""
                in
                """
                @font-face {
                    font-family: """ ++ quote name ++ """;
                    font-style: """ ++ quote fontStyle ++ """;
                    font-weight: """ ++ quote fontWeight ++ """;
                    src: local(""" ++ quote name ++ """), url(""" ++ quote url ++ """);
                }
                """
            )
        |> String.join "\n\n"


type alias Font =
    { url : String
    , name : String
    , fontStyle : String
    , fontWeight : String
    }


fateCoreFonts : List Font
fateCoreFonts =
    [ { url = "/fonts/Garamond.ttf"
      , name = "Garamond"
      , fontStyle = "normal"
      , fontWeight = "normal"
      }
    , { url = "/fonts/Gotham-Ultra.otf"
      , name = "Gotham"
      , fontStyle = "normal"
      , fontWeight = "ultra"
      }
    ]


wanderhomeFonts : List Font
wanderhomeFonts =
    [ { url = "/fonts/ArnoPro.otf"
      , name = "Arno Pro"
      , fontStyle = "normal"
      , fontWeight = "normal"
      }
    , { url = "/fonts/ArnoPro-Italic.otf"
      , name = "Arno Pro"
      , fontStyle = "italic"
      , fontWeight = "normal"
      }
    , { url = "/fonts/ArnoPro-SemiBold-Italic.otf"
      , name = "Arno Pro"
      , fontStyle = "italic"
      , fontWeight = "semibold"
      }
    , { url = "/fonts/Luminari.ttf"
      , name = "Luminari"
      , fontStyle = "normal"
      , fontWeight = "normal"
      }
    , { url = "/fonts/Ruritania.ttf"
      , name = "Ruritania"
      , fontStyle = "normal"
      , fontWeight = "normal"
      }
    ]


{-| Used internally by Elm Land to connect your pages together.
-}
map : (msg1 -> msg2) -> View msg1 -> View msg2
map fn view =
    { kind = view.kind
    , body = Element.map fn view.body
    }


{-| Used internally by Elm Land whenever transitioning between
authenticated pages.
-}
none : View msg
none =
    { kind = Home
    , body = Element.none
    }


{-| If you customize the `View` module, anytime you run `elm-land add page`,
the generated page will use this when adding your `view` function.

That way your app will compile after adding new pages, and you can see
the new page working in the web browser!

-}
fromString : String -> View msg
fromString moduleName =
    { kind = Home
    , body = Element.text moduleName
    }
