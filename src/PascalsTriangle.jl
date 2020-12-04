module PascalsTriangle

# Exceptions
export OutOfBoundsError, NonAdjacentError

# Types
export Entry, Row, Column

# Accessors
export rownumber, rowposition, colnumber, value

# Checks
export isfirst, isatleft, isatright, isadjacent, areadjacent
export isinterior, issubtractable, aresubtractable, isvalid

# Conversion
export toarray

# Modifiers
export up, down, left, right, prev, next
export up!, down!, left!, right!, prev!, next!

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

Returns the value of the entry `e`, or the values of the row `r` or column `c`.

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

# Examples
```jldoctest
julia> isatright(Entry(4,3))
false

julia> isatright(Entry(4,4))
true
```
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

Returns true if the entry is in the interior of Pascal's triangle (that is, it
isn't a 1)

# Examples
```jldoctest
julia> isinterior(Entry(4,2))
true

julia> isinterior(Entry(4,4))
false
```
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

Returns true if the data contained in `e`, `r` or `c` represents a
valid entry, row or column. This is useful for checking if the internal
state has been corrupted but can be slow and is not normally necessary
when using the methods of this package.

See [`Row`](@ref) for the internal structure of a `Row`.

# Examples
```jldoctest
julia> PascalsTriangle.isvalid(Entry(6,4,10))
false

julia> PascalsTriangle.isvalid(Column(3,[1,3,7]))
false

julia> PascalsTriangle.isvalid(Row(2,[1,6]))
true
```
"""
function isvalid end

"""
    toarray(r::Row)
    toarray(c::Column)

Returns an array of `Entry`s equivalent to the given row or column.

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

"""
    Entry(n, k, val)
    Entry(n, k)
    Entry(n => k)
    Entry(V::Type, n, k)
    Entry(e::Entry)

Represents a single entry in Pascal's triangle. The supplied `val` is not checked for
correctness but arguments that only specify `n` and `k` must satisfy 0 ≤ k ≤ n and must
both be integer types. The argument `V` specifies a type for the value field.

# Examples
```jldoctest
julia> Entry(6,2)
Entry{Int64,Int64}(6, 2, 15)

julia> Entry(Float64, 6, 2)
Entry{Int64,Float64}(6, 2, 15.0)

julia> Entry(6,2,10) # incorrect value not checked
Entry{Int64,Int64}(6, 2, 10)
```
"""
struct Entry{I <: Integer, V <: Real}
    n::I
    k::I
    val::V
    function Entry(n,k,val)
        0 ≤ k ≤ n || throw(ArgumentError("Entry requires 0 ≤ k ≤ n but n:$n, k:$k"))
        return new{typeof(n), typeof(val)}(n,k,val)
    end
end
Entry(e::Entry) = Entry(e.n, e.k, e.val)
Entry(n,k) = Entry(n,k,binomial(n,convert(typeof(n),k)))
Entry(p::Pair) = Entry(first(p),last(p))
Entry(V::Type,n,k) = Entry(n,k,V(binomial(n,k)))

rownumber(e::Entry) = e.n
rowposition(e::Entry) = e.k
value(e::Entry) = e.val

Base.show(io::IO, ::MIME"text/plain", e::Entry) = print(io, "$(typeof(e).name)($(e.n), $(e.k), $(e.val))")
Base.show(io::IO, e::Entry) = print(io, "($(e.n), $(e.k), $(e.val))")

"""
    ==(a::Entry, b::Entry)

Two entries are equal if they represent the same entry in Pascal's triangle. That is,
they are from the same row, row position and have the same value, although the types 
need not match. 
"""
Base.:(==)(a::Entry, b::Entry) = a.n == b.n && a.k == b.k && a.val == b.val

"""
    isless(a::Entry, b::Entry)

Entries are ordered only by their value, ignoring their rows and row positions.
"""
Base.isless(a::Entry, b::Entry) = a.val < b.val

"""
    ≈(a::Entry, b::Entry)

Entries are approximately equal if they represent the same location within Pascal's
triangle and their values are approximately equal.
"""
Base.isapprox(a::Entry, b::Entry) = a.n == b.n && a.k == b.k && isapprox(a.val, b.val)

"""
    +(a::Entry, b::Entry)

Adding adjacent entries gives the entry directly beneath the two.
"""
function Base.:+(a::Entry, b::Entry)
    isadjacent(a,b) || throw(NonAdjacentError())
    return Entry(a.n+1, max(a.k, b.k), a.val + b.val)
end

"""
    -(a::Entry, b::Entry)

Subtracting two entries that are directly above each other gives the entry directly
adjacent to the upper one, utilising the well-known relation on Pascal's triangle.
"""
function Base.:-(a::Entry, b::Entry)
    issubtractable(a,b) || throw(NonAdjacentError())
    return Entry(b.n, 2a.k - b.k - 1, a.val - b.val)
end

isfirst(a::Entry) = a.n == 0 && a.k == 0
isatleft(a::Entry) = a.k ≤ 0
isatright(a::Entry) = a.k ≥ a.n
isadjacent(a::Entry, b::Entry) = a.n == b.n && abs(a.k - b.k) == 1
isinterior(a::Entry) = a.n ≥ 2 && a.k ≥ 1 && a.k < a.n
issubtractable(a::Entry, b::Entry) = a.n == b.n + 1 && isinterior(a) && 0 ≤ a.k - b.k ≤ 1
isvalid(a::Entry) = 0 ≤ a.n && 0 ≤ a.k ≤ a.n && binomial(a.n, a.k) == a.val

"""
    ZeroRange(max::Integer)

Represents the integer range 0:max.
"""
struct ZeroRange <: AbstractUnitRange{Integer}
    max::Integer
    function ZeroRange(max)
        max ≥ 0 || throw(ArgumentError("end of range must be nonnegative"))
        new(max)
    end
end
Base.length(z::ZeroRange) = z.max + 1
Base.first(z::ZeroRange) = 0
Base.last(z::ZeroRange) = z.max
Base.iterate(z::ZeroRange, i = 0) = i > z.max ? nothing : (i, i+1)
function Base.getindex(z::ZeroRange, i::Integer)
    1 ≤ i ≤ z.max+1 || throw(BoundsError("index out of bounds"))
    return i-1
end
function Base.convert(::Type{AbstractUnitRange{T}}, z::ZeroRange) where {T}
    return 0:z.max
end
Base.show(io::IO, z::ZeroRange) = print(io, typeof(z).name, "(", z.max, ")")

"""
    numelements(rownum)

A utility function to return the number of elements that need to be
stored in order to represent row `rownum`. This is two less than half
the entries in the row so as to reduce redundancy.
"""
numelements(rownum) = rownum ≤ 3 ? 0 : (rownum-2)÷2

"""
    Row(rownum, data)
    Row(rownum)
    Row(V::Type, rownum, datasize)
    Row(r::Row)

Represents a single row of Pascal's triangle. Supplied `data` is not checked
for correctness, and since `Row`s are mutable storage can be pre-allocated to
ensure enough storage for up to row `datasize`. Constructing with just the
`rownum` will efficiently calculate the row entries. In all cases, `rownum`
must be nonnegative.

Note: Row uses an internal data structure that reduces redundant data storage.
Directly supplying a `data` argument is not recommended.

# Examples
```jldoctest
julia> Row(2)
3-element Row{Integer} with indices PascalsTriangle.ZeroRange(2):
 1
 2
 1

julia> Row(Float64, 2, 10)
3-element Row{Float64} with indices PascalsTriangle.ZeroRange(2):
 1.0
 2.0
 1.0
```
"""
mutable struct Row{V} <: AbstractVector{V}
    rownum::Integer
    data::Vector{V}
    function Row(rownum,data)
        rownum ≥ 0 || throw(DomainError(rownum,"rownum must be nonnegative"))
        return new{eltype(data)}(rownum,data)
    end
end
Row(r::Row) = Row(r.rownum, copy(r.data))
Row(rownum) = Row(Integer, rownum, rownum)
Row(V::Type, rownum) = Row(V, rownum, rownum)
function Row(V::Type, rownum, datasize)
    rownum ≥ 0 || throw(DomainError(rownum,"rownum must be nonnegative"))
    datasize ≥ rownum || throw(ArgumentError("datasize specified is not enough to store the row"))
    arr = Vector{V}(undef, numelements(datasize))
    datalength = numelements(rownum)
    if datalength ≥ 1
        entry = Entry(rownum,1,rownum*one(V))
        for i ∈ 1:datalength
            entry = right(entry)
            arr[i] = entry.val
        end
    end
    return Row(rownum, arr)    
end

rownumber(r::Row) = r.rownum
function value(r::Row)
    arr = ones(eltype(r.data), r.rownum+1)
    for i ∈ 1:(r.rownum-1)
        arr[i+1] = r[i]
    end
    return arr
end
Base.values(r::Row) = value(r)

const THRESHOLD = 10
const HALF = 4
function tostring(r::Row)
    v = values(r)
    s = "<"
    if r.rownum < THRESHOLD
        s *= join(v, ", ") 
    else
        s *= join(v[1:HALF], ", ")
        s *= ", ..., "
        s *= join(v[end-HALF+1:end], ", ")
    end
    s *= ">"
    return s
end
function Base.show(io::IO, ::MIME"text/plain", r::Row)
    print(io, "$(typeof(r).name)")
    print(io, tostring(r))
end
function Base.show(io::IO, r::Row)
    print(io, tostring(r))
end

function Base.sum(f, r::Row)
    if r.rownum == 0
        return f(1)
    elseif r.rownum == 1
        return 2f(1)
    elseif r.rownum == 2
        return 2f(1) + f(2)
    end
    unit = one(eltype(r.data))
    s = 2f(unit) + 2f(unit*r.rownum)
    datalength = numelements(r.rownum)
    if datalength > 0
        for i ∈ 1:(datalength-1)
            s += 2f(r.data[i])
        end
        if iseven(r.rownum)
            s += f(r.data[datalength])
        else
            s += 2f(r.data[datalength])
        end
    end
    return s
end
Base.sum(r::Row) = 2^r.rownum
Base.axes(r::Row) = (ZeroRange(r.rownum),)
Base.axes1(r::Row) = ZeroRange(r.rownum)
Base.LinearIndices(r::Row) = ZeroRange(r.rownum)
Base.size(r::Row) = (r.rownum + 1,)
Base.IndexStyle(::Type{<:Row}) = IndexLinear()
function Base.getindex(r::Row, i::Int)
    0 ≤ i ≤ r.rownum || throw(BoundsError(r, i))
    index = i > r.rownum÷2 ? r.rownum - i : i
    if index == 0
        return one(eltype(r.data))
    end
    if index == 1
        return one(eltype(r.data))*r.rownum
    end
    return r.data[index-1]
end
Base.getindex(r::Row, ::Colon) = value(r)
Base.getindex(r::Row, I) = [r[i] for i ∈ I]
Base.firstindex(r::Row) = 0
Base.lastindex(r::Row) = r.rownum

Base.:(==)(a::Row, b::Row) = a.rownum == b.rownum &&
    a.data[1:numelements(a.rownum)] == b.data[1:numelements(b.rownum)]

isfirst(r::Row) = r.rownum == 0
isvalid(r::Row) = r.rownum ≥ 0 &&
    length(r.data) ≥ numelements(r.rownum) && 
    r.data[1:numelements(r.rownum)] == Row(r.rownum).data
toarray(r::Row) = Entry.(r.rownum,0:r.rownum,value(r))

"""
    Column(colnum, data)
    Column(colnum, datasize)
    Column(V::Type, colnum, datasize)
    Column(c::Column)

Represents a column of Pascal's triangle. That is, the top-most
`datasize` elements of `binomial(n,colnum)` where `n ≥ colnum`,
but this is calculated more efficiently. As with all types in this
package, columns are numbered from 0.

# Examples
```jldoctest
julia> Column(2, 3)
3-element Column{Integer}:
 1
 3
 6

julia> Column(Float64, 2, 3)
3-element Column{Float64}:
 1.0
 3.0
 6.0
```
"""
mutable struct Column{V} <: AbstractVector{V}
    colnum::Integer
    data::Array{V,1}
    function Column(colnum::Integer, data::Array)
        colnum ≥ 0 || throw(DomainError("colnum must be nonnegative"))
        return new{eltype(data)}(colnum, data)
    end
end 
Column(c::Column) = Column(c.colnum, deepcopy(c.data))
function Column(V::Type, colnum, datasize)
    datasize ≥ 0 || throw(DomainError("datasize must be nonnegative"))
    arr = ones(V,datasize)
    entry = Entry(colnum,colnum,one(V))
    for i ∈ 2:datasize
        entry = down(entry)
        arr[i] = entry.val
    end
    return Column(colnum, arr)
end
Column(colnum, datasize) = Column(Integer, colnum, datasize)

colnumber(c::Column) = c.colnum
value(c::Column) = c.data
Base.values(c::Column) = value(c)

Base.size(c::Column) = (length(c.data),)
Base.IndexStyle(::Type{<:Column}) = IndexLinear()
Base.getindex(c::Column, i::Int) = c.data[i]
Base.firstindex(c::Column) = 1
Base.lastindex(c::Column) = length(c.data)

isfirst(c::Column) = c.colnum == 0
isatleft(c::Column) = isfirst(c)
isvalid(c::Column) = c.colnum ≥ 0 && c.data == Column(c.colnum, length(c.data)).data
toarray(c::Column) = Entry.(c.colnum:(c.colnum+length(c.data)-1), c.colnum, c.data)

_up(a::Entry{I, <: Integer}) where {I} = Entry(a.n-1, a.k, a.val*(a.n - a.k)÷a.n)
_up(a::Entry{I, <: AbstractFloat}) where {I} = Entry(a.n-1, a.k, a.val*(a.n - a.k)/a.n)
function up(a::Entry)
    if isatright(a) || isfirst(a)
        throw(OutOfBoundsError("no entry above"))
    end
    return _up(a)
end

up!(r::Row) = prev!(r)
up(r::Row) = prev(r)

down(a::Entry{I, <: Integer}) where {I} = Entry(a.n+1, a.k, a.val*(a.n + 1)÷(a.n - a.k + 1))
down(a::Entry{I, <: AbstractFloat}) where {I} = Entry(a.n+1, a.k, a.val*(a.n + 1)/(a.n - a.k + 1))

down!(r::Row) = next!(r)
down(r::Row) = next(r)

_left(a::Entry{I, <: Integer}) where {I} = Entry(a.n, a.k-1, a.val*a.k÷(a.n - a.k + 1))
_left(a::Entry{I, <: AbstractFloat}) where {I} = Entry(a.n, a.k-1, a.val*a.k/(a.n - a.k + 1))
function left(a::Entry)
    isatleft(a) && throw(OutOfBoundsError("no entry to the left"))
    return _left(a)
end

left!(c::Column) = prev!(c)
left(c::Column) = prev(c)

_right(a::Entry{I, <: Integer}) where {I} = Entry(a.n, a.k+1, a.val*(a.n - a.k)÷(a.k + 1))
_right(a::Entry{I, <: AbstractFloat}) where {I} = Entry(a.n, a.k+1, a.val*(a.n - a.k)/(a.k + 1))
function right(a::Entry)
    isatright(a) && throw(OutOfBoundsError("no entry to the right"))
    return _right(a)
end

right!(c::Column) = next!(c)
right(c::Column) = next(c)

function prev(a::Entry)
    isfirst(a) && throw(OutOfBoundsError("no previous entry"))
    if !isatleft(a)
        # Need to do division last in case a.val is an integer
        return _left(a)
    else
        return Entry(a.n-1, a.n-1, one(a.val))
    end
end

function prev!(r::Row)
    isfirst(r) && throw(OutOfBoundsError("no previous row"))
    r.rownum -= 1
    datalength = numelements(r.rownum)
    if datalength ≥ 1
        r.data[1] -= r.rownum
        for i ∈ 2:datalength
            r.data[i] -= r.data[i-1]
        end
    end
    return r
end

function prev(r::Row)
    newrow = Row(r)
    return prev!(newrow)
end

function prev!(c::Column)
    isfirst(c) && throw(OutOfBoundsError("no previous column"))
    c.colnum -= 1
    for i ∈ length(c.data):-1:2
        c.data[i] -= c.data[i-1]
    end
    return c
end

function prev(c::Column)
    newcol = Column(c)
    return prev!(newcol)
end

function next(a::Entry)
    if !isatright(a)
        # Need to do division last in case a.val is an integer
        return _right(a)
    else
        return Entry(a.n+1, zero(a.k), one(a.val))
    end
end

function next!(r::Row)
    datalength = numelements(r.rownum)
    if isodd(r.rownum) && r.rownum ≥ 3
        if r.rownum == 3
            newdata = one(eltype(r.data))*6
        else
            newdata = r.data[datalength]
        end
        if length(r.data) > datalength
            r.data[datalength+1] = newdata
        else
            push!(r.data, newdata)
        end
        datalength += 1
    end
    if datalength ≥ 1
        for i ∈ datalength:-1:2
            r.data[i] += r.data[i-1]
        end
        r.data[1] += r.rownum
    end
    r.rownum += 1
    return r
end

function next(r::Row)
    newrow = Row(r)
    return next!(newrow)
end

function next!(c::Column)
    c.colnum += 1
    for i ∈ 2:length(c.data)
        c.data[i] += c.data[i-1]
    end
    return c
end

function next(c::Column)
    newcol = Column(c)
    return next!(newcol)
end
end # of module