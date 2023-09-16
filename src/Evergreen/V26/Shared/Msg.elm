module Evergreen.V26.Shared.Msg exposing (..)

import Evergreen.V26.Shared.Model


type Msg
    = CheckedLogin (Maybe Evergreen.V26.Shared.Model.User)
    | InvalidEmail
    | EmailSent
    | EmailError
