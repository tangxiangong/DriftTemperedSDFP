module space
using Gridap, GridapGmsh
export Space, fe_space

struct Space
    trial_space::TrialFESpace
    test_space::FESpace
    measure::Measure
    function Space(trial_space::TrialFESpace, test_space::FESpace, measure::Measure)
        new(trial_space, test_space, measure)
    end
end

function fe_space(mesh::String, order::Int=1)
    model = GmshDiscreteModel(mesh)
    reffe = ReferenceFE(lagrangian, Float64, order)
    V = TestFESpace(model, reffe; conformity=:H1, dirichlet_tags="boundary")
    U = TrialFESpace(V, x -> 0)
    Ω = Triangulation(model)
    dΩ = Measure(Ω, order + 1)
    return Space(U, V, dΩ)
end
end
