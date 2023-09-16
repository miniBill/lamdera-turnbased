module Evergreen.V26.Route.Path exposing (..)


type Path
    = Home_
    | Admin
    | Fate
    | Fate_Id_
        { id : String
        }
    | Wanderhome
    | Wanderhome_Id_
        { id : String
        }
    | NotFound_
