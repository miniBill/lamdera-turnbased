module Pages.Home_ exposing (Model, Msg(..), page, updateFromBackend)

import Bridge exposing (ToFrontendPage(..))
import Dict
import Effect exposing (..)
import Element.WithContext as Element
import Html exposing (..)
import Html.Attributes exposing (..)
import Page exposing (Page)
import Route exposing (Route)
import Route.Path
import Shared
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
    { input : String }


init : () -> ( Model, Effect Msg )
init _ =
    ( { input = "" }
    , Effect.none
    )



-- UPDATE


type Msg
    = Join


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        Join ->
            ( model
            , Effect.pushRoute
                { path = Route.Path.Id_ { id = model.input }
                , query = Dict.empty
                , hash = Nothing
                }
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Shared.Model -> Model -> View Msg
view _ _ =
    { title = "Elm Land ❤️ Lamdera"
    , body = Element.text "..."
    }


updateFromBackend : ToFrontendPage -> Model -> ( Model, Cmd Msg )
updateFromBackend msg model =
    case msg of
        TFSessions _ ->
            ( model, Cmd.none )
