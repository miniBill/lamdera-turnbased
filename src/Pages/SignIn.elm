module Pages.SignIn exposing (Model, Msg, page, updateFromBackend)

import Bridge exposing (ToFrontendPage(..))
import Effect exposing (Effect)
import Element.WithContext as Element exposing (centerX, centerY, el, fill, text, width)
import Element.WithContext.Font as Font
import Element.WithContext.Input as Input
import Page exposing (Page)
import Route exposing (Route)
import Shared
import Theme
import View exposing (View)


page : Shared.Model -> Route () -> Page Model Msg
page shared route =
    Page.new
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- INIT


type alias Model =
    { email : String
    , isSubmitting : Bool
    }


init : () -> ( Model, Effect Msg )
init () =
    ( { email = ""
      , isSubmitting = False
      }
    , Effect.none
    )



-- UPDATE


type Msg
    = Email String
    | Submit


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        Email email ->
            ( { model | email = email }, Effect.none )

        Submit ->
            if not model.isSubmitting && isInputValid model then
                ( { model | isSubmitting = True }, Effect.none )

            else
                ( model, Effect.none )


isInputValid : Model -> Bool
isInputValid model =
    case List.reverse <| String.split "@" model.email of
        domain :: _ :: _ ->
            case List.reverse <| String.split "." domain of
                tld :: _ :: _ ->
                    String.length tld > 1

                _ ->
                    False

        _ ->
            False



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { kind = View.Home
    , body =
        Theme.column
            [ centerX
            , centerY
            ]
            [ el
                [ centerX
                , Font.size 40
                ]
                (text "Log in or sign up")
            , Input.email [ Theme.onEnter Submit ]
                { label = Input.labelLeft [] <| text "Email"
                , text = model.email
                , onChange = Email
                , placeholder = Just <| Input.placeholder [] <| text "your@email.here"
                }
            , Theme.button
                [ width fill
                , Font.center
                ]
                (if model.isSubmitting then
                    { onPress = Nothing
                    , label = text "Submitting..."
                    }

                 else if isInputValid model then
                    { onPress = Just Submit
                    , label = text "Submit"
                    }

                 else
                    { onPress = Nothing
                    , label = text "Insert a valid email"
                    }
                )
            ]
    }


updateFromBackend : ToFrontendPage -> Model -> ( Model, Cmd Msg )
updateFromBackend msg model =
    case msg of
        TFAdminPageData _ ->
            ( model, Cmd.none )
