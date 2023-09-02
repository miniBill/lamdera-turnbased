module Evergreen.V1.Types.UserIdDict exposing (..)

import Dict
import Evergreen.V1.Types.UserId


type UserIdDict v
    = UserIdDict (Dict.Dict String ( Evergreen.V1.Types.UserId.UserId, v ))
