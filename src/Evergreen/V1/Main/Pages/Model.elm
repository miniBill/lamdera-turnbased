module Evergreen.V1.Main.Pages.Model exposing (..)

import Evergreen.V1.Pages.Admin
import Evergreen.V1.Pages.Fate
import Evergreen.V1.Pages.Fate.Id_
import Evergreen.V1.Pages.Home_
import Evergreen.V1.Pages.NotFound_
import Evergreen.V1.Pages.Wanderhome
import Evergreen.V1.Pages.Wanderhome.Id_


type Model
    = Home_ Evergreen.V1.Pages.Home_.Model
    | Admin Evergreen.V1.Pages.Admin.Model
    | Fate Evergreen.V1.Pages.Fate.Model
    | Fate_Id_
        { id : String
        }
        Evergreen.V1.Pages.Fate.Id_.Model
    | Wanderhome Evergreen.V1.Pages.Wanderhome.Model
    | Wanderhome_Id_
        { id : String
        }
        Evergreen.V1.Pages.Wanderhome.Id_.Model
    | NotFound_ Evergreen.V1.Pages.NotFound_.Model
    | Redirecting_
    | Loading_
