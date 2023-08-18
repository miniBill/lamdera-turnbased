module Types.GameIdDict exposing (GameIdDict, empty, filter, foldl, foldr, fromList, get, getMax, getMaxKey, getMin, getMinKey, insert, isEmpty, keys, map, member, partition, popMax, popMin, remove, singleton, size, toList, update, values)

{-| 
## Build

@docs empty, singleton, insert, update, remove

## Dictionaries

@docs GameIdDict

## Lists

@docs keys, values, toList, fromList

## Min / Max

@docs getMinKey, getMin, popMin, getMaxKey, getMax, popMax

## Query

@docs isEmpty, member, get, size

## Transform

@docs map, foldl, foldr, filter, partition
-}


import FastDict
import Types
import Types.GameId


type GameIdDict v
    = GameIdDict (FastDict.Dict String ( Types.GameId.GameId, v ))


empty : Types.GameIdDict v
empty =
    GameIdDict FastDict.empty


singleton : Types.GameId.GameId -> v -> Types.GameIdDict v
singleton key value =
    GameIdDict (FastDict.singleton (Types.GameId.toString key) ( key, value ))


insert : Types.GameId.GameId -> v -> Types.GameIdDict v -> Types.GameIdDict v
insert key value d =
    case d of
        GameIdDict dict ->
            GameIdDict
                (FastDict.insert (Types.GameId.toString key) ( key, value ) dict
                )


update :
    Types.GameId.GameId
    -> (Maybe b -> Maybe b)
    -> Types.GameIdDict b
    -> Types.GameIdDict b
update key f d =
    case d of
        GameIdDict dict ->
            GameIdDict
                (FastDict.update
                    (Types.GameId.toString key)
                    (\updateUnpack ->
                        Maybe.map
                            (Tuple.pair key)
                            (f (Maybe.map Tuple.second updateUnpack))
                    )
                    dict
                )


remove : Types.GameId.GameId -> Types.GameIdDict v -> Types.GameIdDict v
remove key d =
    case d of
        GameIdDict dict ->
            GameIdDict (FastDict.remove (Types.GameId.toString key) dict)


isEmpty : Types.GameIdDict v -> Bool
isEmpty d =
    case d of
        GameIdDict dict ->
            FastDict.isEmpty dict


member : Types.GameId.GameId -> Types.GameIdDict v -> Bool
member key d =
    case d of
        GameIdDict dict ->
            FastDict.member (Types.GameId.toString key) dict


get : Types.GameId.GameId -> Types.GameIdDict b -> Maybe b
get key d =
    case d of
        GameIdDict dict ->
            Maybe.map
                Tuple.second
                (FastDict.get (Types.GameId.toString key) dict)


size : Types.GameIdDict v -> Int
size d =
    case d of
        GameIdDict dict ->
            FastDict.size dict


keys : Types.GameIdDict v -> List Types.GameId.GameId
keys d =
    case d of
        GameIdDict dict ->
            List.map Tuple.first (FastDict.values dict)


values : Types.GameIdDict v -> List v
values d =
    case d of
        GameIdDict dict ->
            List.map Tuple.second (FastDict.values dict)


toList : Types.GameIdDict v -> List ( Types.GameId.GameId, v )
toList d =
    case d of
        GameIdDict dict ->
            FastDict.values dict


fromList : List ( Types.GameId.GameId, v ) -> Types.GameIdDict v
fromList l =
    GameIdDict
        (FastDict.fromList
            (List.map
                (\e ->
                    case e of
                        ( k, v ) ->
                            ( Types.GameId.toString k, e )
                )
                l
            )
        )


map :
    (Types.GameId.GameId -> a -> b) -> Types.GameIdDict a -> Types.GameIdDict b
map f d =
    case d of
        GameIdDict dict ->
            GameIdDict
                (FastDict.map
                    (\mapUnpack ->
                        \unpack ->
                            case unpack of
                                ( k, a ) ->
                                    ( k, f k a )
                    )
                    dict
                )


foldl : (Types.GameId.GameId -> v -> b -> b) -> b -> Types.GameIdDict v -> b
foldl f b0 d =
    case d of
        GameIdDict dict ->
            FastDict.foldl
                (\_ kv b ->
                    case kv of
                        ( k, v ) ->
                            f k v b
                )
                b0
                dict


foldr : (Types.GameId.GameId -> v -> b -> b) -> b -> Types.GameIdDict v -> b
foldr f b0 d =
    case d of
        GameIdDict dict ->
            FastDict.foldr
                (\_ kv b ->
                    case kv of
                        ( k, v ) ->
                            f k v b
                )
                b0
                dict


filter :
    (Types.GameId.GameId -> v -> Bool)
    -> Types.GameIdDict v
    -> Types.GameIdDict v
filter f d =
    GameIdDict
        (case d of
            GameIdDict dict ->
                FastDict.filter
                    (\filterUnpack ->
                        \unpack ->
                            case unpack of
                                ( k, v ) ->
                                    f k v
                    )
                    dict
        )


partition :
    (Types.GameId.GameId -> v -> Bool)
    -> Types.GameIdDict v
    -> ( Types.GameIdDict v, Types.GameIdDict v )
partition f d =
    case d of
        GameIdDict dict ->
            Tuple.mapBoth
                GameIdDict
                GameIdDict
                (FastDict.partition
                    (\partitionUnpack ->
                        \unpack ->
                            case unpack of
                                ( k, v ) ->
                                    f k v
                    )
                    dict
                )


getMinKey : Types.GameIdDict v -> Maybe String
getMinKey d =
    case d of
        GameIdDict dict ->
            FastDict.getMinKey dict


getMin : Types.GameIdDict v -> Maybe ( String, ( Types.GameId.GameId, v ) )
getMin d =
    case d of
        GameIdDict dict ->
            FastDict.getMin dict


popMin :
    Types.GameIdDict v
    -> Maybe ( ( String, ( Types.GameId.GameId, v ) ), FastDict.Dict String ( Types.GameId.GameId, v ) )
popMin d =
    case d of
        GameIdDict dict ->
            FastDict.popMin dict


getMaxKey : Types.GameIdDict v -> Maybe String
getMaxKey d =
    case d of
        GameIdDict dict ->
            FastDict.getMaxKey dict


getMax : Types.GameIdDict v -> Maybe ( String, ( Types.GameId.GameId, v ) )
getMax d =
    case d of
        GameIdDict dict ->
            FastDict.getMax dict


popMax :
    Types.GameIdDict v
    -> Maybe ( ( String, ( Types.GameId.GameId, v ) ), FastDict.Dict String ( Types.GameId.GameId, v ) )
popMax d =
    case d of
        GameIdDict dict ->
            FastDict.popMax dict