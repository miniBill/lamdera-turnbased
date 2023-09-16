module Types.UserIdSet exposing
    ( empty, singleton, insert, remove
    , toList, fromList
    , isEmpty, member, size
    , UserIdSet
    , foldl, foldr, filter, partition
    )

{-|


## Build

@docs empty, singleton, insert, remove


## Lists

@docs toList, fromList


## Query

@docs isEmpty, member, size


## Sets

@docs UserIdSet


## Transform

@docs foldl, foldr, filter, partition

-}

import Dict
import Types.UserId


type UserIdSet
    = UserIdSet (Dict.Dict String Types.UserId.UserId)


empty : UserIdSet
empty =
    UserIdSet Dict.empty


singleton : Types.UserId.UserId -> UserIdSet
singleton value =
    UserIdSet (Dict.singleton (Types.UserId.toString value) value)


insert : Types.UserId.UserId -> UserIdSet -> UserIdSet
insert value d =
    case d of
        UserIdSet dict ->
            UserIdSet (Dict.insert (Types.UserId.toString value) value dict)


remove : Types.UserId.UserId -> UserIdSet -> UserIdSet
remove value d =
    case d of
        UserIdSet dict ->
            UserIdSet (Dict.remove (Types.UserId.toString value) dict)


isEmpty : UserIdSet -> Bool
isEmpty d =
    case d of
        UserIdSet dict ->
            Dict.isEmpty dict


member : Types.UserId.UserId -> UserIdSet -> Bool
member value d =
    case d of
        UserIdSet dict ->
            Dict.member (Types.UserId.toString value) dict


size : UserIdSet -> Int
size d =
    case d of
        UserIdSet dict ->
            Dict.size dict


toList : UserIdSet -> List Types.UserId.UserId
toList d =
    case d of
        UserIdSet dict ->
            Dict.values dict


fromList : List Types.UserId.UserId -> UserIdSet
fromList l =
    UserIdSet
        (Dict.fromList (List.map (\e -> ( Types.UserId.toString e, e )) l))


foldl : (Types.UserId.UserId -> b -> b) -> b -> UserIdSet -> b
foldl f b0 d =
    case d of
        UserIdSet dict ->
            Dict.foldl (\_ e b -> f e b) b0 dict


foldr : (Types.UserId.UserId -> b -> b) -> b -> UserIdSet -> b
foldr f b0 d =
    case d of
        UserIdSet dict ->
            Dict.foldr (\_ e b -> f e b) b0 dict


filter : (Types.UserId.UserId -> Bool) -> UserIdSet -> UserIdSet
filter f d =
    UserIdSet
        (case d of
            UserIdSet dict ->
                Dict.filter (\filterUnpack -> f) dict
        )


partition : (Types.UserId.UserId -> Bool) -> UserIdSet -> ( UserIdSet, UserIdSet )
partition f d =
    case d of
        UserIdSet dict ->
            Tuple.mapBoth
                UserIdSet
                UserIdSet
                (Dict.partition (\partitionUnpack -> f) dict)
