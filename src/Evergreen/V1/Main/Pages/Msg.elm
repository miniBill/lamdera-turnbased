module Evergreen.V1.Main.Pages.Msg exposing (..)

import Evergreen.V1.Pages.Admin
import Evergreen.V1.Pages.Fate
import Evergreen.V1.Pages.Fate.Id_
import Evergreen.V1.Pages.Home_
import Evergreen.V1.Pages.NotFound_
import Evergreen.V1.Pages.Wanderhome
import Evergreen.V1.Pages.Wanderhome.Id_


type Msg
    = Home_ Evergreen.V1.Pages.Home_.Msg
    | Admin Evergreen.V1.Pages.Admin.Msg
    | Fate Evergreen.V1.Pages.Fate.Msg
    | Fate_Id_ Evergreen.V1.Pages.Fate.Id_.Msg
    | Wanderhome Evergreen.V1.Pages.Wanderhome.Msg
    | Wanderhome_Id_ Evergreen.V1.Pages.Wanderhome.Id_.Msg
    | NotFound_ Evergreen.V1.Pages.NotFound_.Msg
