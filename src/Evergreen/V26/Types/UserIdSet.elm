module Evergreen.V26.Types.UserIdSet exposing (..)

import Dict
import Evergreen.V26.Types.UserId


type UserIdSet
    = UserIdSet (Dict.Dict String Evergreen.V26.Types.UserId.UserId)
