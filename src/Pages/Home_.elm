module Pages.Home_ exposing (Model, Msg, page, updateFromBackend)

import Bridge exposing (ToFrontendPage(..))
import Effect exposing (Effect)
import Element.WithContext exposing (centerX, centerY, fill, link, rgb255, width)
import Element.WithContext.Background as Background
import Element.WithContext.Border as Border
import Element.WithContext.Font as Font
import Page exposing (Page)
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
    {}


init : () -> ( Model, Effect Msg )
init _ =
    ( {}
    , Effect.none
    )



-- UPDATE


type alias Msg =
    {}


update : Msg -> Model -> ( Model, Effect Msg )
update _ model =
    ( model, Effect.none )



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
                    Route.Path.toString Route.Path.Wanderhome
                , label = Theme.wanderhomeOnlineTitle
                }
            , link
                [ centerX
                , Border.width 1
                , Theme.padding
                , Border.rounded Theme.rythm
                , width fill
                , Border.color <| rgb255 0 0 0
                , Background.color Theme.colors.fateBackground
                , Font.color Theme.colors.fate
                ]
                { url =
                    Route.Path.toString Route.Path.Fate
                , label = Theme.fateTitle
                }
            ]
    }


updateFromBackend : ToFrontendPage -> Model -> ( Model, Effect Msg )
updateFromBackend msg model =
    case msg of
        TFAdminPageData _ ->
            ( model, Effect.none )
