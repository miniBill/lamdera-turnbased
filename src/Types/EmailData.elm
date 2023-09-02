module Types.EmailData exposing (EmailData(..), HtmlEmail, toHtmlEmail, toSendGrid)

import Dict
import Email.Html
import Email.Html.Attributes
import EmailAddress exposing (EmailAddress)
import Env
import List.Nonempty as Nonempty
import Route exposing (Route)
import SendGrid
import String.Nonempty exposing (NonemptyString(..))
import Types.Token exposing (Token(..))


type EmailData
    = LoginEmail
        { to : EmailAddress
        , route : Route ()
        , token : Token
        }


toSendGrid : EmailData -> Maybe SendGrid.Email
toSendGrid email =
    toHtmlEmail email
        |> Maybe.map SendGrid.htmlEmail


type alias HtmlEmail =
    { nameOfSender : String
    , emailAddressOfSender : EmailAddress
    , to : Nonempty.Nonempty EmailAddress
    , subject : NonemptyString
    , content : Email.Html.Html
    }


toHtmlEmail : EmailData -> Maybe HtmlEmail
toHtmlEmail email =
    case email of
        LoginEmail { route, to, token } ->
            senderEmail
                |> Maybe.map
                    (\sender ->
                        { subject = NonemptyString 'L' "ogin to TurnBased"
                        , to = Nonempty.fromElement to
                        , content = loginEmailDetails route token
                        , nameOfSender = Env.emailSenderName
                        , emailAddressOfSender = sender
                        }
                    )


loginEmailDetails : Route () -> Token -> Email.Html.Html
loginEmailDetails route (Token token) =
    Email.Html.div
        []
        [ Email.Html.a
            [ Email.Html.Attributes.href <|
                Env.domain
                    ++ Route.toString
                        { route
                            | query = Dict.insert "token" token route.query
                        }
            ]
            [ Email.Html.text "Login"
            ]
        ]


senderEmail : Maybe EmailAddress
senderEmail =
    EmailAddress.fromString Env.emailSenderAddress
