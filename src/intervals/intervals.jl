# This file is part of the IntervalArithmetic.jl package; MIT licensed

# The order in which files are included is important,
# since certain things need to be defined before others use them

## Interval type

if haskey(ENV, "IA_VALID") == true
    const validity_check = true
else
    const validity_check = false
end

abstract type AbstractInterval{T} <: Real end

struct Interval{T<:Real} <: AbstractInterval{T}
    lo :: T
    hi :: T

    function Interval{T}(a::Real, b::Real) where T<:Real

        if validity_check

            if is_valid_interval(a, b)
                new(a, b)

            else
                throw(ArgumentError("Interval of form [$a, $b] not allowed. Must have a ≤ b to construct interval(a, b)."))
            end

        end

        new(a, b)

    end
end



## Outer constructors

Interval(a::T, b::T) where T<:Real = Interval{T}(a, b)
Interval(a::T) where T<:Real = Interval(a, a)
Interval(a::Tuple) = Interval(a...)
Interval(a::T, b::S) where {T<:Real, S<:Real} = Interval(promote(a,b)...)

## Concrete constructors for Interval, to effectively deal only with Float64,
# BigFloat or Rational{Integer} intervals.
Interval(a::T, b::T) where T<:Integer = Interval(float(a), float(b))
Interval(a::T, b::T) where T<:Irrational = Interval(float(a), float(b))

eltype(x::Interval{T}) where T<:Real = T

Interval(x::Interval) = x
Interval(x::Complex) = Interval(real(x)) + im*Interval(imag(x))

Interval{T}(x) where T = Interval(convert(T, x))

Interval{T}(x::Interval) where T = convert(Interval{T}, x)

"""
    is_valid_interval(a::Real, b::Real)

Check if `(a, b)` constitute a valid interval
"""
function is_valid_interval(a::Real, b::Real)

    # println("isvalid()")

    if isnan(a) || isnan(b)
        if isnan(a) && isnan(b)
            return true
        else
            return false
        end
    end

    if a > b
        if isinf(a) && isinf(b)
            return true  # empty interval = [∞,-∞]
        else
            return false
        end
    end

    if a == Inf || b == -Inf
        return false
    end

    return true
end

"""
    interval(a, b)

`interval(a, b)` checks whether [a, b] is a valid `Interval`, which is the case if `-∞ <= a <= b <= ∞`, using the (non-exported) `is_valid_interval` function. If so, then an `Interval(a, b)` object is returned; if not, then an error is thrown.
"""
function interval(a::Real, b::Real)
    if !is_valid_interval(a, b)
        throw(ArgumentError("`[$a, $b]` is not a valid interval. Need `a ≤ b` to construct `interval(a, b)`."))
    end

    return Interval(a, b)
end

interval(a::Real) = interval(a, a)


## Include files
include("special.jl")
include("macros.jl")
include("rounding_macros.jl")
include("rounding.jl")
include("conversion.jl")
include("precision.jl")
include("set_operations.jl")
include("arithmetic.jl")
include("functions.jl")
include("trigonometric.jl")
include("hyperbolic.jl")


# Syntax for intervals

a..b = interval(convert(Interval, a).lo, convert(Interval, b).hi)

# ..(a::Integer, b::Integer) = interval(a, b)
# ..(a::Integer, b::Real) = interval(a, nextfloat(float(b)))
# ..(a::Real, b::Integer) = interval(prevfloat(float(a)), b)
#
# ..(a::Real, b::Real) = interval(prevfloat(float(a)), nextfloat(float(b)))

macro I_str(ex)  # I"[3,4]"
    @interval(ex)
end

a ± b = (a-b)..(a+b)
