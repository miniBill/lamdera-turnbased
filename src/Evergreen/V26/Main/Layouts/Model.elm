module Evergreen.V26.Main.Layouts.Model exposing (..)

import Evergreen.V26.Layouts.Default


type Model
    = Default
        { default : Evergreen.V26.Layouts.Default.Model
        }
