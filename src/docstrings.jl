# Function declarations for documention

"""
    rownumber(e::Entry)
    rownumber(r::Row)

Returns the row of Pascal's triangle that the entry `e` lies within or that the row `r`
represents

# Examples
```jldoctest
julia> rownumber(Entry(6,3))
6

julia> rownumber(Row(6))
6
```
"""
function rownumber end

"""
    rowposition(e::Entry)

Returns the position of the entry `e` within the row of Pascal's triangle.

# Examples
```jldoctest
julia> rowposition(Entry(6,3))
3
```
"""
function rowposition end

"""
    value(e::Entry)
    value(r::Row) or values(r::Row)
    value(c::Column) or values(c::Column)
    value(c::Centre) or values(c::Centre)

Returns the value of the entry `e`, or the values of the row `r`, column `c`
or a sequence of central elements `c`.

# Examples
```jldoctest
julia> value(Entry(6,3))
20

julia> value(Row(4))
5-element Array{Integer,1}:
 1
 4
 6
 4
 1

julia> value(Column(4,3))
3-element Array{Integer,1}:
  1
  5
 15
```
"""
function value end

"""
    isfirst(e::Entry)
    isfirst(r::Row)
    isfirst(c::Column)

Returns whether the given entry, row or column is at the top-left of Pascal's triangle.
That is, if `e` is the top entry, `r` is the top row or `c` is the left-most column.
Note that rows and columns are numbered from zero.

# Examples
```jldoctest
julia> isfirst(Entry(0,0))
true

julia> isfirst(Row(0))
true

julia> isfirst(Column(0,0))
true
```
"""
function isfirst end

"""
    isatleft(e::Entry)
    isatleft(c::Column)

Returns true if the entry or column are at the left edge of Pascal's triangle. That is,
if entry `e` is in the left-most column, or `c` is column number zero. This corresponds
to entries (n,0).

# Examples
```jldoctest
julia> isatleft(Entry(4,0))
true

julia> isatleft(Column(0,3))
true
```
"""
function isatleft end

"""
    isatright(e::Entry)

Returns true if the entry is at the right edge of Pascal's triangle. That is, if entry
`e` corresponds to an entry (n,n).
"""
function isatright end

"""
    isadjacent(a::Entry, b::Entry) or areadjacent(a::Entry, b::Entry)

Returns true if the two entries are directly adjacent on the same row of Pascal's
triangle.

# Examples
```jldoctest
julia> isadjacent(Entry(6,3), Entry(6,4))
true

julia> areadjacent(Entry(6,2), Entry(6,6))
false
```
"""
function isadjacent end
const areadjacent = isadjacent

"""
    isinterior(a::Entry)

Returns true if the entry is in the interior of Pascal's triangle (that is, the
value isn't 1)
"""
function isinterior end

"""
    issubtractable(a::Entry, b::Entry) or aresubtractable(a::Entry, b::Entry)

Returns true if `a` and `b` are arranged so that they can be subtracted. This is
equivalent to `a` being in the row beneath `b` and either directly beneath or
one place to the right.

# Examples
```jldoctest
julia> issubtractable(Entry(6,3), Entry(5,3))
true

julia> aresubtractable(Entry(6,3), Entry(5,2))
true
```
"""
function issubtractable end
const aresubtractable = issubtractable

"""
    isvalid(e::Entry)
    isvalid(r::Row)
    isvalid(c::Column)
    isvalid(c::Centre)
    isvalid(l::LazyCentre)

Returns true if the data contained in `e`, `r`, `c` or `l` represents a
valid entry, row, column or central elements. This is useful for checking
if the internal state has been corrupted but can be slow and is not normally
necessary when using the methods of this package.

See [`Row`](@ref) for the internal structure of a `Row`.
"""
function isvalid end

"""
    toarray(r::Row)
    toarray(c::Column)
    toarray(c::Centre)
    toarray(l::LazyCentre)

Returns an array of `Entry`s equivalent to the given row, column or central
elements. For a `LazyCentre` this will only include the elements that have
actually been calculated (which may be more than those that have been
explicitly requested).

```jldoctest
julia> toarray(Row(2))
3-element Array{Entry{Int64,Int64},1}:
 Entry{Int64,Int64}(2, 0, 1)
 Entry{Int64,Int64}(2, 1, 2)
 Entry{Int64,Int64}(2, 2, 1)

julia> toarray(Column(2,3))
3-element Array{Entry{Int64,Int64},1}:
 Entry{Int64,Int64}(2, 2, 1)
 Entry{Int64,Int64}(3, 2, 3)
 Entry{Int64,Int64}(4, 2, 6)
```
"""
function toarray end

"""
    up(e::Entry)
    up(r::Row)
    up!(r::Row)

Returns the entry or row above the given one in Pascal's triangle. Throws
an [`OutOfBoundsError`](@ref) if there is no entry or row above.

# Examples
```jldoctest
julia> up(Entry(4,3))
Entry{Int64,Int64}(3, 3, 1)

julia> up(Row(2))
2-element Row{Integer} with indices PascalsTriangle.ZeroRange(1):
 1
 1

julia> up(Entry(4,4))
ERROR: OutOfBoundsError: no entry above
[...]
```
"""
function up end
function up! end

"""
    down(e::Entry)
    down(r::Row)
    down!(r::Row)

Returns the entry or row directly below the given one in Pascal's triangle.

# Examples
```jldoctest
julia> down(Entry(3,2))
Entry{Int64,Int64}(4, 2, 6)

julia> down(Row(2))
4-element Row{Integer} with indices PascalsTriangle.ZeroRange(3):
 1
 3
 3
 1
```
"""
function down end
function down! end

"""
    left(e::Entry)
    left(c::Column)
    left!(c::Column)

Returns the entry or column to the left of the given one in Pascal's triangle.
Throws an [`OutOfBoundsError`](@ref) if the entry or column is at the left edge
(ie column number 0, or an entry (n,0)).

# Examples
```jldoctest
julia> left(Entry(4,2))
Entry{Int64,Int64}(4, 1, 4)

julia> left(Column(2,3))
3-element Column{Integer}:
 1
 2
 3

julia> left!(Column(0,0))
ERROR: OutOfBoundsError: no previous column
[...]
```
"""
function left end
function left! end

"""
    right(e::Entry)
    right(c::Column)
    right!(c::Column)

Returns the entry or column to the right of the given one in Pascal's triangle.
Throws an [`OutOfBoundsError`](@ref) if the entry is at the right edge (ie an
entry (n,n))

# Examples
```jldoctest
julia> right(Entry(4,2))
Entry{Int64,Int64}(4, 3, 4)

julia> right(Column(4,0))
0-element Column{Integer}

julia> right(Entry(4,4))
ERROR: OutOfBoundsError: no entry to the right
[...]
```
"""
function right end
function right! end

"""
    prev(e::Entry)
    prev(r::Row)
    prev(c::Column)
    prev!(r::Row)
    prev!(c::Column)

Returns the previous entry, row or column. The previous row is the one
above the given `r` and the previous column is the one to the left of
the given `c`. The previous entry is to the left of the given `e` unless
its at the start of the row, in which case it will wrap to the right of
the previous row.

Throws an [`OutOfBoundsError`](@ref) if there is no previous entry, row
or column.

# Examples
```jldoctest
julia> prev(Entry(4,0))
Entry{Int64,Int64}(3, 3, 1)

julia> prev(Row(3))
3-element Row{Integer} with indices PascalsTriangle.ZeroRange(2):
 1
 2
 1

julia> prev(Column(0,0))
ERROR: OutOfBoundsError: no previous column
[...]
```
"""
function prev end
function prev! end

"""
    next(e::Entry)
    next(r::Row)
    next(c::Column)
    next!(r::Row)
    next!(c::Column)

Returns the next entry, row or column in Pascal's triangle. The next row
is the one beneath the given `r` and the next column is the one to the
right of the given `c`. The next entry is to the right unless `e` is at the
end of the row, in which case it will wrap to the beginning of the next
row.

# Examples
```jldoctest
julia> next(Entry(4,4))
Entry{Int64,Int64}(5, 0, 1)

julia> next(Row(3))
5-element Row{Integer} with indices PascalsTriangle.ZeroRange(4):
 1
 4
 9
 4
 1

julia> next(Column(4,0))
0-element Column{Integer}
```
"""
function next end
function next! end