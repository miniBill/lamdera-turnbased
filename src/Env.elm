module Env exposing (adminKey, emailSenderAddress, emailSenderName, isDev, pingTime, sendGridKey)


sendGridKey : String
sendGridKey =
    ""


isDev : Bool
isDev =
    True


adminKey : String
adminKey =
    "abc"


{-| Time between pings, in milliseconds.
-}
pingTime : number
pingTime =
    if isDev then
        10 * 1000

    else
        60 * 1000


emailSenderAddress : String
emailSenderAddress =
    "leonardo@taglialegne.it"


emailSenderName : String
emailSenderName =
    "Leonardo Taglialegne"
