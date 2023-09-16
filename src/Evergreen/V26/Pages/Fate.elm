module Evergreen.V26.Pages.Fate exposing (..)

import Evergreen.V26.Types.Fate
import Evergreen.V26.Types.ServerData


type alias Model =
    { input : String
    , placeholder : Maybe String
    , characters : Evergreen.V26.Types.ServerData.ServerData (List Evergreen.V26.Types.Fate.Character)
    }


type Msg
    = Input String
    | Placeholder String
    | CreateCharacter
    | SetCharacterAt Int Evergreen.V26.Types.Fate.Character
