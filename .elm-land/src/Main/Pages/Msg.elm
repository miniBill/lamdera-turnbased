module Main.Pages.Msg exposing (Msg(..))

import Pages.Home_
import Pages.Admin
import Pages.Fate
import Pages.Fate.Id_
import Pages.Wanderhome
import Pages.Wanderhome.Id_
import Pages.NotFound_


type Msg
    = Home_ Pages.Home_.Msg
    | Admin Pages.Admin.Msg
    | Fate Pages.Fate.Msg
    | Fate_Id_ Pages.Fate.Id_.Msg
    | Wanderhome Pages.Wanderhome.Msg
    | Wanderhome_Id_ Pages.Wanderhome.Id_.Msg
    | NotFound_ Pages.NotFound_.Msg
