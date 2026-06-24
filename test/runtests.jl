using Test
using DriftTemperedSDFP
using GridapGmsh: GmshDiscreteModel

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
