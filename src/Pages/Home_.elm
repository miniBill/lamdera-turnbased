module Pages.Home_ exposing (Model, Msg(..), page, updateFromBackend)

import Bridge exposing (ToFrontendPage(..))
import Diceware
import Dict
import Effect exposing (..)
import Element.WithContext as Element exposing (alignBottom, alignRight, centerX, centerY, el, fill, image, link, paddingEach, paragraph, px, rgb255, text, width)
import Element.WithContext.Background as Background
import Element.WithContext.Border as Border
import Element.WithContext.Font as Font
import Html.Attributes
import Page exposing (Page)
import Random
import Route exposing (Route)
import Route.Path
import Shared
import Theme
import View exposing (View)


page : Shared.Model -> Route () -> Page Model Msg
page shared _ =
    Page.new
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view shared
        }



-- INIT


type alias Model =
    { input : String
    , placeholder : Maybe String
    }


init : () -> ( Model, Effect Msg )
init _ =
    ( { input = ""
      , placeholder = Nothing
      }
    , Random.int Diceware.listLength (Diceware.listLength ^ 2 - 1)
        |> Random.map Diceware.numberToWords
        |> Random.generate Placeholder
        |> Effect.sendCmd
    )



-- UPDATE


type Msg
    = Input String
    | Placeholder String


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        Input input ->
            ( { model | input = input }, Effect.none )

        Placeholder placeholder ->
            ( { model | placeholder = Just placeholder }, Effect.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Shared.Model -> Model -> View Msg
view _ _ =
    { kind = View.Home
    , body =
        Theme.column
            [ centerX
            , centerY
            ]
            [ link
                [ centerX
                , Border.width 1
                , Theme.padding
                , Border.rounded Theme.rythm
                , Background.color Theme.colors.wanderhomeBackground
                , Font.color Theme.colors.wanderhome
                ]
                { url =
                    Route.toString
                        { path = Route.Path.Wanderhome
                        , query = Dict.empty
                        , hash = Nothing
                        }
                , label = Theme.wanderhomeOnlineTitle
                }
            , link
                [ centerX
                , Border.width 1
                , Theme.padding
                , Border.rounded Theme.rythm
                , width fill
                , Border.color <| rgb255 0 0 0
                , Background.color Theme.colors.fateCoreBackground
                , Font.color Theme.colors.fateCore
                ]
                { url =
                    Route.toString
                        { path = Route.Path.Fate
                        , query = Dict.empty
                        , hash = Nothing
                        }
                , label =
                    Theme.row [ width fill ]
                        [ el
                            [ Theme.fonts.gotham
                            , Font.size 60
                            , Element.moveDown 12
                            ]
                            (text " FATE ONLINE")
                        , image
                            [ width <| px 300
                            , alignRight
                            ]
                            { src = "/powered-by-fate-dark.png"
                            , description = "Powered by Fate"
                            }
                        ]
                }
            ]
    }


updateFromBackend : ToFrontendPage -> Model -> ( Model, Cmd Msg )
updateFromBackend msg model =
    case msg of
        TFSessions _ ->
            ( model, Cmd.none )
