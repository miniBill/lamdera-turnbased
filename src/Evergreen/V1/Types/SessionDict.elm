module Evergreen.V1.Types.SessionDict exposing (..)

import Dict
import Evergreen.V1.Types.Fate
import Evergreen.V1.Types.GameId
import Evergreen.V1.Types.GameIdDict
import Evergreen.V1.Types.Session
import Evergreen.V1.Types.TokenDict
import Evergreen.V1.Types.UserId
import Evergreen.V1.Types.UserIdDict
import Evergreen.V1.Types.Wanderhome
import Lamdera
import Set
import Time


type alias Client =
    { session : Lamdera.SessionId
    , lastSeen : Time.Posix
    , playing : Maybe Evergreen.V1.Types.GameId.GameId
    }


type alias UserData =
    { name : String
    , fate : Evergreen.V1.Types.Fate.UserData
    }


type GameData
    = FateGameData Evergreen.V1.Types.Fate.GameData
    | WanderhomeGameData Evergreen.V1.Types.Wanderhome.GameData


type alias Game =
    { clients : Set.Set Lamdera.ClientId
    , gameData : GameData
    }


type SessionDict
    = SessionDict
        { sessions : Dict.Dict Lamdera.SessionId Evergreen.V1.Types.Session.Session
        , clients : Dict.Dict Lamdera.ClientId Client
        , users : Evergreen.V1.Types.UserIdDict.UserIdDict UserData
        , games : Evergreen.V1.Types.GameIdDict.GameIdDict Game
        , tokens : Evergreen.V1.Types.TokenDict.TokenDict Evergreen.V1.Types.UserId.UserId
        }
