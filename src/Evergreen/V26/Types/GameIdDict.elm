module Evergreen.V26.Types.GameIdDict exposing (..)

import Dict
import Evergreen.V26.Types.GameId


type GameIdDict v
    = GameIdDict (Dict.Dict String ( Evergreen.V26.Types.GameId.GameId, v ))
