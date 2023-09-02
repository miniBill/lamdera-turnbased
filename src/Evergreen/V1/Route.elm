module Evergreen.V1.Route exposing (..)

import Dict
import Evergreen.V1.Route.Path
import Url


type alias Route params =
    { path : Evergreen.V1.Route.Path.Path
    , params : params
    , query : Dict.Dict String String
    , hash : Maybe String
    , url : Url.Url
    }
