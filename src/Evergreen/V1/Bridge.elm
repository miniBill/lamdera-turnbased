module Evergreen.V1.Bridge exposing (..)

import Dict
import Evergreen.V1.Route
import Evergreen.V1.Shared.Model
import Evergreen.V1.Types.EmailData
import Evergreen.V1.Types.Fate
import Evergreen.V1.Types.GameId
import Evergreen.V1.Types.SessionDict
import Evergreen.V1.Types.Token
import Time


type alias AdminPageData =
    { sessions : Evergreen.V1.Types.SessionDict.SessionDict
    , errors :
        Dict.Dict
            String
            { count : Int
            , last : Time.Posix
            }
    , emails : List Evergreen.V1.Types.EmailData.EmailData
    }


type ToBackend
    = TBJoin Evergreen.V1.Types.GameId.GameId
    | TBPong
    | TBLoginAsAdmin String
    | TBLogin (Evergreen.V1.Route.Route ()) String
    | TBCheckLogin
    | TBLoginWithToken Evergreen.V1.Types.Token.Token
    | TBClearEmails
    | TBLoadFateCharacters
    | TBSaveFateCharacters (List Evergreen.V1.Types.Fate.Character)


type ToFrontendPage
    = TFAdminPageData AdminPageData
    | TFLoadedFateCharacters (List Evergreen.V1.Types.Fate.Character)


type ToFrontend
    = TFPage ToFrontendPage
    | TFPing
    | TFCheckedLogin (Maybe Evergreen.V1.Shared.Model.User)
    | TFInvalidEmail
    | TFEmailSent
    | TFEmailError
