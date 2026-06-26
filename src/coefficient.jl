module coefficient
export coe
function coe(α::Float64, μ::Float64, τ::Float64, n::Int64)
    c = 1 / (1 + τ * μ)
    ω = zeros(n + 1)
    @inbounds ω[1] = ((1 + τ * μ)^α - (τ * μ)^α) / τ^α
    @inbounds for k in 1:n
        ω[k+1] = c * (1 - (α + 1) / k) * ω[k]
    end
    return ω
end
end
