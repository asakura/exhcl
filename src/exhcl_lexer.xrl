Definitions.

ATOM       = [a-zA-Z_]+[0-9a-zA-Z_]*
INTEGER    = (\+|-)?[0-9]+
FLOAT      = (\+|-)?[0-9]+\.[0-9]+((E|e)(\+|-)?[0-9]+)?
String       = "(\\\^.|\\.|[^\"])*"
BOOL       = (true|false)
WHITESPACE = [\s\t\r]
NEWLINE    = [\n]
LINECOMM   = (#|\/\/).*
BLOCKCOMM  = \/\*(.*\n?)+\*\/

Rules.
%/\/\*([^*]*\*+[^/*])*[^*]*\*+\//
{INTEGER}     : {token, {integer, TokenLine, list_to_integer(TokenChars)}}.
{FLOAT}       : {token, {float,   TokenLine, list_to_float(TokenChars)}}.
{BOOL}        : {token, {bool,    TokenLine, to_atom(TokenChars)}}.
{ATOM}        : {token, {atom,    TokenLine, to_atom(TokenChars)}}.
{String}      : {token, {text,    TokenLine, to_unicode(TokenChars)}}.
{LINECOMM}    : skip_token.
{BLOCKCOMM}   : skip_token.
{NEWLINE}+    : skip_token.
\[            : {token, {'[',     TokenLine}}.
\]            : {token, {']',     TokenLine}}.
\{            : {token, {'{',     TokenLine}}.
\}            : {token, {'}',     TokenLine}}.
,             : skip_token.  % {token, {',',     TokenLine}}.
=             : {token, {'=',     TokenLine}}.
{WHITESPACE}+ : skip_token.

Erlang code.

to_atom(Chars) ->
    list_to_atom(Chars).

to_unicode(Chars) ->
    Str = string:sub_string(Chars, 2, length(Chars) - 1),
    'Elixir.String.Chars':to_string(Str).
