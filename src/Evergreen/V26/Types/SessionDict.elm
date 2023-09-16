module Evergreen.V26.Types.SessionDict exposing (..)

import Dict
import Evergreen.V26.Types.Fate
import Evergreen.V26.Types.GameIdDict
import Evergreen.V26.Types.Session
import Evergreen.V26.Types.TokenDict
import Evergreen.V26.Types.UserId
import Evergreen.V26.Types.UserIdDict
import Evergreen.V26.Types.UserIdSet
import Evergreen.V26.Types.Wanderhome
import Lamdera
import Time


type alias Client =
    { session : Lamdera.SessionId
    , lastSeen : Time.Posix
    }


type alias UserData =
    { name : String
    , fate : Evergreen.V26.Types.Fate.UserData
    }


type GameData
    = FateGameData Evergreen.V26.Types.Fate.GameData
    | WanderhomeGameData Evergreen.V26.Types.Wanderhome.GameData


type alias Game =
    { users : Evergreen.V26.Types.UserIdSet.UserIdSet
    , gameData : GameData
    }


type SessionDict
    = SessionDict
        { sessions : Dict.Dict Lamdera.SessionId Evergreen.V26.Types.Session.Session
        , clients : Dict.Dict Lamdera.ClientId Client
        , users : Evergreen.V26.Types.UserIdDict.UserIdDict UserData
        , games : Evergreen.V26.Types.GameIdDict.GameIdDict Game
        , tokens : Evergreen.V26.Types.TokenDict.TokenDict Evergreen.V26.Types.UserId.UserId
        }
