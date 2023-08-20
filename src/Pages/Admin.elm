module Pages.Admin exposing (Model, Msg, page, updateFromBackend)

import Bridge exposing (ToFrontendPage(..))
import Diceware
import Dict
import Effect exposing (Effect)
import Element.WithContext as Element exposing (Color, alignTop, el, rgb255, text)
import Element.WithContext.Background as Background
import Element.WithContext.Border as Border
import Element.WithContext.Font as Font
import FNV1a
import Lamdera exposing (SessionId)
import Page exposing (Page)
import Route exposing (Route)
import Route.Path as Path
import Set
import Shared
import Theme exposing (Element)
import Types.SessionDict as SessionDict exposing (Session, SessionDict)
import View exposing (View)


page : Shared.Model -> Route () -> Page Model Msg
page _ route =
    Page.new
        { init = init route
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- INIT


type alias Model =
    { sessions : SessionDict }


init : Route () -> () -> ( Model, Effect Msg )
init route () =
    ( { sessions = SessionDict.empty }
    , case Dict.get "key" route.query of
        Just key ->
            Effect.loginAsAdmin key

        Nothing ->
            Effect.replaceRoute
                { path = Path.Home_
                , query = Dict.empty
                , hash = Nothing
                }
    )



-- UPDATE


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        NoOp ->
            ( model
            , Effect.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { kind = View.Home
    , body = viewSessions model.sessions
    }


viewSessions : SessionDict -> Element Msg
viewSessions sessionsDict =
    sessionsDict
        |> SessionDict.sessions
        |> Dict.toList
        |> List.map viewSession
        |> Theme.wrappedRow []
        |> el [ Theme.padding ]


viewSession : ( SessionId, Session ) -> Element Msg
viewSession ( sessionId, session ) =
    Theme.column
        [ Border.rounded Theme.rythm
        , Theme.padding
        , alignTop
        , Border.width 1
        ]
        [ Theme.row []
            [ viewId sessionId
            , if session.isAdmin then
                text <| "(admin)"

              else
                Element.none
            ]
        , Theme.wrappedRow [] (List.map viewId <| Set.toList session.clients)
        ]


viewId : String -> Element Msg
viewId id =
    let
        niceId : String
        niceId =
            Diceware.numberToWords (modBy (Diceware.listLength ^ 3) hash)

        hash : Int
        hash =
            FNV1a.hash id

        r : Int
        r =
            modBy 256 (hash // 65536)

        g : Int
        g =
            modBy 256 (hash // 256)

        b : Int
        b =
            modBy 256 (hash // 1)

        foregroundColor : Color
        foregroundColor =
            if r + g + b <= 127 * 3 then
                rgb255 0xFF 0xFF 0xFF

            else
                rgb255 0 0 0
    in
    el
        [ Theme.padding
        , Background.color <| rgb255 r g b
        , Font.color foregroundColor
        , Border.color foregroundColor
        , Border.width 1
        ]
    <|
        text niceId


updateFromBackend : ToFrontendPage -> Model -> ( Model, Cmd Msg )
updateFromBackend msg model =
    case msg of
        TFSessions sessions ->
            ( { model | sessions = sessions }, Cmd.none )
