# Defines various functions for "moving" around
# Pascal's triangle.

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