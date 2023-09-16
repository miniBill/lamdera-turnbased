module Evergreen.V26.Shared.Model exposing (..)

import Evergreen.V26.Types.UserId


type alias User =
    { userId : Evergreen.V26.Types.UserId.UserId
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
