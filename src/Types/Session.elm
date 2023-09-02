module Types.Session exposing (Session, empty, isAdmin)

import Lamdera exposing (ClientId)
import Set exposing (Set)
import Time
import Types.UserId as UserId exposing (UserId)


type alias Session =
    { clients : Set ClientId
    , loggedIn : Maybe UserId
    , lastSeen : Time.Posix
    }


isAdmin : Session -> Bool
isAdmin { loggedIn } =
    loggedIn == Just UserId.admin


empty : Time.Posix -> Session
empty now =
    { clients = Set.empty
    , loggedIn = Nothing
    , lastSeen = now
    }
