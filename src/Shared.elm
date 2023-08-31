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

import Dict
import Effect exposing (Effect)
import Json.Decode
import Route exposing (Route)
import Route.Path
import Shared.Model exposing (Context, LoggedIn(..))
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
    ( { context = initialContext }, Effect.checkLogin )


initialContext : Context
initialContext =
    { loggedIn = Unknown }



-- UPDATE


type alias Msg =
    Shared.Msg.Msg


update : Route () -> Msg -> Model -> ( Model, Effect Msg )
update route msg ({ context } as model) =
    case msg of
        CheckedLogin Nothing ->
            ( { model | context = { context | loggedIn = NotLoggedIn } }, Effect.none )

        CheckedLogin (Just result) ->
            ( { model | context = { context | loggedIn = LoggedInAs result } }
            , case
                Dict.get "returnTo" route.query |> Maybe.andThen Route.Path.fromString
              of
                Nothing ->
                    Effect.pushPath Route.Path.Home_

                Just returnTo ->
                    Effect.pushPath returnTo
            )



-- SUBSCRIPTIONS


subscriptions : Route () -> Model -> Sub Msg
subscriptions _ _ =
    Sub.none
