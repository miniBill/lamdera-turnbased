module Types.TokenDict exposing
    ( empty, singleton, insert, update, remove
    , TokenDict
    , keys, values, toList, fromList
    , isEmpty, member, get, size
    , map, foldl, foldr, filter, partition
    )

{-|


## Build

@docs empty, singleton, insert, update, remove


## Dictionaries

@docs TokenDict


## Lists

@docs keys, values, toList, fromList


## Query

@docs isEmpty, member, get, size


## Transform

@docs map, foldl, foldr, filter, partition

-}

import Dict
import Types.Token


type TokenDict v
    = TokenDict (Dict.Dict String ( Types.Token.Token, v ))


empty : TokenDict v
empty =
    TokenDict Dict.empty


singleton : Types.Token.Token -> v -> TokenDict v
singleton key value =
    TokenDict (Dict.singleton (Types.Token.toString key) ( key, value ))


insert : Types.Token.Token -> v -> TokenDict v -> TokenDict v
insert key value d =
    case d of
        TokenDict dict ->
            TokenDict
                (Dict.insert (Types.Token.toString key) ( key, value ) dict)


update : Types.Token.Token -> (Maybe b -> Maybe b) -> TokenDict b -> TokenDict b
update key f d =
    case d of
        TokenDict dict ->
            TokenDict
                (Dict.update
                    (Types.Token.toString key)
                    (\updateUnpack ->
                        Maybe.map
                            (Tuple.pair key)
                            (f (Maybe.map Tuple.second updateUnpack))
                    )
                    dict
                )


remove : Types.Token.Token -> TokenDict v -> TokenDict v
remove key d =
    case d of
        TokenDict dict ->
            TokenDict (Dict.remove (Types.Token.toString key) dict)


isEmpty : TokenDict v -> Bool
isEmpty d =
    case d of
        TokenDict dict ->
            Dict.isEmpty dict


member : Types.Token.Token -> TokenDict v -> Bool
member key d =
    case d of
        TokenDict dict ->
            Dict.member (Types.Token.toString key) dict


get : Types.Token.Token -> TokenDict b -> Maybe b
get key d =
    case d of
        TokenDict dict ->
            Maybe.map Tuple.second (Dict.get (Types.Token.toString key) dict)


size : TokenDict v -> Int
size d =
    case d of
        TokenDict dict ->
            Dict.size dict


keys : TokenDict v -> List Types.Token.Token
keys d =
    case d of
        TokenDict dict ->
            List.map Tuple.first (Dict.values dict)


values : TokenDict v -> List v
values d =
    case d of
        TokenDict dict ->
            List.map Tuple.second (Dict.values dict)


toList : TokenDict v -> List ( Types.Token.Token, v )
toList d =
    case d of
        TokenDict dict ->
            Dict.values dict


fromList : List ( Types.Token.Token, v ) -> TokenDict v
fromList l =
    TokenDict
        (Dict.fromList
            (List.map
                (\e ->
                    case e of
                        ( k, v ) ->
                            ( Types.Token.toString k, e )
                )
                l
            )
        )


map : (Types.Token.Token -> a -> b) -> TokenDict a -> TokenDict b
map f d =
    case d of
        TokenDict dict ->
            TokenDict
                (Dict.map
                    (\mapUnpack ->
                        \unpack ->
                            case unpack of
                                ( k, a ) ->
                                    ( k, f k a )
                    )
                    dict
                )


foldl : (Types.Token.Token -> v -> b -> b) -> b -> TokenDict v -> b
foldl f b0 d =
    case d of
        TokenDict dict ->
            Dict.foldl
                (\_ kv b ->
                    case kv of
                        ( k, v ) ->
                            f k v b
                )
                b0
                dict


foldr : (Types.Token.Token -> v -> b -> b) -> b -> TokenDict v -> b
foldr f b0 d =
    case d of
        TokenDict dict ->
            Dict.foldr
                (\_ kv b ->
                    case kv of
                        ( k, v ) ->
                            f k v b
                )
                b0
                dict


filter : (Types.Token.Token -> v -> Bool) -> TokenDict v -> TokenDict v
filter f d =
    TokenDict
        (case d of
            TokenDict dict ->
                Dict.filter
                    (\filterUnpack ->
                        \unpack ->
                            case unpack of
                                ( k, v ) ->
                                    f k v
                    )
                    dict
        )


partition :
    (Types.Token.Token -> v -> Bool)
    -> TokenDict v
    -> ( TokenDict v, TokenDict v )
partition f d =
    case d of
        TokenDict dict ->
            Tuple.mapBoth
                TokenDict
                TokenDict
                (Dict.partition
                    (\partitionUnpack ->
                        \unpack ->
                            case unpack of
                                ( k, v ) ->
                                    f k v
                    )
                    dict
                )
