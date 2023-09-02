module Env exposing (adminKey, domain, emailSenderAddress, emailSenderName, pingTime, sendGridKey)


sendGridKey : String
sendGridKey =
    ""


adminKey : String
adminKey =
    "abcd"


{-| Time between pings, in milliseconds.
-}
pingTime : Int
pingTime =
    100 * 1000


emailSenderAddress : String
emailSenderAddress =
    "leonardo@taglialegne.it"


emailSenderName : String
emailSenderName =
    "Leonardo Taglialegne"


domain : String
domain =
    "http://localhost:8000"
