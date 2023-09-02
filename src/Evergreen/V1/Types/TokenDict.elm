module Evergreen.V1.Types.TokenDict exposing (..)

import Dict
import Evergreen.V1.Types.Token


type TokenDict v
    = TokenDict (Dict.Dict String ( Evergreen.V1.Types.Token.Token, v ))
