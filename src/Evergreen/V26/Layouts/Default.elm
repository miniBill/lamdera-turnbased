module Evergreen.V26.Layouts.Default exposing (..)


type alias Model =
    { email : String
    , isSubmitting : Bool
    }


type Msg
    = Email String
    | Submit
