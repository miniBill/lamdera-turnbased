module Evergreen.V1.Types.GameIdDict exposing (..)

import Dict
import Evergreen.V1.Types.GameId


type GameIdDict v
    = GameIdDict (Dict.Dict String ( Evergreen.V1.Types.GameId.GameId, v ))
