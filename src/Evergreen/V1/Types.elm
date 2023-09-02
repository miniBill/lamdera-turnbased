module Evergreen.V1.Types exposing (..)

import Dict
import Evergreen.V1.Bridge
import Evergreen.V1.Main
import Evergreen.V1.Types.EmailData
import Evergreen.V1.Types.SessionDict
import Lamdera
import Random
import SendGrid
import Time


type alias FrontendModel =
    Evergreen.V1.Main.Model


type alias BackendModel =
    { seed : Random.Seed
    , sessions : Evergreen.V1.Types.SessionDict.SessionDict
    , errors :
        Dict.Dict
            String
            { count : Int
            , last : Time.Posix
            }
    , emails : List Evergreen.V1.Types.EmailData.EmailData
    }


type alias FrontendMsg =
    Evergreen.V1.Main.Msg


type alias ToBackend =
    Evergreen.V1.Bridge.ToBackend


type InnerBackendMsg
    = OnConnect Lamdera.SessionId Lamdera.ClientId
    | OnDisconnect Lamdera.SessionId Lamdera.ClientId
    | FromFrontend Lamdera.SessionId Lamdera.ClientId ToBackend
    | ShouldPing
    | SendResult Lamdera.ClientId (Result SendGrid.Error ())


type BackendMsg
    = WithoutTime InnerBackendMsg
    | WithTime InnerBackendMsg Time.Posix
    | Seed Random.Seed


type alias ToFrontend =
    Evergreen.V1.Bridge.ToFrontend
