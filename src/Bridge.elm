module Bridge exposing (AdminPageData, ToBackend(..), ToFrontend(..), ToFrontendPage(..))

import Dict exposing (Dict)
import Shared.Model exposing (User)
import Time
import Types.EmailData exposing (EmailData)
import Types.GameId exposing (GameId)
import Types.SessionDict exposing (SessionDict)


type ToBackend
    = TBJoin GameId
    | TBPong
    | TBLoginAsAdmin String
    | TBLogin String
    | TBCheckLogin


type ToFrontend
    = TFPage ToFrontendPage
    | TFPing
    | TFCheckedLogin (Maybe User)


type ToFrontendPage
    = TFAdminPageData AdminPageData


type alias AdminPageData =
    { sessions : SessionDict
    , errors : Dict String { count : Int, last : Time.Posix }
    , emails : List EmailData
    }
