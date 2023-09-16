module Evergreen.V26.Main exposing (..)

import Browser
import Browser.Navigation
import Evergreen.V26.Main.Layouts.Model
import Evergreen.V26.Main.Layouts.Msg
import Evergreen.V26.Main.Pages.Model
import Evergreen.V26.Main.Pages.Msg
import Evergreen.V26.Shared
import Url


type alias Model =
    { key : Browser.Navigation.Key
    , url : Url.Url
    , page : Evergreen.V26.Main.Pages.Model.Model
    , layout : Maybe Evergreen.V26.Main.Layouts.Model.Model
    , shared : Evergreen.V26.Shared.Model
    }


type Msg
    = UrlRequested Browser.UrlRequest
    | UrlChanged Url.Url
    | Page Evergreen.V26.Main.Pages.Msg.Msg
    | Layout Evergreen.V26.Main.Layouts.Msg.Msg
    | Shared Evergreen.V26.Shared.Msg
    | Batch (List Msg)
