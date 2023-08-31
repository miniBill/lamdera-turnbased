module Backend exposing (app)

import Bridge exposing (ToBackend(..), ToFrontend(..), ToFrontendPage(..))
import Dict
import EmailAddress
import Env
import Lamdera exposing (ClientId, SessionId)
import SendGrid
import Shared.Model exposing (LoggedIn(..))
import String.Nonempty exposing (NonemptyString(..))
import Task
import Time
import Types exposing (BackendModel, BackendMsg(..), InnerBackendMsg(..), ToBackend)
import Types.EmailData as EmailData exposing (EmailData(..))
import Types.Game as Game
import Types.Session as Session
import Types.SessionDict as SessionDict exposing (SessionDict)


app :
    { init : ( BackendModel, Cmd BackendMsg )
    , update : BackendMsg -> BackendModel -> ( BackendModel, Cmd BackendMsg )
    , updateFromFrontend : SessionId -> ClientId -> ToBackend -> BackendModel -> ( BackendModel, Cmd BackendMsg )
    , subscriptions : BackendModel -> Sub BackendMsg
    }
app =
    Lamdera.backend
        { init = init
        , update = update
        , updateFromFrontend = updateFromFrontend
        , subscriptions = subscriptions
        }


subscriptions : BackendModel -> Sub BackendMsg
subscriptions _ =
    Sub.batch
        [ Sub.map WithoutTime <| Lamdera.onConnect OnConnect
        , Sub.map WithoutTime <| Lamdera.onDisconnect OnDisconnect
        , Time.every Env.pingTime (WithTime ShouldPing)
        ]


init : ( BackendModel, Cmd BackendMsg )
init =
    ( { sessions = SessionDict.empty
      , errors = Dict.empty
      , emails = []
      }
    , Cmd.none
    )


update : BackendMsg -> BackendModel -> ( BackendModel, Cmd BackendMsg )
update msg model =
    case msg of
        WithoutTime innerMsg ->
            ( model, Task.perform (WithTime innerMsg) Time.now )

        WithTime innerMsg now ->
            let
                ( newModel, cmd ) =
                    innerUpdate now innerMsg model
            in
            if newModel.sessions == model.sessions then
                ( newModel, cmd )

            else
                ( newModel
                , newModel.sessions
                    |> SessionDict.sessions
                    |> Dict.toList
                    |> List.filter (\( _, session ) -> Session.isAdmin session)
                    |> List.map
                        (\( sid, _ ) ->
                            Lamdera.sendToFrontend sid <|
                                TFPage <|
                                    TFAdminPageData
                                        { sessions = newModel.sessions
                                        , errors = newModel.errors
                                        , emails = newModel.emails
                                        }
                        )
                    |> (::) cmd
                    |> Cmd.batch
                )


appendError : Time.Posix -> String -> BackendModel -> BackendModel
appendError now message model =
    { model
        | errors =
            Dict.update message
                (\old ->
                    let
                        oldCount =
                            Maybe.map .count old
                                |> Maybe.withDefault 0
                    in
                    { count = oldCount + 1, last = now }
                        |> Just
                )
                model.errors
    }


sendGridErrorToString : SendGrid.Error -> String
sendGridErrorToString error =
    let
        messageToString : SendGrid.ErrorMessage -> String
        messageToString { field, message, errorId } =
            [ ( "field", field )
            , ( "message", Just message )
            , ( "errorId", errorId )
            ]
                |> List.filterMap (\( k, v ) -> Maybe.map (\w -> k ++ ": " ++ w) v)
                |> String.join " - "

        message403ToString : SendGrid.ErrorMessage403 -> String
        message403ToString { field, message, help } =
            [ ( "field", field )
            , ( "message", message )
            , ( "help", help )
            ]
                |> List.filterMap (\( k, v ) -> Maybe.map (\w -> k ++ ": " ++ w) v)
                |> String.join " - "
    in
    case error of
        SendGrid.StatusCode400 messages ->
            "400: " ++ String.join ", " (List.map messageToString messages)

        SendGrid.StatusCode401 messages ->
            "401: " ++ String.join ", " (List.map messageToString messages)

        SendGrid.StatusCode413 messages ->
            "413: " ++ String.join ", " (List.map messageToString messages)

        SendGrid.StatusCode403 { errors, id } ->
            (case id of
                Nothing ->
                    "403: "

                Just i ->
                    "403 (id " ++ i ++ "):"
            )
                ++ String.join ", " (List.map message403ToString errors)

        SendGrid.UnknownError { statusCode, body } ->
            String.fromInt statusCode ++ ": " ++ body

        SendGrid.NetworkError ->
            "Network error"

        SendGrid.Timeout ->
            "Timeout"

        SendGrid.BadUrl url ->
            "Bad Url: " ++ url


innerUpdate : Time.Posix -> InnerBackendMsg -> BackendModel -> ( BackendModel, Cmd BackendMsg )
innerUpdate now submsg model =
    case submsg of
        OnConnect sid cid ->
            ( { model | sessions = SessionDict.seen now sid cid model.sessions }
            , Cmd.none
            )

        OnDisconnect sid cid ->
            ( { model | sessions = SessionDict.disconnected sid cid model.sessions }
            , Cmd.none
            )

        FromFrontend sid cid tbmsg ->
            let
                newSessions : SessionDict
                newSessions =
                    SessionDict.seen now sid cid model.sessions
            in
            innerUpdateFromFrontend now
                sid
                cid
                tbmsg
                { model | sessions = newSessions }

        ShouldPing ->
            ( { model | sessions = SessionDict.cleanup now model.sessions }, Lamdera.broadcast TFPing )

        SendResult (Ok ()) ->
            ( model, Cmd.none )

        SendResult (Err e) ->
            ( appendError now (sendGridErrorToString e) model
            , Cmd.none
            )


innerUpdateFromFrontend :
    Time.Posix
    -> SessionId
    -> ClientId
    -> Bridge.ToBackend
    -> BackendModel
    -> ( BackendModel, Cmd BackendMsg )
innerUpdateFromFrontend now sid cid msg model =
    case msg of
        TBJoin gameId ->
            let
                newSessions =
                    SessionDict.join Game.Fate cid gameId model.sessions
            in
            ( { model | sessions = newSessions }, Cmd.none )

        TBPong ->
            ( model, Cmd.none )

        TBLoginAsAdmin key ->
            if key == Env.adminKey then
                ( { model | sessions = SessionDict.toAdmin sid model.sessions }, Cmd.none )

            else
                ( model, Cmd.none )

        TBLogin email ->
            case EmailAddress.fromString email of
                Just recipient ->
                    sendEmail now
                        (LoginEmail
                            { to = recipient
                            , token =
                                let
                                    _ =
                                        Debug.todo
                                in
                                "TOKEN"
                            }
                        )
                        model

                Nothing ->
                    ( model, Cmd.none )

        TBCheckLogin ->
            ( model
            , SessionDict.getSession sid model.sessions
                |> Maybe.andThen .loggedIn
                |> Maybe.map (\userId -> LoggedInAs { userId = userId })
                |> Maybe.withDefault NotLoggedIn
                |> TFCheckedLogin
                |> Lamdera.sendToFrontend cid
            )


sendEmail : Time.Posix -> EmailData -> BackendModel -> ( BackendModel, Cmd BackendMsg )
sendEmail now email model =
    if Env.isDev then
        ( { model | emails = email :: model.emails }, Cmd.none )

    else
        case EmailData.toSendGrid email of
            Nothing ->
                ( appendError now "Error parsing from address" model, Cmd.none )

            Just sendGridEmail ->
                ( model
                , SendGrid.sendEmail
                    (SendResult >> WithoutTime)
                    (SendGrid.apiKey Env.sendGridKey)
                    sendGridEmail
                )


updateFromFrontend : SessionId -> ClientId -> ToBackend -> BackendModel -> ( BackendModel, Cmd BackendMsg )
updateFromFrontend sid cid msg model =
    ( model
    , FromFrontend sid cid msg
        |> Task.succeed
        |> Task.perform WithoutTime
    )
