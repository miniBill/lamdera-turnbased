module Types.ServerData exposing (ServerData(..), map)


type ServerData a
    = Loading
    | Loaded a


map : (a -> b) -> ServerData a -> ServerData b
map f data =
    case data of
        Loading ->
            Loading

        Loaded x ->
            Loaded (f x)
