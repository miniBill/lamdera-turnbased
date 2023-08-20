module Bridge exposing (ToBackend(..), ToFrontend(..), ToFrontendPage(..))

import Types.GameId exposing (GameId)
import Types.SessionDict exposing (SessionDict)


type ToBackend
    = TBJoin GameId
    | TBPong
    | TBLoginAsAdmin String
    | TBSendTestEmail


type ToFrontend
    = TFPage ToFrontendPage
    | TFPing


type ToFrontendPage
    = TFSessions SessionDict
