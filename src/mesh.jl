module mesh
    import GridapGmsh: gmsh

    export generate_msh, msh_1d, msh_2d, msh_3d

    function generate_msh(domain::NTuple{N,NTuple{2,Float64}}, h::Float64; path::String="./model/", name::String="model") where {N}
        if N == 1
            return msh_1d(domain, h; path=path, name=name)
        elseif N == 2
            return msh_2d(domain, h; path=path, name=name)
        elseif N == 3
            return msh_3d(domain, h; path=path, name=name)
        end
        throw(ArgumentError("N must be 1, 2, or 3"))
    end

    function msh_1d(domain::NTuple{1,NTuple{2,Float64}}, h::Float64; path::String="./model/", name::String="model")
        x_min, x_max = domain[1]
        @assert x_min < x_max
        @assert h > 0
        mkpath(path)

        gmsh.initialize()
        try
            gmsh.model.add(name)
            p1 = gmsh.model.geo.addPoint(x_min, 0.0, 0.0, h)
            p2 = gmsh.model.geo.addPoint(x_max, 0.0, 0.0, h)
            line = gmsh.model.geo.addLine(p1, p2)
            gmsh.model.geo.synchronize()

            boundary_group = gmsh.model.addPhysicalGroup(0, [p1, p2])
            domain_group = gmsh.model.addPhysicalGroup(1, [line])
            gmsh.model.setPhysicalName(0, boundary_group, "boundary")
            gmsh.model.setPhysicalName(1, domain_group, "domain")

            gmsh.model.mesh.generate(1)
            msh_file = joinpath(path, "$(name)_1d.msh")
            gmsh.write(msh_file)
            return msh_file
        finally
            gmsh.finalize()
        end
    end

    function msh_2d(domain::NTuple{2,NTuple{2,Float64}}, h::Float64; path::String="./model/", name::String="model")
        x_min, x_max = domain[1]
        y_min, y_max = domain[2]
        @assert x_min < x_max && y_min < y_max
        @assert h > 0
        mkpath(path)

        gmsh.initialize()
        try
            gmsh.model.add(name)
            p1 = gmsh.model.geo.addPoint(x_min, y_min, 0.0, h)
            p2 = gmsh.model.geo.addPoint(x_max, y_min, 0.0, h)
            p3 = gmsh.model.geo.addPoint(x_max, y_max, 0.0, h)
            p4 = gmsh.model.geo.addPoint(x_min, y_max, 0.0, h)
            l1 = gmsh.model.geo.addLine(p1, p2)
            l2 = gmsh.model.geo.addLine(p2, p3)
            l3 = gmsh.model.geo.addLine(p3, p4)
            l4 = gmsh.model.geo.addLine(p4, p1)
            curve_loop = gmsh.model.geo.addCurveLoop([l1, l2, l3, l4])
            plane_surface = gmsh.model.geo.addPlaneSurface([curve_loop])
            gmsh.model.geo.synchronize()

            boundary_group = gmsh.model.addPhysicalGroup(1, [l1, l2, l3, l4])
            domain_group = gmsh.model.addPhysicalGroup(2, [plane_surface])
            gmsh.model.setPhysicalName(1, boundary_group, "boundary")
            gmsh.model.setPhysicalName(2, domain_group, "domain")

            gmsh.model.mesh.generate(2)
            msh_file = joinpath(path, "$(name)_2d.msh")
            gmsh.write(msh_file)
            return msh_file
        finally
            gmsh.finalize()
        end
    end

    function msh_3d(domain::NTuple{3,NTuple{2,Float64}}, h::Float64; path::String="./model/", name::String="model")
        x_min, x_max = domain[1]
        y_min, y_max = domain[2]
        z_min, z_max = domain[3]
        @assert x_min < x_max && y_min < y_max && z_min < z_max
        @assert h > 0
        mkpath(path)

        gmsh.initialize()
        try
            gmsh.model.add(name)
            volume = gmsh.model.occ.addBox(
                x_min,
                y_min,
                z_min,
                x_max - x_min,
                y_max - y_min,
                z_max - z_min,
            )
            gmsh.model.occ.mesh.setSize(gmsh.model.occ.getEntities(0), h)
            gmsh.model.occ.synchronize()

            faces = [tag for (dim, tag) in gmsh.model.getBoundary([(3, volume)], false, false) if dim == 2]
            boundary_group = gmsh.model.addPhysicalGroup(2, faces)
            domain_group = gmsh.model.addPhysicalGroup(3, [volume])
            gmsh.model.setPhysicalName(2, boundary_group, "boundary")
            gmsh.model.setPhysicalName(3, domain_group, "domain")

            gmsh.model.mesh.generate(3)
            msh_file = joinpath(path, "$(name)_3d.msh")
            gmsh.write(msh_file)
            return msh_file
        finally
            gmsh.finalize()
        end
    end
end # module mesh
