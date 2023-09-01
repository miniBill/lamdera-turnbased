module Types.Token exposing (Token(..), toString)


type Token
    = Token String


toString : Token -> String
toString (Token token) =
    token
