const INTERVAL_REGEX = r"""
    ^
    (\[|\()                      # Lower bound type (1)
    (?|                          # Lower bound value (2)
        "((?:[^"]|(?<=\\)")*?)"|
        ((?:[^,.]|\.(?!\.))*?)
    )
    (?:,|\ ?\.\.)\ ?             # Delimiter
    (?|                          # Upper bound value (3)
        "((?:[^"]|(?<=\\)")*?)"|
        ((?:[^,.]|\.(?!\.))*?)
    )
    (\]|\))                      # Upper bound type (4)
    $
    """x

"""
    parse(::Type{Interval{T}}, str; element_parser=parse) -> Interval{T}

Parse a string of the form `<lower-type><lower-value><delim><upper-value><upper-type>`
(e.g. `[1 .. 2)`) as an `Interval{T}`. The format above is interpreted as:

- `lower-type`: Must be either "[" or "(" which indicates if the lower-endpoint of the
  interval is either `Closed` or `Open`.

- `lower-value`: Specifies the value of the lower-endpoint which will be parsed as the type
  `T`. If the value string has a length of zero then the lower-endpoint will be specified as
  `Unbounded`. If the value string contains the delimiter (see below) then you may
  double-quote the value string to avoid any ambiguity.

- `delim`: Must be either ".." or "," which indicates the delimiter separating the
  lower/upper endpoint values.

- `upper-value`: Specifies the value of the upper-endpoint. See `lower-value` for more
  details.

- `upper-type`: Must be either "]" or ")" which indicates if the upper-endpoint of the
   interval is either `Closed` or `Open`.

The `element_parser` keyword allows a custom parser to be used when parsing the lower/upper
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
        lower = nothing
    else
        L = m[1] == "[" ? Closed : Open
        lower = element_parser(T, m[2])
    end

    if isempty(m[3])
        U = Unbounded
        upper = nothing
    else
        U = m[4] == "]" ? Closed : Open
        upper = element_parser(T, m[3])
    end

    return Interval{T,L,U}(lower, upper)
end
