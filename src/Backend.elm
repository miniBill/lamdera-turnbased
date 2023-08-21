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
import Types exposing (BackendModel, BackendMsg(..), InnerBackendMsg(..), ToBackend)
import Types.Game as Game
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
    ( { sessions = SessionDict.empty }
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

                newSessions : SessionDict
                newSessions =
                    newModel.sessions
            in
            if newSessions == model.sessions then
                ( newModel, cmd )

            else
                ( newModel
                , newSessions
                    |> SessionDict.sessions
                    |> Dict.toList
                    |> List.filter (\( _, { isAdmin } ) -> isAdmin)
                    |> List.map (\( sid, _ ) -> Lamdera.sendToFrontend sid <| TFPage <| TFSessions newSessions)
                    |> (::) cmd
                    |> Cmd.batch
                )

        SendResult (Ok ()) ->
            ( model, Cmd.none )

        SendResult (Err e) ->
            let
                _ =
                    Debug.log "Error sending email" e
            in
            ( model, Cmd.none )


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

        TBSendTestEmail ->
            if SessionDict.isAdmin sid model.sessions then
                case
                    ( EmailAddress.fromString "leonardo@taglialegne.it"
                    , EmailAddress.fromString "cmt.miniBill@gmail.com"
                    )
                of
                    ( Just sender, Just recipient ) ->
                        ( model
                        , SendGrid.sendEmail
                            SendResult
                            (SendGrid.apiKey Env.sendGridKey)
                            (SendGrid.htmlEmail
                                { subject = NonemptyString 'S' "ubject"
                                , to = List.Nonempty.fromElement recipient
                                , content =
                                    Email.Html.div
                                        []
                                        [ Email.Html.text "Hi!" ]
                                , nameOfSender = "Leonardo Taglialegne"
                                , emailAddressOfSender = sender
                                }
                            )
                        )

                    _ ->
                        ( model, Cmd.none )

            else
                ( model, Cmd.none )


updateFromFrontend : SessionId -> ClientId -> ToBackend -> BackendModel -> ( BackendModel, Cmd BackendMsg )
updateFromFrontend sid cid msg model =
    ( model
    , FromFrontend sid cid msg
        |> Task.succeed
        |> Task.perform WithoutTime
    )
