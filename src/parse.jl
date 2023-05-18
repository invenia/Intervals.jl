const INTERVAL_REGEX = r"""
    ^
    (\[|\()                      # Left bound type (1)
    (?|                          # Left bound value (2)
        "((?:[^"]|(?<=\\)")*?)"|
        ((?:[^,.]|\.(?!\.))*?)
    )
    (?:,|\ ?\.\.)\ ?             # Delimiter
    (?|                          # Right bound value (3)
        "((?:[^"]|(?<=\\)")*?)"|
        ((?:[^,.]|\.(?!\.))*?)
    )
    (\]|\))                      # Right bound type (4)
    $
    """x

"""
    parse(::Type{Interval{T}}, str; element_parser=parse) -> Interval{T}

Parse a string of the form `<left-type><left-value><delim><right-value><right-type>`
(e.g. `[1 .. 2)`) as an `Interval{T}`. The format above is interpreted as:

- `left-type`: Must be either "[" or "(" which indicates if the left-endpoint of the
  interval is either `Closed` or `Open`.

- `left-value`: Specifies the value of the left-endpoint which will be parsed as the type
  `T`. If the value string has a length of zero then the left-endpoint will be specified as
  `Unbounded`. If the value string contains the delimiter (see below) then you may
  double-quote the value string to avoid any ambiguity.

- `delim`: Must be either ".." or "," which indicates the delimiter separating the
  left/right endpoint values.

- `right-value`: Specifies the value of the right-endpoint. See `left-value` for more
  details.

- `right-type`: Must be either "]" or ")" which indicates if the right-endpoint of the
   interval is either `Closed` or `Open`.

The `element_parser` keyword allows a custom parser to be used when parsing the left/right
values. The function is expected to take two arguments: `Type{T}` and `AbstractString`.
This is useful for supplying additional arguments/keywords, alternative parser functions, or
for types that do not define `parse` (e.g. `String`).
"""
function Base.parse(::Type{Interval{T}}, str::AbstractString; element_parser=parse) where T
    m = match(INTERVAL_REGEX, str)

    if m === nothing
        throw(ArgumentError("Unable to parse \"$str\" as an interval"))
    end

    if isempty(m[2])
        L = Unbounded
        left = nothing
    else
        L = m[1] == "[" ? Closed : Open
        left = element_parser(T, m[2])
    end

    if isempty(m[3])
        R = Unbounded
        right = nothing
    else
        R = m[4] == "]" ? Closed : Open
        right = element_parser(T, m[3])
    end

    return Interval{T}(left, right, (L, R))
end
