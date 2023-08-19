module Pages.Home_ exposing (Model, Msg(..), page, updateFromBackend)

import Bridge exposing (ToFrontendPage(..))
import Diceware
import Dict
import Effect exposing (..)
import Element.WithContext as Element exposing (centerX, centerY, el, link, rgb255, text)
import Element.WithContext.Border as Border
import Element.WithContext.Font as Font
import Element.WithContext.Input as Input
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
view _ model =
    { title = "Fate Core"
    , body =
        Theme.column
            [ centerX
            , centerY
            ]
            [ Input.text [ Font.center ]
                { label = Input.labelAbove [ centerX ] <| text "Join game"
                , onChange = Input
                , text = model.input
                , placeholder =
                    Maybe.map
                        (\placeholder ->
                            Input.placeholder [] <| text placeholder
                        )
                        model.placeholder
                }
            , if String.length model.input > 5 then
                link
                    [ centerX
                    , Border.width 1
                    , Theme.padding
                    , Border.rounded Theme.rythm
                    ]
                    { url =
                        Route.toString
                            { path = Route.Path.Id_ { id = model.input }
                            , query = Dict.empty
                            , hash = Nothing
                            }
                    , label = text "Play"
                    }

              else
                el
                    [ Theme.padding
                    , Border.width 1
                    , Border.color <| rgb255 255 255 255
                    ]
                <|
                    text " "
            ]
    }


updateFromBackend : ToFrontendPage -> Model -> ( Model, Cmd Msg )
updateFromBackend msg model =
    case msg of
        TFSessions _ ->
            ( model, Cmd.none )
