module View exposing
    ( View, map
    , none, fromString
    , toBrowserDocument
    )

{-|

@docs View, map
@docs none, fromString
@docs toBrowserDocument

-}

import Browser
import Element.WithContext as Element exposing (alignBottom, centerX, fill, height, link, paragraph, text, textColumn, width)
import Element.WithContext.Font as Font
import Html
import Route exposing (Route)
import Shared.Model
import Theme exposing (Element)


type alias View msg =
    { title : String
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
    { title = view.title
    , body =
        [ Html.node "style"
            []
            [ Html.text fontsCss ]
        , Element.layout shared.context
            [ width fill
            , height fill
            , Font.family [ Theme.fonts.arnoPro ]
            ]
          <|
            Theme.column
                [ width fill
                , height fill
                , Theme.padding
                ]
                [ view.body
                , textColumn
                    [ centerX
                    , alignBottom
                    ]
                    [ paragraph []
                        [ link [ Font.underline ]
                            { url = "https://possumcreekgames.com/pages/wanderhome"
                            , label = text "Wanderhome"
                            }
                        , text " is copyright of "
                        , link [ Font.underline ]
                            { url = "https://possumcreekgames.com/"
                            , label = text "Possum Creek Games Inc."
                            }
                        ]
                    , paragraph []
                        [ text "Wanderhome Online is an independent production by Leonardo Taglialegne and is not affiliated with Possum Creek Games Inc. It is published under the "
                        , link [ Font.underline ]
                            { url = "https://possumcreekgames.com/pages/wanderhome-3rd-party-license"
                            , label = text "Wanderhome Third Party License"
                            }
                        , text "."
                        ]
                    ]
                ]
        ]
    }


fontsCss : String
fontsCss =
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


fonts :
    List
        { url : String
        , name : String
        , fontStyle : String
        , fontWeight : String
        }
fonts =
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
    { title = view.title
    , body = Element.map fn view.body
    }


{-| Used internally by Elm Land whenever transitioning between
authenticated pages.
-}
none : View msg
none =
    { title = "Wanderhome Online"
    , body = Element.none
    }


{-| If you customize the `View` module, anytime you run `elm-land add page`,
the generated page will use this when adding your `view` function.

That way your app will compile after adding new pages, and you can see
the new page working in the web browser!

-}
fromString : String -> View msg
fromString moduleName =
    { title = moduleName
    , body = Element.text moduleName
    }
