# Note: To support testing against the latest Julia nightly we'll assume the serialization
# format is the same as the last version of Julia we've tested against.
const SERIALIZED_HEADER = if VERSION >= v"1.5"
    "7JL\n\x04\0\0"
elseif VERSION >= v"1.4"
    "7JL\t\x04\0\0"
elseif VERSION >= v"1.2"
    "7JL\b\x04\0\0"
elseif VERSION >= v"1.0"
    "7JL\a\x04\0\0"
else
    error("Julia versions earlier than 1.0 are unsupported")
end
