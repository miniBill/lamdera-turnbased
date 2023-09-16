module Types.SessionDict exposing (Client, Game, GameData, SessionDict, UserData, addToken, cleanup, disconnected, empty, games, getUserFromSessionId, getUserIdFromSessionId, isAdmin, join, seen, sessions, toAdmin, tryLogin, updateUserFromSessionId, users)

import Dict exposing (Dict)
import Env
import Lamdera exposing (ClientId, SessionId)
import Maybe.Extra
import Set
import Time
import Types.Fate as Fate
import Types.GameId exposing (GameId)
import Types.GameIdDict as GameIdDict exposing (GameIdDict)
import Types.GameType as GameType exposing (GameType)
import Types.Session as Session exposing (Session)
import Types.Token exposing (Token)
import Types.TokenDict as TokenDict exposing (TokenDict)
import Types.UserId as UserId exposing (UserId)
import Types.UserIdDict as UserIdDict exposing (UserIdDict)
import Types.UserIdSet as UserIdSet exposing (UserIdSet)
import Types.Wanderhome as Wanderhome


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


emptyUserData : UserData
emptyUserData =
    { name = ""
    , fate = Fate.emptyUserData
    }


type alias Game =
    { users : UserIdSet
    , gameData : GameData
    }


type GameData
    = FateGameData Fate.GameData
    | WanderhomeGameData Wanderhome.GameData


type alias Client =
    { session : SessionId
    , lastSeen : Time.Posix
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


updateWithDefault : comparable -> a -> (a -> a) -> Dict comparable a -> Dict comparable a
updateWithDefault key default updater dict =
    Dict.update key
        (\value ->
            value
                |> Maybe.withDefault default
                |> updater
                |> Just
        )
        dict


seen : Time.Posix -> SessionId -> ClientId -> SessionDict -> SessionDict
seen now sessionId clientId (SessionDict dict) =
    SessionDict
        { dict
            | sessions =
                updateWithDefault sessionId
                    (Session.empty now)
                    (\session ->
                        { session
                            | clients = Set.insert clientId session.clients
                            , lastSeen = now
                        }
                    )
                    dict.sessions
            , clients =
                updateWithDefault clientId
                    { session = sessionId
                    , lastSeen = now
                    }
                    (\client -> { client | lastSeen = now })
                    dict.clients
        }


disconnected : Time.Posix -> SessionId -> ClientId -> SessionDict -> SessionDict
disconnected now sessionId clientId (SessionDict dict) =
    let
        session : Session
        session =
            Dict.get sessionId dict.sessions
                |> Maybe.withDefault (Session.empty now)

        newSession : Session
        newSession =
            { session
                | clients = Set.filter (\c -> c /= clientId) session.clients
            }
    in
    SessionDict
        { dict
            | sessions = Dict.insert sessionId newSession dict.sessions
            , clients = Dict.remove clientId dict.clients
        }


clients : SessionDict -> Dict ClientId Client
clients (SessionDict dict) =
    dict.clients


sessions : SessionDict -> Dict SessionId Session
sessions (SessionDict dict) =
    dict.sessions


users : SessionDict -> UserIdDict UserData
users (SessionDict dict) =
    dict.users


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

        (SessionDict clientsRemoved) =
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
                |> List.foldl (\( clientId, { session } ) -> disconnected now session clientId) dict
    in
    SessionDict
        { clientsRemoved
            | sessions =
                Dict.filter
                    (\_ session ->
                        let
                            elapsed : Int
                            elapsed =
                                nowMillis - Time.posixToMillis session.lastSeen
                        in
                        -- Keep sessions active for 30 days
                        (elapsed <= 30 * 86400 * 1000)
                            || not (Set.isEmpty session.clients)
                    )
                    clientsRemoved.sessions
        }


isAdmin : SessionId -> SessionDict -> Bool
isAdmin sessionId dict =
    case getSession sessionId dict of
        Just session ->
            Session.isAdmin session

        Nothing ->
            False


join : GameType -> UserId -> GameId -> SessionDict -> SessionDict
join gameType userId gameId (SessionDict dict) =
    SessionDict
        { dict
            | games =
                GameIdDict.update gameId
                    (\maybeGame ->
                        let
                            game : Game
                            game =
                                maybeGame
                                    |> Maybe.Extra.withDefaultLazy
                                        (\_ ->
                                            { users = UserIdSet.empty
                                            , gameData =
                                                case gameType of
                                                    GameType.Fate ->
                                                        FateGameData Fate.emptyGameData

                                                    GameType.Wanderhome ->
                                                        WanderhomeGameData Wanderhome.emptyGameData
                                            }
                                        )
                        in
                        Just { game | users = UserIdSet.insert userId game.users }
                    )
                    dict.games
        }


games : SessionDict -> GameIdDict Game
games (SessionDict dict) =
    dict.games


tryLogin : Token -> SessionId -> SessionDict -> Maybe ( SessionDict, UserId.UserId )
tryLogin token sid (SessionDict dict) =
    TokenDict.get token dict.tokens
        |> Maybe.map
            (\userId ->
                ( SessionDict
                    { dict
                        | tokens = TokenDict.remove token dict.tokens
                        , sessions =
                            Dict.update
                                sid
                                (Maybe.map (\session -> { session | loggedIn = Just userId }))
                                dict.sessions
                    }
                , userId
                )
            )


addToken : Token -> UserId.UserId -> SessionDict -> SessionDict
addToken token userId (SessionDict dict) =
    SessionDict { dict | tokens = TokenDict.insert token userId dict.tokens }


getUserFromSessionId : SessionId -> SessionDict -> UserData
getUserFromSessionId sid ((SessionDict dict) as ses) =
    getUserIdFromSessionId sid ses
        |> Maybe.andThen (\userId -> UserIdDict.get userId dict.users)
        |> Maybe.withDefault emptyUserData


updateUserFromSessionId : SessionId -> SessionDict -> (UserData -> UserData) -> SessionDict
updateUserFromSessionId sid (SessionDict dict) updater =
    Dict.get sid dict.sessions
        |> Maybe.andThen (\{ loggedIn } -> loggedIn)
        |> Maybe.map
            (\userId ->
                { dict
                    | users =
                        UserIdDict.update userId
                            (\user ->
                                user
                                    |> Maybe.withDefault emptyUserData
                                    |> updater
                                    |> Just
                            )
                            dict.users
                }
            )
        |> Maybe.withDefault dict
        |> SessionDict


getUserIdFromSessionId : SessionId -> SessionDict -> Maybe UserId
getUserIdFromSessionId sid (SessionDict dict) =
    Dict.get sid dict.sessions
        |> Maybe.andThen (\{ loggedIn } -> loggedIn)
