module Evergreen.V26.Types.TokenDict exposing (..)

import Dict
import Evergreen.V26.Types.Token


type TokenDict v
    = TokenDict (Dict.Dict String ( Evergreen.V26.Types.Token.Token, v ))
