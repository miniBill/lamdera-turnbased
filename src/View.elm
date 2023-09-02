module View exposing
    ( View, map
    , none, fromString
    , toBrowserDocument
    , Font
    )

{-|

@docs View, ViewKind, map
@docs none, fromString
@docs toBrowserDocument
@docs Font

-}

import Browser
import Element.WithContext as Element exposing (Color, alignBottom, el, fill, height, link, paragraph, rgb255, text, width)
import Element.WithContext.Background as Background
import Element.WithContext.Font as Font
import Fonts
import Html
import Route exposing (Route)
import Shared.Model exposing (ViewKind(..))
import Theme exposing (Attribute, Element)


type alias View msg =
    { kind : ViewKind
    , body : Element msg
    }


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
        data :
            { title : String
            , font : Attribute msg
            , background : Color
            , color : Color
            , footer : List (Element msg)
            }
        data =
            case view.kind of
                AdminView ->
                    { title = "TurnBased - Admin"
                    , font = Font.family [ Font.sansSerif ]
                    , background = rgb255 0xFF 0xFF 0xFF
                    , color = rgb255 0 0 0
                    , footer = []
                    }

                HomeView ->
                    { title = "TurnBased"
                    , font = Font.family [ Font.sansSerif ]
                    , background = rgb255 0xAD 0xD7 0xF6
                    , color = rgb255 0x28 0x12 0x2B
                    , footer =
                        footer Fonts.arnoPro wanderhomeFooter
                            ++ el [] (text " ")
                            :: footer Fonts.garamond fateFooter
                    }

                WanderhomeView ->
                    { title = "Wanderhome - TurnBased"
                    , font = Fonts.arnoPro
                    , background = Theme.colors.wanderhomeBackground
                    , color = Theme.colors.wanderhome
                    , footer = footer Fonts.arnoPro wanderhomeFooter
                    }

                FateView ->
                    { title = "Fate Core - TurnBased"
                    , font = Fonts.garamond
                    , background = Theme.colors.fateBackground
                    , color = Theme.colors.fate
                    , footer = footer Fonts.garamond fateFooter
                    }
    in
    { title = data.title
    , body =
        [ Html.node "style" [] [ Html.text (fontsCss view.kind) ]
        , Element.layout
            { loggedIn = shared.loggedIn
            , viewKind = view.kind
            }
            [ width fill
            , height fill
            , data.font
            , Font.color data.color
            , Background.color data.background
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
                    , Theme.padding
                    ]
                    data.footer
                ]
            )
        ]
    }


footer : Attribute msg -> List (List (Element msg)) -> List (Element msg)
footer font content =
    [ Theme.column
        [ font ]
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
    , [ text "Online Wanderhome is an independent production by Leonardo Taglialegne and is not affiliated with Possum Creek Games Inc. It is published under the "
      , link [ Font.underline ]
            { url = "https://possumcreekgames.com/pages/wanderhome-3rd-party-license"
            , label = text "Wanderhome Third Party License"
            }
      , text "."
      ]
    ]


fateFooter : List (List (Element msg))
fateFooter =
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
                AdminView ->
                    []

                WanderhomeView ->
                    wanderhomeFonts

                HomeView ->
                    wanderhomeFonts ++ fateFonts

                FateView ->
                    fateFonts
    in
    fonts
        |> List.map
            (\{ url, name, style, weight } ->
                let
                    quote : String -> String
                    quote value =
                        "\"" ++ value ++ "\""
                in
                """
                @font-face {
                    font-family: """ ++ quote name ++ """;
                    font-style: """ ++ quote style ++ """;
                    font-weight: """ ++ quote weight ++ """;
                    src: local(""" ++ quote name ++ """), url(""" ++ quote url ++ """);
                }
                """
            )
        |> String.join "\n\n"


type alias Font =
    { url : String
    , name : String
    , style : String
    , weight : String
    }


fateFonts : List Font
fateFonts =
    Fonts.garamondFonts
        ++ Fonts.gothamFonts


wanderhomeFonts : List Font
wanderhomeFonts =
    Fonts.arnoProFonts
        ++ Fonts.luminariFonts
        ++ Fonts.ruritaniaFonts


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
    { kind = HomeView
    , body = Element.none
    }


{-| If you customize the `View` module, anytime you run `elm-land add page`,
the generated page will use this when adding your `view` function.

That way your app will compile after adding new pages, and you can see
the new page working in the web browser!

-}
fromString : String -> View msg
fromString moduleName =
    { kind = HomeView
    , body = Element.text moduleName
    }
