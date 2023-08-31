module Frontend exposing (app)

import Bridge exposing (ToBackend(..), ToFrontend(..))
import Browser exposing (UrlRequest)
import Browser.Navigation as Nav
import Effect exposing (Effect)
import Json.Encode
import Lamdera
import Main as ElmLand
import Main.Pages.Model
import Main.Pages.Msg
import Pages.Admin
import Pages.Fate
import Pages.Fate.Id_
import Pages.Home_
import Pages.Wanderhome
import Pages.Wanderhome.Id_
import Task
import Types exposing (FrontendModel, FrontendMsg, ToFrontend)
import Url


app :
    { init : Lamdera.Url -> Nav.Key -> ( FrontendModel, Cmd ElmLand.Msg )
    , view : FrontendModel -> Browser.Document ElmLand.Msg
    , update : ElmLand.Msg -> FrontendModel -> ( FrontendModel, Cmd ElmLand.Msg )
    , updateFromBackend : ToFrontend -> FrontendModel -> ( FrontendModel, Cmd ElmLand.Msg )
    , subscriptions : FrontendModel -> Sub ElmLand.Msg
    , onUrlRequest : UrlRequest -> ElmLand.Msg
    , onUrlChange : Url.Url -> ElmLand.Msg
    }
app =
    Lamdera.frontend
        { init = ElmLand.init Json.Encode.null
        , onUrlRequest = ElmLand.UrlRequested
        , onUrlChange = ElmLand.UrlChanged
        , update = ElmLand.update
        , updateFromBackend = updateFromBackend
        , subscriptions = ElmLand.subscriptions
        , view = ElmLand.view
        }


updateFromBackend : ToFrontend -> FrontendModel -> ( FrontendModel, Cmd FrontendMsg )
updateFromBackend msg model =
    let
        ( newModel, effect ) =
            case msg of
                TFPage pageMsg ->
                    let
                        updatePageFromBackend :
                            (Bridge.ToFrontendPage -> subModel -> ( subModel, Effect subMsg ))
                            -> (subModel -> Main.Pages.Model.Model)
                            -> (subMsg -> Main.Pages.Msg.Msg)
                            -> subModel
                            -> ( FrontendModel, Effect FrontendMsg )
                        updatePageFromBackend update toModel toMsg subModel =
                            let
                                ( newPage, cmd ) =
                                    update pageMsg subModel
                            in
                            ( { model | page = toModel newPage }
                            , Effect.map (ElmLand.Page << toMsg) cmd
                            )
                    in
                    case model.page of
                        Main.Pages.Model.Home_ innerModel ->
                            updatePageFromBackend
                                Pages.Home_.updateFromBackend
                                Main.Pages.Model.Home_
                                Main.Pages.Msg.Home_
                                innerModel

                        Main.Pages.Model.Admin innerModel ->
                            updatePageFromBackend
                                Pages.Admin.updateFromBackend
                                Main.Pages.Model.Admin
                                Main.Pages.Msg.Admin
                                innerModel

                        Main.Pages.Model.Fate innerModel ->
                            updatePageFromBackend
                                Pages.Fate.updateFromBackend
                                Main.Pages.Model.Fate
                                Main.Pages.Msg.Fate
                                innerModel

                        Main.Pages.Model.Fate_Id_ route innerModel ->
                            updatePageFromBackend
                                Pages.Fate.Id_.updateFromBackend
                                (Main.Pages.Model.Fate_Id_ route)
                                Main.Pages.Msg.Fate_Id_
                                innerModel

                        Main.Pages.Model.Wanderhome innerModel ->
                            updatePageFromBackend
                                Pages.Wanderhome.updateFromBackend
                                Main.Pages.Model.Wanderhome
                                Main.Pages.Msg.Wanderhome
                                innerModel

                        Main.Pages.Model.Wanderhome_Id_ route innerModel ->
                            updatePageFromBackend
                                Pages.Wanderhome.Id_.updateFromBackend
                                (Main.Pages.Model.Wanderhome_Id_ route)
                                Main.Pages.Msg.Wanderhome_Id_
                                innerModel

                        Main.Pages.Model.NotFound_ notFoundModel ->
                            updatePageFromBackend
                                (\_ pageModel ->
                                    -- Pages.NotFound_.updateFromBackend
                                    ( pageModel, Effect.none )
                                )
                                Main.Pages.Model.NotFound_
                                Main.Pages.Msg.NotFound_
                                notFoundModel

                        Main.Pages.Model.Redirecting_ ->
                            ( model, Effect.none )

                        Main.Pages.Model.Loading_ ->
                            ( model, Effect.none )

                TFPing ->
                    ( model, Effect.sendCmd <| Lamdera.sendToBackend TBPong )

                TFCheckedLogin result ->
                    ( model, Effect.checkedLogin result )
    in
    ( newModel
    , Effect.toCmd
        { key = model.key
        , url = model.url
        , shared = model.shared
        , fromSharedMsg = ElmLand.Shared
        , batch = ElmLand.Batch
        , toCmd = Task.succeed >> Task.perform identity
        }
        effect
    )
