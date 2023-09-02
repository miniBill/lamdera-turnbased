module Pages.Fate exposing (Model, Msg, page, updateFromBackend)

import Bridge exposing (ToBackend(..), ToFrontendPage(..))
import Diceware
import Dict exposing (Dict)
import Effect exposing (Effect)
import Element.WithContext as Element exposing (Column, alignRight, alignTop, centerX, centerY, column, el, fill, fillPortion, height, link, padding, paddingXY, paragraph, px, rgb255, shrink, table, text, width)
import Element.WithContext.Background as Background
import Element.WithContext.Border as Border
import Element.WithContext.Font as Font
import Element.WithContext.Input as Input
import Fonts
import Layouts
import List.Extra
import Page exposing (Page)
import Random
import Route exposing (Route)
import Route.Path
import Set exposing (Set)
import Shared
import Shared.Model exposing (ViewKind(..))
import Theme exposing (Attribute, Context, Element)
import Types.Fate as Fate exposing (Aspects, Character, Consequences, Skill)
import Types.ServerData as ServerData exposing (ServerData(..))
import View exposing (View)


page : Shared.Model -> Route () -> Page Model Msg
page shared _ =
    Page.new
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view shared
        }
        |> Page.withLayout (\_ -> Layouts.Default {})



-- INIT


type alias Model =
    { input : String
    , placeholder : Maybe String
    , characters : ServerData (List Character)
    }


init : () -> ( Model, Effect Msg )
init _ =
    ( { input = ""
      , placeholder = Nothing
      , characters = ServerData.Loading
      }
    , Effect.batch
        [ Random.int Diceware.listLength (Diceware.listLength ^ 2 - 1)
            |> Random.map Diceware.numberToWords
            |> Random.generate Placeholder
            |> Effect.sendCmd
        , Effect.sendToBackend TBLoadFateCharacters
        ]
    )



-- UPDATE


type Msg
    = Input String
    | Placeholder String
    | CreateCharacter
    | SetCharacterAt Int Character


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        Input input ->
            ( { model | input = input }, Effect.none )

        Placeholder placeholder ->
            ( { model | placeholder = Just placeholder }, Effect.none )

        CreateCharacter ->
            ( { model
                | characters =
                    ServerData.map
                        ((::) Fate.emptyCharacter)
                        model.characters
              }
            , Effect.none
            )

        SetCharacterAt index character ->
            ( { model
                | characters =
                    ServerData.map
                        (List.Extra.setAt index character)
                        model.characters
              }
            , Effect.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Shared.Model -> Model -> View Msg
view _ model =
    { kind = FateView
    , body = body model
    }


body : Model -> Theme.Element Msg
body model =
    Theme.column
        [ width fill
        , height fill
        ]
        [ Theme.fateTitle [ centerX ]
        , Theme.box
            [ width fill
            , Fonts.gotham
            , Theme.htmlStyle "font-variant" "small-caps"
            ]
            { label =
                Theme.row [ width fill ]
                    [ el
                        [ Font.bold
                        ]
                        (text "Characters")
                    , Theme.button [ alignRight ]
                        { onPress = Just CreateCharacter
                        , label = text "Create new"
                        }
                    ]
            , children =
                case model.characters of
                    Loading ->
                        [ text "Loading..." ]

                    Loaded [] ->
                        [ Theme.row []
                            [ text "None yet, maybe you want to"
                            , Theme.button [ alignRight ]
                                { onPress = Just CreateCharacter
                                , label = text "create a new one"
                                }
                            , text "?"
                            ]
                        ]

                    Loaded characters ->
                        List.indexedMap
                            (\i character ->
                                Element.map
                                    (SetCharacterAt i)
                                    (viewCharacter character)
                            )
                            characters
            }
        , if false then
            joinView model

          else
            Element.none
        ]


viewCharacter : Character -> Element Character
viewCharacter character =
    let
        children =
            [ [ aspectsBlock character.aspects
                    |> Element.map (\newAspects -> { character | aspects = newAspects })
              , skillsBlock character.skills
                    |> Element.map (\newSkills -> { character | skills = newSkills })
              ]
            , [ stressAndConsequencesBlock character, stuntsAndExtrasBlock character ]
            ]
    in
    Theme.column [ Theme.padding, width fill ]
        [ Theme.wrappedRow [ width fill ]
            [ idBox character ]
        , Theme.grid [ width fill ]
            [ fillPortion 1, fillPortion 2 ]
            children
        ]


idBox : Character -> Element Character
idBox character =
    Theme.titledBox (text "Id") [ width fill ] <|
        Theme.row [ width fill, Theme.padding ]
            [ viewAvatar character.avatarUrl
            , Theme.column [ width fill, alignTop ]
                [ Theme.grid [ width fill ]
                    [ fill, shrink ]
                    [ [ label "Name", label "Fate" ]
                    , [ Input.text
                            [ width fill, centerY ]
                            { label = Input.labelHidden "Name"
                            , onChange = \n -> { character | name = n }
                            , text = character.name
                            , placeholder = Nothing
                            }
                      , Element.map
                            (\fate -> { character | fate = fate })
                        <|
                            plusMinus character.fate
                      ]
                    , [ label "Description", label "Refresh" ]
                    , [ Input.text
                            [ width fill ]
                            { label = Input.labelHidden "Description"
                            , onChange = \n -> { character | description = n }
                            , text = character.description
                            , placeholder = Nothing
                            }
                      , el [ alignTop ] <|
                            Element.map
                                (\refresh -> { character | refresh = refresh })
                            <|
                                plusMinus character.refresh
                      ]
                    ]
                , Input.text
                    [ width fill, Theme.htmlStyle "word-break" "break-all" ]
                    { label = Input.labelAbove [] <| text "Avatar"
                    , onChange = \n -> { character | avatarUrl = n }
                    , text = character.avatarUrl
                    , placeholder = Nothing
                    }
                ]
            ]


plusMinus : Int -> Element Int
plusMinus value =
    Theme.row [ centerY ]
        [ Theme.button []
            { onPress =
                if value > 0 then
                    Just (value - 1)

                else
                    Nothing
            , label = text "-"
            }
        , text <| String.fromInt value
        , Theme.button []
            { onPress = Just (value + 1)
            , label = text "+"
            }
        ]


label : String -> Element msg
label content =
    Element.el
        [ Font.size 14
        , Font.color Theme.colors.disabled
        ]
        (text content)


viewAvatar : String -> Element msg
viewAvatar avatarUrl =
    if String.isEmpty avatarUrl then
        el [ centerY ] <| text "No avatar"

    else
        imageContain
            [ width <| px 200
            , height <| px 200
            , Element.pointer
            , centerY
            ]
            { src = avatarUrl
            , description = "Avatar"
            }


imageContain :
    List (Attribute msg)
    -> { src : String, description : String }
    -> Element msg
imageContain attrs { src } =
    el
        ([ Theme.htmlStyle "background-image" <| "url(\"" ++ src ++ "\")"
         , Theme.htmlStyle "background-position" "center"
         , Theme.htmlStyle "background-repeat" "no-repeat"
         , Theme.htmlStyle "background-size" "contain"
         ]
            ++ attrs
        )
        Element.none


stuntsAndExtrasBlock : Character -> Element Character
stuntsAndExtrasBlock ({ stunts } as character) =
    let
        filteredStunts =
            stunts
                |> List.filter (not << String.isEmpty)
                |> (\l -> l ++ [ "" ])

        viewStunt i stunt =
            Input.text
                [ width fill ]
                { label = Input.labelHidden "Stunt"
                , onChange = \v -> { character | stunts = List.Extra.setAt i v filteredStunts }
                , text = stunt
                , placeholder = Nothing
                }
    in
    filteredStunts
        |> List.indexedMap viewStunt
        |> Theme.column [ Theme.padding, width fill ]
        |> Theme.titledBox (text "Stunts and Extras") [ width <| Element.minimum 800 fill, height fill ]


stressAndConsequencesBlock : Character -> Element Character
stressAndConsequencesBlock ({ physicalStress, mentalStress, consequences, skills } as character) =
    let
        physique : Int
        physique =
            Dict.get "Physique" skills |> Maybe.withDefault 0

        will : Int
        will =
            Dict.get "Will" skills |> Maybe.withDefault 0

        lbl value =
            el
                [ width fill
                , Font.center
                , Font.size 14
                , Font.color Theme.colors.disabled
                ]
                (text value)

        hr =
            el
                [ Border.color Theme.colors.disabled
                , Border.width 1
                , width fill
                ]
                Element.none

        setFlip v s =
            if Set.member v s then
                Set.remove v s

            else
                Set.insert v s

        container =
            Theme.titledBox (text "Stress and Consequences") [ width fill, alignTop ]
    in
    container <|
        Theme.column [ alignTop, Theme.padding, width fill ]
            [ Theme.grid [ width fill ]
                [ fill, fill ]
                [ [ lbl "Physical Stress (Physique)"
                  , lbl "Mental Stress (Will)"
                  ]
                , [ stressTrack
                        (\s -> { character | physicalStress = setFlip s physicalStress })
                        physique
                        physicalStress
                  , stressTrack
                        (\s -> { character | mentalStress = setFlip s mentalStress })
                        will
                        mentalStress
                  ]
                ]
            , hr
            , viewConsequence character True 2 "Mild" consequences.two <| \v -> { consequences | two = v }
            , hr
            , viewConsequence character True 4 "Moderate" consequences.four <| \v -> { consequences | four = v }
            , hr
            , viewConsequence character True 6 "Severe" consequences.six <| \v -> { consequences | six = v }
            , hr
            , viewConsequence character (will >= 5 || physique >= 5) 2 "Mild" consequences.twoExtra <| \v -> { consequences | twoExtra = v }
            ]


viewConsequence : Character -> Bool -> Int -> String -> Maybe String -> (Maybe String -> Consequences) -> Element Character
viewConsequence character enabled points consequenceLabel value setter =
    let
        tackButton =
            el [ centerY ] <| stressCell tackParams

        tackParams =
            { tack = points
            , crossed = value /= Nothing
            , enabled = enabled
            , onPress =
                if enabled then
                    Just <|
                        { character
                            | consequences =
                                setter
                                    (if value == Nothing then
                                        Just ""

                                     else
                                        Nothing
                                    )
                        }

                else
                    Nothing
            }

        valueBox =
            if enabled then
                Input.text
                    [ width fill ]
                    { label = Input.labelHidden consequenceLabel
                    , placeholder = Nothing
                    , onChange = \nv -> { character | consequences = setter <| Just nv }
                    , text = Maybe.withDefault "" value
                    }

            else
                el [ centerY, paddingXY Theme.rythm 0 ] <| text "---"
    in
    Theme.grid [ width fill ]
        [ px 42, fill ]
        [ [ Element.none
          , Element.el
                [ Font.size 14
                , Font.color Theme.colors.disabled
                ]
                (text consequenceLabel)
          ]
        , [ tackButton, valueBox ]
        ]


stressTrack : (Int -> msg) -> Int -> Set Int -> Element msg
stressTrack toMsg skillLevel tacks =
    let
        tc tack sl =
            stressCell
                { tack = tack
                , crossed = Set.member tack tacks
                , onPress =
                    if skillLevel >= sl then
                        Just <| toMsg tack

                    else
                        Nothing
                }
    in
    el [ width fill ] <|
        Theme.row [ centerX ]
            [ tc 1 0
            , tc 2 0
            , tc 3 1
            , tc 4 3
            ]


stressCell : { a | tack : Int, crossed : Bool, onPress : Maybe msg } -> Element msg
stressCell { tack, crossed, onPress } =
    Theme.button
        [ padding <| Theme.rythm // 2
        , crossBehind crossed
        ]
        { label =
            el [ centerX, centerY ] <|
                text <|
                    String.fromInt tack
        , onPress = onPress
        }


crossBehind : Bool -> Attribute msg
crossBehind crossed =
    Element.behindContent <|
        if crossed then
            el [ centerX, centerY ] (text "❌")

        else
            Element.none


aspectsBlock : Aspects -> Element Aspects
aspectsBlock aspects =
    let
        filteredOther =
            aspects.others
                |> List.filter (not << String.isEmpty)
                |> pad 3 ""

        pad len padding list =
            if List.length list >= len then
                list

            else
                list ++ List.repeat (len - List.length list) padding

        otherView i o =
            Input.text
                [ width fill ]
                { text = o
                , placeholder = Nothing
                , onChange = \v -> { aspects | others = List.Extra.setAt i v filteredOther }
                , label = Input.labelAbove [] <| text "Aspect"
                }
    in
    Theme.titledBox (text "Aspects") [ width fill, height fill ] <|
        Theme.column [ width fill, Theme.padding ] <|
            [ Input.text
                []
                { label = Input.labelHidden "High Concept"
                , text = aspects.highConcept
                , placeholder = Nothing
                , onChange = \v -> { aspects | highConcept = v }
                }
            , Input.text
                []
                { label = Input.labelHidden "Trouble"
                , text = aspects.trouble
                , placeholder = Nothing
                , onChange = \v -> { aspects | trouble = v }
                }
            , Element.el
                [ Font.size 14
                , Font.color Theme.colors.disabled
                ]
                (text "Other aspects")
            ]
                ++ List.indexedMap otherView filteredOther


skillsBlock : Dict Skill Int -> Element (Dict Skill Int)
skillsBlock skills =
    let
        maxOrMaxPlusOne l =
            l
                |> List.maximum
                |> Maybe.withDefault 0
                |> (+) 1

        skillWidth =
            skills
                |> Dict.values
                |> List.Extra.gatherEquals
                |> List.map (\( _, others ) -> List.length others)
                |> maxOrMaxPlusOne

        maxSkillLevel =
            skills
                |> Dict.values
                |> maxOrMaxPlusOne

        hr rowNumber =
            let
                e { top, bottom } =
                    el
                        [ width fill
                        , height <| px 3
                        , Border.color Theme.colors.disabled
                        , Border.widthEach { top = top, left = 0, right = 1, bottom = bottom }
                        ]
                        Element.none
            in
            column [] <|
                if rowNumber == 0 then
                    [ e { top = 0, bottom = 1 }
                    ]

                else if rowNumber == maxSkillLevel * 2 then
                    [ e { top = 1, bottom = 0 }
                    ]

                else
                    [ e { top = 0, bottom = 1 }
                    , e { top = 0, bottom = 0 }
                    ]

        labelsColumn : Column Context Int msg
        labelsColumn =
            { header = Element.none
            , width = shrink
            , view =
                \rowNumber ->
                    case modBy 2 rowNumber of
                        0 ->
                            hr rowNumber

                        _ ->
                            intToSkillLabel ((rowNumber + 1) // 2)
                                |> text
                                |> el [ Font.bold, centerY, Theme.padding ]
            }

        skillColumn : Int -> Column Context Int (Dict Skill Int)
        skillColumn colNumber =
            { header = Element.none
            , width = fill
            , view =
                \rowNumber ->
                    if modBy 2 rowNumber == 0 then
                        hr rowNumber

                    else
                        viewSkillCell skills colNumber rowNumber
            }

        container =
            Theme.titledBox (text "Skills") [ width fill, height fill, alignTop ]

        skillsSquare =
            container <|
                table []
                    { data = List.range 0 (2 * maxSkillLevel) |> List.reverse
                    , columns = labelsColumn :: List.map skillColumn (List.range 1 skillWidth)
                    }
    in
    skillsSquare


viewSkillCell : Dict Skill Int -> Int -> Int -> Element (Dict Skill Int)
viewSkillCell skills colNumber rowNumber =
    let
        skillLevel =
            (rowNumber + 1) // 2

        got =
            skills
                |> Dict.toList
                |> List.filter (\( _, lvl ) -> lvl == skillLevel)
                |> List.map Tuple.first

        maybeSkill =
            got
                |> List.drop (colNumber - 1)
                |> List.head

        skillInput _ =
            Theme.select [ Theme.padding ]
                { items = Fate.allSkills
                , view = identity
                , selected = maybeSkill
                , onChange =
                    \newValue ->
                        let
                            removed =
                                case maybeSkill of
                                    Just skill ->
                                        Dict.remove skill skills

                                    Nothing ->
                                        skills
                        in
                        case newValue of
                            Nothing ->
                                removed

                            Just skill ->
                                Dict.insert skill skillLevel removed
                }
    in
    if List.length got < colNumber - 1 then
        Element.none

    else
        skillInput ()


intToSkillLabel : Int -> String
intToSkillLabel i =
    case i of
        0 ->
            "Mediocre (+0)"

        1 ->
            "Average (+1)"

        2 ->
            "Fair (+2)"

        3 ->
            "Good (+3)"

        4 ->
            "Greate (+4)"

        5 ->
            "Superb (+5)"

        6 ->
            "Fantastic (+6)"

        7 ->
            "Epic (+7)"

        8 ->
            "Legendary (+8)"

        _ ->
            if i == -1 then
                "Poor (-1)"

            else if i == -2 then
                "Terrible (-2)"

            else if i < 0 then
                "??? (" ++ String.fromInt i ++ ")"

            else
                "!!! (+" ++ String.fromInt i ++ ")"


joinView : Model -> Element Msg
joinView model =
    Theme.column [ centerX, centerY ]
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
                        [ text "Game name" ]
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
                , label = text "Join game"
                }

          else
            el
                [ Theme.padding
                , Border.width 1
                , Border.color Theme.colors.fateBackground
                ]
                (text " ")
        ]


false : Bool
false =
    False


updateFromBackend : ToFrontendPage -> Model -> ( Model, Effect Msg )
updateFromBackend msg model =
    case msg of
        TFAdminPageData _ ->
            ( model, Effect.none )

        TFLoadedFateCharacters characters ->
            ( { model | characters = Loaded characters }, Effect.none )
