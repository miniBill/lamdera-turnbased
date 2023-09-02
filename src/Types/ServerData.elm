module Types.ServerData exposing (ServerData(..))


type ServerData a
    = Loading
    | Loaded a
