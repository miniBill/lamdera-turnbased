module Pages.Fate.Id_ exposing (Model, Msg, page, updateFromBackend)

import Bridge exposing (ToBackend(..), ToFrontendPage(..))
import Effect exposing (Effect)
import Element.WithContext exposing (text)
import Lamdera
import Layouts
import Page exposing (Page)
import Route exposing (Route)
import Shared
import Types.GameId as GameId exposing (GameId)
import View exposing (View, ViewKind(..))


page : Shared.Model -> Route { id : String } -> Page Model Msg
page _ route =
    Page.new
        { init = init { id = GameId.fromString route.params.id }
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
        |> Page.withLayout (\_ -> Layouts.Default {})



-- INIT


type Model
    = Joining


init : { id : GameId } -> () -> ( Model, Effect Msg )
init { id } () =
    ( Joining
    , Effect.sendCmd <| Lamdera.sendToBackend <| TBJoin id
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
    { kind = Fate
    , body = text "TODO"
    }


updateFromBackend : ToFrontendPage -> Model -> ( Model, Effect Msg )
updateFromBackend msg model =
    case msg of
        TFAdminPageData _ ->
            ( model, Effect.none )
