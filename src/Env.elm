module Env exposing (adminKey, domain, emailSenderAddress, emailSenderName, isDev, pingTime, sendGridKey)


sendGridKey : String
sendGridKey =
    ""


isDev : Bool
isDev =
    True


adminKey : String
adminKey =
    "abcd"


{-| Time between pings, in milliseconds.
-}
pingTime : number
pingTime =
    if isDev then
        100 * 1000

    else
        60 * 1000


emailSenderAddress : String
emailSenderAddress =
    "leonardo@taglialegne.it"


emailSenderName : String
emailSenderName =
    "Leonardo Taglialegne"


domain : String
domain =
    "http://localhost:8000"
