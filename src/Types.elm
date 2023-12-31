module Types exposing
    ( BackendModel
    , BackendMsg(..)
    , FrontendModel
    , FrontendMsg
    , InnerBackendMsg(..)
    , ToBackend
    , ToFrontend
    )

import Bridge
import Dict exposing (Dict)
import Lamdera exposing (ClientId, SessionId)
import Main as ElmLand
import Random
import SendGrid
import Time
import Types.EmailData exposing (EmailData)
import Types.SessionDict exposing (SessionDict)


type alias FrontendModel =
    ElmLand.Model


type alias BackendModel =
    { seed : Random.Seed
    , sessions : SessionDict
    , errors : Dict String { count : Int, last : Time.Posix }
    , emails : List EmailData
    }


type alias FrontendMsg =
    ElmLand.Msg


type alias ToBackend =
    Bridge.ToBackend


type alias ToFrontend =
    Bridge.ToFrontend


type BackendMsg
    = WithoutTime InnerBackendMsg
    | WithTime InnerBackendMsg Time.Posix
    | Seed Random.Seed


type InnerBackendMsg
    = OnConnect SessionId ClientId
    | OnDisconnect SessionId ClientId
    | FromFrontend SessionId ClientId ToBackend
    | ShouldPing
    | SendResult ClientId (Result SendGrid.Error ())
