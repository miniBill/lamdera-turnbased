module Types.GameIdDict exposing (GameIdDict, empty, filter, foldl, foldr, fromList, get, insert, isEmpty, keys, map, member, partition, remove, singleton, size, toList, update, values)

{-| 
## Build

@docs empty, singleton, insert, update, remove

## Dictionaries

@docs GameIdDict

## Lists

@docs keys, values, toList, fromList

## Query

@docs isEmpty, member, get, size

## Transform

@docs map, foldl, foldr, filter, partition
-}


import Dict
import Types.GameId


type GameIdDict v
    = GameIdDict (Dict.Dict String ( Types.GameId.GameId, v ))


empty : GameIdDict v
empty =
    GameIdDict Dict.empty


singleton : Types.GameId.GameId -> v -> GameIdDict v
singleton key value =
    GameIdDict (Dict.singleton (Types.GameId.toString key) ( key, value ))


insert : Types.GameId.GameId -> v -> GameIdDict v -> GameIdDict v
insert key value d =
    case d of
        GameIdDict dict ->
            GameIdDict
                (Dict.insert (Types.GameId.toString key) ( key, value ) dict)


update :
    Types.GameId.GameId -> (Maybe b -> Maybe b) -> GameIdDict b -> GameIdDict b
update key f d =
    case d of
        GameIdDict dict ->
            GameIdDict
                (Dict.update
                    (Types.GameId.toString key)
                    (\updateUnpack ->
                        Maybe.map
                            (Tuple.pair key)
                            (f (Maybe.map Tuple.second updateUnpack))
                    )
                    dict
                )


remove : Types.GameId.GameId -> GameIdDict v -> GameIdDict v
remove key d =
    case d of
        GameIdDict dict ->
            GameIdDict (Dict.remove (Types.GameId.toString key) dict)


isEmpty : GameIdDict v -> Bool
isEmpty d =
    case d of
        GameIdDict dict ->
            Dict.isEmpty dict


member : Types.GameId.GameId -> GameIdDict v -> Bool
member key d =
    case d of
        GameIdDict dict ->
            Dict.member (Types.GameId.toString key) dict


get : Types.GameId.GameId -> GameIdDict b -> Maybe b
get key d =
    case d of
        GameIdDict dict ->
            Maybe.map Tuple.second (Dict.get (Types.GameId.toString key) dict)


size : GameIdDict v -> Int
size d =
    case d of
        GameIdDict dict ->
            Dict.size dict


keys : GameIdDict v -> List Types.GameId.GameId
keys d =
    case d of
        GameIdDict dict ->
            List.map Tuple.first (Dict.values dict)


values : GameIdDict v -> List v
values d =
    case d of
        GameIdDict dict ->
            List.map Tuple.second (Dict.values dict)


toList : GameIdDict v -> List ( Types.GameId.GameId, v )
toList d =
    case d of
        GameIdDict dict ->
            Dict.values dict


fromList : List ( Types.GameId.GameId, v ) -> GameIdDict v
fromList l =
    GameIdDict
        (Dict.fromList
            (List.map
                (\e ->
                    case e of
                        ( k, v ) ->
                            ( Types.GameId.toString k, e )
                )
                l
            )
        )


map : (Types.GameId.GameId -> a -> b) -> GameIdDict a -> GameIdDict b
map f d =
    case d of
        GameIdDict dict ->
            GameIdDict
                (Dict.map
                    (\mapUnpack ->
                        \unpack ->
                            case unpack of
                                ( k, a ) ->
                                    ( k, f k a )
                    )
                    dict
                )


foldl : (Types.GameId.GameId -> v -> b -> b) -> b -> GameIdDict v -> b
foldl f b0 d =
    case d of
        GameIdDict dict ->
            Dict.foldl
                (\_ kv b ->
                    case kv of
                        ( k, v ) ->
                            f k v b
                )
                b0
                dict


foldr : (Types.GameId.GameId -> v -> b -> b) -> b -> GameIdDict v -> b
foldr f b0 d =
    case d of
        GameIdDict dict ->
            Dict.foldr
                (\_ kv b ->
                    case kv of
                        ( k, v ) ->
                            f k v b
                )
                b0
                dict


filter : (Types.GameId.GameId -> v -> Bool) -> GameIdDict v -> GameIdDict v
filter f d =
    GameIdDict
        (case d of
            GameIdDict dict ->
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
    (Types.GameId.GameId -> v -> Bool)
    -> GameIdDict v
    -> ( GameIdDict v, GameIdDict v )
partition f d =
    case d of
        GameIdDict dict ->
            Tuple.mapBoth
                GameIdDict
                GameIdDict
                (Dict.partition
                    (\partitionUnpack ->
                        \unpack ->
                            case unpack of
                                ( k, v ) ->
                                    f k v
                    )
                    dict
                )