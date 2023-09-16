module Evergreen.V26.Main.Pages.Msg exposing (..)

import Evergreen.V26.Pages.Admin
import Evergreen.V26.Pages.Fate
import Evergreen.V26.Pages.Fate.Id_
import Evergreen.V26.Pages.Home_
import Evergreen.V26.Pages.NotFound_
import Evergreen.V26.Pages.Wanderhome
import Evergreen.V26.Pages.Wanderhome.Id_


type Msg
    = Home_ Evergreen.V26.Pages.Home_.Msg
    | Admin Evergreen.V26.Pages.Admin.Msg
    | Fate Evergreen.V26.Pages.Fate.Msg
    | Fate_Id_ Evergreen.V26.Pages.Fate.Id_.Msg
    | Wanderhome Evergreen.V26.Pages.Wanderhome.Msg
    | Wanderhome_Id_ Evergreen.V26.Pages.Wanderhome.Id_.Msg
    | NotFound_ Evergreen.V26.Pages.NotFound_.Msg
