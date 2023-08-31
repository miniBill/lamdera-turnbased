module Types.Fate exposing (Aspects, Character, Consequences, GameData, SharedData, Skill, UserData, allSkills, emptyGameData)

import Dict exposing (Dict)
import Set exposing (Set)
import Types.UserIdDict as UserIdDict exposing (UserIdDict)


type alias UserData =
    { characters : List Character
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
    , skills : Dict Skill Int
    , consequences : Consequences
    , stunts : List String
    , aspects : Aspects
    , physicalStress : Set Int
    , mentalStress : Set Int
    }


type alias Skill =
    String


allSkills : List Skill
allSkills =
    [ "Academics"
    , "Athletics"
    , "Contacts"
    , "Deceive"
    , "Empathy"
    , "Engineering"
    , "Fight"
    , "Investigate"
    , "Notice"
    , "Physique"
    , "Pilot"
    , "Provoke"
    , "Rapport"
    , "Resources"
    , "Security"
    , "Shoot"
    , "Stealth"
    , "Will"
    ]


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
