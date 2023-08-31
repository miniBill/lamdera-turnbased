module Effect exposing
    ( Effect
    , none, batch
    , sendCmd, sendMsg
    , pushRoute, replaceRoute, loadExternalUrl
    , map, toCmd
    , checkLogin, checkedLogin, emailError, emailSent, invalidEmail, loginAsAdmin, pushPath, replacePath
    )

{-|

@docs Effect
@docs none, batch
@docs sendCmd, sendMsg
@docs pushRoute, replaceRoute, loadExternalUrl

@docs map, toCmd

-}

import Bridge exposing (ToBackend(..))
import Browser.Navigation
import Dict exposing (Dict)
import Lamdera
import Route
import Route.Path
import Shared.Model exposing (User)
import Shared.Msg
import Task
import Url exposing (Url)


type Effect msg
    = -- BASICS
      None
    | Batch (List (Effect msg))
    | SendCmd (Cmd msg)
      -- ROUTING
    | PushUrl String
    | ReplaceUrl String
    | LoadExternalUrl String
      -- SHARED
    | SendSharedMsg Shared.Msg.Msg
    | LoginAsAdmin String
    | CheckLogin



-- BASICS


{-| Don't send any effect.
-}
none : Effect msg
none =
    None


{-| Send multiple effects at once.
-}
batch : List (Effect msg) -> Effect msg
batch =
    Batch


{-| Send a normal `Cmd msg` as an effect, something like `Http.get` or `Random.generate`.
-}
sendCmd : Cmd msg -> Effect msg
sendCmd =
    SendCmd


{-| Send a message as an effect. Useful when emitting events from UI components.
-}
sendMsg : msg -> Effect msg
sendMsg msg =
    Task.succeed msg
        |> Task.perform identity
        |> SendCmd



-- ROUTING


{-| Set the new route, and make the back button go back to the current route.
-}
pushRoute :
    { path : Route.Path.Path
    , query : Dict String String
    , hash : Maybe String
    }
    -> Effect msg
pushRoute route =
    PushUrl (Route.toString route)


pushPath : Route.Path.Path -> Effect msg
pushPath path =
    pushRoute
        { path = path
        , query = Dict.empty
        , hash = Nothing
        }


{-| Set the new route, but replace the previous one, so clicking the back
button **won't** go back to the previous route.
-}
replaceRoute :
    { path : Route.Path.Path
    , query : Dict String String
    , hash : Maybe String
    }
    -> Effect msg
replaceRoute route =
    ReplaceUrl (Route.toString route)


replacePath : Route.Path.Path -> Effect msg
replacePath path =
    replaceRoute
        { path = path
        , query = Dict.empty
        , hash = Nothing
        }


{-| Redirect users to a new URL, somewhere external your web application.
-}
loadExternalUrl : String -> Effect msg
loadExternalUrl =
    LoadExternalUrl



-- SPECIFIC


loginAsAdmin : String -> Effect msg
loginAsAdmin =
    LoginAsAdmin


checkLogin : Effect msg
checkLogin =
    CheckLogin


checkedLogin : Maybe User -> Effect msg
checkedLogin user =
    SendSharedMsg (Shared.Msg.CheckedLogin user)


invalidEmail : Effect msg
invalidEmail =
    SendSharedMsg Shared.Msg.InvalidEmail


emailSent : Effect msg
emailSent =
    SendSharedMsg Shared.Msg.EmailSent


emailError : Effect msg
emailError =
    SendSharedMsg Shared.Msg.EmailError



-- INTERNALS


{-| Elm Land depends on this function to connect pages and layouts
together into the overall app.
-}
map : (msg1 -> msg2) -> Effect msg1 -> Effect msg2
map fn effect =
    case effect of
        None ->
            None

        Batch list ->
            Batch (List.map (map fn) list)

        SendCmd cmd ->
            SendCmd (Cmd.map fn cmd)

        PushUrl url ->
            PushUrl url

        ReplaceUrl url ->
            ReplaceUrl url

        LoadExternalUrl url ->
            LoadExternalUrl url

        SendSharedMsg sharedMsg ->
            SendSharedMsg sharedMsg

        LoginAsAdmin key ->
            LoginAsAdmin key

        CheckLogin ->
            CheckLogin


{-| Elm Land depends on this function to perform your effects.
-}
toCmd :
    { key : Browser.Navigation.Key
    , url : Url
    , shared : Shared.Model.Model
    , fromSharedMsg : Shared.Msg.Msg -> msg
    , batch : List msg -> msg
    , toCmd : msg -> Cmd msg
    }
    -> Effect msg
    -> Cmd msg
toCmd options effect =
    case effect of
        None ->
            Cmd.none

        Batch list ->
            Cmd.batch (List.map (toCmd options) list)

        SendCmd cmd ->
            cmd

        PushUrl url ->
            Browser.Navigation.pushUrl options.key url

        ReplaceUrl url ->
            Browser.Navigation.replaceUrl options.key url

        LoadExternalUrl url ->
            Browser.Navigation.load url

        SendSharedMsg sharedMsg ->
            sendShared options sharedMsg

        LoginAsAdmin key ->
            Lamdera.sendToBackend <| TBLoginAsAdmin key

        CheckLogin ->
            Lamdera.sendToBackend TBCheckLogin


sendShared :
    { a | fromSharedMsg : Shared.Msg.Msg -> msg }
    -> Shared.Msg.Msg
    -> Cmd msg
sendShared options sharedMsg =
    Task.succeed sharedMsg
        |> Task.perform options.fromSharedMsg
