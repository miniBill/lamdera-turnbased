module Pages.Admin exposing (Model, Msg, page, updateFromBackend)

import Bridge exposing (AdminPageData, ToBackend(..), ToFrontendPage(..))
import Color
import Color.Oklch
import Diceware
import Dict exposing (Dict)
import Effect exposing (Effect)
import Element.WithContext as Element exposing (Color, alignTop, centerX, centerY, column, el, fill, height, paragraph, px, rgb, rgb255, row, shrink, spacing, text, width)
import Element.WithContext.Background as Background
import Element.WithContext.Border as Border
import Element.WithContext.Font as Font
import Email.Html
import EmailAddress
import Env
import FNV1a
import Lamdera exposing (SessionId)
import Layouts
import List.Extra
import List.Nonempty as Nonempty
import Page exposing (Page)
import Route exposing (Route)
import Route.Path as Path
import Set
import Shared
import Shared.Model exposing (ViewKind(..))
import String.Nonempty
import Theme exposing (Attribute, Element)
import Theme.Fate
import Time
import Types.EmailData as EmailData exposing (EmailData, HtmlEmail)
import Types.Fate as Fate
import Types.GameId as GameId exposing (GameId)
import Types.GameIdDict as GameIdDict
import Types.Session exposing (Session)
import Types.SessionDict as SessionDict exposing (Game, SessionDict, UserData)
import Types.UserId as UserId exposing (UserId)
import Types.UserIdDict as UserIdDict
import Types.UserIdSet as UserIdSet
import View exposing (View)


page : Shared.Model -> Route () -> Page Model Msg
page _ route =
    Page.new
        { init = init route
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
        |> Page.withLayout (\_ -> Layouts.Default {})



-- INIT


type alias Model =
    Maybe AdminPageData


init : Route () -> () -> ( Model, Effect Msg )
init route () =
    ( Nothing
    , case Dict.get "key" route.query of
        Just key ->
            Effect.batch
                [ Effect.sendToBackend <| TBLoginAsAdmin key
                , case Env.mode of
                    Env.Development ->
                        Effect.none

                    Env.Production ->
                        Effect.replacePath Path.Admin
                ]

        Nothing ->
            Effect.replacePath Path.Home_
    )



-- UPDATE


type Msg
    = ClearEmails


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        ClearEmails ->
            ( model, Effect.sendToBackend TBClearEmails )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> View Msg
view maybeModel =
    { kind = AdminView
    , body =
        case maybeModel of
            Nothing ->
                el [ centerX, centerY ] <| text "Loading..."

            Just model ->
                Theme.column [ Theme.padding ]
                    [ text "Sessions"
                    , viewSessions model.sessions
                    , text "Users"
                    , viewUsers model.sessions
                    , text "Games"
                    , viewGames model.sessions
                    , text "Errors"
                    , viewErrors model.errors
                    , Theme.row []
                        [ text "Emails"
                        , Theme.button []
                            { onPress = Just ClearEmails
                            , label = text "Delete all"
                            }
                        ]
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
        , Theme.wrappedRow [] (List.map (viewUserId << Just) <| UserIdSet.toList game.users)
        ]


viewSessions : SessionDict -> Element msg
viewSessions sessionsDict =
    sessionsDict
        |> SessionDict.sessions
        |> Dict.toList
        |> List.map viewSession
        |> Theme.wrappedRow []


viewUsers : SessionDict -> Element Msg
viewUsers sessionsDict =
    sessionsDict
        |> SessionDict.users
        |> UserIdDict.toList
        |> List.filterMap viewUser
        |> List.Extra.greedyGroupsOf 2
        |> List.map (Theme.row [ width fill ])
        |> Theme.column [ width fill ]


viewSession : ( SessionId, Session ) -> Element msg
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
            , viewUserId session.loggedIn
            ]
        , Theme.wrappedRow [] (List.map viewHashedId <| Set.toList session.clients)
        ]


viewUser : ( UserId, UserData ) -> Maybe (Element msg)
viewUser ( userId, userData ) =
    if
        List.all
            (\character ->
                String.length (character.aspects.highConcept ++ character.aspects.trouble) < 10
            )
            userData.fate.characters
    then
        Nothing

    else
        userData.fate.characters
            |> List.map viewCharacter
            |> Theme.column
                [ Border.rounded Theme.rythm
                , Border.width 1
                , Theme.padding
                , alignTop
                , width fill
                ]
            |> Just


viewCharacter : Fate.Character -> Element msg
viewCharacter character =
    let
        paragraph_ : List (Attribute msg) -> String -> Element msg
        paragraph_ attrs line =
            paragraph (alignTop :: attrs) [ text line ]
    in
    Theme.column [ width fill ] <|
        [ Theme.row [ width fill ]
            [ Theme.Fate.imageContain
                [ width <| px 80
                , height <| px 80
                ]
                { description = "Avatar"
                , src = character.avatarUrl
                }
            , [ paragraph_ [] character.name
              , paragraph_ [] character.aspects.highConcept
              ]
                |> Theme.column [ width fill ]
            ]
        , viewSkill character.skills
        , (character.aspects.trouble
            :: character.aspects.others
          )
            |> List.filter (not << String.isEmpty)
            |> List.map
                (paragraph_
                    [ Border.width 1
                    , Theme.padding
                    ]
                )
            |> List.Extra.greedyGroupsOf 2
            |> List.map (Theme.row [ alignTop, width fill ])
            |> Theme.column
                [ spacing <| Theme.rythm // 2
                , alignTop
                , width fill
                ]
        , character.stunts
            |> List.filter (not << String.isEmpty)
            |> List.map
                (paragraph_
                    [ Border.width 1
                    , Theme.padding
                    ]
                )
            |> Theme.column
                [ spacing <| Theme.rythm // 2
                , alignTop
                , width fill
                ]
        ]


viewSkill : Dict Fate.Skill Int -> Element msg
viewSkill skills =
    skills
        |> Dict.toList
        |> List.Extra.gatherEqualsBy Tuple.second
        |> List.map
            (\( ( skill, level ), others ) ->
                ( level, skill :: List.map Tuple.first others )
            )
        |> List.sortBy (\( level, _ ) -> -level)
        |> List.map
            (\( level, skillsRow ) ->
                List.map text (String.fromInt level :: skillsRow)
            )
        |> Theme.grid [ alignTop ] []


viewUserId : Maybe UserId -> Element msg
viewUserId maybeUser =
    case maybeUser of
        Nothing ->
            text "(anon)"

        Just user ->
            let
                splat =
                    UserId.toString user |> String.split "@"
            in
            paragraph []
                [ el
                    [ Background.color <| rgb 0 0 0
                    , Element.mouseOver [ Background.color <| rgb 1 1 1 ]
                    ]
                    (text <| String.join "@" <| List.reverse <| List.drop 1 <| List.reverse splat)
                , text "@"
                , text <| String.join "@" <| List.reverse <| List.take 1 <| List.reverse splat
                ]


viewErrors : Dict String { count : Int, last : Time.Posix } -> Element msg
viewErrors errors =
    errors
        |> Dict.toList
        |> List.sortBy (\( _, { last } ) -> -(Time.posixToMillis last))
        |> List.map
            (\( error, { count, last } ) ->
                paragraph []
                    [ [ String.fromInt (Time.posixToMillis last)
                      , error
                      , "(" ++ String.fromInt count ++ ")"
                      ]
                        |> String.join " "
                        |> text
                    ]
            )
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


viewHashedId : String -> Element msg
viewHashedId id =
    id
        |> FNV1a.hash
        |> modBy (Diceware.listLength ^ 3)
        |> Diceware.numberToWords
        |> viewId


viewId : String -> Element msg
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


updateFromBackend : ToFrontendPage -> Model -> ( Model, Effect Msg )
updateFromBackend msg model =
    case msg of
        TFAdminPageData data ->
            ( Just data, Effect.none )

        TFLoadedFateCharacters _ ->
            ( model, Effect.none )
