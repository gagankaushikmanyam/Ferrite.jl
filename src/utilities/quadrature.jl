
"""
A type that perform quadrature points
"""
type QuadratureRule{dim}
    weights::Vector{Float64}
    points::Vector{Vector{Float64}}
end

weights(qr::QuadratureRule) = qr.weights
points(qr::QuadratureRule) = qr.points

"""
Integrates the function *f* with the given
`QuadratureRule`
"""
function integrate(qr::QuadratureRule, f)
    w = weights(qr)
    p = points(qr)
    I = w[1] * f(p[1])
    for (w, x) in zip(w[2:end], p[2:end])
        I += w * f(x)
    end
    return I
end


function get_gaussrule(::Type{Dim{2}}, ::Triangle, order::Int)
    if order <= 5
        return trirules[order]
    else
        return make_trirule(order)
    end
end

function get_gaussrule(::Type{Dim{1}}, ::Square, order::Int)
    if order <= 5
        return linerules[order]
    else
        return make_linerule(order)
    end
end

function get_gaussrule(::Type{Dim{2}}, ::Square, order::Int)
    if order <= 5
        return quadrules[order]
    else
        return make_quadrule(order)
    end
end

function get_gaussrule(::Type{Dim{3}}, ::Square, order::Int)
    if order <= 5
        return cuberules[order]
    else
        return make_cuberule(order)
    end
end


"""
Creates a `GaussQuadratureRule` that integrates
functions on a cube to the given order.
"""
function make_cuberule(order::Int)
    p, w = gausslegendre(order)
    weights = Array(Float64, order^3)
    points = Array(Vector{Float64}, order^3)
    count = 1
    for i = 1:order, j = 1:order, k = 1:order
        points[count] = [p[i], p[j], p[k]]
        weights[count] = w[i] * w[j] * w[k]
        count += 1
    end
    QuadratureRule{3}(weights, points)
end

const cuberules = [make_cuberule(i) for i = 1:5]
function get_cuberule(order::Int)
    if order <= 5
        return cuberules[order]
    else
        return make_cuberule(order)
    end
end

"""
Creates a `QuadratureRule` that integrates
functions on a square to the given order.
"""
function make_quadrule(order::Int)
    p, w = gausslegendre(order)
    weights = Array(Float64, order^2)
    points = Array(Vector{Float64}, order^2)
    count = 1
    for i = 1:order, j = 1:order
        points[count] = [p[i], p[j]]
        weights[count] = w[i] * w[j]
        count += 1
    end
    QuadratureRule{2}(weights, points)
end

const quadrules = [make_quadrule(i) for i = 1:5]
function get_quadrule(order::Int)
    if order <= 5
        return quadrules[order]
    else
        return make_quadrule(order)
    end
end

"""
Creates a `QuadratureRule` that integrates
functions on a line to the given order.
"""
function make_linerule(order::Int)
    p, weights = gausslegendre(order)
    points = Array(Vector{Float64}, order)
    for i = 1:order
        points[i] = [p[i]]
    end
    QuadratureRule{1}(weights, points)
end

const linerules = [make_linerule(i) for i = 1:5]
function get_linerule(order::Int)
    if order <= 5
        return linerules[order]
    else
        return make_linerule(order)
    end
end

include("gaussquad_tri_table.jl")

function make_trirule(order::Int)
    data = _get_gauss_tridata(order)
    n_points = size(data,1)
    weights = Array(Float64, n_points)
    points = Array(Vector{Float64}, n_points)

    for p in 1:size(data, 1)
        points[p] = [data[p, 1], data[p, 2]]
    end

    weights = 0.5 * data[:, 3]

    QuadratureRule{2}(weights, points)
end

const trirules = [make_trirule(i) for i = 1:5]
function get_trirule(order::Int)
    if order <= 5
        return trirules[order]
    else
        return make_trirule(order)
    end
end
