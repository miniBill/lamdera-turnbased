module Types.SessionDict exposing (Client, Game, GameData, SessionDict, cleanup, clients, disconnected, empty, games, getSession, isAdmin, join, seen, sessions, toAdmin, tryLogin)

import Dict exposing (Dict)
import Env
import Lamdera exposing (ClientId, SessionId)
import Maybe.Extra
import Set exposing (Set)
import Time
import Types.Fate as Fate
import Types.Game as Game exposing (Game)
import Types.GameId exposing (GameId)
import Types.GameIdDict as GameIdDict exposing (GameIdDict)
import Types.Session as Session exposing (Session)
import Types.Token exposing (Token)
import Types.TokenDict as TokenDict exposing (TokenDict)
import Types.UserId as UserId exposing (UserId)
import Types.UserIdDict as UserIdDict exposing (UserIdDict)


type SessionDict
    = SessionDict
        { sessions : Dict SessionId Session
        , clients : Dict ClientId Client
        , users : UserIdDict UserData
        , games : GameIdDict Game
        , tokens : TokenDict UserId
        }


type alias UserData =
    { name : String
    , fate : Fate.UserData
    }


type alias Game =
    { clients : Set ClientId
    , gameData : GameData
    }


type GameData
    = FateGameData Fate.GameData


emptySession : Session
emptySession =
    { clients = Set.empty
    , loggedIn = Nothing
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
        , users = UserIdDict.empty
        , tokens = TokenDict.empty
        }


getSession : SessionId -> SessionDict -> Maybe Session
getSession sessionId (SessionDict dict) =
    Dict.get sessionId dict.sessions


seen : Time.Posix -> SessionId -> ClientId -> SessionDict -> SessionDict
seen now sessionId clientId (SessionDict dict) =
    SessionDict
        { dict
            | sessions =
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
        { dict
            | sessions =
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
                            (Maybe.andThen
                                (\game ->
                                    let
                                        newClients : Set ClientId
                                        newClients =
                                            Set.remove clientId game.clients
                                    in
                                    if Set.isEmpty newClients then
                                        Nothing

                                    else
                                        { game
                                            | clients = newClients
                                        }
                                            |> Just
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
                                | loggedIn = Just UserId.admin
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
    case getSession sessionId dict of
        Just session ->
            Session.isAdmin session

        Nothing ->
            False


join : Game.Game -> ClientId -> GameId -> SessionDict -> SessionDict
join gameType clientId gameId (SessionDict dict) =
    SessionDict
        { dict
            | clients =
                Dict.update clientId
                    (Maybe.map
                        (\client ->
                            { client | playing = Just gameId }
                        )
                    )
                    dict.clients
            , games =
                GameIdDict.update gameId
                    (\maybeGame ->
                        let
                            game : Game
                            game =
                                maybeGame
                                    |> Maybe.Extra.withDefaultLazy
                                        (\_ ->
                                            { clients = Set.empty
                                            , gameData =
                                                case gameType of
                                                    Game.Fate ->
                                                        FateGameData Fate.emptyGameData

                                                    Game.Wanderhome ->
                                                        Debug.todo "branch 'Wanderhome' not implemented"
                                            }
                                        )
                        in
                        Just { game | clients = Set.insert clientId game.clients }
                    )
                    dict.games
        }


games : SessionDict -> GameIdDict Game
games (SessionDict dict) =
    dict.games


tryLogin : SessionId -> Token -> SessionDict -> Maybe ( SessionDict, UserId.UserId )
tryLogin sid token (SessionDict dict) =
    TokenDict.get token dict.tokens
        |> Maybe.map
            (\userId ->
                ( SessionDict { dict | tokens = TokenDict.remove token dict.tokens }
                , userId
                )
            )
