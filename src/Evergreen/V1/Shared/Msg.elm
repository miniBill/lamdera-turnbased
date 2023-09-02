module Evergreen.V1.Shared.Msg exposing (..)

import Evergreen.V1.Shared.Model


type Msg
    = CheckedLogin (Maybe Evergreen.V1.Shared.Model.User)
    | InvalidEmail
    | EmailSent
    | EmailError
