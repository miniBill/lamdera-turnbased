module Types.Email exposing (Email(..), EmailDetails, toDetails, toSendGrid)

import Email.Html
import EmailAddress exposing (EmailAddress)
import Env
import List.Nonempty as Nonempty
import SendGrid
import String.Nonempty exposing (NonemptyString(..))


type Email
    = LoginEmail
        { to : EmailAddress
        , token : String
        }


toSendGrid : Email -> Maybe SendGrid.Email
toSendGrid email =
    toDetails email
        |> Maybe.map SendGrid.htmlEmail


type alias EmailDetails =
    { nameOfSender : String
    , emailAddressOfSender : EmailAddress
    , to : Nonempty.Nonempty EmailAddress
    , subject : NonemptyString
    , content : Email.Html.Html
    }


toDetails : Email -> Maybe EmailDetails
toDetails email =
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
