module Pages.Admin exposing (Model, Msg, page, updateFromBackend)

import Bridge exposing (ToFrontendPage(..))
import Color
import Color.Oklch
import Diceware
import Dict
import Effect exposing (Effect)
import Element.WithContext as Element exposing (Color, alignTop, el, fill, height, row, text)
import Element.WithContext.Background as Background
import Element.WithContext.Border as Border
import FNV1a
import Lamdera exposing (SessionId)
import Page exposing (Page)
import Route exposing (Route)
import Route.Path as Path
import Set
import Shared
import Theme exposing (Element)
import Types.GameId as GameId exposing (GameId)
import Types.GameIdDict as GameIdDict
import Types.SessionDict as SessionDict exposing (Game, Session, SessionDict)
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
    { kind = View.Admin
    , body =
        Theme.column [ Theme.padding ]
            [ text "Sessions"
            , viewSessions model.sessions
            , text "Games"
            , viewGames model.sessions
            ]
    }


viewGames : SessionDict -> Element Msg
viewGames sessionsDict =
    sessionsDict
        |> SessionDict.games
        |> GameIdDict.toList
        |> List.map viewGame
        |> Theme.wrappedRow []


viewGame : ( GameId, Game ) -> Element Msg
viewGame ( gameId, game ) =
    Theme.column
        [ Border.rounded Theme.rythm
        , Theme.padding
        , alignTop
        , Border.width 1
        ]
        [ Theme.row [] [ text "Game", viewId <| GameId.toString gameId ]
        , Theme.wrappedRow [] (List.map viewHashedId <| Set.toList game.clients)
        ]


viewSessions : SessionDict -> Element Msg
viewSessions sessionsDict =
    sessionsDict
        |> SessionDict.sessions
        |> Dict.toList
        |> List.map viewSession
        |> Theme.wrappedRow []


viewSession : ( SessionId, Session ) -> Element Msg
viewSession ( sessionId, session ) =
    Theme.column
        [ Border.rounded Theme.rythm
        , Theme.padding
        , alignTop
        , Border.width 1
        ]
        [ Theme.row []
            [ text "Session"
            , viewHashedId sessionId
            , if session.isAdmin then
                text "(admin)"

              else
                Element.none
            ]
        , Theme.wrappedRow [] (List.map viewHashedId <| Set.toList session.clients)
        ]


viewHashedId : String -> Element Msg
viewHashedId id =
    id
        |> FNV1a.hash
        |> modBy (Diceware.listLength ^ 3)
        |> Diceware.numberToWords
        |> viewId


viewId : String -> Element Msg
viewId id =
    let
        pieces : List String
        pieces =
            String.split " " id

        piecesCount : Int
        piecesCount =
            List.length pieces
    in
    pieces
        |> List.indexedMap
            (\index piece ->
                el
                    [ Theme.padding
                    , Background.color <| stringToColor piece
                    , height fill
                    , if index == 0 then
                        Border.width 1

                      else
                        Border.widthEach { top = 1, bottom = 1, left = 0, right = 1 }
                    , if piecesCount == 1 then
                        Border.rounded Theme.rythm

                      else if index == 0 then
                        Border.roundEach
                            { topLeft = Theme.rythm
                            , topRight = 0
                            , bottomRight = 0
                            , bottomLeft = Theme.rythm
                            }

                      else if index == piecesCount - 1 then
                        Border.roundEach
                            { topLeft = 0
                            , topRight = Theme.rythm
                            , bottomRight = Theme.rythm
                            , bottomLeft = 0
                            }

                      else
                        height fill
                    ]
                    (text piece)
            )
        |> row
            []


stringToColor : String -> Color
stringToColor input =
    let
        hash : Int
        hash =
            FNV1a.hash input

        hue : Float
        hue =
            toFloat hash / (2 ^ 32)

        backgroundColor : Color.Color
        backgroundColor =
            Color.Oklch.oklch 0.8 0.1 hue
                |> Color.Oklch.toColor
    in
    backgroundColor
        |> Color.toRgba
        |> (\{ red, green, blue, alpha } -> Element.rgba red green blue alpha)


updateFromBackend : ToFrontendPage -> Model -> ( Model, Cmd Msg )
updateFromBackend msg model =
    case msg of
        TFSessions sessions ->
            ( { model | sessions = sessions }, Cmd.none )
