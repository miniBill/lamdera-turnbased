module Types.UserIdDict exposing
    ( empty, singleton, insert, update, remove
    , UserIdDict
    , keys, values, toList, fromList
    , isEmpty, member, get, size
    , map, foldl, foldr, filter, partition
    )

{-|


## Build

@docs empty, singleton, insert, update, remove


## Dictionaries

@docs UserIdDict


## Lists

@docs keys, values, toList, fromList


## Query

@docs isEmpty, member, get, size


## Transform

@docs map, foldl, foldr, filter, partition

-}

import Dict
import Types.UserId


type UserIdDict v
    = UserIdDict (Dict.Dict String ( Types.UserId.UserId, v ))


empty : UserIdDict v
empty =
    UserIdDict Dict.empty


singleton : Types.UserId.UserId -> v -> UserIdDict v
singleton key value =
    UserIdDict (Dict.singleton (Types.UserId.toString key) ( key, value ))


insert : Types.UserId.UserId -> v -> UserIdDict v -> UserIdDict v
insert key value d =
    case d of
        UserIdDict dict ->
            UserIdDict
                (Dict.insert (Types.UserId.toString key) ( key, value ) dict)


update : Types.UserId.UserId -> (Maybe b -> Maybe b) -> UserIdDict b -> UserIdDict b
update key f d =
    case d of
        UserIdDict dict ->
            UserIdDict
                (Dict.update
                    (Types.UserId.toString key)
                    (\updateUnpack ->
                        Maybe.map
                            (Tuple.pair key)
                            (f (Maybe.map Tuple.second updateUnpack))
                    )
                    dict
                )


remove : Types.UserId.UserId -> UserIdDict v -> UserIdDict v
remove key d =
    case d of
        UserIdDict dict ->
            UserIdDict (Dict.remove (Types.UserId.toString key) dict)


isEmpty : UserIdDict v -> Bool
isEmpty d =
    case d of
        UserIdDict dict ->
            Dict.isEmpty dict


member : Types.UserId.UserId -> UserIdDict v -> Bool
member key d =
    case d of
        UserIdDict dict ->
            Dict.member (Types.UserId.toString key) dict


get : Types.UserId.UserId -> UserIdDict b -> Maybe b
get key d =
    case d of
        UserIdDict dict ->
            Maybe.map Tuple.second (Dict.get (Types.UserId.toString key) dict)


size : UserIdDict v -> Int
size d =
    case d of
        UserIdDict dict ->
            Dict.size dict


keys : UserIdDict v -> List Types.UserId.UserId
keys d =
    case d of
        UserIdDict dict ->
            List.map Tuple.first (Dict.values dict)


values : UserIdDict v -> List v
values d =
    case d of
        UserIdDict dict ->
            List.map Tuple.second (Dict.values dict)


toList : UserIdDict v -> List ( Types.UserId.UserId, v )
toList d =
    case d of
        UserIdDict dict ->
            Dict.values dict


fromList : List ( Types.UserId.UserId, v ) -> UserIdDict v
fromList l =
    UserIdDict
        (Dict.fromList
            (List.map
                (\e ->
                    case e of
                        ( k, v ) ->
                            ( Types.UserId.toString k, e )
                )
                l
            )
        )


map : (Types.UserId.UserId -> a -> b) -> UserIdDict a -> UserIdDict b
map f d =
    case d of
        UserIdDict dict ->
            UserIdDict
                (Dict.map
                    (\mapUnpack ->
                        \unpack ->
                            case unpack of
                                ( k, a ) ->
                                    ( k, f k a )
                    )
                    dict
                )


foldl : (Types.UserId.UserId -> v -> b -> b) -> b -> UserIdDict v -> b
foldl f b0 d =
    case d of
        UserIdDict dict ->
            Dict.foldl
                (\_ kv b ->
                    case kv of
                        ( k, v ) ->
                            f k v b
                )
                b0
                dict


foldr : (Types.UserId.UserId -> v -> b -> b) -> b -> UserIdDict v -> b
foldr f b0 d =
    case d of
        UserIdDict dict ->
            Dict.foldr
                (\_ kv b ->
                    case kv of
                        ( k, v ) ->
                            f k v b
                )
                b0
                dict


filter : (Types.UserId.UserId -> v -> Bool) -> UserIdDict v -> UserIdDict v
filter f d =
    UserIdDict
        (case d of
            UserIdDict dict ->
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
    (Types.UserId.UserId -> v -> Bool)
    -> UserIdDict v
    -> ( UserIdDict v, UserIdDict v )
partition f d =
    case d of
        UserIdDict dict ->
            Tuple.mapBoth
                UserIdDict
                UserIdDict
                (Dict.partition
                    (\partitionUnpack ->
                        \unpack ->
                            case unpack of
                                ( k, v ) ->
                                    f k v
                    )
                    dict
                )
