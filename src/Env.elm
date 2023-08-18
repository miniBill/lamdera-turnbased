module Env exposing (adminKey, isDev, pingTime)


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
