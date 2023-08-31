module Pages.Fate exposing (Model, Msg, page, updateFromBackend)

import Bridge exposing (ToFrontendPage(..))
import Diceware
import Effect exposing (Effect)
import Element.WithContext exposing (centerX, centerY, el, fill, height, link, paragraph, rgb255, text)
import Element.WithContext.Background as Background
import Element.WithContext.Border as Border
import Element.WithContext.Font as Font
import Element.WithContext.Input as Input
import Fonts
import Page exposing (Page)
import Random
import Route exposing (Route)
import Route.Path
import Shared
import Theme
import View exposing (View, ViewKind(..))


page : Shared.Model -> Route () -> Page Model Msg
page shared _ =
    Page.new
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view shared
        }



-- INIT


type alias Model =
    { input : String
    , placeholder : Maybe String
    }


init : () -> ( Model, Effect Msg )
init _ =
    ( { input = ""
      , placeholder = Nothing
      }
    , Random.int Diceware.listLength (Diceware.listLength ^ 2 - 1)
        |> Random.map Diceware.numberToWords
        |> Random.generate Placeholder
        |> Effect.sendCmd
    )



-- UPDATE


type Msg
    = Input String
    | Placeholder String


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        Input input ->
            ( { model | input = input }, Effect.none )

        Placeholder placeholder ->
            ( { model | placeholder = Just placeholder }, Effect.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Shared.Model -> Model -> View Msg
view _ model =
    { kind = Fate
    , body = body model
    }


body : Model -> Theme.Element Msg
body model =
    Theme.column
        [ centerX
        , height fill
        ]
        [ Theme.fateTitle
        , Theme.column [ centerX, centerY ]
            [ Input.text
                [ Font.center
                , centerY
                , Background.color Theme.colors.fateBackground
                , Border.color Theme.colors.fate
                ]
                { label =
                    Input.labelAbove [ centerX ] <|
                        paragraph
                            [ Fonts.gotham ]
                            [ text "GAME NAME" ]
                , onChange = Input
                , text = model.input
                , placeholder =
                    Maybe.map
                        (\placeholder ->
                            Input.placeholder
                                [ Font.color <| rgb255 0xA8 0xAA 0xA5 ]
                                (text placeholder)
                        )
                        model.placeholder
                }
            , if String.length model.input > 5 then
                link
                    [ centerX
                    , Border.width 1
                    , Theme.padding
                    , Border.rounded Theme.rythm
                    , Fonts.gotham
                    ]
                    { url = Route.Path.toString <| Route.Path.Fate_Id_ { id = model.input }
                    , label = text "JOIN GAME"
                    }

              else
                el
                    [ Theme.padding
                    , Border.width 1
                    , Border.color Theme.colors.fateBackground
                    ]
                    (text " ")
            ]
        ]


updateFromBackend : ToFrontendPage -> Model -> ( Model, Effect Msg )
updateFromBackend msg model =
    case msg of
        TFAdminPageData _ ->
            ( model, Effect.none )
