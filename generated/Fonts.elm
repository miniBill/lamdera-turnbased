module Fonts exposing
    ( arnoPro, garamond, gotham, luminari, ruritania
    , arnoProPath, garamondPath, gothamPath, luminariPath, ruritaniaPath
    )

{-|


## Attributes

@docs arnoPro, garamond, gotham, luminari, ruritania


## Paths

@docs arnoProPath, garamondPath, gothamPath, luminariPath, ruritaniaPath

-}

import Element.WithContext
import Element.WithContext.Font


arnoPro : Element.WithContext.Attribute context msg
arnoPro =
    Element.WithContext.Font.family
        [ Element.WithContext.Font.typeface "Arno Pro" ]


arnoProPath : String
arnoProPath =
    "/fonts/ArnoPro-Italic.otf"


garamond : Element.WithContext.Attribute context msg
garamond =
    Element.WithContext.Font.family
        [ Element.WithContext.Font.typeface "Garamond" ]


garamondPath : String
garamondPath =
    "/fonts/Garamond.ttf"


gotham : Element.WithContext.Attribute context msg
gotham =
    Element.WithContext.Font.family
        [ Element.WithContext.Font.typeface "Gotham" ]


gothamPath : String
gothamPath =
    "/fonts/Gotham-Ultra.otf"


luminari : Element.WithContext.Attribute context msg
luminari =
    Element.WithContext.Font.family
        [ Element.WithContext.Font.typeface "Luminari" ]


luminariPath : String
luminariPath =
    "/fonts/Luminari.ttf"


ruritania : Element.WithContext.Attribute context msg
ruritania =
    Element.WithContext.Font.family
        [ Element.WithContext.Font.typeface "Ruritania" ]


ruritaniaPath : String
ruritaniaPath =
    "/fonts/Ruritania.ttf"
