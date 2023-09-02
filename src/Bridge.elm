module Bridge exposing (AdminPageData, ToBackend(..), ToFrontend(..), ToFrontendPage(..))

import Dict exposing (Dict)
import Route exposing (Route)
import Shared.Model exposing (User)
import Time
import Types.EmailData exposing (EmailData)
import Types.Fate as Fate
import Types.GameId exposing (GameId)
import Types.SessionDict exposing (SessionDict)
import Types.Token exposing (Token)


type ToBackend
    = TBJoin GameId
    | TBPong
    | TBLoginAsAdmin String
    | TBLogin (Route ()) String
    | TBCheckLogin
    | TBLoginWithToken Token
    | TBClearEmails
    | TBLoadFateCharacters


type ToFrontend
    = TFPage ToFrontendPage
    | TFPing
    | TFCheckedLogin (Maybe User)
    | TFInvalidEmail
    | TFEmailSent
    | TFEmailError


type ToFrontendPage
    = TFAdminPageData AdminPageData
    | TFLoadedFateCharacters (List Fate.Character)


type alias AdminPageData =
    { sessions : SessionDict
    , errors : Dict String { count : Int, last : Time.Posix }
    , emails : List EmailData
    }
