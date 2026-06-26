using Test
using DriftTemperedSDFP
using GridapGmsh: GmshDiscreteModel
using Gridap

@testset "space" begin
    tmp = mktempdir()
    msh_1d = DriftTemperedSDFP.mesh.generate_msh(((0.0, 1.0),), 0.25; path=tmp, name="sp_interval")
    msh_2d = DriftTemperedSDFP.mesh.generate_msh(((0.0, 1.0), (0.0, 1.0)), 0.5; path=tmp, name="sp_square")

    @testset "fe_space 1D order 1 (default)" begin
        sp = DriftTemperedSDFP.space.fe_space(msh_1d)
        @test sp isa DriftTemperedSDFP.space.Space
        @test sp.trial_space isa Gridap.FESpaces.TrialFESpace
        @test sp.test_space isa Gridap.FESpaces.FESpace
        @test sp.measure isa Gridap.CellData.Measure
        # trial and test spaces share the same interior DOFs
        @test num_free_dofs(sp.trial_space) == num_free_dofs(sp.test_space)
        # Dirichlet BC applied: both endpoints constrained
        @test num_dirichlet_dofs(sp.test_space) >= 2
        @test num_free_dofs(sp.trial_space) > 0
    end

    @testset "fe_space 1D order 2" begin
        sp1 = DriftTemperedSDFP.space.fe_space(msh_1d, 1)
        sp2 = DriftTemperedSDFP.space.fe_space(msh_1d, 2)
        @test sp2 isa DriftTemperedSDFP.space.Space
        @test sp2.trial_space isa Gridap.FESpaces.TrialFESpace
        @test sp2.test_space isa Gridap.FESpaces.FESpace
        @test sp2.measure isa Gridap.CellData.Measure
        # higher polynomial order => more interior DOFs
        @test num_free_dofs(sp2.trial_space) > num_free_dofs(sp1.trial_space)
    end

    @testset "Space direct construction" begin
        sp = DriftTemperedSDFP.space.fe_space(msh_1d)
        # Reconstruct from the same components to exercise the inner constructor
        sp2 = DriftTemperedSDFP.space.Space(sp.trial_space, sp.test_space, sp.measure)
        @test sp2 isa DriftTemperedSDFP.space.Space
        @test sp2.trial_space === sp.trial_space
        @test sp2.test_space === sp.test_space
        @test sp2.measure === sp.measure
    end

    @testset "fe_space 2D order 1 (default)" begin
        sp = DriftTemperedSDFP.space.fe_space(msh_2d)
        @test sp isa DriftTemperedSDFP.space.Space
        @test sp.trial_space isa Gridap.FESpaces.TrialFESpace
        @test sp.test_space isa Gridap.FESpaces.FESpace
        @test sp.measure isa Gridap.CellData.Measure
        @test num_free_dofs(sp.trial_space) == num_free_dofs(sp.test_space)
        @test num_dirichlet_dofs(sp.test_space) > 0
        @test num_free_dofs(sp.trial_space) > 0
    end

    @testset "2D mesh has more free DOFs than 1D mesh" begin
        sp1d = DriftTemperedSDFP.space.fe_space(msh_1d)
        sp2d = DriftTemperedSDFP.space.fe_space(msh_2d)
        @test num_free_dofs(sp2d.trial_space) > num_free_dofs(sp1d.trial_space)
    end
end

@testset "mesh generation" begin
    tmp = mktempdir()

    one_d = DriftTemperedSDFP.mesh.generate_msh(((0.0, 1.0),), 0.25; path=tmp, name="interval")
    @test one_d == joinpath(tmp, "interval_1d.msh")
    @test isfile(one_d)
    @test GmshDiscreteModel(one_d) !== nothing
    @test occursin("0 1 \"boundary\"", read(one_d, String))
    @test occursin("1 2 \"domain\"", read(one_d, String))

    two_d = DriftTemperedSDFP.mesh.generate_msh(((0.0, 1.0), (0.0, 1.0)), 0.5; path=tmp, name="square")
    @test two_d == joinpath(tmp, "square_2d.msh")
    @test isfile(two_d)
    @test GmshDiscreteModel(two_d) !== nothing
    @test occursin("1 1 \"boundary\"", read(two_d, String))
    @test occursin("2 2 \"domain\"", read(two_d, String))

    three_d = DriftTemperedSDFP.mesh.generate_msh(
        ((0.0, 1.0), (0.0, 1.0), (0.0, 1.0)),
        0.75;
        path=tmp,
        name="cube",
    )
    @test three_d == joinpath(tmp, "cube_3d.msh")
    @test isfile(three_d)
    @test GmshDiscreteModel(three_d) !== nothing
    @test occursin("2 1 \"boundary\"", read(three_d, String))
    @test occursin("3 2 \"domain\"", read(three_d, String))
end
