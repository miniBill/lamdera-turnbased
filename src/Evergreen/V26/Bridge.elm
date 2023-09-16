module Evergreen.V26.Bridge exposing (..)

import Dict
import Evergreen.V26.Route
import Evergreen.V26.Shared.Model
import Evergreen.V26.Types.EmailData
import Evergreen.V26.Types.Fate
import Evergreen.V26.Types.GameId
import Evergreen.V26.Types.SessionDict
import Evergreen.V26.Types.Token
import Time


type alias AdminPageData =
    { sessions : Evergreen.V26.Types.SessionDict.SessionDict
    , errors :
        Dict.Dict
            String
            { count : Int
            , last : Time.Posix
            }
    , emails : List Evergreen.V26.Types.EmailData.EmailData
    }


type ToBackend
    = TBJoin Evergreen.V26.Types.GameId.GameId
    | TBPong
    | TBLoginAsAdmin String
    | TBLogin (Evergreen.V26.Route.Route ()) String
    | TBCheckLogin
    | TBLoginWithToken Evergreen.V26.Types.Token.Token
    | TBClearEmails
    | TBLoadFateCharacters
    | TBSaveFateCharacters (List Evergreen.V26.Types.Fate.Character)


type ToFrontendPage
    = TFAdminPageData AdminPageData
    | TFLoadedFateCharacters (List Evergreen.V26.Types.Fate.Character)


type ToFrontend
    = TFPage ToFrontendPage
    | TFPing
    | TFCheckedLogin (Maybe Evergreen.V26.Shared.Model.User)
    | TFInvalidEmail
    | TFEmailSent
    | TFEmailError
