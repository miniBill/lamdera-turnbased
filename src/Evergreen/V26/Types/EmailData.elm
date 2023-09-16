module Evergreen.V26.Types.EmailData exposing (..)

import EmailAddress
import Evergreen.V26.Route
import Evergreen.V26.Types.Token


type EmailData
    = LoginEmail
        { to : EmailAddress.EmailAddress
        , route : Evergreen.V26.Route.Route ()
        , token : Evergreen.V26.Types.Token.Token
        }
