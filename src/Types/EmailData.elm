module Types.EmailData exposing (EmailData(..), HtmlEmail, toHtmlEmail, toSendGrid)

import Email.Html
import EmailAddress exposing (EmailAddress)
import Env
import List.Nonempty as Nonempty
import Route exposing (Route)
import SendGrid
import String.Nonempty exposing (NonemptyString(..))


type EmailData
    = LoginEmail
        { to : EmailAddress
        , route : Route ()
        , token : String
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
        LoginEmail { to, token } ->
            senderEmail
                |> Maybe.map
                    (\sender ->
                        { subject = NonemptyString 'L' "ogin to TurnBased"
                        , to = Nonempty.fromElement to
                        , content = loginEmailDetails token
                        , nameOfSender = Env.emailSenderName
                        , emailAddressOfSender = sender
                        }
                    )


loginEmailDetails : String -> Email.Html.Html
loginEmailDetails token =
    let
        _ =
            Debug.todo
    in
    Email.Html.div
        []
        [ Email.Html.text <| "Your token is " ++ token ]


senderEmail : Maybe EmailAddress
senderEmail =
    EmailAddress.fromString Env.emailSenderAddress
