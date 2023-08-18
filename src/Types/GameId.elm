module Types.GameId exposing (GameId(..), toString)


type GameId
    = GameId String


toString : GameId -> String
toString (GameId id) =
    id
