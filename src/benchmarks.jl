using PascalsTriangle
using BenchmarkTools

function binomialrow(n)
    return binomial.(n, 0:n)
end

function ptrow(n)
    return Row(n)
end

function bin_all_rows(n)
    a = Vector(undef, n+1)
    for i ∈ 0:n
        a[1:i+1] = binomial.(i,0:i)
    end
end

function pt_all_rows(n)
    r = Row(Integer,0,n)
    for i ∈ 1:n
        next!(r)
    end
end

rnums = rand(0:50, 100)

@btime binomialrow.(rnums)
@btime ptrow.(rnums)

@btime bin_all_rows(50)
@btime pt_all_rows(50)