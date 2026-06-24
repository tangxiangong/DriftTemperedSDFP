using DriftTemperedSDFP: Problem, UnitRectangle

f(x, t) = 0.0
u₀(x) = 0.0

problem = Problem(
    1.0,              # κ > 0
    0.5,              # 0 < α < 1
    0.0,              # μ >= 0
    1.0,              # T >= 0
    UnitRectangle(1), # Ω, e.g. ((0.0, 1.0),) for 1D
    f,
    u₀,
)

println(problem)
