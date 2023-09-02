module Evergreen.V1.Pages.Admin exposing (..)

import Evergreen.V1.Bridge


type alias Model =
    Maybe Evergreen.V1.Bridge.AdminPageData


type Msg
    = ClearEmails
