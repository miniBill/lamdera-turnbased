module Types.Session exposing (Session, isAdmin)

import Lamdera exposing (ClientId)
import Set exposing (Set)
import Types.UserId as UserId exposing (UserId)


type alias Session =
    { clients : Set ClientId
    , loggedIn : Maybe UserId
    }


isAdmin : Session -> Bool
isAdmin { loggedIn } =
    loggedIn == Just UserId.admin
