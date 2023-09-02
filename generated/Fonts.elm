module Fonts exposing
    ( arnoPro, garamond, gotham, luminari, ruritania
    , Font, arnoProFonts, garamondFonts, gothamFonts, luminariFonts, ruritaniaFonts
    )

{-|


## Attributes

@docs arnoPro, garamond, gotham, luminari, ruritania


## Fonts

@docs Font, arnoProFonts, garamondFonts, gothamFonts, luminariFonts, ruritaniaFonts

-}

import Element.WithContext
import Element.WithContext.Font


type alias Font =
    { url : String, name : String, style : String, weight : String }


arnoPro : Element.WithContext.Attribute context msg
arnoPro =
    Element.WithContext.Font.family
        [ Element.WithContext.Font.typeface "Arno Pro" ]


arnoProFonts : List Font
arnoProFonts =
    [ { url = "/fonts/ArnoPro-Italic.otf"
      , name = "Arno Pro"
      , style = "italic"
      , weight = "normal"
      }
    , { url = "/fonts/ArnoPro-SemiBold-Italic.otf"
      , name = "Arno Pro"
      , style = "italic"
      , weight = "semibold"
      }
    , { url = "/fonts/ArnoPro.otf"
      , name = "Arno Pro"
      , style = "normal"
      , weight = "normal"
      }
    ]


garamond : Element.WithContext.Attribute context msg
garamond =
    Element.WithContext.Font.family
        [ Element.WithContext.Font.typeface "Garamond" ]


garamondFonts : List Font
garamondFonts =
    [ { url = "/fonts/Garamond.ttf"
      , name = "Garamond"
      , style = "normal"
      , weight = "normal"
      }
    ]


gotham : Element.WithContext.Attribute context msg
gotham =
    Element.WithContext.Font.family
        [ Element.WithContext.Font.typeface "Gotham" ]


gothamFonts : List Font
gothamFonts =
    [ { url = "/fonts/Gotham-Black.otf"
      , name = "Gotham"
      , style = "normal"
      , weight = "black"
      }
    , { url = "/fonts/Gotham-Medium.ttf"
      , name = "Gotham"
      , style = "normal"
      , weight = "medium"
      }
    , { url = "/fonts/Gotham-Ultra.otf"
      , name = "Gotham"
      , style = "normal"
      , weight = "ultra"
      }
    ]


luminari : Element.WithContext.Attribute context msg
luminari =
    Element.WithContext.Font.family
        [ Element.WithContext.Font.typeface "Luminari" ]


luminariFonts : List Font
luminariFonts =
    [ { url = "/fonts/Luminari.ttf"
      , name = "Luminari"
      , style = "normal"
      , weight = "normal"
      }
    ]


ruritania : Element.WithContext.Attribute context msg
ruritania =
    Element.WithContext.Font.family
        [ Element.WithContext.Font.typeface "Ruritania" ]


ruritaniaFonts : List Font
ruritaniaFonts =
    [ { url = "/fonts/Ruritania.ttf"
      , name = "Ruritania"
      , style = "normal"
      , weight = "normal"
      }
    ]
