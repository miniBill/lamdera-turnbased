port module PkgPorts exposing
    ( load_from_localstorage
    , loaded_from_localstorage
    , ports
    , save_to_localstorage
    )


ports :
    { save_to_localstorage : String -> Cmd msg
    , load_from_localstorage : {} -> Cmd msg
    , loaded_from_localstorage : (String -> msg) -> Sub msg
    }
ports =
    { save_to_localstorage = save_to_localstorage
    , load_from_localstorage = load_from_localstorage
    , loaded_from_localstorage = loaded_from_localstorage
    }


port save_to_localstorage : String -> Cmd msg


port load_from_localstorage : {} -> Cmd msg


port loaded_from_localstorage : (String -> msg) -> Sub msg
