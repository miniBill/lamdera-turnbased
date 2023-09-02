module Types.ServerData exposing (ServerData(..), map)


type ServerData a
    = NotAsked
    | Loading
    | Loaded a


map : (a -> b) -> ServerData a -> ServerData b
map f data =
    case data of
        NotAsked ->
            NotAsked

        Loading ->
            Loading

        Loaded x ->
            Loaded (f x)
