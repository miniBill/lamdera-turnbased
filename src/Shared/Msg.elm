module Shared.Msg exposing (Msg(..))

{-| -}

import Shared.Model exposing (User)


{-| Normally, this value would live in "Shared.elm"
but that would lead to a circular dependency import cycle.

For that reason, both `Shared.Model` and `Shared.Msg` are in their
own file, so they can be imported by `Effect.elm`

-}
type Msg
    = CheckedLogin (Maybe User)
    | InvalidEmail
    | EmailSent
    | EmailError
