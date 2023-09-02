module Main.Pages.Model exposing (Model(..))

import Pages.Home_
import Pages.Admin
import Pages.Fate
import Pages.Fate.Id_
import Pages.Wanderhome
import Pages.Wanderhome.Id_
import Pages.NotFound_
import View exposing (View)


type Model
    = Home_ Pages.Home_.Model
    | Admin Pages.Admin.Model
    | Fate Pages.Fate.Model
    | Fate_Id_ { id : String } Pages.Fate.Id_.Model
    | Wanderhome Pages.Wanderhome.Model
    | Wanderhome_Id_ { id : String } Pages.Wanderhome.Id_.Model
    | NotFound_ Pages.NotFound_.Model
    | Redirecting_
    | Loading_
