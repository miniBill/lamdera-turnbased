module Evergreen.V1.Main.Layouts.Model exposing (..)

import Evergreen.V1.Layouts.Default


type Model
    = Default
        { default : Evergreen.V1.Layouts.Default.Model
        }
