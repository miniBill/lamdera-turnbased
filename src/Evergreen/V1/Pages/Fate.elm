module Evergreen.V1.Pages.Fate exposing (..)

import Evergreen.V1.Types.Fate
import Evergreen.V1.Types.ServerData


type alias Model =
    { input : String
    , placeholder : Maybe String
    , characters : Evergreen.V1.Types.ServerData.ServerData (List Evergreen.V1.Types.Fate.Character)
    }


type Msg
    = Input String
    | Placeholder String
    | CreateCharacter
    | SetCharacterAt Int Evergreen.V1.Types.Fate.Character
