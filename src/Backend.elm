module Backend exposing (app)

import Bridge exposing (ToBackend(..), ToFrontend(..), ToFrontendPage(..))
import Diceware
import Dict
import EmailAddress
import Env
import Lamdera exposing (ClientId, SessionId)
import Random
import Random.Extra
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
import Types.Token exposing (Token(..))
import Types.UserId as UserId


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
      , seed = Random.initialSeed 0
      }
    , Random.generate Seed Random.independentSeed
    )


update : BackendMsg -> BackendModel -> ( BackendModel, Cmd BackendMsg )
update msg model =
    case msg of
        Seed seed ->
            ( { model | seed = seed }, Cmd.none )

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
            ( { model | sessions = SessionDict.disconnected now sid cid model.sessions }
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

        SendResult cid (Ok ()) ->
            ( model, Lamdera.sendToFrontend cid TFEmailSent )

        SendResult cid (Err e) ->
            ( appendError now (sendGridErrorToString e) model
            , Lamdera.sendToFrontend cid TFEmailError
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
                ( { model | sessions = SessionDict.toAdmin sid model.sessions }
                , Lamdera.sendToFrontend sid <|
                    TFCheckedLogin (Just { userId = UserId.admin })
                )

            else
                ( model, Cmd.none )

        TBClearEmails ->
            if SessionDict.isAdmin sid model.sessions then
                ( { model | emails = [] }, Cmd.none )

            else
                ( model, Cmd.none )

        TBLoginWithToken token ->
            case SessionDict.tryLogin token sid model.sessions of
                Just ( newSession, userId ) ->
                    ( { model | sessions = newSession }
                    , Lamdera.sendToFrontend sid <|
                        TFCheckedLogin (Just { userId = userId })
                    )

                Nothing ->
                    ( model
                    , Lamdera.sendToFrontend sid <|
                        TFCheckedLogin Nothing
                    )

        TBLogin route email ->
            case EmailAddress.fromString email of
                Just recipient ->
                    let
                        ( token, newSeed ) =
                            Random.step tokenGenerator model.seed
                    in
                    { model
                        | seed = newSeed
                        , sessions =
                            SessionDict.addToken token
                                (UserId.fromString email)
                                model.sessions
                    }
                        |> sendEmail now
                            cid
                            (LoginEmail
                                { to = recipient
                                , route = route
                                , token = token
                                }
                            )

                Nothing ->
                    ( model, Lamdera.sendToFrontend cid TFInvalidEmail )

        TBCheckLogin ->
            ( model
            , SessionDict.getSession sid model.sessions
                |> Maybe.andThen .loggedIn
                |> Maybe.map (\userId -> { userId = userId })
                |> TFCheckedLogin
                |> Lamdera.sendToFrontend sid
            )


tokenGenerator : Random.Generator Token
tokenGenerator =
    let
        wordGenerator =
            Random.int 0 (Diceware.listLength - 1)
                |> Random.map Diceware.numberToWords
    in
    List.repeat 8 wordGenerator
        |> Random.Extra.combine
        |> Random.map
            (\components ->
                components
                    |> (::) "aardvark"
                    |> String.join "-"
                    |> Token
            )


sendEmail : Time.Posix -> ClientId -> EmailData -> BackendModel -> ( BackendModel, Cmd BackendMsg )
sendEmail now cid email model =
    case EmailData.toSendGrid email of
        Nothing ->
            ( appendError now "Error parsing from address" model, Cmd.none )

        Just sendGridEmail ->
            if Env.isDev then
                let
                    _ =
                        Debug.log "Email sent" sendGridEmail
                in
                ( { model | emails = email :: model.emails }, Lamdera.sendToFrontend cid TFEmailSent )

            else
                ( model
                , SendGrid.sendEmail
                    (SendResult cid >> WithoutTime)
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
