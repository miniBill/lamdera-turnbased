module Evergreen.V26.Types.UserIdDict exposing (..)

import Dict
import Evergreen.V26.Types.UserId


type UserIdDict v
    = UserIdDict (Dict.Dict String ( Evergreen.V26.Types.UserId.UserId, v ))
