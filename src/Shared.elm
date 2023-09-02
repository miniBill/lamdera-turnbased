module Shared exposing
    ( Flags, decoder
    , Model, Msg
    , init, update, subscriptions
    )

{-|

@docs Flags, decoder
@docs Model, Msg
@docs init, update, subscriptions

-}

import Bridge exposing (ToBackend(..))
import Effect exposing (Effect)
import Json.Decode
import Route exposing (Route)
import Shared.Model
import Shared.Msg exposing (Msg(..))



-- FLAGS


type alias Flags =
    {}


decoder : Json.Decode.Decoder Flags
decoder =
    Json.Decode.succeed {}



-- INIT


type alias Model =
    Shared.Model.Model


init : Result Json.Decode.Error Flags -> Route () -> ( Model, Effect Msg )
init _ _ =
    ( { loggedIn = Shared.Model.Unknown }
    , Effect.sendToBackend TBCheckLogin
    )



-- UPDATE


type alias Msg =
    Shared.Msg.Msg


update : Route () -> Msg -> Model -> ( Model, Effect Msg )
update _ msg model =
    case msg of
        CheckedLogin Nothing ->
            ( { model | loggedIn = Shared.Model.NotLoggedIn }, Effect.none )

        CheckedLogin (Just result) ->
            ( { model | loggedIn = Shared.Model.LoggedInAs result }
            , Effect.none
            )

        InvalidEmail ->
            ( { model | loggedIn = Shared.Model.InvalidEmail }, Effect.none )

        EmailSent ->
            ( { model | loggedIn = Shared.Model.EmailSent }, Effect.none )

        EmailError ->
            ( { model | loggedIn = Shared.Model.EmailError }, Effect.none )



-- SUBSCRIPTIONS


subscriptions : Route () -> Model -> Sub Msg
subscriptions _ _ =
    Sub.none
