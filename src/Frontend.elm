module Frontend exposing (app, updateFromBackend)

import Bridge exposing (ToBackend(..), ToFrontend(..))
import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Json.Encode
import Lamdera
import Main as ElmLand
import Main.Pages.Model
import Main.Pages.Msg
import Pages.Admin
import Pages.Home_
import Pages.Id_
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
    case msg of
        TFPage pageMsg ->
            let
                updatePageFromBackend :
                    (Bridge.ToFrontendPage -> subModel -> ( subModel, Cmd subMsg ))
                    -> (subModel -> Main.Pages.Model.Model)
                    -> (subMsg -> Main.Pages.Msg.Msg)
                    -> subModel
                    -> ( FrontendModel, Cmd FrontendMsg )
                updatePageFromBackend update toModel toMsg subModel =
                    let
                        ( newPage, cmd ) =
                            update pageMsg subModel
                    in
                    ( { model | page = toModel newPage }
                    , Cmd.map (ElmLand.Page << toMsg) cmd
                    )
            in
            case model.page of
                Main.Pages.Model.Home_ homeModel ->
                    updatePageFromBackend
                        Pages.Home_.updateFromBackend
                        Main.Pages.Model.Home_
                        Main.Pages.Msg.Home_
                        homeModel

                Main.Pages.Model.Admin adminModel ->
                    updatePageFromBackend
                        Pages.Admin.updateFromBackend
                        Main.Pages.Model.Admin
                        Main.Pages.Msg.Admin
                        adminModel

                Main.Pages.Model.Id_ route idModel ->
                    updatePageFromBackend
                        Pages.Id_.updateFromBackend
                        (Main.Pages.Model.Id_ route)
                        Main.Pages.Msg.Id_
                        idModel

                Main.Pages.Model.NotFound_ notFoundModel ->
                    updatePageFromBackend
                        (\_ pageModel ->
                            -- Pages.NotFound_.updateFromBackend
                            ( pageModel, Cmd.none )
                        )
                        Main.Pages.Model.NotFound_
                        Main.Pages.Msg.NotFound_
                        notFoundModel

                Main.Pages.Model.Redirecting_ ->
                    ( model, Cmd.none )

                Main.Pages.Model.Loading_ ->
                    ( model, Cmd.none )

        TFPing ->
            ( model, Lamdera.sendToBackend TBPong )
