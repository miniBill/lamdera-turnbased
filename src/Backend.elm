module Backend exposing (app)

import Bridge exposing (ToBackend(..), ToFrontend(..), ToFrontendPage(..))
import Dict
import Email.Html
import EmailAddress
import Env
import Lamdera exposing (ClientId, SessionId)
import List.Nonempty
import SendGrid
import String.Nonempty exposing (NonemptyString(..))
import Task
import Time
import Types exposing (BackendModel, BackendMsg(..), Email(..), InnerBackendMsg(..), ToBackend)
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
      , errors = []
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
                                        }
                        )
                    |> (::) cmd
                    |> Cmd.batch
                )

        SendResult (Ok ()) ->
            ( model, Cmd.none )

        SendResult (Err e) ->
            ( { model | errors = sendGridErrorToString e :: model.errors }
            , Cmd.none
            )


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


innerUpdateFromFrontend :
    Time.Posix
    -> SessionId
    -> ClientId
    -> Bridge.ToBackend
    -> BackendModel
    -> ( BackendModel, Cmd BackendMsg )
innerUpdateFromFrontend _ sid cid msg model =
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
                    sendEmail
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


sendEmail : Email -> BackendModel -> ( BackendModel, Cmd BackendMsg )
sendEmail email model =
    if Env.isDev then
        ( { model | emails = email :: model.emails }, Cmd.none )

    else
        case emailToSendGrid email of
            Nothing ->
                ( { model | errors = "Error parsing from address" :: model.errors }, Cmd.none )

            Just sendGridEmail ->
                ( model
                , SendGrid.sendEmail
                    SendResult
                    (SendGrid.apiKey Env.sendGridKey)
                    sendGridEmail
                )


emailToSendGrid : Email -> Maybe SendGrid.Email
emailToSendGrid email =
    case email of
        LoginEmail { to, token } ->
            EmailAddress.fromString "leonardo@taglialegne.it"
                |> Maybe.map
                    (\sender ->
                        SendGrid.htmlEmail
                            { subject =
                                let
                                    _ =
                                        Debug.todo
                                in
                                NonemptyString 'S' "ubject"
                            , to = List.Nonempty.fromElement to
                            , content =
                                let
                                    _ =
                                        Debug.todo
                                in
                                Email.Html.div
                                    []
                                    [ Email.Html.text <| "Your token is " ++ token ]
                            , nameOfSender =
                                let
                                    _ =
                                        Debug.todo
                                in
                                "Leonardo Taglialegne"
                            , emailAddressOfSender = sender
                            }
                    )


updateFromFrontend : SessionId -> ClientId -> ToBackend -> BackendModel -> ( BackendModel, Cmd BackendMsg )
updateFromFrontend sid cid msg model =
    ( model
    , FromFrontend sid cid msg
        |> Task.succeed
        |> Task.perform WithoutTime
    )
