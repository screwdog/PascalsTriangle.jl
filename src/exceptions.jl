"""
    OutOfBoundsError(msg)

An attempt to calculate a part of Pascal's triangle that doesn't exist.
That is, an entry (n,k) for which 0 ≤ k ≤ n doen't hold, or a row or column
before the first.

# Examples
```jldoctest
julia> prev(Entry(0,0))
ERROR: OutOfBoundsError: no previous entry
[...]
```
"""
struct OutOfBoundsError <: Exception
    msg::String
end
Base.showerror(io::IO, e::OutOfBoundsError) = print(io, "OutOfBoundsError: ", e.msg)

"""
    NonAdjacentError()

An attempt to add or subtract entries within Pascal's triangle that are not appropriately
arranged. Entries that are adjacent on the same row can be added together, and entries
that are directly above each other can be subtracted. Attempting to apply `+` or `-` in
any other circumstance will result in this error.

# Examples
```jldoctest
julia> Entry(4,3) + Entry(5,1)
ERROR: NonAdjacentError: entries not appropriately arranged
[...]
```

```jldoctest
julia> Entry(5,1) - Entry(4,3)
ERROR: NonAdjacentError: entries not appropriately arranged
[...]
```
"""
struct NonAdjacentError <: Exception end
Base.showerror(io::IO, ::NonAdjacentError) = print(io, 
    "NonAdjacentError: entries not appropriately arranged")