module Types.Fate exposing (Aspects, Character, Consequences, GameData, SharedData, UserData, emptyGameData, emptyUser)

import Dict exposing (Dict)
import Set exposing (Set)
import Types.UserIdDict as UserIdDict exposing (UserIdDict)


type alias UserData =
    { characters : List Character
    }


emptyUser : UserData
emptyUser =
    { characters = []
    }


type alias GameData =
    { userData : UserIdDict SharedData
    }


emptyGameData : GameData
emptyGameData =
    { userData = UserIdDict.empty
    }


type alias SharedData =
    { name : String
    , character : Maybe Character
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
