# PascalsTriangle
A package for efficient calculations associated with Pascal's
triangle. The key types introduced are `Entry`, `Row`, and `Column`
representing individual entries, rows, and columns of Pascal's
triangle.

## Data format
This package follows the convention of considering the entries
of Pascal's triangle as arranged in a zero-indexed lower-triangular
matrix. That is, the top of the triangle is indexed as (0,0) and
the two entries on the row below that are (1,0) and (1,1). This
means that the first row is row 0, and the value in position
(n,k) is binomial(n,k).

A column is defined as being a continuous sequence of the entries
at (n,k) where n varies from k upwards. This is a column in the
matrix form, or a left diagonal in the more traditional arrangement
of entries.

## Types
For individual entries use the `Entry` type. These can hold either
integer or float values.
```julia
julia> using PascalsTriangle

julia> Entry{Int}(6,4)
Entry(6, 4, 15)

julia> Entry{Float64}(6,4)
Entry(6, 4, 15.0)
```

For a row of values it is more efficient to use a `Row` rather than
an array of entries. Rows can also have different data types.
```julia
julia> using PascalsTriangle

julia> Row{Int}(4)
Row<1, 4, 6, 4, 1>

julia> Row{Float64}(4)
Row<1.0, 4.0, 6.0, 4.0, 1.0>
```

If you plan to iterate over a series of rows you can pre-allocate
the storage by specifying a maximum row value to allocate for. In
the example below the row is pre-allocated with enough storage for
up to row 10.
```julia
julia> using PascalsTriangle

julia> @time begin
           r = Row(4, 10)
           for i ∈ 5:10
               next!(r)
           end
       end
  0.000004 seconds (2 allocations: 144 bytes)
```

A vertical array of values is efficiently generated and stored
in a `Column` type. With `Column` you need to specify the number
of entries to be generated.
```julia
julia> using PascalsTriangle

julia> c = Column{Float64}(10, 4)
4-element Column{Float64}:
   1.0
  11.0
  66.0
 286.0
```
The `Column` above are the entries (10,10), (11,10), (12,10) and
(13,10) but generated efficiently.

In is often useful to work with an array of entries, which can be
obtained from a `Row` or `Column` using the `toarray` function.
```julia
julia> toarray(Row(3))
4-element Array{Entry{Int64},1}:
 Entry(3, 0, 1)
 Entry(3, 1, 3)
 Entry(3, 2, 3)
 Entry(3, 3, 1)

julia> toarray(Column(3,3))
3-element Array{Entry{Int64},1}:
 Entry(3, 3, 1)
 Entry(4, 3, 4)
 Entry(5, 3, 10)
```