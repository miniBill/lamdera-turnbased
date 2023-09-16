module Evergreen.V26.Pages.Admin exposing (..)

import Evergreen.V26.Bridge


type alias Model =
    Maybe Evergreen.V26.Bridge.AdminPageData


type Msg
    = ClearEmails
