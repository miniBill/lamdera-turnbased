module Evergreen.V26.Types.Session exposing (..)

import Evergreen.V26.Types.UserId
import Lamdera
import Set
import Time


type alias Session =
    { clients : Set.Set Lamdera.ClientId
    , loggedIn : Maybe Evergreen.V26.Types.UserId.UserId
    , lastSeen : Time.Posix
    }
