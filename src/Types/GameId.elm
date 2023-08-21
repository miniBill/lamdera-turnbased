module Types.GameId exposing (GameId, fromString, toString)

import Url


type GameId
    = GameId String


fromString : String -> GameId
fromString id =
    GameId (Maybe.withDefault id <| Url.percentDecode id)


toString : GameId -> String
toString (GameId id) =
    id
