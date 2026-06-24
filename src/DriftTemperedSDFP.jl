module DriftTemperedSDFP

export Problem, UnitRectangle

"""
Problem(κ::Float64, α::Float64, μ::Float64, T::Float64, Ω::NTuple{N,NTuple{2,Float64}}, f::F, u₀::U₀) where {N,F,U₀}

A struct representing a drift-tempered SDFP problem in `N` dimensions.
"""
struct Problem{N,F,U₀}
    κ::Float64
    α::Float64
    μ::Float64
    T::Float64
    Ω::NTuple{N,NTuple{2,Float64}}
    f::F
    u₀::U₀

    function Problem(κ::Float64, α::Float64, μ::Float64, T::Float64, Ω::NTuple{N,NTuple{2,Float64}}, f::F, u₀::U₀) where {N,F,U₀}
        if N >= 3
            throw(ArgumentError("N must be less than 3"))
        end
        if κ <= 0
            throw(ArgumentError("κ must be positive"))
        end
        if α <= 0 || α >= 1
            throw(ArgumentError("α must be between 0 and 1"))
        end
        if μ < 0
            throw(ArgumentError("μ must be non-negative"))
        end
        if T < 0
            throw(ArgumentError("T must be non-negative"))
        end
        for i in 1:N
            if Ω[i][1] >= Ω[i][2]
                throw(ArgumentError("Ω[$i] must have a lower bound less than its upper bound"))
            end
        end
        new{N,F,U₀}(κ, α, μ, T, Ω, f, u₀)
    end
end

"""
    UnitRectangle(N::Integer)

Returns a `NTuple{N,NTuple{2,Float64}}` representing a unit rectangle in `N` dimensions.
"""
function UnitRectangle(N::Integer)
    ntuple(_ -> (0.0, 1.0), N)
end

include("mesh.jl")

end # module DriftTemperedSDFP
