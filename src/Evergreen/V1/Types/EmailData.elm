module Evergreen.V1.Types.EmailData exposing (..)

import EmailAddress
import Evergreen.V1.Route
import Evergreen.V1.Types.Token


type EmailData
    = LoginEmail
        { to : EmailAddress.EmailAddress
        , route : Evergreen.V1.Route.Route ()
        , token : Evergreen.V1.Types.Token.Token
        }
