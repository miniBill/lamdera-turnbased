module Types.Fate exposing (Aspects, Character, Consequences, GameData, SharedData, Skill, UserData, allSkills, emptyCharacter, emptyGameData, emptyUserData)

import Dict exposing (Dict)
import Set exposing (Set)
import Types.UserIdDict as UserIdDict exposing (UserIdDict)


type alias GameData =
    { userData : UserIdDict SharedData
    }


emptyGameData : GameData
emptyGameData =
    { userData = UserIdDict.empty
    }


type alias UserData =
    { characters : List Character
    }


emptyUserData : UserData
emptyUserData =
    { characters = [] }


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


emptyCharacter : Character
emptyCharacter =
    { avatarUrl = ""
    , name = ""
    , description = ""
    , fate = 3
    , refresh = 3
    , skills = Dict.empty
    , consequences = emptyConsequences
    , stunts = []
    , aspects = emptyAspects
    , physicalStress = Set.empty
    , mentalStress = Set.empty
    }


emptyAspects : Aspects
emptyAspects =
    { highConcept = ""
    , trouble = ""
    , others = []
    }


emptyConsequences : Consequences
emptyConsequences =
    { two = Nothing
    , four = Nothing
    , six = Nothing
    , twoExtra = Nothing
    }


type alias Skill =
    String


allSkills : List Skill
allSkills =
    [ "Academics" -- Lore
    , "Athletics"
    , "Contacts"
    , "Deceive"
    , "Empathy"
    , "Engineering" -- Crafts
    , "Fight"
    , "Investigate"
    , "Notice"
    , "Physique"
    , "Pilot" -- Drive
    , "Provoke"
    , "Rapport"
    , "Resources"
    , "Security" -- Burglary
    , "Shoot"
    , "Stealth"
    , "Will"
    ]


originalSkills : List String
originalSkills =
    [ "Athletics"
    , "Burglary" -- Security
    , "Contacts"
    , "Crafts" -- Engineering
    , "Deceive"
    , "Drive" -- Pilot
    , "Empathy"
    , "Fight"
    , "Investigate"
    , "Lore" -- Academics
    , "Notice"
    , "Physique"
    , "Provoke"
    , "Rapport"
    , "Resources"
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
