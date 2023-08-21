module Types.SessionDict exposing (Client, Session, SessionDict, cleanup, clients, disconnected, empty, getSession, isAdmin, join, seen, sessions, toAdmin)

import Dict exposing (Dict)
import Env
import Lamdera exposing (ClientId, SessionId)
import Set exposing (Set)
import Time
import Types.GameId exposing (GameId)
import Types.GameIdDict as GameIdDict exposing (GameIdDict)


type SessionDict
    = SessionDict
        { sessions : Dict SessionId Session
        , clients : Dict ClientId Client
        , games : GameIdDict Game
        }


type alias Game =
    { clients : Set ClientId
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
    , playing : Maybe GameId
    }


empty : SessionDict
empty =
    SessionDict
        { sessions = Dict.empty
        , clients = Dict.empty
        , games = GameIdDict.empty
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
                            , playing = Nothing
                            }
                                |> Just
                )
                dict.clients
        , games = dict.games
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

        maybeGameId : Maybe GameId
        maybeGameId =
            Dict.get clientId dict.clients
                |> Maybe.andThen .playing
    in
    SessionDict
        { sessions =
            if Set.isEmpty newSession.clients then
                Dict.remove sessionId dict.sessions

            else
                Dict.insert sessionId newSession dict.sessions
        , clients = Dict.remove clientId dict.clients
        , games =
            case maybeGameId of
                Nothing ->
                    dict.games

                Just gameId ->
                    GameIdDict.update gameId
                        (Maybe.map
                            (\game ->
                                { game
                                    | clients = Set.remove clientId game.clients
                                }
                            )
                        )
                        dict.games
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


isAdmin : SessionId -> SessionDict -> Bool
isAdmin sessionId dict =
    getSession sessionId dict
        |> Maybe.map .isAdmin
        |> Maybe.withDefault False


join : ClientId -> GameId -> SessionDict -> SessionDict
join clientId gameId (SessionDict dict) =
    SessionDict
        { dict
            | games =
                GameIdDict.update gameId
                    (\maybeGame ->
                        let
                            game =
                                Maybe.withDefault { clients = Set.empty } maybeGame
                        in
                        Just { game | clients = Set.insert clientId game.clients }
                    )
                    dict.games
        }
