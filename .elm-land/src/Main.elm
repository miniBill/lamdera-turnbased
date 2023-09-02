module Main exposing (..)

import Auth
import Auth.Action
import Browser
import Browser.Navigation
import Effect exposing (Effect)
import Html exposing (Html)
import Json.Decode
import Layout
import Layouts
import Layouts.Default
import Main.Layouts.Model
import Main.Layouts.Msg
import Main.Pages.Model
import Main.Pages.Msg
import Page
import Pages.Home_
import Pages.Admin
import Pages.Fate
import Pages.Fate.Id_
import Pages.Wanderhome
import Pages.Wanderhome.Id_
import Pages.NotFound_
import Pages.NotFound_
import Route exposing (Route)
import Route.Path
import Shared
import Task
import Url exposing (Url)
import View exposing (View)


main : Program Json.Decode.Value Model Msg
main =
    Browser.application
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = UrlRequested
        }



-- INIT


type alias Model =
    { key : Browser.Navigation.Key
    , url : Url
    , page : Main.Pages.Model.Model
    , layout : Maybe Main.Layouts.Model.Model
    , shared : Shared.Model
    }


init : Json.Decode.Value -> Url -> Browser.Navigation.Key -> ( Model, Cmd Msg )
init json url key =
    let
        flagsResult : Result Json.Decode.Error Shared.Flags
        flagsResult =
            Json.Decode.decodeValue Shared.decoder json

        ( sharedModel, sharedEffect ) =
            Shared.init flagsResult (Route.fromUrl () url)

        { page, layout } =
            initPageAndLayout { key = key, url = url, shared = sharedModel, layout = Nothing }
    in
    ( { url = url
      , key = key
      , page = Tuple.first page
      , layout = layout |> Maybe.map Tuple.first
      , shared = sharedModel
      }
    , Cmd.batch
          [ Tuple.second page
          , layout |> Maybe.map Tuple.second |> Maybe.withDefault Cmd.none
          , fromSharedEffect { key = key, url = url, shared = sharedModel } sharedEffect
          ]
    )


initLayout : { key : Browser.Navigation.Key, url : Url, shared : Shared.Model, layout : Maybe Main.Layouts.Model.Model } -> Layouts.Layout Msg -> ( Main.Layouts.Model.Model, Cmd Msg )
initLayout model layout =
    case ( layout, model.layout ) of
        ( Layouts.Default props, Just (Main.Layouts.Model.Default existing) ) ->
            ( Main.Layouts.Model.Default existing
            , Cmd.none
            )

        ( Layouts.Default props, _ ) ->
            let
                route : Route ()
                route =
                    Route.fromUrl () model.url

                defaultLayout =
                    Layouts.Default.layout props model.shared route

                ( defaultLayoutModel, defaultLayoutEffect ) =
                    Layout.init defaultLayout ()
            in
            ( Main.Layouts.Model.Default { default = defaultLayoutModel }
            , fromLayoutEffect model (Effect.map Main.Layouts.Msg.Default defaultLayoutEffect)
            )


initPageAndLayout : { key : Browser.Navigation.Key, url : Url, shared : Shared.Model, layout : Maybe Main.Layouts.Model.Model } -> { page : ( Main.Pages.Model.Model, Cmd Msg ), layout : Maybe ( Main.Layouts.Model.Model, Cmd Msg ) }
initPageAndLayout model =
    case Route.Path.fromUrl model.url of
        Route.Path.Home_ ->
            let
                page : Page.Page Pages.Home_.Model Pages.Home_.Msg
                page =
                    Pages.Home_.page model.shared (Route.fromUrl () model.url)

                ( pageModel, pageEffect ) =
                    Page.init page ()
            in
            { page = 
                Tuple.mapBoth
                    Main.Pages.Model.Home_
                    (Effect.map Main.Pages.Msg.Home_ >> fromPageEffect model)
                    ( pageModel, pageEffect )
            , layout = 
                Page.layout pageModel page
                    |> Maybe.map (Layouts.map (Main.Pages.Msg.Home_ >> Page))
                    |> Maybe.map (initLayout model)
            }

        Route.Path.Admin ->
            let
                page : Page.Page Pages.Admin.Model Pages.Admin.Msg
                page =
                    Pages.Admin.page model.shared (Route.fromUrl () model.url)

                ( pageModel, pageEffect ) =
                    Page.init page ()
            in
            { page = 
                Tuple.mapBoth
                    Main.Pages.Model.Admin
                    (Effect.map Main.Pages.Msg.Admin >> fromPageEffect model)
                    ( pageModel, pageEffect )
            , layout = 
                Page.layout pageModel page
                    |> Maybe.map (Layouts.map (Main.Pages.Msg.Admin >> Page))
                    |> Maybe.map (initLayout model)
            }

        Route.Path.Fate ->
            let
                page : Page.Page Pages.Fate.Model Pages.Fate.Msg
                page =
                    Pages.Fate.page model.shared (Route.fromUrl () model.url)

                ( pageModel, pageEffect ) =
                    Page.init page ()
            in
            { page = 
                Tuple.mapBoth
                    Main.Pages.Model.Fate
                    (Effect.map Main.Pages.Msg.Fate >> fromPageEffect model)
                    ( pageModel, pageEffect )
            , layout = 
                Page.layout pageModel page
                    |> Maybe.map (Layouts.map (Main.Pages.Msg.Fate >> Page))
                    |> Maybe.map (initLayout model)
            }

        Route.Path.Fate_Id_ params ->
            let
                page : Page.Page Pages.Fate.Id_.Model Pages.Fate.Id_.Msg
                page =
                    Pages.Fate.Id_.page model.shared (Route.fromUrl params model.url)

                ( pageModel, pageEffect ) =
                    Page.init page ()
            in
            { page = 
                Tuple.mapBoth
                    (Main.Pages.Model.Fate_Id_ params)
                    (Effect.map Main.Pages.Msg.Fate_Id_ >> fromPageEffect model)
                    ( pageModel, pageEffect )
            , layout = 
                Page.layout pageModel page
                    |> Maybe.map (Layouts.map (Main.Pages.Msg.Fate_Id_ >> Page))
                    |> Maybe.map (initLayout model)
            }

        Route.Path.Wanderhome ->
            let
                page : Page.Page Pages.Wanderhome.Model Pages.Wanderhome.Msg
                page =
                    Pages.Wanderhome.page model.shared (Route.fromUrl () model.url)

                ( pageModel, pageEffect ) =
                    Page.init page ()
            in
            { page = 
                Tuple.mapBoth
                    Main.Pages.Model.Wanderhome
                    (Effect.map Main.Pages.Msg.Wanderhome >> fromPageEffect model)
                    ( pageModel, pageEffect )
            , layout = 
                Page.layout pageModel page
                    |> Maybe.map (Layouts.map (Main.Pages.Msg.Wanderhome >> Page))
                    |> Maybe.map (initLayout model)
            }

        Route.Path.Wanderhome_Id_ params ->
            let
                page : Page.Page Pages.Wanderhome.Id_.Model Pages.Wanderhome.Id_.Msg
                page =
                    Pages.Wanderhome.Id_.page model.shared (Route.fromUrl params model.url)

                ( pageModel, pageEffect ) =
                    Page.init page ()
            in
            { page = 
                Tuple.mapBoth
                    (Main.Pages.Model.Wanderhome_Id_ params)
                    (Effect.map Main.Pages.Msg.Wanderhome_Id_ >> fromPageEffect model)
                    ( pageModel, pageEffect )
            , layout = 
                Page.layout pageModel page
                    |> Maybe.map (Layouts.map (Main.Pages.Msg.Wanderhome_Id_ >> Page))
                    |> Maybe.map (initLayout model)
            }

        Route.Path.NotFound_ ->
            let
                page : Page.Page Pages.NotFound_.Model Pages.NotFound_.Msg
                page =
                    Pages.NotFound_.page model.shared (Route.fromUrl () model.url)

                ( pageModel, pageEffect ) =
                    Page.init page ()
            in
            { page = 
                Tuple.mapBoth
                    Main.Pages.Model.NotFound_
                    (Effect.map Main.Pages.Msg.NotFound_ >> fromPageEffect model)
                    ( pageModel, pageEffect )
            , layout = 
                Page.layout pageModel page
                    |> Maybe.map (Layouts.map (Main.Pages.Msg.NotFound_ >> Page))
                    |> Maybe.map (initLayout model)
            }


runWhenAuthenticated : { model | shared : Shared.Model, url : Url, key : Browser.Navigation.Key } -> (Auth.User -> ( Main.Pages.Model.Model, Cmd Msg )) -> ( Main.Pages.Model.Model, Cmd Msg )
runWhenAuthenticated model toTuple =
    let
        record =
            runWhenAuthenticatedWithLayout model (\user -> { page = toTuple user, layout = Nothing })
    in
    record.page


runWhenAuthenticatedWithLayout : { model | shared : Shared.Model, url : Url, key : Browser.Navigation.Key } -> (Auth.User -> { page : ( Main.Pages.Model.Model, Cmd Msg ), layout : Maybe ( Main.Layouts.Model.Model, Cmd Msg ) }) -> { page : ( Main.Pages.Model.Model, Cmd Msg ), layout : Maybe ( Main.Layouts.Model.Model, Cmd Msg ) }
runWhenAuthenticatedWithLayout model toRecord =
    let
        authAction : Auth.Action.Action Auth.User
        authAction =
            Auth.onPageLoad model.shared (Route.fromUrl () model.url)

        toCmd : Effect Msg -> Cmd Msg
        toCmd =
            Effect.toCmd
                { key = model.key
                , url = model.url
                , shared = model.shared
                , fromSharedMsg = Shared
                , batch = Batch
                , toCmd = Task.succeed >> Task.perform identity
                }
    in
    case authAction of
        Auth.Action.LoadPageWithUser user ->
            toRecord user

        Auth.Action.ShowLoadingPage loadingView ->
            { page = 
                ( Main.Pages.Model.Loading_
                , Cmd.none
                )
            , layout = Nothing
            }

        Auth.Action.ReplaceRoute options ->
            { page = 
                ( Main.Pages.Model.Redirecting_
                , toCmd (Effect.replaceRoute options)
                )
            , layout = Nothing
            }

        Auth.Action.PushRoute options ->
            { page = 
                ( Main.Pages.Model.Redirecting_
                , toCmd (Effect.pushRoute options)
                )
            , layout = Nothing
            }

        Auth.Action.LoadExternalUrl externalUrl ->
            { page = 
                ( Main.Pages.Model.Redirecting_
                , Browser.Navigation.load externalUrl
                )
            , layout = Nothing
            }



-- UPDATE


type Msg
    = UrlRequested Browser.UrlRequest
    | UrlChanged Url
    | Page Main.Pages.Msg.Msg
    | Layout Main.Layouts.Msg.Msg
    | Shared Shared.Msg
    | Batch (List Msg)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlRequested (Browser.Internal url) ->
            ( model
            , Browser.Navigation.pushUrl model.key (Url.toString url)
            )

        UrlRequested (Browser.External url) ->
            ( model
            , Browser.Navigation.load url
            )

        UrlChanged url ->
            if Route.Path.fromUrl url == Route.Path.fromUrl model.url then
                let
                    newModel : Model
                    newModel =
                        { model | url = url }
                in
                ( newModel
                , Cmd.batch
                      [ toPageUrlHookCmd newModel
                            { from = Route.fromUrl () model.url
                            , to = Route.fromUrl () newModel.url
                            }
                      , toLayoutUrlHookCmd model newModel
                            { from = Route.fromUrl () model.url
                            , to = Route.fromUrl () newModel.url
                            }
                      ]
                )

            else
                let
                    { page, layout } =
                        initPageAndLayout { key = model.key, shared = model.shared, layout = model.layout, url = url }

                    ( pageModel, pageCmd ) =
                        page

                    ( layoutModel, layoutCmd ) =
                        case layout of
                            Just ( layoutModel_, layoutCmd_ ) ->
                                ( Just layoutModel_, layoutCmd_ )

                            Nothing ->
                                ( Nothing, Cmd.none )

                    newModel =
                        { model | url = url, page = pageModel, layout = layoutModel }
                in
                ( newModel
                , Cmd.batch
                      [ pageCmd
                      , layoutCmd
                      , toLayoutUrlHookCmd model newModel
                            { from = Route.fromUrl () model.url
                            , to = Route.fromUrl () newModel.url
                            }
                      ]
                )

        Page pageMsg ->
            let
                ( pageModel, pageCmd ) =
                    updateFromPage pageMsg model
            in
            ( { model | page = pageModel }
            , pageCmd
            )

        Layout layoutMsg ->
            let
                ( layoutModel, layoutCmd ) =
                    updateFromLayout layoutMsg model
            in
            ( { model | layout = layoutModel }
            , layoutCmd
            )

        Shared sharedMsg ->
            let
                ( sharedModel, sharedEffect ) =
                    Shared.update (Route.fromUrl () model.url) sharedMsg model.shared

                ( oldAction, newAction ) =
                    ( Auth.onPageLoad model.shared (Route.fromUrl () model.url)
                    , Auth.onPageLoad sharedModel (Route.fromUrl () model.url)
                    )
            in
            if isAuthProtected (Route.fromUrl () model.url).path && oldAction /= newAction then
                let
                    { layout, page } =
                        initPageAndLayout { key = model.key, shared = sharedModel, url = model.url, layout = model.layout }

                    ( pageModel, pageCmd ) =
                        page

                    ( layoutModel, layoutCmd ) =
                        ( layout |> Maybe.map Tuple.first
                        , layout |> Maybe.map Tuple.second |> Maybe.withDefault Cmd.none
                        )
                in
                ( { model | shared = sharedModel, page = pageModel, layout = layoutModel }
                , Cmd.batch
                      [ pageCmd
                      , layoutCmd
                      , fromSharedEffect { model | shared = sharedModel } sharedEffect
                      ]
                )

            else
                ( { model | shared = sharedModel }
                , fromSharedEffect { model | shared = sharedModel } sharedEffect
                )

        Batch messages ->
            ( model
            , messages
                  |> List.map (Task.succeed >> Task.perform identity)
                  |> Cmd.batch
            )


updateFromPage : Main.Pages.Msg.Msg -> Model -> ( Main.Pages.Model.Model, Cmd Msg )
updateFromPage msg model =
    case ( msg, model.page ) of
        ( Main.Pages.Msg.Home_ pageMsg, Main.Pages.Model.Home_ pageModel ) ->
            Tuple.mapBoth
                Main.Pages.Model.Home_
                (Effect.map Main.Pages.Msg.Home_ >> fromPageEffect model)
                (Page.update (Pages.Home_.page model.shared (Route.fromUrl () model.url)) pageMsg pageModel)

        ( Main.Pages.Msg.Admin pageMsg, Main.Pages.Model.Admin pageModel ) ->
            Tuple.mapBoth
                Main.Pages.Model.Admin
                (Effect.map Main.Pages.Msg.Admin >> fromPageEffect model)
                (Page.update (Pages.Admin.page model.shared (Route.fromUrl () model.url)) pageMsg pageModel)

        ( Main.Pages.Msg.Fate pageMsg, Main.Pages.Model.Fate pageModel ) ->
            Tuple.mapBoth
                Main.Pages.Model.Fate
                (Effect.map Main.Pages.Msg.Fate >> fromPageEffect model)
                (Page.update (Pages.Fate.page model.shared (Route.fromUrl () model.url)) pageMsg pageModel)

        ( Main.Pages.Msg.Fate_Id_ pageMsg, Main.Pages.Model.Fate_Id_ params pageModel ) ->
            Tuple.mapBoth
                (Main.Pages.Model.Fate_Id_ params)
                (Effect.map Main.Pages.Msg.Fate_Id_ >> fromPageEffect model)
                (Page.update (Pages.Fate.Id_.page model.shared (Route.fromUrl params model.url)) pageMsg pageModel)

        ( Main.Pages.Msg.Wanderhome pageMsg, Main.Pages.Model.Wanderhome pageModel ) ->
            Tuple.mapBoth
                Main.Pages.Model.Wanderhome
                (Effect.map Main.Pages.Msg.Wanderhome >> fromPageEffect model)
                (Page.update (Pages.Wanderhome.page model.shared (Route.fromUrl () model.url)) pageMsg pageModel)

        ( Main.Pages.Msg.Wanderhome_Id_ pageMsg, Main.Pages.Model.Wanderhome_Id_ params pageModel ) ->
            Tuple.mapBoth
                (Main.Pages.Model.Wanderhome_Id_ params)
                (Effect.map Main.Pages.Msg.Wanderhome_Id_ >> fromPageEffect model)
                (Page.update (Pages.Wanderhome.Id_.page model.shared (Route.fromUrl params model.url)) pageMsg pageModel)

        ( Main.Pages.Msg.NotFound_ pageMsg, Main.Pages.Model.NotFound_ pageModel ) ->
            Tuple.mapBoth
                Main.Pages.Model.NotFound_
                (Effect.map Main.Pages.Msg.NotFound_ >> fromPageEffect model)
                (Page.update (Pages.NotFound_.page model.shared (Route.fromUrl () model.url)) pageMsg pageModel)

        _ ->
            ( model.page
            , Cmd.none
            )


updateFromLayout : Main.Layouts.Msg.Msg -> Model -> ( Maybe Main.Layouts.Model.Model, Cmd Msg )
updateFromLayout msg model =
    let
        route : Route ()
        route =
            Route.fromUrl () model.url
    in
    case ( toLayoutFromPage model, model.layout, msg ) of
        ( Just (Layouts.Default settings), Just (Main.Layouts.Model.Default layoutModel), Main.Layouts.Msg.Default layoutMsg ) ->
            Tuple.mapBoth
                (\newModel -> Just (Main.Layouts.Model.Default { layoutModel | default = newModel }))
                (Effect.map Main.Layouts.Msg.Default >> fromLayoutEffect model)
                (Layout.update (Layouts.Default.layout settings model.shared route) layoutMsg layoutModel.default)

        _ ->
            ( model.layout
            , Cmd.none
            )


toLayoutFromPage : Model -> Maybe (Layouts.Layout Msg)
toLayoutFromPage model =
    case model.page of
        Main.Pages.Model.Home_ pageModel ->
            Route.fromUrl () model.url
                |> Pages.Home_.page model.shared
                |> Page.layout pageModel
                |> Maybe.map (Layouts.map (Main.Pages.Msg.Home_ >> Page))

        Main.Pages.Model.Admin pageModel ->
            Route.fromUrl () model.url
                |> Pages.Admin.page model.shared
                |> Page.layout pageModel
                |> Maybe.map (Layouts.map (Main.Pages.Msg.Admin >> Page))

        Main.Pages.Model.Fate pageModel ->
            Route.fromUrl () model.url
                |> Pages.Fate.page model.shared
                |> Page.layout pageModel
                |> Maybe.map (Layouts.map (Main.Pages.Msg.Fate >> Page))

        Main.Pages.Model.Fate_Id_ params pageModel ->
            Route.fromUrl params model.url
                |> Pages.Fate.Id_.page model.shared
                |> Page.layout pageModel
                |> Maybe.map (Layouts.map (Main.Pages.Msg.Fate_Id_ >> Page))

        Main.Pages.Model.Wanderhome pageModel ->
            Route.fromUrl () model.url
                |> Pages.Wanderhome.page model.shared
                |> Page.layout pageModel
                |> Maybe.map (Layouts.map (Main.Pages.Msg.Wanderhome >> Page))

        Main.Pages.Model.Wanderhome_Id_ params pageModel ->
            Route.fromUrl params model.url
                |> Pages.Wanderhome.Id_.page model.shared
                |> Page.layout pageModel
                |> Maybe.map (Layouts.map (Main.Pages.Msg.Wanderhome_Id_ >> Page))

        Main.Pages.Model.NotFound_ pageModel ->
            Route.fromUrl () model.url
                |> Pages.NotFound_.page model.shared
                |> Page.layout pageModel
                |> Maybe.map (Layouts.map (Main.Pages.Msg.NotFound_ >> Page))

        Main.Pages.Model.Redirecting_ ->
            Nothing

        Main.Pages.Model.Loading_ ->
            Nothing


toAuthProtectedPage : Model -> (Auth.User -> Shared.Model -> Route params -> Page.Page model msg) -> Route params -> Maybe (Page.Page model msg)
toAuthProtectedPage model toPage route =
    case Auth.onPageLoad model.shared (Route.fromUrl () model.url) of
        Auth.Action.LoadPageWithUser user ->
            Just (toPage user model.shared route)

        _ ->
            Nothing


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        subscriptionsFromPage : Sub Msg
        subscriptionsFromPage =
            case model.page of
                Main.Pages.Model.Home_ pageModel ->
                    Page.subscriptions (Pages.Home_.page model.shared (Route.fromUrl () model.url)) pageModel
                        |> Sub.map Main.Pages.Msg.Home_
                        |> Sub.map Page

                Main.Pages.Model.Admin pageModel ->
                    Page.subscriptions (Pages.Admin.page model.shared (Route.fromUrl () model.url)) pageModel
                        |> Sub.map Main.Pages.Msg.Admin
                        |> Sub.map Page

                Main.Pages.Model.Fate pageModel ->
                    Page.subscriptions (Pages.Fate.page model.shared (Route.fromUrl () model.url)) pageModel
                        |> Sub.map Main.Pages.Msg.Fate
                        |> Sub.map Page

                Main.Pages.Model.Fate_Id_ params pageModel ->
                    Page.subscriptions (Pages.Fate.Id_.page model.shared (Route.fromUrl params model.url)) pageModel
                        |> Sub.map Main.Pages.Msg.Fate_Id_
                        |> Sub.map Page

                Main.Pages.Model.Wanderhome pageModel ->
                    Page.subscriptions (Pages.Wanderhome.page model.shared (Route.fromUrl () model.url)) pageModel
                        |> Sub.map Main.Pages.Msg.Wanderhome
                        |> Sub.map Page

                Main.Pages.Model.Wanderhome_Id_ params pageModel ->
                    Page.subscriptions (Pages.Wanderhome.Id_.page model.shared (Route.fromUrl params model.url)) pageModel
                        |> Sub.map Main.Pages.Msg.Wanderhome_Id_
                        |> Sub.map Page

                Main.Pages.Model.NotFound_ pageModel ->
                    Page.subscriptions (Pages.NotFound_.page model.shared (Route.fromUrl () model.url)) pageModel
                        |> Sub.map Main.Pages.Msg.NotFound_
                        |> Sub.map Page

                Main.Pages.Model.Redirecting_ ->
                    Sub.none

                Main.Pages.Model.Loading_ ->
                    Sub.none

        maybeLayout : Maybe (Layouts.Layout Msg)
        maybeLayout =
            toLayoutFromPage model

        route : Route ()
        route =
            Route.fromUrl () model.url

        subscriptionsFromLayout : Sub Msg
        subscriptionsFromLayout =
            case ( maybeLayout, model.layout ) of
                ( Just (Layouts.Default settings), Just (Main.Layouts.Model.Default layoutModel) ) ->
                    Layout.subscriptions (Layouts.Default.layout settings model.shared route) layoutModel.default
                        |> Sub.map Main.Layouts.Msg.Default
                        |> Sub.map Layout

                _ ->
                    Sub.none
    in
    Sub.batch
        [ Shared.subscriptions route model.shared
              |> Sub.map Shared
        , subscriptionsFromPage
        , subscriptionsFromLayout
        ]



-- VIEW


view : Model -> Browser.Document Msg
view model =
    let
        view_ : View Msg
        view_ =
            toView model
    in
    View.toBrowserDocument
        { shared = model.shared
        , route = Route.fromUrl () model.url
        , view = view_
        }


toView : Model -> View Msg
toView model =
    let
        route : Route ()
        route =
            Route.fromUrl () model.url
    in
    case ( toLayoutFromPage model, model.layout ) of
        ( Just (Layouts.Default settings), Just (Main.Layouts.Model.Default layoutModel) ) ->
            Layout.view
                (Layouts.Default.layout settings model.shared route)
                { model = layoutModel.default
                , toContentMsg = Main.Layouts.Msg.Default >> Layout
                , content = viewPage model
                }

        _ ->
            viewPage model


viewPage : Model -> View Msg
viewPage model =
    case model.page of
        Main.Pages.Model.Home_ pageModel ->
            Page.view (Pages.Home_.page model.shared (Route.fromUrl () model.url)) pageModel
                |> View.map Main.Pages.Msg.Home_
                |> View.map Page

        Main.Pages.Model.Admin pageModel ->
            Page.view (Pages.Admin.page model.shared (Route.fromUrl () model.url)) pageModel
                |> View.map Main.Pages.Msg.Admin
                |> View.map Page

        Main.Pages.Model.Fate pageModel ->
            Page.view (Pages.Fate.page model.shared (Route.fromUrl () model.url)) pageModel
                |> View.map Main.Pages.Msg.Fate
                |> View.map Page

        Main.Pages.Model.Fate_Id_ params pageModel ->
            Page.view (Pages.Fate.Id_.page model.shared (Route.fromUrl params model.url)) pageModel
                |> View.map Main.Pages.Msg.Fate_Id_
                |> View.map Page

        Main.Pages.Model.Wanderhome pageModel ->
            Page.view (Pages.Wanderhome.page model.shared (Route.fromUrl () model.url)) pageModel
                |> View.map Main.Pages.Msg.Wanderhome
                |> View.map Page

        Main.Pages.Model.Wanderhome_Id_ params pageModel ->
            Page.view (Pages.Wanderhome.Id_.page model.shared (Route.fromUrl params model.url)) pageModel
                |> View.map Main.Pages.Msg.Wanderhome_Id_
                |> View.map Page

        Main.Pages.Model.NotFound_ pageModel ->
            Page.view (Pages.NotFound_.page model.shared (Route.fromUrl () model.url)) pageModel
                |> View.map Main.Pages.Msg.NotFound_
                |> View.map Page

        Main.Pages.Model.Redirecting_ ->
            View.none

        Main.Pages.Model.Loading_ ->
            Auth.viewLoadingPage model.shared (Route.fromUrl () model.url)
                |> View.map never



-- INTERNALS


fromPageEffect : { model | key : Browser.Navigation.Key, url : Url, shared : Shared.Model } -> Effect Main.Pages.Msg.Msg -> Cmd Msg
fromPageEffect model effect =
    Effect.toCmd
        { key = model.key
        , url = model.url
        , shared = model.shared
        , fromSharedMsg = Shared
        , batch = Batch
        , toCmd = Task.succeed >> Task.perform identity
        }
        (Effect.map Page effect)


fromLayoutEffect : { model | key : Browser.Navigation.Key, url : Url, shared : Shared.Model } -> Effect Main.Layouts.Msg.Msg -> Cmd Msg
fromLayoutEffect model effect =
    Effect.toCmd
        { key = model.key
        , url = model.url
        , shared = model.shared
        , fromSharedMsg = Shared
        , batch = Batch
        , toCmd = Task.succeed >> Task.perform identity
        }
        (Effect.map Layout effect)


fromSharedEffect : { model | key : Browser.Navigation.Key, url : Url, shared : Shared.Model } -> Effect Shared.Msg -> Cmd Msg
fromSharedEffect model effect =
    Effect.toCmd
        { key = model.key
        , url = model.url
        , shared = model.shared
        , fromSharedMsg = Shared
        , batch = Batch
        , toCmd = Task.succeed >> Task.perform identity
        }
        (Effect.map Shared effect)



-- URL HOOKS FOR PAGES


toPageUrlHookCmd : Model -> { from : Route (), to : Route () } -> Cmd Msg
toPageUrlHookCmd model routes =
    let
        toCommands messages =
            messages
                |> List.map (Task.succeed >> Task.perform identity)
                |> Cmd.batch
    in
    case model.page of
        Main.Pages.Model.Home_ pageModel ->
            Page.toUrlMessages routes (Pages.Home_.page model.shared (Route.fromUrl () model.url)) 
                |> List.map Main.Pages.Msg.Home_
                |> List.map Page
                |> toCommands

        Main.Pages.Model.Admin pageModel ->
            Page.toUrlMessages routes (Pages.Admin.page model.shared (Route.fromUrl () model.url)) 
                |> List.map Main.Pages.Msg.Admin
                |> List.map Page
                |> toCommands

        Main.Pages.Model.Fate pageModel ->
            Page.toUrlMessages routes (Pages.Fate.page model.shared (Route.fromUrl () model.url)) 
                |> List.map Main.Pages.Msg.Fate
                |> List.map Page
                |> toCommands

        Main.Pages.Model.Fate_Id_ params pageModel ->
            Page.toUrlMessages routes (Pages.Fate.Id_.page model.shared (Route.fromUrl params model.url)) 
                |> List.map Main.Pages.Msg.Fate_Id_
                |> List.map Page
                |> toCommands

        Main.Pages.Model.Wanderhome pageModel ->
            Page.toUrlMessages routes (Pages.Wanderhome.page model.shared (Route.fromUrl () model.url)) 
                |> List.map Main.Pages.Msg.Wanderhome
                |> List.map Page
                |> toCommands

        Main.Pages.Model.Wanderhome_Id_ params pageModel ->
            Page.toUrlMessages routes (Pages.Wanderhome.Id_.page model.shared (Route.fromUrl params model.url)) 
                |> List.map Main.Pages.Msg.Wanderhome_Id_
                |> List.map Page
                |> toCommands

        Main.Pages.Model.NotFound_ pageModel ->
            Page.toUrlMessages routes (Pages.NotFound_.page model.shared (Route.fromUrl () model.url)) 
                |> List.map Main.Pages.Msg.NotFound_
                |> List.map Page
                |> toCommands

        Main.Pages.Model.Redirecting_ ->
            Cmd.none

        Main.Pages.Model.Loading_ ->
            Cmd.none


toLayoutUrlHookCmd : Model -> Model -> { from : Route (), to : Route () } -> Cmd Msg
toLayoutUrlHookCmd oldModel model routes =
    let
        toCommands messages =
            if shouldFireUrlChangedEvents then
                messages
                    |> List.map (Task.succeed >> Task.perform identity)
                    |> Cmd.batch

            else
                Cmd.none

        shouldFireUrlChangedEvents =
            hasNavigatedWithinNewLayout
                { from = toLayoutFromPage oldModel
                , to = toLayoutFromPage model
                }

        route =
            Route.fromUrl () model.url
    in
    case ( toLayoutFromPage model, model.layout ) of
        ( Just (Layouts.Default settings), Just (Main.Layouts.Model.Default layoutModel) ) ->
            Layout.toUrlMessages routes (Layouts.Default.layout settings model.shared route)
                |> List.map Main.Layouts.Msg.Default
                |> List.map Layout
                |> toCommands

        _ ->
            Cmd.none


hasNavigatedWithinNewLayout : { from : Maybe (Layouts.Layout msg), to : Maybe (Layouts.Layout msg) } -> Bool
hasNavigatedWithinNewLayout { from, to } =
    let
        isRelated maybePair =
            case maybePair of
                Just ( Layouts.Default _, Layouts.Default _ ) ->
                    True

                _ ->
                    False
    in
    List.any isRelated
        [ Maybe.map2 Tuple.pair from to
        , Maybe.map2 Tuple.pair to from
        ]


isAuthProtected : Route.Path.Path -> Bool
isAuthProtected routePath =
    case routePath of
        Route.Path.Home_ ->
            False

        Route.Path.Admin ->
            False

        Route.Path.Fate ->
            False

        Route.Path.Fate_Id_ _ ->
            False

        Route.Path.Wanderhome ->
            False

        Route.Path.Wanderhome_Id_ _ ->
            False

        Route.Path.NotFound_ ->
            False
