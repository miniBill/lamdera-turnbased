module Types.Fate exposing (Aspects, Character, Consequences, GameData, SharedData)

import Dict exposing (Dict)
import Lamdera exposing (SessionId)
import Set exposing (Set)


type alias GameData =
    { userData : Dict SessionId SharedData
    }


type alias SharedData =
    { character : Maybe Character
    }


type alias Character =
    { avatarUrl : String
    , name : String
    , description : String
    , fate : Int
    , refresh : Int
    , skills : Dict String Int
    , consequences : Consequences
    , stunts : List String
    , aspects : Aspects
    , physicalStress : Set Int
    , mentalStress : Set Int
    }


type alias Consequences =
    { two : Maybe String
    , four : Maybe String
    , six : Maybe String
    , twoExtra : Maybe String
    }


type alias Aspects =
    { highConcept : String
    , trouble : String
    , others : List String
    }
