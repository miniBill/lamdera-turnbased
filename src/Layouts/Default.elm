module Layouts.Default exposing (Model, Msg, Props, layout)

import Bridge exposing (ToBackend(..))
import Dict
import Effect exposing (Effect)
import Element.WithContext as Element exposing (centerX, centerY, el, fill, height, paragraph, rgb, text, width)
import Element.WithContext.Background as Background
import Element.WithContext.Border as Border
import Element.WithContext.Font as Font
import Element.WithContext.Input as Input
import Layout exposing (Layout)
import Route exposing (Route)
import Shared
import Shared.Model exposing (LoggedIn(..), ViewKind(..))
import Theme exposing (Element)
import Types.Token exposing (Token(..))
import Types.UserId as UserId
import View exposing (View)


type alias Props =
    {}


layout : Props -> Shared.Model -> Route () -> Layout () Model Msg contentMsg
layout _ shared route =
    Layout.new
        { init = init route
        , update = update route
        , view = view shared
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { email : String
    , isSubmitting : Bool
    }


init : Route () -> () -> ( Model, Effect Msg )
init route _ =
    case Dict.get "token" route.query of
        Nothing ->
            ( { email = ""
              , isSubmitting = False
              }
            , Effect.none
            )

        Just token ->
            ( { email = ""
              , isSubmitting = False
              }
            , Effect.batch
                [ Effect.sendToBackend <| TBLoginWithToken (Token token)
                , Effect.replaceRoute { route | query = Dict.remove "token" route.query }
                ]
            )



-- UPDATE


type Msg
    = Email String
    | Submit


update : Route () -> Msg -> Model -> ( Model, Effect Msg )
update route msg model =
    case msg of
        Email email ->
            ( { model | email = email }, Effect.none )

        Submit ->
            if not model.isSubmitting && isInputValid model then
                ( { model | isSubmitting = True }
                , Effect.sendToBackend <| TBLogin route model.email
                )

            else
                ( model, Effect.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Shared.Model -> { toContentMsg : Msg -> contentMsg, content : View contentMsg, model : Model } -> View contentMsg
view shared { toContentMsg, model, content } =
    { kind = content.kind
    , body =
        case shared.loggedIn of
            Shared.Model.Unknown ->
                el [ centerX, centerY ] <| text "Loading..."

            LoggedInAs user ->
                Theme.column
                    [ width fill
                    , height fill
                    ]
                    [ text <| "Logged in as " ++ UserId.toString user.userId
                    , content.body
                    ]

            NotLoggedIn ->
                viewLoginForm model Nothing
                    |> Element.map toContentMsg

            InvalidEmail ->
                viewLoginForm model (Just "Invalid email!")
                    |> Element.map toContentMsg

            EmailError ->
                viewLoginForm model (Just "There was an error in sending the email link, try again later.")
                    |> Element.map toContentMsg

            EmailSent ->
                paragraph [ centerX, centerY ]
                    [ text "We sent you an email with your login link. Check your inbox! And spam folder! And Cthulhu folder (just in case)!"
                    ]
                    |> Element.map toContentMsg
    }


viewLoginForm : Model -> Maybe String -> Element Msg
viewLoginForm model error =
    Element.withContext <|
        \{ viewKind } ->
            let
                loginColumn : List (Element Msg)
                loginColumn =
                    [ el
                        [ centerX
                        , Font.size 40
                        ]
                        (text "Log in or sign up")
                    , Input.email
                        (Theme.onEnter Submit :: colors)
                        { label = Input.labelLeft [] <| text "Email"
                        , text = model.email
                        , onChange = Email
                        , placeholder = Just <| Input.placeholder [] <| text "your@email.here"
                        }
                    , case error of
                        Nothing ->
                            Element.none

                        Just e ->
                            el [ Font.color <| rgb 1 0 0, Font.bold ] <| text e
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

                colors =
                    case viewKind of
                        HomeView ->
                            []

                        FateView ->
                            [ Background.color Theme.colors.fateBackground
                            , Border.color Theme.colors.fate
                            ]

                        WanderhomeView ->
                            [ Background.color Theme.colors.wanderhomeBackground
                            , Border.color Theme.colors.wanderhome
                            ]

                        AdminView ->
                            []
            in
            loginColumn
                |> Theme.column
                    [ centerX
                    , centerY
                    ]


isInputValid : Model -> Bool
isInputValid { email } =
    isEmailValid email


isEmailValid : String -> Bool
isEmailValid email =
    case List.reverse <| String.split "@" email of
        domain :: _ :: _ ->
            case List.reverse <| String.split "." domain of
                tld :: _ :: _ ->
                    String.length tld > 1

                _ ->
                    False

        _ ->
            False
