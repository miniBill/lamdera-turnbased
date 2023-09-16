module Evergreen.V26.Types.Fate exposing (..)

import Dict
import Evergreen.V26.Types.UserIdDict
import Set


type alias Skill =
    String


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


type alias Character =
    { avatarUrl : String
    , name : String
    , description : String
    , fate : Int
    , refresh : Int
    , skills : Dict.Dict Skill Int
    , consequences : Consequences
    , stunts : List String
    , aspects : Aspects
    , physicalStress : Set.Set Int
    , mentalStress : Set.Set Int
    }


type alias UserData =
    { characters : List Character
    }


type alias SharedData =
    { name : String
    , character : Maybe Character
    }


type alias GameData =
    { userData : Evergreen.V26.Types.UserIdDict.UserIdDict SharedData
    }
