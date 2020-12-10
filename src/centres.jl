# Defines the types Centre, LazyCentre, and associated
# functions. These represent a sequence of elements at
# the middle of each row and are zero-indexed. That is,
# if c is a Centre, then c[i] is the value of the middle
# element(s) of row i.

# LazyCentre calculates only the elements actually
# requested, Centre calculates all the requested elements
# up front.

# Center and LazyCenter are accepted aliases.
"""
    AbstractCentre <: AbstractVector

Supertype of all types representing the central elements
of Pascal's triangle.
"""
abstract type AbstractCentre{V <: Real} <: AbstractVector{V} end
Base.IndexStyle(::AbstractCentre) = IndexLinear()

"""
    Centre(data)
    Centre(c::Centre)
    Centre{V}(maxrow)
    Centre(maxrow)
    Centre(l::LazyCentre)

Represents a finite sequence of central elements of Pascal's
triangle. That is, the middle value(s) in each row, starting
from row 0 and up to `maxrow`.

`Center` is an alias for `Centre`.
"""
struct Centre{V <: Real} <: AbstractCentre{V}
    data::Vector{V}
end
Centre(c::Centre) = Centre(copy(c.data))
function Centre{V}(maxrow::Integer) where {V <: Real}
    maxrow ≥ 0 || throw(DomainError("maxrow must be non-negative, maxrow: $maxrow"))
    data = ones(V, maxrow+1)
    if maxrow ≥ 2
        e = Entry(2, 1, V(2))
        for i ∈ 3:2:maxrow-1
            data[i] = e.val
            down!(e)
            data[i+1] = e.val
            e.n += 1
            e.k += 1
            e.val *= 2
        end
        if iseven(maxrow)
            data[maxrow+1] = e.val
        end
    end
    return Centre{V}(data)
end
Centre(maxrow::Integer) = Centre{BigInt}(maxrow)

value(c::Centre) = c.data
Base.values(c::Centre) = value(c)

Base.axes(c::Centre) = (ZeroRange(length(c.data)-1),)
Base.axes(c::Centre, d::Integer) = d == 1 ? axes(c)[1] : nothing
Base.LinearIndices(c::Centre) = ZeroRange(length(c.data)-1)
Base.size(c::Centre) = (length(c.data),)
function Base.getindex(c::Centre, i::Int)
    0 ≤ i < length(c.data) || throw(BoundsError(c, i))
    return c.data[i+1]
end
Base.getindex(c::Centre, ::Colon) = value(c)
Base.getindex(c::Centre, I) = [c[i] for i ∈ I]
Base.firstindex(c::Centre) = 0
Base.lastindex(c::Centre) = length(c.data)-1
function toarray(c::Centre, leftbias=true)
    rm = leftbias ? RoundDown : RoundUp
    ns = axes(c,1)
    ks = div.(ns, 2, rm)
    return Entry.(ns, ks, c.data)
end

function tostring(c::Centre; oneline=false)
    sep = oneline ? ", " : "\n"
    v = values(c)
    s = ""
    if length(v) < THRESHOLD
        s *= join(v, sep) 
    else
        s *= join(v[1:HALF], sep)
        s *= oneline ? ", …, " : "\n⋮\n"
        s *= join(v[end-HALF+1:end], sep)
    end
    return s
end
function Base.show(io::IO, ::MIME"text/plain", c::Centre)
    print(io, "$(typeof(c).name){$(eltype(c).name)}")
    print(io, " up to row $(length(c.data)-1)\n")
    print(io, tostring(c))
end
function Base.show(io::IO, c::Centre)
    print(io, tostring(c, oneline=true))
end

function isvalid(c::Centre)
    ns = big(0):length(c.data)-1
    ks = ns .÷ 2
    return value(c) == binomial.(ns, ks)
end

"""
    LazyCentre(data)
    LazyCentre(l::LazyCentre)
    LazyCentre{V}()
    LazyCentre()
    LazyCentre(c::Centre)

Represents the central elements of Pascal's triangle but
lazily evaluated. `data` can be supplied as a dictionary
mapping a row number to a value. `V` is a data type for
the values.

`LazyCenter` is an alias for `LazyCentre`.
"""
struct LazyCentre{V <: Real} <: AbstractCentre{V}
    data::Dict{Int,V}
end
LazyCentre(c::LazyCentre) = LazyCentre(copy(c.data))
LazyCentre{V}() where {V <: Real} = LazyCentre{V}(Dict{Int,V}(0 => 1, 1 => 1))
LazyCentre() = LazyCentre{BigInt}()
LazyCentre(c::Centre) = LazyCentre(Dict(axes(c,1) .=> values(c)))

const PRECALC_NUMBER = 5
function Base.getindex(c::LazyCentre, i::Int)
    0 ≤ i || throw(BoundsError(c, i))
    if haskey(c.data, i)
        return c.data[i]
    end
    # Calculating adjacent entries is ≈ 10x faster than calculating
    # isolated entries using binomial, so when calculating a new
    # value we do several either side of it.
    e = Entry{valtype(c.data)}(i, i÷2)
    uprange = (i-1):-1:max(2,i-PRECALC_NUMBER)
    a = Entry(e)
    for j ∈ uprange
        up!(a)
        if isodd(a.n)
            a.k -= 1
        end
        if !haskey(c.data, j)
            c.data[j] = a.val
        end
    end
    downrange = (i+1):(i+PRECALC_NUMBER)
    a = Entry(e)
    for j ∈ downrange
        down!(a)
        if isodd(a.n)
            a.k += 1
        end
        if !haskey(c.data, j)
            c.data[j] = a.val
        end
    end
    return e.val
end
Base.getindex(c::LazyCentre, I) = [c[i] for i ∈ I]
Base.firstindex(c::LazyCentre) = 0
Base.IteratorSize(::LazyCentre) = Base.IsInfinite()
Base.eltype(::LazyCentre{V}) where {V <: Real} = V

Base.:(==)(a::LazyCentre, b::LazyCentre) = a.data == b.data

function isvalid(c::LazyCentre)
    return all(c.data) do (n, val)
        binomial(n, n÷2) == val
    end
end

function toarray(c::LazyCentre, leftbias=true)
    rm = leftbias ? RoundDown : RoundUp
    ns = keys(c.data)
    ks = div.(ns, 2, rm)
    return Entry.(ns, ks, values(c.data))
end

function Base.show(io::IO, ::MIME"text/plain", c::LazyCentre)
    print(io, "$(typeof(c).name){$(eltype(c).name)}")
    print(io, "($(length(c.data)) elements precalculated, ")
    print(io, "up to row $(maximum(keys(c.data))))")
end
function Base.show(io::IO, c::LazyCentre)
    print(io, "$(typeof(c).name)")
    print(io, "($(length(c.data)))")
end

function Centre(c::LazyCentre)
    data = eltype(c)[]
    i = 0
    while haskey(c.data, i)
        push!(data, c.data[i])
        i += 1
    end
    return Centre(data)
end

const Center = Centre
const LazyCenter = LazyCentre