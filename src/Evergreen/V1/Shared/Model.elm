module Evergreen.V1.Shared.Model exposing (..)

import Evergreen.V1.Types.UserId


type alias User =
    { userId : Evergreen.V1.Types.UserId.UserId
    }


type LoggedIn
    = Unknown
    | LoggedInAs User
    | NotLoggedIn
    | InvalidEmail
    | EmailSent
    | EmailError


type alias Model =
    { loggedIn : LoggedIn
    }
