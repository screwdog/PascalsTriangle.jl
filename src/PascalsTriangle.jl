module PascalsTriangle

# Exceptions
export OutOfBoundsError, NonAdjacentError

# Types
export Entry, Row, Column

# Accessors
export rownumber, rowposition, colnumber, value

# Checks
export isfirst, isatleft, isatright, isadjacent, isinterior
export issubtractable, isvalid

# Conversion
export toarray

# Modifiers
export up, down, left, right, prev, next
export up!, down!, left!, right!, prev!, next!

struct OutOfBoundsError <: Exception
    msg::String
end
struct NonAdjacentError <: Exception end

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

Base.:(==)(a::Entry, b::Entry) = a.n == b.n && a.k == b.k && a.val == b.val
Base.:<(a::Entry, b::Entry) = a.val < b.val
Base.isapprox(a::Entry, b::Entry) = a.n == b.n && a.k == b.k && isapprox(a.val, b.val)

function Base.:+(a::Entry, b::Entry)
    isadjacent(a,b) || throw(NonAdjacentError())
    return Entry(a.n+1, max(a.k, b.k), a.val + b.val)
end

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

numelements(rownum) = rownum ≤ 3 ? 0 : (rownum-2)÷2

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

Base.show(io::IO, r::Row) = show(io, value(r))
function Base.sum(f, r::Row)
    if r.rownum == 0
        return f(1)
    elseif r.rownum == 1
        return 2f(1)
    end
    s = 2*one(eltype(r.data))
    datalength = numelements(r.rownum)
    if datalength > 0
        if iseven(r.rownum)
            s += f(r.data[datalength])
        else
            s += 2f(r.data[datalength])
        end
        for i ∈ (datalength-1):-1:1
            s += 2f(r.data[i])
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

Base.size(c::Column) = (length(c.data),)
Base.IndexStyle(::Type{<:Column}) = IndexLinear()
Base.getindex(c::Column, i::Int) = c.data[i]
Base.firstindex(c::Column) = 1
Base.lastindex(c::Column) = length(c.data)

isfirst(c::Column) = c.colnum == 0
isvalid(c::Column) = c.colnum ≥ 0 && c.data == Column(c.colnum, length(c.data)).data
toarray(c::Column) = Entry.(c.colnum:(c.colnum+length(c.data)-1), c.colnum, c.data)

function up(a::Entry)
    if isatright(a) || isfirst(a)
        throw(OutOfBoundsError("no entry above"))
    end
    # Need to do division last in case a.val is an integer
    return Entry(a.n-1, a.k, a.val*(a.n - a.k)÷a.n)
end

up!(r::Row) = prev!(r)
up(r::Row) = prev(r)

function down(a::Entry)
    # Need to do division last in case a.val is an integer
    Entry(a.n+1, a.k, a.val*(a.n + 1)÷(a.n - a.k + 1))
end

down!(r::Row) = next!(r)
down(r::Row) = next(r)

function left(a::Entry)
    isatleft(a) && throw(OutOfBoundsError("no entry to the left"))
    return prev(a)
end

left!(c::Column) = prev!(c)
left(c::Column) = prev(c)

function right(a::Entry)
    isatright(a) && throw(OutOfBoundsError("no entry to the right"))
    return next(a)
end

right!(c::Column) = next!(c)
right(c::Column) = next(c)

function prev(a::Entry)
    isfirst(a) && throw(OutOfBoundsError("no previous entry"))
    if !isatleft(a)
        # Need to do division last in case a.val is an integer
        return Entry(a.n, a.k-1, a.val*a.k÷(a.n - a.k + 1))
    else
        return Entry(a.n-1, a.n-1, 1)
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
        return Entry(a.n, a.k+1, a.val*(a.n - a.k)÷(a.k + 1))
    else
        return Entry(a.n+1, 0, 1)
    end
end

function next!(r::Row)
    datalength = numelements(r.rownum)
    if isodd(r.rownum) && r.rownum ≥ 3
        if r.rownum == 3
            newdata = 6
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