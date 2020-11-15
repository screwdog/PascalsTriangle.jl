module PascalsTriangle

struct OutOfBoundsError <: Exception end
struct NonAdjacentError <: Exception end

struct Entry{I <: Integer, V <: Real}
    n::I
    k::I
    val::V
end
Entry(e::Entry) = Entry(e.n, e.k, e.val)
Entry(n,k) = Entry(n,k,binomial(n,k))
Entry(V::Type,n,k) = Entry(n,k,V(binomial(n,k)))

Base.:<(a::Entry, b::Entry) = a.val < b.val

function Base.:+(a::Entry, b::Entry)
    isadjacent(a,b) || throw(NonAdjacentError("can't add these entries"))
    return Entry(a.n+1, max(a.k, b.k), a.val + b.val)
end

function Base.:-(a::Entry, b::Entry)
    issubtractable(a,b) || throw(NonAdjacentError("can't subtract these entries"))
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
Base.axes(z::ZeroRange) = (z,)
Base.length(z::ZeroRange) = z.max + 1
Base.first(z::ZeroRange) = 0
Base.last(z::ZeroRange) = z.max
function Base.getindex(z::ZeroRange, i::Integer)
    0 ≤ i ≤ z.max || throw(BoundsError("index out of bounds"))
    return i
end

numelements(rownum) = max(ceil(Integer, (rownum-3)÷2), 0)

mutable struct Row{V} <: AbstractVector{V}
    rownum::Integer
    data::Array{V,1}
    function Row(rownum,data)
        rownum ≥ 0 || throw(DomainError(rownum,"rownum must be nonnegative"))
        return new{eltype(data)}(rownum,data)
    end
end
Row(r::Row) = Row(r.rownum, copy(r.data))
Row(rownum) = Row(Integer, rownum, rownum+1)
function Row(V::Type, rownum, datasize)
    datasize > rownum || throw(ArgumentError("datasize specified is not enough to store the requested row"))
    datalength = numelements(datasize)
    arr = ones(V,datalength)
    entry = Entry(rownum,1,rownum*one(V))
    for i ∈ 1:datalength
        entry = right(entry)
        arr[i] = entry.val
    end
    return Row(rownum, arr)    
end

Base.axes(r::Row) = (ZeroRange(r.rownum),)
Base.size(r::Row) = (r.rownum + 1,)
Base.IndexStyle(::Type{<:Row}) = IndexLinear()
function Base.getindex(r::Row, i::Int)
    0 ≤ i ≤ r.rownum || throw(BoundsError("index out of bounds"))
    index = i > r.rownum/2 ? r.rownum - i : i
    if index == 0
        return one(eltype(r.data))
    end
    if index == 1
        return r.rownum*one(eltype(r.data))
    end
    return r.data[index-1]
end
Base.firstindex(r::Row) = 0
Base.lastindex(r::Row) = r.rownum

isfirst(r::Row) = r.rownum == 0
isvalid(r::Row) = r.rownum ≥ 0 && length(r.data) ≥ rownum + 1 && r.data[1:rownum+1] == Row(rownum).data
toarray(r::Row) = map((k,v) -> Entry(r.rownum,k,v), 0:r.rownum, r.data)

mutable struct Column{V} <: AbstractVector{V}
    colnum::Integer
    data::Array{V,1}
    function Column(colnum::Integer, data::Array)
        colnum ≥ 0 || throw(DomainError("colnum must be nonnegative"))
        return new{eltype(data)}(colnum, data)
    end
end
Column(c::Column) = Column(c.colnum, copy(c.data))
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

Base.size(c::Column) = (length(c.data),)
Base.IndexStyle(::Type{<:Column}) = IndexLinear()
Base.getindex(c::Column, i::Int) = c.data[i]
Base.firstindex(c::Column) = 1
Base.lastindex(c::Column) = length(c.data)

isfirst(c::Column) = c.colnum == 1
isvalid(c::Column) = c.colnum ≥ 1 && c.data == Column(colnum, length(c.data))

function up(a::Entry)
    if isatright(a) || isfirst(a)
        throw(OutOfBoundsError("no entry above"))
    end
    return Entry(a.n-1, a.k, (a.n - a.k)/a.n*a.val)
end

up!(r::Row) = prev!(r)
up(r::Row) = prev(r)

function down(a::Entry)
    Entry(a.n+1, a.k, (a.n + 1)/(a.n - a.k + 1)*a.val)
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
    isatright(a) && throw(OutOfBoundsError("no enrty to the right"))
    return next(a)
end

right!(c::Column) = next!(c)
right(c::Column) = next(c)

function prev(a::Entry)
    isfirst(a) && throw(OutOfBoundsError("no previous entry"))
    if !isatleft(a)
        return Entry(a.n, a.k-1, a.k/(a.n - a.k + 1)*a.val)
    else
        return Entry(a.n-1, a.n-1, 1)
    end
end

function prev!(r::Row)
    isfirst(r) && throw(OutOfBoundsError("no previous row"))
    rowdata = @view r.data[1:r.rownum]
    for i ∈ 2:r.rownum
        rowdata[i] -= rowdata[i-1]
    end
    r.rownum -= 1
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
    return prev!(c)
end

function next(a::Entry)
    if !isatright(a)
        return Entry(a.n, a.k+1, (a.n - a.k)/(a.k + 1)*a.val)
    else
        return Entry(a.n+1, 0, 1)
    end
end

function next!(r::Row)
    r.rownum += 1
    for i ∈ 2:r.rownum
        r.data[i] += r.data[i-1]
    end
    if length(r.data) > r.rownum
        r.data[r.rownum+1] = one(eltype(r.data))
    else
        push!(r.data, one(eltype(r.data)))
    end
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
    return next!(c)
end
end # of module