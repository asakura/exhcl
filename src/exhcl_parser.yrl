Nonterminals
 root object props prop list elems elem keys key value data.

Terminals
 '{' '}' '=' '[' ']' ',' integer float atom bool text.

Rootsymbol root.
Right 100 '='.

root -> object          : '$1'.

root -> object root     : merge('$1', '$2').

root -> prop          : make_map('$1').
root -> prop root     : merge(make_map('$1'), make_map('$2')).

object -> '{' '}'       : #{}.
object -> '{' props '}' : make_map('$2').

props -> prop           : ['$1'].
props -> prop props     : ['$1'|'$2'].

props -> object           : ['$1'].
props -> object props     : ['$1'|'$2'].

prop -> keys object   : {hd('$1'), make_map({tl('$1'), '$2'})}.
prop -> key '=' value : {'$1', '$3'}.

list -> '[' ']'       : [].
list -> '[' elems ']' : '$2'.

elems -> elem       : ['$1'].
elems -> elem elems : ['$1'|'$2'].

elem -> value  : '$1'.
elem -> object : '$1'.

keys -> key      : ['$1'].
keys -> key keys : ['$1'] ++ '$2'.

key -> text : unwrapn('$1').
key -> data : '$1'.

value -> text : unwrapn('$1').
value -> list : '$1'.
value -> data : '$1'.

data -> integer : unwrapn('$1').
data ->   float : unwrapn('$1').
data ->    atom : unwrapn('$1').
data ->    bool : unwrapn('$1').

Erlang code.

unwrapn({_Token, _Line, Value}) -> Value.

make_map(Map) when is_map(Map) ->
    Map;
make_map({Keys, Data}) when is_list(Keys) ->
    lists:foldr(fun(Key, Acc) -> maps:from_list([{Key, Acc}]) end, Data, Keys);
make_map(List) when is_list(List) ->
    maps:from_list(List);
make_map(Tuple) when is_tuple(Tuple) ->
    maps:from_list([Tuple]).

merge(V1, V2) when not is_map(V1) and not is_map(V2) ->
    V2;
merge(V1, Map2) when not is_map(V1) and is_map(Map2) ->
    Map2;
merge(Map1, V2) when is_map(Map1) and not is_map(V2) ->
    V2;
merge(Map1, Map2) when is_map(Map1) and is_map(Map2) ->
    Fun = fun(K, V, Acc) ->
                  case maps:find(K, Acc) of
                      {ok, Value} ->
                          maps:put(K, merge(Value, V), Acc);
                      error ->
                          maps:put(K, V, Acc)
                  end
          end,
    maps:fold(Fun, Map1, Map2).
