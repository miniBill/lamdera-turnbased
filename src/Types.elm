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
import Lamdera exposing (ClientId, SessionId)
import Main as ElmLand
import SendGrid
import Time
import Types.SessionDict exposing (SessionDict)


type alias FrontendModel =
    ElmLand.Model


type alias BackendModel =
    { sessions : SessionDict
    , errors : List String
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
    | SendResult (Result SendGrid.Error ())


type InnerBackendMsg
    = OnConnect SessionId ClientId
    | OnDisconnect SessionId ClientId
    | FromFrontend SessionId ClientId ToBackend
    | ShouldPing
