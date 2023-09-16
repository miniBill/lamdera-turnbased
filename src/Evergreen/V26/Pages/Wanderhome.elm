module Evergreen.V26.Pages.Wanderhome exposing (..)


type alias Model =
    { input : String
    , placeholder : Maybe String
    }


type Msg
    = Input String
    | Placeholder String
