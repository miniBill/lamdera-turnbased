module Pages.Admin exposing (Model, Msg, page, updateFromBackend)

import Bridge exposing (ToFrontendPage(..))
import Color
import Color.Oklch
import Diceware
import Dict
import Effect exposing (Effect)
import Element.WithContext as Element exposing (Color, alignTop, column, el, fill, height, paragraph, px, rgb255, row, shrink, text, width)
import Element.WithContext.Background as Background
import Element.WithContext.Border as Border
import Element.WithContext.Font as Font
import Email.Html
import EmailAddress
import FNV1a
import Lamdera exposing (SessionId)
import List.Nonempty as Nonempty
import Page exposing (Page)
import Route exposing (Route)
import Route.Path as Path
import Set
import Shared
import String.Nonempty
import Theme exposing (Element)
import Types.EmailData as EmailData exposing (EmailData, HtmlEmail)
import Types.GameId as GameId exposing (GameId)
import Types.GameIdDict as GameIdDict
import Types.Session as Session exposing (Session)
import Types.SessionDict as SessionDict exposing (Game, SessionDict)
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
    { sessions : SessionDict
    , errors : List String
    , emails : List EmailData
    }


init : Route () -> () -> ( Model, Effect Msg )
init route () =
    ( { sessions = SessionDict.empty
      , errors = []
      , emails = []
      }
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
            , text "Errors"
            , viewErrors model.errors
            , text "Emails"
            , viewEmails model.emails
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
        , Border.width 1
        , Theme.padding
        , alignTop
        ]
        [ Theme.row []
            [ text "Session"
            , viewHashedId sessionId
            , if Session.isAdmin session then
                text "(admin)"

              else
                Element.none
            ]
        , Theme.wrappedRow [] (List.map viewHashedId <| Set.toList session.clients)
        ]


viewErrors : List String -> Element msg
viewErrors errors =
    errors
        |> List.map (\error -> paragraph [] [ text error ])
        |> Theme.column
            [ Border.rounded Theme.rythm
            , Border.width 1
            , Theme.padding
            ]


viewEmails : List EmailData -> Element msg
viewEmails emails =
    emails
        |> List.filterMap
            (\email ->
                email
                    |> EmailData.toHtmlEmail
                    |> Maybe.map viewHtmlEmail
            )
        |> Theme.column
            [ Border.rounded Theme.rythm
            , Border.width 1
            , Theme.padding
            ]


viewHtmlEmail : HtmlEmail -> Element msg
viewHtmlEmail details =
    column
        [ Border.width 1
        , Border.rounded Theme.rythm
        , Background.color <| rgb255 0xE8 0xE8 0xE8
        ]
        [ Element.table
            [ Theme.padding
            , Theme.spacing
            ]
            { data =
                [ ( "From", details.nameOfSender )
                , ( "", EmailAddress.toString details.emailAddressOfSender )
                , ( "To"
                  , details.to
                        |> Nonempty.toList
                        |> List.map EmailAddress.toString
                        |> String.join ", "
                  )
                , ( "Subject", String.Nonempty.toString details.subject )
                ]
            , columns =
                [ { view =
                        \( label, _ ) ->
                            el
                                [ Font.size 16
                                , Font.color <| rgb255 0x30 0x30 0x30
                                , Element.alignBottom
                                ]
                                (text label)
                  , header = Element.none
                  , width = shrink
                  }
                , { view = \( _, content ) -> text content
                  , header = Element.none
                  , width = shrink
                  }
                ]
            }
        , el
            [ width fill
            , height <| px 1
            , Border.widthEach
                { left = 0
                , right = 0
                , top = 0
                , bottom = 1
                }
            ]
            Element.none
        , el [ Theme.padding ] <| Element.html <| Email.Html.toHtml details.content
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
updateFromBackend msg _ =
    case msg of
        TFAdminPageData data ->
            ( data, Cmd.none )
