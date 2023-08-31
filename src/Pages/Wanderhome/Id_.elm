module Pages.Wanderhome.Id_ exposing (Model, Msg, page, updateFromBackend)

import Bridge exposing (ToFrontendPage(..))
import Effect exposing (Effect)
import Element.WithContext exposing (text)
import Page exposing (Page)
import Route exposing (Route)
import Shared
import View exposing (View, ViewKind(..))


page : Shared.Model -> Route { id : String } -> Page Model Msg
page _ _ =
    Page.new
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- INIT


type alias Model =
    {}


init : () -> ( Model, Effect Msg )
init () =
    ( {}
    , Effect.none
    )



-- UPDATE


type Msg
    = ExampleMsgReplaceMe


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        ExampleMsgReplaceMe ->
            ( model
            , Effect.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> View Msg
view _ =
    { kind = Wanderhome
    , body = text "TODO"
    }


updateFromBackend : ToFrontendPage -> Model -> ( Model, Effect Msg )
updateFromBackend msg model =
    case msg of
        TFAdminPageData _ ->
            ( model, Effect.none )
