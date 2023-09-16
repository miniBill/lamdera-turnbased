module Evergreen.V26.Main.Pages.Model exposing (..)

import Evergreen.V26.Pages.Admin
import Evergreen.V26.Pages.Fate
import Evergreen.V26.Pages.Fate.Id_
import Evergreen.V26.Pages.Home_
import Evergreen.V26.Pages.NotFound_
import Evergreen.V26.Pages.Wanderhome
import Evergreen.V26.Pages.Wanderhome.Id_


type Model
    = Home_ Evergreen.V26.Pages.Home_.Model
    | Admin Evergreen.V26.Pages.Admin.Model
    | Fate Evergreen.V26.Pages.Fate.Model
    | Fate_Id_
        { id : String
        }
        Evergreen.V26.Pages.Fate.Id_.Model
    | Wanderhome Evergreen.V26.Pages.Wanderhome.Model
    | Wanderhome_Id_
        { id : String
        }
        Evergreen.V26.Pages.Wanderhome.Id_.Model
    | NotFound_ Evergreen.V26.Pages.NotFound_.Model
    | Redirecting_
    | Loading_
