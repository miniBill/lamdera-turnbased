module Types.SessionDict exposing (Client, Session, SessionDict, cleanup, clients, disconnected, empty, getSession, seen, sessions, toAdmin)

import Dict exposing (Dict)
import Env
import Lamdera exposing (ClientId, SessionId)
import Set exposing (Set)
import Time


type SessionDict
    = SessionDict
        { sessions : Dict SessionId Session
        , clients : Dict ClientId Client
        }


type alias Session =
    { clients : Set ClientId
    , isAdmin : Bool
    }


emptySession : Session
emptySession =
    { clients = Set.empty
    , isAdmin = False
    }


type alias Client =
    { session : SessionId
    , lastSeen : Time.Posix
    }


empty : SessionDict
empty =
    SessionDict
        { sessions = Dict.empty
        , clients = Dict.empty
        }


getSession : SessionId -> SessionDict -> Maybe Session
getSession sessionId (SessionDict dict) =
    Dict.get sessionId dict.sessions


seen : Time.Posix -> SessionId -> ClientId -> SessionDict -> SessionDict
seen now sessionId clientId (SessionDict dict) =
    SessionDict
        { sessions =
            Dict.update sessionId
                (\v ->
                    let
                        session : Session
                        session =
                            Maybe.withDefault emptySession v
                    in
                    Just { session | clients = Set.insert clientId session.clients }
                )
                dict.sessions
        , clients =
            Dict.update clientId
                (\maybeClient ->
                    case maybeClient of
                        Just client ->
                            { client
                                | lastSeen = now
                            }
                                |> Just

                        Nothing ->
                            { session = sessionId
                            , lastSeen = now
                            }
                                |> Just
                )
                dict.clients
        }


disconnected : SessionId -> ClientId -> SessionDict -> SessionDict
disconnected sessionId clientId (SessionDict dict) =
    let
        session : Session
        session =
            Dict.get sessionId dict.sessions
                |> Maybe.withDefault emptySession

        newSession : Session
        newSession =
            { session | clients = Set.filter (\c -> c /= clientId) session.clients }
    in
    SessionDict
        { sessions =
            if Set.isEmpty newSession.clients then
                Dict.remove sessionId dict.sessions

            else
                Dict.insert sessionId newSession dict.sessions
        , clients = Dict.remove clientId dict.clients
        }


clients : SessionDict -> Dict ClientId Client
clients (SessionDict dict) =
    dict.clients


sessions : SessionDict -> Dict SessionId Session
sessions (SessionDict dict) =
    dict.sessions


toAdmin : SessionId -> SessionDict -> SessionDict
toAdmin sessionId (SessionDict dict) =
    SessionDict
        { dict
            | sessions =
                Dict.update sessionId
                    (Maybe.map
                        (\session ->
                            { session
                                | isAdmin = True
                            }
                        )
                    )
                    dict.sessions
        }


cleanup : Time.Posix -> SessionDict -> SessionDict
cleanup now dict =
    let
        nowMillis : Int
        nowMillis =
            Time.posixToMillis now
    in
    dict
        |> clients
        |> Dict.toList
        |> List.filter
            (\( _, { lastSeen } ) ->
                let
                    elapsed : Int
                    elapsed =
                        nowMillis - Time.posixToMillis lastSeen
                in
                elapsed > Env.pingTime * 3 // 2
            )
        |> List.foldl (\( clientId, { session } ) -> disconnected session clientId) dict
