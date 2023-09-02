module Shared.Model exposing (Context, LoggedIn(..), Model, User, ViewKind(..))

{-| -}

import Types.UserId exposing (UserId)


{-| Normally, this value would live in "Shared.elm"
but that would lead to a circular dependency import cycle.

For that reason, both `Shared.Model` and `Shared.Msg` are in their
own file, so they can be imported by `Effect.elm`

-}
type alias Model =
    { context : Context }


type alias Context =
    { loggedIn : LoggedIn
    }


type ViewKind
    = HomeView
    | WanderhomeView
    | FateView
    | AdminView


type LoggedIn
    = Unknown
    | LoggedInAs User
    | NotLoggedIn
    | InvalidEmail
    | EmailSent
    | EmailError


type alias User =
    { userId : UserId }
