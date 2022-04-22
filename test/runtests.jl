using ExtendableSparse
using HydrologyPlanetesimals
using Parameters
using StaticArrays
using Test

@testset verbose = true "HydrologyPlanetesimals.jl" begin

    @testset "staggered grid setup" begin
        xsize=140_000.0
        ysize=140_000.0
        rplanet=50_000.0
        rcrust=48_000.0
        Nx=141
        Ny=141
        Nxmc=4
        Nymc=4
        sp = HydrologyPlanetesimals.StaticParameters(
            xsize=xsize,
            ysize=ysize,
            rplanet=rplanet,
            rcrust=rcrust,
            Nx=Nx,
            Ny=Ny,
            Nxmc=Nxmc,
            Nymc=Nymc
        )
        function setup(sp)
            @unpack xsize, ysize,
                Nx, Ny,
                Nx1, Ny1,
                dx, dy,
                jmin_basic, jmax_basic,
                imin_basic, imax_basic,
                jmin_vx, jmax_vx,
                imin_vx, imax_vx,
                jmin_vy, jmax_vy,
                imin_vy, imax_vy,
                jmin_p, jmax_p,
                imin_p, imax_p,
                rhosolidm,
                rhofluidm,
                etasolidm,
                etasolidmm,
                etafluidm,
                etafluidmm,
                rhocpsolidm,
                rhocpfluidm,
                alphasolidm,
                alphafluidm,
                ksolidm,
                kfluidm,
                start_hrsolidm,
                start_hrfluidm,
                gggsolidm,
                frictsolidm,
                cohessolidm,
                tenssolidm,
                kphim0,
                etaphikoef,
                phim0,
                tmsilicate,
                tmiron,
                etamin,
                nplast,
                dtelastic,
                start_step,
                nsteps,
                start_time, 
                endtime,
                start_marknum = sp
            x = SVector{Nx, Float64}([j for j = 0:dx:xsize])
            y = SVector{Ny, Float64}([j for j = 0:dy:ysize])
            xvx = SVector{Ny1, Float64}([j for j = 0:dx:xsize+dy])
            yvx = SVector{Nx1, Float64}([i for i = -dy/2:dy:ysize+dy/2])
            xvy = SVector{Nx1, Float64}([j for j = -dx/2:dx:xsize+dx/2])
            yvy = SVector{Ny1, Float64}([i for i = 0:dy:ysize+dy])
            xp = SVector{Nx1, Float64}([j for j = -dx/2:dx:xsize+dx/2])
            yp = SVector{Ny1, Float64}([i for i = -dy/2:dy:ysize+dy/2])
            return x, y, xvx, yvx, xvy, yvy, xp, yp
        end
        x, y, xvx, yvx, xvy, yvy, xp, yp = setup(sp)
        # from madcph.m lines 24ff
        xsize=140000
        ysize=140000
        Nx=141
        Ny=141
        Nx1=Nx+1
        Ny1=Ny+1
        dx=xsize/(Nx-1)
        dy=ysize/(Ny-1)
        x_ver=0:dx:xsize
        y_ver=0:dy:ysize
        xvx_ver=0:dx:xsize+dy
        yvx_ver=-dy/2:dy:ysize+dy/2
        xvy_ver=-dx/2:dx:xsize+dx/2
        yvy_ver=0:dy:ysize+dy
        xp_ver=-dx/2:dx:xsize+dx/2
        yp_ver=-dy/2:dy:ysize+dy/2
        # tests
        @test x == collect(x_ver)
        @test y == collect(y_ver)
        @test xvx == collect(xvx_ver)
        @test yvx == collect(yvx_ver)
        @test xvy == collect(xvy_ver)
        @test yvy == collect(yvy_ver)
        @test xp == collect(xp_ver)
        @test yp == collect(yp_ver)
    end # testset "staggered grid setup"

    @testset "distance()" begin
        @test HydrologyPlanetesimals.distance(0, 0, 0, 0) == 0
        @test HydrologyPlanetesimals.distance(1, 0, 0, 0) == 1
        @test HydrologyPlanetesimals.distance(0, 1, 0, 0) == 1
        @test HydrologyPlanetesimals.distance(0, 0, 1, 0) == 1
        @test HydrologyPlanetesimals.distance(0, 0, 0, 1) == 1
        @test HydrologyPlanetesimals.distance(0, 0, 1, 1) ≈ sqrt(2)
        @test HydrologyPlanetesimals.distance(1, 1, 0, 0) ≈ sqrt(2)
        @test HydrologyPlanetesimals.distance(-1, -1, 1, 1) ≈ sqrt(8)
        # random tests
        num_samples = 100
        x = rand(0:0.001:1000, 2, num_samples)
        y = rand(0:0.001:1000, 2, num_samples)
        for i in 1:num_samples
            @test HydrologyPlanetesimals.distance(
                x[:, i]..., y[:, i]...) ≈ sqrt(sum((x[:, i] - y[:, i]).^2))
        end
    end # testset "distance()"

    @testset "total()" begin
        @test HydrologyPlanetesimals.total(0, 0, 0) == 0
        @test HydrologyPlanetesimals.total(1, 0, 0) == 1
        @test HydrologyPlanetesimals.total(0, 1, 0) == 0
        @test HydrologyPlanetesimals.total(0, 0, 1) == 0
        @test HydrologyPlanetesimals.total(1, 2, 0.5) == 1.5
    end # testset "total()"

    @testset "ktotal()" begin
        # from madcph.m, line 1761
        ktotalm(ksolidm, kfluid, phim)=(ksolidm*kfluid/2+((ksolidm*(3*phim-2)+kfluid*(1-3*phim))^2)/16)^0.5-(ksolidm*(3*phim-2)+ kfluid*(1-3*phim))/4
        @test HydrologyPlanetesimals.ktotal(1., 2., 3.) == ktotalm(1., 2., 3.)
    end # testset "ktotal()"

    @testset "kphi()" begin
        # from madcph.m, line 333
        kphim(kphim0, phim, phim0)=kphim0*(phim/phim0)^3/((1-phim)/(1-phim0))^2
        @test HydrologyPlanetesimals.kphi(1., 2., 3.) == kphim(1., 2., 3.)
    end # testset "kphi()"

    @testset "Q_radiogenic()" begin
        # from madcph.m, line 276
        Q(f, ratio, E, tau, timesum)=f*ratio*E*exp(-timesum/tau)/tau
        @test HydrologyPlanetesimals.Q_radiogenic(1., 2., 3., 4., 5.) == Q(
            1., 2., 3., 4., 5.)
        @test HydrologyPlanetesimals.Q_radiogenic(1., 2., 3., 4., 0.) == Q(
            1., 2., 3., 4., 0.)
    end # testset "Q_radiogenic()"

    @testset "calculate_radioactive_heating()" begin
        hr_al = false
        hr_fe = false
        v = @SVector [0., 0., 0.]
        sp = HydrologyPlanetesimals.StaticParameters(hr_al=hr_al, hr_fe=hr_fe)
        @test HydrologyPlanetesimals.calculate_radioactive_heating(
            1000., sp) == (v, v)

        hr_al = true
        hr_fe = false        
        sp2 = HydrologyPlanetesimals.StaticParameters(hr_al=hr_al, hr_fe=hr_fe)
        Q_al = HydrologyPlanetesimals.Q_radiogenic(
            sp2.f_al, sp2.ratio_al, sp2.E_al, sp2.tau_al, 1000.)
        u = @SVector [Q_al * sp2.rhosolidm[1], Q_al * sp2.rhosolidm[2], 0.]
        @test HydrologyPlanetesimals.calculate_radioactive_heating(
            1000., sp2) == (u, v)

        hr_al = false
        hr_fe = true
        sp3 = HydrologyPlanetesimals.StaticParameters(hr_al=hr_al, hr_fe=hr_fe)
        Q_fe = HydrologyPlanetesimals.Q_radiogenic(
            sp3.f_fe, sp3.ratio_fe, sp3.E_fe, sp3.tau_fe, 1000.)
        w = @SVector [Q_fe * sp2.rhofluidm[1], 0., 0.]
        @test HydrologyPlanetesimals.calculate_radioactive_heating(
            1000., sp3) == (v, w)
    end # testset "calculate_radioactive_heating()"

    @testset "fix_weights() elementary" begin
        sp = HydrologyPlanetesimals.StaticParameters()
        Nx, Ny = sp.Nx, sp.Ny
        dx, dy = sp.dx, sp.dy
        xsize, ysize = sp.xsize, sp.ysize
        # from madcph.m, line 38ff
        # Basic nodes
        x=0:dx:xsize
        y=0:dy:ysize
        # Vx-Nodes
        xvx=0:dx:xsize+dy
        yvx=-dy/2:dy:ysize+dy/2
        # Vy-nodes
        xvy=-dx/2:dx:xsize+dx/2
        yvy=0:dy:ysize+dy
        # P-Nodes
        xp=-dx/2:dx:xsize+dx/2
        yp=-dy/2:dy:ysize+dy/2

        @testset "basic nodes" begin
        # from madcph.m, line 373ff
        jmin, jmax = sp.jmin_basic, sp.jmax_basic
        imin, imax = sp.imin_basic, sp.imax_basic
        function fix_basic(xm, ym, x_axis, y_axis, dx, dy)
            j=trunc(Int, (xm-x_axis[1])/dx)+1;
            i=trunc(Int, (ym-y_axis[1])/dy)+1;
            if j<1
                j=1
            elseif j>Nx-1 
                j=Nx-1
            end
            if i<1 
                i=1
            elseif i>Ny-1
                i=Ny-1
            end
            dxmj=xm-x[j];
            dymi=ym-y[i];
            wtmij=(1-dxmj/dx)*(1-dymi/dy);
            wtmi1j=(1-dxmj/dx)*(dymi/dy);    
            wtmij1=(dxmj/dx)*(1-dymi/dy);
            wtmi1j1=(dxmj/dx)*(dymi/dy);
            return i, j, @SVector [wtmij, wtmi1j, wtmij1, wtmi1j1]
        end
        # top left
        xm = -x[1]
        ym = -y[1]
        @test HydrologyPlanetesimals.fix_weights(
            xm, ym, x, y, dx, dy, jmin, jmax, imin, imax) == fix_basic(
            xm, ym, x, y, dx, dy)
        # bottom left
        xm = x[1]
        ym = y[end]
        @test HydrologyPlanetesimals.fix_weights(
            xm, ym, x, y, dx, dy, jmin, jmax, imin, imax) == fix_basic(
            xm, ym, x, y, dx, dy)
        # top right
        xm = x[end]
        ym = y[1]
        j=trunc(Int, (xm-x[1])/dx)+1;
        i=trunc(Int, (ym-y[1])/dy)+1;
        @test HydrologyPlanetesimals.fix_weights(
            xm, ym, x, y, dx, dy, jmin, jmax, imin, imax) == fix_basic(
            xm, ym, x, y, dx, dy)
        # bottom right
        xm = x[end]
        ym = y[end]
        @test HydrologyPlanetesimals.fix_weights(
            xm, ym, x, y, dx, dy, jmin, jmax, imin, imax) == fix_basic(
            xm, ym, x, y, dx, dy)
        end # testset "basic nodes"

        @testset "Vx nodes" begin
        # from madcph.m, line 434ff
        jmin, jmax = sp.jmin_vx, sp.jmax_vx
        imin, imax = sp.imin_vx, sp.imax_vx
        function fix_vx(xm, ym, x_axis, y_axis, dx, dy)
            j=trunc(Int, (xm-x_axis[1])/dx)+1;
            i=trunc(Int, (ym-y_axis[1])/dy)+1;
            if j<1
                j=1
            elseif j>Nx-1 
                j=Nx-1
            end
            if i<1 
                i=1
            elseif i>Ny
                i=Ny
            end
            dxmj=xm-xvx[j];
            dymi=ym-yvx[i];
            wtmij=(1-dxmj/dx)*(1-dymi/dy);
            wtmi1j=(1-dxmj/dx)*(dymi/dy);    
            wtmij1=(dxmj/dx)*(1-dymi/dy);
            wtmi1j1=(dxmj/dx)*(dymi/dy);
            return i, j, @SVector [wtmij, wtmi1j, wtmij1, wtmi1j1]
        end
        # top left
        xm = -xvx[1]
        ym = -yvx[1]
        @test HydrologyPlanetesimals.fix_weights(
            xm, ym, xvx, yvx, dx, dy, jmin, jmax, imin, imax) == fix_vx(
            xm, ym, xvx, yvx, dx, dy)
        # bottom left
        xm = xvx[1]
        ym = yvx[end]
        @test HydrologyPlanetesimals.fix_weights(
            xm, ym, xvx, yvx, dx, dy, jmin, jmax, imin, imax) == fix_vx(
            xm, ym, xvx, yvx, dx, dy)
        # top right
        xm = xvx[end]
        ym = yvx[1]
        @test HydrologyPlanetesimals.fix_weights(
            xm, ym, xvx, yvx, dx, dy, jmin, jmax, imin, imax) == fix_vx(
            xm, ym, xvx, yvx, dx, dy)
        # bottom right
        xm = xvx[end]
        ym = yvx[end]
        @test HydrologyPlanetesimals.fix_weights(
            xm, ym, xvx, yvx, dx, dy, jmin, jmax, imin, imax) == fix_vx(
            xm, ym, xvx, yvx, dx, dy)
        end # testset "Vx nodes"

        @testset "Vy nodes" begin
        # from madcph.m, line 484ff
        jmin, jmax = sp.jmin_vy, sp.jmax_vy
        imin, imax = sp.imin_vy, sp.imax_vy
        function fix_vy(xm, ym, x_axis, y_axis, dx, dy)
            j=trunc(Int, (xm-x_axis[1])/dx)+1;
            i=trunc(Int, (ym-y_axis[1])/dy)+1;
            if j<1
                j=1
            elseif j>Nx 
                j=Nx
            end
            if i<1 
                i=1
            elseif i>Ny-1
                i=Ny-1
            end
            dxmj=xm-xvy[j];
            dymi=ym-yvy[i];
            wtmij=(1-dxmj/dx)*(1-dymi/dy);
            wtmi1j=(1-dxmj/dx)*(dymi/dy);    
            wtmij1=(dxmj/dx)*(1-dymi/dy);
            wtmi1j1=(dxmj/dx)*(dymi/dy);
            return i, j, @SVector [wtmij, wtmi1j, wtmij1, wtmi1j1]
        end
        # top left
        xm = -xvy[1]
        ym = -yvy[1]
        @test HydrologyPlanetesimals.fix_weights(
            xm, ym, xvy, yvy, dx, dy, jmin, jmax, imin, imax) == fix_vy(
            xm, ym, xvy, yvy, dx, dy)
        # bottom left
        xm = xvy[1]
        ym = yvy[end]
        @test HydrologyPlanetesimals.fix_weights(
            xm, ym, xvy, yvy, dx, dy, jmin, jmax, imin, imax) == fix_vy(
            xm, ym, xvy, yvy, dx, dy)
        # top right
        xm = xvy[end]
        ym = yvy[1]
        @test HydrologyPlanetesimals.fix_weights(
            xm, ym, xvy, yvy, dx, dy, jmin, jmax, imin, imax) == fix_vy(
            xm, ym, xvy, yvy, dx, dy)
        # bottom right
        xm = xvy[end]
        ym = yvy[end]
        @test HydrologyPlanetesimals.fix_weights(
            xm, ym, xvy, yvy, dx, dy, jmin, jmax, imin, imax) == fix_vy(
            xm, ym, xvy, yvy, dx, dy)
        end # testset "Vy nodes"
    
        @testset "P nodes" begin
        # from madcph.m, line 538ff
        jmin, jmax = sp.jmin_p, sp.jmax_p
        imin, imax = sp.imin_p, sp.imax_p
        function fix_p(xm, ym, x_axis, y_axis, dx, dy)
            j=trunc(Int, (xm-x_axis[1])/dx)+1;
            i=trunc(Int, (ym-y_axis[1])/dy)+1;
            if j<1
                j=1
            elseif j>Nx 
                j=Nx
            end
            if i<1 
                i=1
            elseif i>Ny
                i=Ny
            end
            dxmj=xm-xp[j];
            dymi=ym-yp[i];
            wtmij=(1-dxmj/dx)*(1-dymi/dy);
            wtmi1j=(1-dxmj/dx)*(dymi/dy);    
            wtmij1=(dxmj/dx)*(1-dymi/dy);
            wtmi1j1=(dxmj/dx)*(dymi/dy);
            return i, j, @SVector [wtmij, wtmi1j, wtmij1, wtmi1j1]
        end
        # top left
        xm = -xp[1]
        ym = -yp[1]
        @test HydrologyPlanetesimals.fix_weights(
            xm, ym, xp, yp, dx, dy, jmin, jmax, imin, imax) == fix_p(
            xm, ym, xp, yp, dx, dy)
        # bottom left
        xm = xp[1]
        ym = yp[end]
        @test HydrologyPlanetesimals.fix_weights(
            xm, ym, xp, yp, dx, dy, jmin, jmax, imin, imax) == fix_p(
            xm, ym, xp, yp, dx, dy)
        # top right
        xm = xp[end]
        ym = yp[1]
        @test HydrologyPlanetesimals.fix_weights(
            xm, ym, xp, yp, dx, dy, jmin, jmax, imin, imax) == fix_p(
            xm, ym, xp, yp, dx, dy)
        # bottom right
        xm = xp[end]
        ym = yp[end]
        @test HydrologyPlanetesimals.fix_weights(
            xm, ym, xp, yp, dx, dy, jmin, jmax, imin, imax) == fix_p(
            xm, ym, xp, yp, dx, dy)
        end # testset "P nodes"    
    end # testset "fix_weights() elementary"

    @testset "fix_weights() advanced" begin
        sp = HydrologyPlanetesimals.StaticParameters()
        Nx, Ny = sp.Nx, sp.Ny
        dx, dy = sp.dx, sp.dy
        xsize, ysize = sp.xsize, sp.ysize
        # from madcph.m, line 38ff
        # basic nodes
        x=0:dx:xsize
        y=0:dy:ysize
        # Vx nodes
        xvx=0:dx:xsize+dy
        yvx=-dy/2:dy:ysize+dy/2
        # Vy nodes
        xvy=-dx/2:dx:xsize+dx/2
        yvy=0:dy:ysize+dy
        # P Nodes
        xp=-dx/2:dx:xsize+dx/2
        yp=-dy/2:dy:ysize+dy/2
        # simulating markers
        num_markers = 10_000
        @testset "basic nodes" begin
            # from madcph.m, line 373ff
            jmin, jmax = sp.jmin_basic, sp.jmax_basic
            imin, imax = sp.imin_basic, sp.imax_basic
            function fix_basic(xm, ym, x_axis, y_axis, dx, dy)
                j=trunc(Int, (xm-x_axis[1])/dx)+1;
                i=trunc(Int, (ym-y_axis[1])/dy)+1;
                if j<1
                    j=1
                elseif j>Nx-1 
                    j=Nx-1
                end
                if i<1 
                    i=1
                elseif i>Ny-1
                    i=Ny-1
                end
                dxmj=xm-x[j];
                dymi=ym-y[i];
                wtmij=(1-dxmj/dx)*(1-dymi/dy);
                wtmi1j=(1-dxmj/dx)*(dymi/dy);    
                wtmij1=(dxmj/dx)*(1-dymi/dy);
                wtmi1j1=(dxmj/dx)*(dymi/dy);
                return i, j, @SVector [wtmij, wtmi1j, wtmij1, wtmi1j1]
            end
            # simulating markers
            xm = rand(-x[1]:0.1:x[end]+dx, num_markers)
            ym = rand(-y[1]:0.1:y[end]+dy, num_markers)
            for m in 1:num_markers
                i, j, weights = HydrologyPlanetesimals.fix_weights(
                    xm[m],
                    ym[m],
                    x,
                    y,
                    dx,
                    dy,
                    jmin,
                    jmax,
                    imin,
                    imax
                )
                i_ver, j_ver, weights_ver = fix_basic(
                    xm[m], ym[m], x, y, dx, dy)
                @debug "fix_weights basic" i i_ver j j_ver weights weights_ver
                @test i == i_ver
                @test j == j_ver
                @test weights == weights_ver
            end
        end # testset "basic nodes"
        
        @testset "Vx nodes" begin
            # from madcph.m, line 434ff
            jmin, jmax = sp.jmin_vx, sp.jmax_vx
            imin, imax = sp.imin_vx, sp.imax_vx
            function fix_vx(xm, ym, x_axis, y_axis, dx, dy)
                j=trunc(Int, (xm-x_axis[1])/dx)+1;
                i=trunc(Int, (ym-y_axis[1])/dy)+1;
                if j<1
                    j=1
                elseif j>Nx-1 
                    j=Nx-1
                end
                if i<1 
                    i=1
                elseif i>Ny
                    i=Ny
                end
                dxmj=xm-xvx[j];
                dymi=ym-yvx[i];
                wtmij=(1-dxmj/dx)*(1-dymi/dy);
                wtmi1j=(1-dxmj/dx)*(dymi/dy);    
                wtmij1=(dxmj/dx)*(1-dymi/dy);
                wtmi1j1=(dxmj/dx)*(dymi/dy);
                return i, j, @SVector [wtmij, wtmi1j, wtmij1, wtmi1j1]
            end
            # simulating markers
            xm = rand(-xvx[1]:0.1:xvx[end]+dx, num_markers)
            ym = rand(-yvx[1]:0.1:yvx[end]+dy, num_markers)
            for m in 1:num_markers
                i, j, weights = HydrologyPlanetesimals.fix_weights(
                    xm[m],
                    ym[m],
                    xvx,
                    yvx,
                    dx,
                    dy,
                    jmin,
                    jmax,
                    imin,
                    imax
                )
                i_ver, j_ver, weights_ver = fix_vx(
                    xm[m], ym[m], xvx, yvx, dx, dy)
                @debug "fix_weights Vx" i i_ver j j_ver weights weights_ver
                @test i == i_ver
                @test j == j_ver
                @test weights == weights_ver
            end
        end # testset "Vx nodes"

        @testset "Vy nodes" begin
            # from madcph.m, line 484ff
            jmin, jmax = sp.jmin_vy, sp.jmax_vy
            imin, imax = sp.imin_vy, sp.imax_vy
            function fix_vy(xm, ym, x_axis, y_axis, dx, dy)
                j=trunc(Int, (xm-x_axis[1])/dx)+1;
                i=trunc(Int, (ym-y_axis[1])/dy)+1;
                if j<1
                    j=1
                elseif j>Nx 
                    j=Nx
                end
                if i<1 
                    i=1
                elseif i>Ny-1
                    i=Ny-1
                end
                dxmj=xm-xvy[j];
                dymi=ym-yvy[i];
                wtmij=(1-dxmj/dx)*(1-dymi/dy);
                wtmi1j=(1-dxmj/dx)*(dymi/dy);    
                wtmij1=(dxmj/dx)*(1-dymi/dy);
                wtmi1j1=(dxmj/dx)*(dymi/dy);
                return i, j, @SVector [wtmij, wtmi1j, wtmij1, wtmi1j1]
            end
            # simulating markers
            xm = rand(-xvy[1]:0.1:xvy[end]+dx, num_markers)
            ym = rand(-yvy[1]:0.1:yvy[end]+dy, num_markers)
            for m in 1:num_markers
                i, j, weights = HydrologyPlanetesimals.fix_weights(
                    xm[m],
                    ym[m],
                    xvy,
                    yvy,
                    dx,
                    dy,
                    jmin,
                    jmax,
                    imin,
                    imax
                )
                i_ver, j_ver, weights_ver = fix_vy(
                    xm[m], ym[m], xvy, yvy, dx, dy)
                @debug "fix_weights Vy" i i_ver j j_ver weights weights_ver
                @test i == i_ver
                @test j == j_ver
                @test weights == weights_ver
            end
        end # testset "Vy nodes"
    
        @testset "P nodes" begin
            # from madcph.m, line 538ff
            jmin, jmax = sp.jmin_p, sp.jmax_p
            imin, imax = sp.imin_p, sp.imax_p
            function fix_p(xm, ym, x_axis, y_axis, dx, dy)
                j=trunc(Int, (xm-x_axis[1])/dx)+1;
                i=trunc(Int, (ym-y_axis[1])/dy)+1;
                if j<1
                    j=1
                elseif j>Nx 
                    j=Nx
                end
                if i<1 
                    i=1
                elseif i>Ny
                    i=Ny
                end
                dxmj=xm-xp[j];
                dymi=ym-yp[i];
                wtmij=(1-dxmj/dx)*(1-dymi/dy);
                wtmi1j=(1-dxmj/dx)*(dymi/dy);    
                wtmij1=(dxmj/dx)*(1-dymi/dy);
                wtmi1j1=(dxmj/dx)*(dymi/dy);
                return i, j, @SVector [wtmij, wtmi1j, wtmij1, wtmi1j1]
            end
            # simulating markers
            xm = rand(-xp[1]:0.1:xp[end]+dx, num_markers)
            ym = rand(-yp[1]:0.1:yp[end]+dy, num_markers)
            for m in 1:num_markers
                i, j, weights = HydrologyPlanetesimals.fix_weights(
                    xm[m],
                    ym[m],
                    xp,
                    yp,
                    dx,
                    dy,
                    jmin,
                    jmax,
                    imin,
                    imax
                )
                i_ver, j_ver, weights_ver = fix_p(
                    xm[m], ym[m], xp, yp, dx, dy)
                @debug "fix_weights P" xm[m] ym[m] i i_ver j j_ver
                @test i == i_ver
                @test j == j_ver
                @test weights == weights_ver
            end
        end # testset "P nodes"    
    end # testset "fix_weights() advanced"
   
    @testset "interpolate!()" begin
        sp = HydrologyPlanetesimals.StaticParameters()
        Nx, Ny = sp.Nx, sp.Ny
        dx, dy = sp.dx, sp.dy
        xsize, ysize = sp.xsize, sp.ysize
        jmin, jmax = sp.jmin_basic, sp.jmax_basic
        imin, imax = sp.imin_basic, sp.imax_basic
        x=0:dx:xsize
        y=0:dy:ysize
        # simulate markers
        num_markers = 10_000
        xm = rand(-x[1]:0.1:x[end]+dx, num_markers)
        ym = rand(-y[1]:0.1:y[end]+dy, num_markers)
        property = rand(num_markers)
        # sample interpolation array
        for m=1:1:num_markers
            grid = zeros(Ny, Nx, Base.Threads.nthreads())
            i, j, weights = HydrologyPlanetesimals.fix_weights(
                xm[m], ym[m], x, y, dx, dy, jmin, jmax, imin, imax)
            HydrologyPlanetesimals.interpolate!(
                i, j, weights, property[m], grid)
            @test grid[i, j] == property[m] * weights[1] 
            @test grid[i+1, j] == property[m] * weights[2]
            @test grid[i, j+1] == property[m] * weights[3]
            @test grid[i+1, j+1] == property[m] * weights[4]
        end
    end # testset "interpolate!()"

    @testset "compute node properties" begin
        sp = HydrologyPlanetesimals.StaticParameters()
        Nx, Ny = sp.Nx, sp.Ny
        Nx1, Ny1 = sp.Nx1, sp.Ny1
        dx, dy = sp.dx, sp.dy
        xsize, ysize = sp.xsize, sp.ysize
        # from madcph.m, line 38ff
        # basic nodes
        x=0:dx:xsize
        y=0:dy:ysize
        # Vx nodes
        xvx=0:dx:xsize+dy
        yvx=-dy/2:dy:ysize+dy/2
        # Vy nodes
        xvy=-dx/2:dx:xsize+dx/2
        yvy=0:dy:ysize+dy
        # P Nodes
        xp=-dx/2:dx:xsize+dx/2
        yp=-dy/2:dy:ysize+dy/2
        # simulating markers
        num_markers = 10_000
        @testset "compute_basic_node_properties!()" begin    
            jmin, jmax = sp.jmin_basic, sp.jmax_basic
            imin, imax = sp.imin_basic, sp.imax_basic
            ETA0SUM = zeros(Ny, Nx, Base.Threads.nthreads())
            ETASUM = zeros(Ny, Nx, Base.Threads.nthreads())
            GGGSUM = zeros(Ny, Nx, Base.Threads.nthreads())
            SXYSUM = zeros(Ny, Nx, Base.Threads.nthreads())
            COHSUM = zeros(Ny, Nx, Base.Threads.nthreads())
            TENSUM = zeros(Ny, Nx, Base.Threads.nthreads())
            FRISUM = zeros(Ny, Nx, Base.Threads.nthreads())
            WTSUM = zeros(Ny, Nx, Base.Threads.nthreads())
            ETA0 = zeros(Float64, Ny, Nx)
            ETA = zeros(Float64, Ny, Nx)
            GGG = zeros(Float64, Ny, Nx)
            SXY0 = zeros(Float64, Ny, Nx)
            COH = zeros(Float64, Ny, Nx)
            TEN = zeros(Float64, Ny, Nx)
            FRI = zeros(Float64, Ny, Nx)
            YNY = zeros(Bool, Ny, Nx)
            ETA0SUM_ver = zeros(Ny, Nx, Base.Threads.nthreads())
            ETASUM_ver = zeros(Ny, Nx, Base.Threads.nthreads())
            GGGSUM_ver = zeros(Ny, Nx, Base.Threads.nthreads())
            SXYSUM_ver = zeros(Ny, Nx, Base.Threads.nthreads())
            COHSUM_ver = zeros(Ny, Nx, Base.Threads.nthreads())
            TENSUM_ver = zeros(Ny, Nx, Base.Threads.nthreads())
            FRISUM_ver = zeros(Ny, Nx, Base.Threads.nthreads())
            WTSUM_ver = zeros(Ny, Nx, Base.Threads.nthreads())
            ETA0_ver = zeros(Float64, Ny, Nx)
            ETA_ver = zeros(Float64, Ny, Nx)
            GGG_ver = zeros(Float64, Ny, Nx)
            SXY0_ver = zeros(Float64, Ny, Nx)
            COH_ver = zeros(Float64, Ny, Nx)
            TEN_ver = zeros(Float64, Ny, Nx)
            FRI_ver = zeros(Float64, Ny, Nx)
            YNY_ver = zeros(Bool, Ny, Nx)
            # simulate markers
            xm = rand(-x[1]:0.1:x[end]+dx, num_markers)
            ym = rand(-y[1]:0.1:y[end]+dy, num_markers)
            property = rand(7, num_markers)
            # calculate grid properties
            for m=1:1:num_markers
                i, j, weights = HydrologyPlanetesimals.fix_weights(
                    xm[m], ym[m], x, y, dx, dy, jmin, jmax, imin, imax)
                HydrologyPlanetesimals.interpolate!(
                    i, j, weights, property[1, m], ETA0SUM)
                HydrologyPlanetesimals.interpolate!(
                    i, j, weights, property[2, m], ETASUM)
                HydrologyPlanetesimals.interpolate!(
                    i, j, weights, inv(property[3, m]), GGGSUM)
                HydrologyPlanetesimals.interpolate!(
                    i, j, weights, property[4, m], SXYSUM)
                HydrologyPlanetesimals.interpolate!(
                    i, j, weights, property[5, m], COHSUM)
                HydrologyPlanetesimals.interpolate!(
                    i, j, weights, property[6, m], TENSUM)
                HydrologyPlanetesimals.interpolate!(
                    i, j, weights, property[7, m], FRISUM)
                HydrologyPlanetesimals.interpolate!(
                    i, j, weights, 1.0, WTSUM)
            end
            HydrologyPlanetesimals.compute_basic_node_properties!(
                ETA0SUM,
                ETASUM,
                GGGSUM,
                SXYSUM,
                COHSUM,
                TENSUM,
                FRISUM,
                WTSUM,
                ETA0,
                ETA,
                GGG,
                SXY0,
                COH,
                TEN,
                FRI,
                YNY
            )
            # verification properties, from madcph.m, lines 373ff, 606ff
            for m=1:1:num_markers
                j=trunc(Int, (xm[m]-x[1])/dx)+1
                i=trunc(Int, (ym[m]-y[1])/dy)+1
                if j<1
                    j=1
                elseif j>Nx-1
                    j=Nx-1
                end
                if i<1
                    i=1
                elseif i>Ny-1 
                    i=Ny-1
                end
                # Compute distances
                dxmj=xm[m]-x[j]
                dymi=ym[m]-y[i]
                # Compute weights
                wtmij=(1-dxmj/dx)*(1-dymi/dy)
                wtmi1j=(1-dxmj/dx)*(dymi/dy);    
                wtmij1=(dxmj/dx)*(1-dymi/dy)
                wtmi1j1=(dxmj/dx)*(dymi/dy)
                # Update properties
                # i;j Node
                ETA0SUM_ver[i,j]=ETA0SUM_ver[i,j]+property[1,m]*wtmij
                ETASUM_ver[i,j]=ETASUM_ver[i,j]+property[2,m]*wtmij
                GGGSUM_ver[i,j]=GGGSUM_ver[i,j]+1/property[3,m]*wtmij
                SXYSUM_ver[i,j]=SXYSUM_ver[i,j]+property[4,m]*wtmij
                COHSUM_ver[i,j]=COHSUM_ver[i,j]+property[5,m]*wtmij
                TENSUM_ver[i,j]=TENSUM_ver[i,j]+property[6,m]*wtmij
                FRISUM_ver[i,j]=FRISUM_ver[i,j]+property[7,m]*wtmij
                WTSUM_ver[i,j]=WTSUM_ver[i,j]+wtmij
                # i+1;j Node
                ETA0SUM_ver[i+1,j]=ETA0SUM_ver[i+1,j]+property[1,m]*wtmi1j
                ETASUM_ver[i+1,j]=ETASUM_ver[i+1,j]+property[2,m]*wtmi1j
                GGGSUM_ver[i+1,j]=GGGSUM_ver[i+1,j]+1/property[3,m]*wtmi1j
                SXYSUM_ver[i+1,j]=SXYSUM_ver[i+1,j]+property[4,m]*wtmi1j
                COHSUM_ver[i+1,j]=COHSUM_ver[i+1,j]+property[5,m]*wtmi1j
                TENSUM_ver[i+1,j]=TENSUM_ver[i+1,j]+property[6,m]*wtmi1j
                FRISUM_ver[i+1,j]=FRISUM_ver[i+1,j]+property[7,m]*wtmi1j
                WTSUM_ver[i+1,j]=WTSUM_ver[i+1,j]+wtmi1j
                # i;j+1 Node
                ETA0SUM_ver[i,j+1]=ETA0SUM_ver[i,j+1]+property[1,m]*wtmij1
                ETASUM_ver[i,j+1]=ETASUM_ver[i,j+1]+property[2,m]*wtmij1
                GGGSUM_ver[i,j+1]=GGGSUM_ver[i,j+1]+1/property[3,m]*wtmij1
                SXYSUM_ver[i,j+1]=SXYSUM_ver[i,j+1]+property[4,m]*wtmij1
                COHSUM_ver[i,j+1]=COHSUM_ver[i,j+1]+property[5,m]*wtmij1
                TENSUM_ver[i,j+1]=TENSUM_ver[i,j+1]+property[6,m]*wtmij1
                FRISUM_ver[i,j+1]=FRISUM_ver[i,j+1]+property[7,m]*wtmij1
                WTSUM_ver[i,j+1]=WTSUM_ver[i,j+1]+wtmij1
                # i+1;j+1 Node
                ETA0SUM_ver[i+1,j+1]=ETA0SUM_ver[i+1,j+1]+property[1,m]*wtmi1j1
                ETASUM_ver[i+1,j+1]=ETASUM_ver[i+1,j+1]+property[2,m]*wtmi1j1
                GGGSUM_ver[i+1,j+1]=GGGSUM_ver[i+1,j+1]+1/property[3,m]*wtmi1j1
                SXYSUM_ver[i+1,j+1]=SXYSUM_ver[i+1,j+1]+property[4,m]*wtmi1j1
                COHSUM_ver[i+1,j+1]=COHSUM_ver[i+1,j+1]+property[5,m]*wtmi1j1
                TENSUM_ver[i+1,j+1]=TENSUM_ver[i+1,j+1]+property[6,m]*wtmi1j1
                FRISUM_ver[i+1,j+1]=FRISUM_ver[i+1,j+1]+property[7,m]*wtmi1j1
                WTSUM_ver[i+1,j+1]=WTSUM_ver[i+1,j+1]+wtmi1j1
            end
            for j=1:1:Nx
                for i=1:1:Ny
                    if WTSUM_ver[i,j]>0 
                        ETA0_ver[i,j]=ETA0SUM_ver[i,j]/WTSUM_ver[i,j]
                        ETA_ver[i,j]=ETASUM_ver[i,j]/WTSUM_ver[i,j]
                        if(ETA_ver[i,j]<ETA0_ver[i,j])
                            YNY_ver[i,j]=1
                        end
                        GGG_ver[i,j]=1/(GGGSUM_ver[i,j]/WTSUM_ver[i,j])
                        SXY0_ver[i,j]=SXYSUM_ver[i,j]/WTSUM_ver[i,j]
                        COH_ver[i,j]=COHSUM_ver[i,j]/WTSUM_ver[i,j]
                        TEN_ver[i,j]=TENSUM_ver[i,j]/WTSUM_ver[i,j]
                        FRI_ver[i,j]=FRISUM_ver[i,j]/WTSUM_ver[i,j]
                    end
                end
            end 
            # test
            for j=1:1:Nx, i=1:1:Ny
                @test ETA0[i, j] == ETA0_ver[i, j]
                @test ETA[i, j] == ETA_ver[i, j]
                @test GGG[i, j] ≈ GGG_ver[i, j]
                @test SXY0[i, j] == SXY0_ver[i, j]
                @test COH[i, j] == COH_ver[i, j]
                @test TEN[i, j] == TEN_ver[i, j]
                @test FRI[i, j] == FRI_ver[i, j]
                @test YNY[i, j] == YNY_ver[i, j]
            end
        end # testset "compute_basic_node_properties!()"

        @testset "compute_vx_node_properties!()" begin
            jmin, jmax = sp.jmin_vx, sp.jmax_vx
            imin, imax = sp.imin_vx, sp.imax_vx 
            RHOXSUM = zeros(Ny1, Nx1, Base.Threads.nthreads())
            RHOFXSUM = zeros(Ny1, Nx1, Base.Threads.nthreads())
            KXSUM = zeros(Ny1, Nx1, Base.Threads.nthreads())
            PHIXSUM = zeros(Ny1, Nx1, Base.Threads.nthreads())
            RXSUM = zeros(Ny1, Nx1, Base.Threads.nthreads())
            WTXSUM = zeros(Ny1, Nx1, Base.Threads.nthreads())
            RHOX = zeros(Float64, Ny1, Nx1)
            RHOFX = zeros(Float64, Ny1, Nx1)
            KX = zeros(Float64, Ny1, Nx1)
            PHIX = zeros(Float64, Ny1, Nx1)
            RX = zeros(Float64, Ny1, Nx1)
            RHOXSUM_ver = zeros(Ny1, Nx1)
            RHOFXSUM_ver = zeros(Ny1, Nx1)
            KXSUM_ver = zeros(Ny1, Nx1)
            PHIXSUM_ver = zeros(Ny1, Nx1)
            RXSUM_ver = zeros(Ny1, Nx1)
            WTXSUM_ver = zeros(Ny1, Nx1)
            RHOX_ver = zeros(Float64, Ny1, Nx1)
            RHOFX_ver = zeros(Float64, Ny1, Nx1)
            KX_ver = zeros(Float64, Ny1, Nx1)
            PHIX_ver = zeros(Float64, Ny1, Nx1)
            RX_ver = zeros(Float64, Ny1, Nx1)
            # simulate markers
            xm = rand(-xvx[1]:0.1:xvx[end]+dx, num_markers)
            ym = rand(-yvx[1]:0.1:yvx[end]+dy, num_markers)
            property = rand(5, num_markers)
            # calculate grid properties
            for m=1:1:num_markers
                i, j, weights = HydrologyPlanetesimals.fix_weights(
                    xm[m], ym[m], xvx, yvx, dx, dy, jmin, jmax, imin, imax)
                HydrologyPlanetesimals.interpolate!(
                    i, j, weights, property[1, m], RHOXSUM)
                HydrologyPlanetesimals.interpolate!(
                    i, j, weights, property[2, m], RHOFXSUM)
                HydrologyPlanetesimals.interpolate!(
                    i, j, weights, property[3, m], KXSUM)
                HydrologyPlanetesimals.interpolate!(
                    i, j, weights, property[4, m], PHIXSUM)
                HydrologyPlanetesimals.interpolate!(
                    i, j, weights, property[5, m], RXSUM)
                HydrologyPlanetesimals.interpolate!(
                    i, j, weights, 1.0, WTXSUM)
            end
            HydrologyPlanetesimals.compute_vx_node_properties!(
                RHOXSUM,
                RHOFXSUM,
                KXSUM,
                PHIXSUM,
                RXSUM,
                WTXSUM,
                RHOX,
                RHOFX,
                KX,
                PHIX,
                RX
            )
            # verification properties, from madcph.m, lines 434ff, 624ff
            for m=1:1:num_markers
                j=trunc(Int, (xm[m]-xvx[1])/dx)+1
                i=trunc(Int, (ym[m]-yvx[1])/dy)+1
                if j<1
                    j=1
                elseif j>Nx-1
                    j=Nx-1
                end
                if(i<1)
                    i=1
                elseif i>Ny
                    i=Ny
                end
                # Compute distances
                dxmj=xm[m]-xvx[j]
                dymi=ym[m]-yvx[i]
                # Compute weights
                wtmij=(1-dxmj/dx)*(1-dymi/dy)
                wtmi1j=(1-dxmj/dx)*(dymi/dy);    
                wtmij1=(dxmj/dx)*(1-dymi/dy)
                wtmi1j1=(dxmj/dx)*(dymi/dy)
                # Update properties
                # i;j Node
                RHOXSUM_ver[i,j]=RHOXSUM_ver[i,j]+property[1, m]*wtmij
                RHOFXSUM_ver[i,j]=RHOFXSUM_ver[i,j]+property[2, m]*wtmij
                KXSUM_ver[i,j]=KXSUM_ver[i,j]+property[3, m]*wtmij
                PHIXSUM_ver[i,j]=PHIXSUM_ver[i,j]+property[4, m]*wtmij
                RXSUM_ver[i,j]=RXSUM_ver[i,j]+property[5, m]*wtmij
                WTXSUM_ver[i,j]=WTXSUM_ver[i,j]+wtmij
                # i+1;j Node
                RHOXSUM_ver[i+1,j]=RHOXSUM_ver[i+1,j]+property[1, m]*wtmi1j
                RHOFXSUM_ver[i+1,j]=RHOFXSUM_ver[i+1,j]+property[2, m]*wtmi1j
                KXSUM_ver[i+1,j]=KXSUM_ver[i+1,j]+property[3, m]*wtmi1j
                PHIXSUM_ver[i+1,j]=PHIXSUM_ver[i+1,j]+property[4, m]*wtmi1j
                RXSUM_ver[i+1,j]=RXSUM_ver[i+1,j]+property[5, m]*wtmi1j
                WTXSUM_ver[i+1,j]=WTXSUM_ver[i+1,j]+wtmi1j
                # i;j+1 Node
                RHOXSUM_ver[i,j+1]=RHOXSUM_ver[i,j+1]+property[1, m]*wtmij1
                RHOFXSUM_ver[i,j+1]=RHOFXSUM_ver[i,j+1]+property[2, m]*wtmij1
                KXSUM_ver[i,j+1]=KXSUM_ver[i,j+1]+property[3, m]*wtmij1
                PHIXSUM_ver[i,j+1]=PHIXSUM_ver[i,j+1]+property[4, m]*wtmij1
                RXSUM_ver[i,j+1]=RXSUM_ver[i,j+1]+property[5, m]*wtmij1
                WTXSUM_ver[i,j+1]=WTXSUM_ver[i,j+1]+wtmij1
                # i+1;j+1 Node
                RHOXSUM_ver[i+1,j+1]=RHOXSUM_ver[i+1,j+1]+property[1, m]*wtmi1j1
                RHOFXSUM_ver[i+1,j+1]=RHOFXSUM_ver[i+1,j+1]+property[2, m]*wtmi1j1
                KXSUM_ver[i+1,j+1]=KXSUM_ver[i+1,j+1]+property[3, m]*wtmi1j1
                PHIXSUM_ver[i+1,j+1]=PHIXSUM_ver[i+1,j+1]+property[4, m]*wtmi1j1
                RXSUM_ver[i+1,j+1]=RXSUM_ver[i+1,j+1]+property[5, m]*wtmi1j1
                WTXSUM_ver[i+1,j+1]=WTXSUM_ver[i+1,j+1]+wtmi1j1
            end
            for j=1:1:Nx1
                for i=1:1:Ny1
                    if(WTXSUM_ver[i,j]>0)
                        RHOX_ver[i,j]=RHOXSUM_ver[i,j]/WTXSUM_ver[i,j]
                        RHOFX_ver[i,j]=RHOFXSUM_ver[i,j]/WTXSUM_ver[i,j]
                        KX_ver[i,j]=KXSUM_ver[i,j]/WTXSUM_ver[i,j]
                        PHIX_ver[i,j]=PHIXSUM_ver[i,j]/WTXSUM_ver[i,j]
                        RX_ver[i,j]=RXSUM_ver[i,j]/WTXSUM_ver[i,j]
                    end
                end
            end
            # test
            for j=1:1:Nx1, i=1:1:Ny1
                @test RHOX[i, j] == RHOX_ver[i, j]
                @test RHOFX[i, j] == RHOFX_ver[i, j]
                @test KX[i, j] == KX_ver[i, j]
                @test PHIX[i, j] == PHIX_ver[i, j]
                @test RX[i, j] == RX_ver[i, j]
            end
        end # testset "compute_vx_node_properties!()"

        @testset "compute_vy_node_properties!()" begin
            jmin, jmax = sp.jmin_vy, sp.jmax_vy
            imin, imax = sp.imin_vy, sp.imax_vy
            RHOYSUM = zeros(Ny1, Nx1, Base.Threads.nthreads())
            RHOFYSUM = zeros(Ny1, Nx1, Base.Threads.nthreads())
            KYSUM = zeros(Ny1, Nx1, Base.Threads.nthreads())
            PHIYSUM = zeros(Ny1, Nx1, Base.Threads.nthreads())
            RYSUM = zeros(Ny1, Nx1, Base.Threads.nthreads())
            WTYSUM = zeros(Ny1, Nx1, Base.Threads.nthreads())
            RHOY = zeros(Float64, Ny1, Nx1)
            RHOFY = zeros(Float64, Ny1, Nx1)
            KY = zeros(Float64, Ny1, Nx1)
            PHIY = zeros(Float64, Ny1, Nx1)
            RY = zeros(Float64, Ny1, Nx1)
            RHOYSUM_ver = zeros(Ny1, Nx1, Base.Threads.nthreads())
            RHOFYSUM_ver = zeros(Ny1, Nx1, Base.Threads.nthreads())
            KYSUM_ver = zeros(Ny1, Nx1, Base.Threads.nthreads())
            PHIYSUM_ver = zeros(Ny1, Nx1, Base.Threads.nthreads())
            RYSUM_ver = zeros(Ny1, Nx1, Base.Threads.nthreads())
            WTYSUM_ver = zeros(Ny1, Nx1, Base.Threads.nthreads())
            RHOY_ver = zeros(Float64, Ny1, Nx1)
            RHOFY_ver = zeros(Float64, Ny1, Nx1)
            KY_ver = zeros(Float64, Ny1, Nx1)
            PHIY_ver = zeros(Float64, Ny1, Nx1)
            RY_ver = zeros(Float64, Ny1, Nx1)
            # simulate markers
            xm = rand(-xvy[1]:0.1:xvy[end]+dx, num_markers)
            ym = rand(-yvy[1]:0.1:yvy[end]+dy, num_markers)
            property = rand(5, num_markers)
            # calculate grid properties
            for m=1:1:num_markers
                i, j, weights = HydrologyPlanetesimals.fix_weights(
                    xm[m], ym[m], xvy, yvy, dx, dy, jmin, jmax, imin, imax)
                HydrologyPlanetesimals.interpolate!(
                    i, j, weights, property[1, m], RHOYSUM)
                HydrologyPlanetesimals.interpolate!(
                    i, j, weights, property[2, m], RHOFYSUM)
                HydrologyPlanetesimals.interpolate!(
                    i, j, weights, property[3, m], KYSUM)
                HydrologyPlanetesimals.interpolate!(
                    i, j, weights, property[4, m], PHIYSUM)
                HydrologyPlanetesimals.interpolate!(
                    i, j, weights, property[5, m], RYSUM)
                HydrologyPlanetesimals.interpolate!(
                    i, j, weights, 1.0, WTYSUM)
            end
            HydrologyPlanetesimals.compute_vy_node_properties!(
                RHOYSUM,
                RHOFYSUM,
                KYSUM,
                PHIYSUM,
                RYSUM,
                WTYSUM,
                RHOY,
                RHOFY,
                KY,
                PHIY,
                RY
            )
            # verification properties, from madcph.m, lines 486ff, 636ff
            for m=1:1:num_markers
                j=trunc(Int, (xm[m]-xvy[1])/dx)+1
                i=trunc(Int, (ym[m]-yvy[1])/dy)+1
                if j<1 
                    j=1
                elseif j>Nx 
                    j=Nx
                end
                if i<1 
                    i=1
                elseif i>Ny-1 
                    i=Ny-1
                end
                # Compute distances
                dxmj=xm[m]-xvy[j]
                dymi=ym[m]-yvy[i]
                # Compute weights
                wtmij=(1-dxmj/dx)*(1-dymi/dy)
                wtmi1j=(1-dxmj/dx)*(dymi/dy);    
                wtmij1=(dxmj/dx)*(1-dymi/dy)
                wtmi1j1=(dxmj/dx)*(dymi/dy)
                # Update properties
                # i;j Node
                RHOYSUM_ver[i,j]=RHOYSUM_ver[i,j]+property[1, m]*wtmij
                RHOFYSUM_ver[i,j]=RHOFYSUM_ver[i,j]+property[2, m]*wtmij
                KYSUM_ver[i,j]=KYSUM_ver[i,j]+property[3, m]*wtmij
                PHIYSUM_ver[i,j]=PHIYSUM_ver[i,j]+property[4, m]*wtmij
                RYSUM_ver[i,j]=RYSUM_ver[i,j]+property[5, m]*wtmij
                WTYSUM_ver[i,j]=WTYSUM_ver[i,j]+wtmij
                # i+1;j Node
                RHOYSUM_ver[i+1,j]=RHOYSUM_ver[i+1,j]+property[1, m]*wtmi1j
                RHOFYSUM_ver[i+1,j]=RHOFYSUM_ver[i+1,j]+property[2, m]*wtmi1j
                KYSUM_ver[i+1,j]=KYSUM_ver[i+1,j]+property[3, m]*wtmi1j
                PHIYSUM_ver[i+1,j]=PHIYSUM_ver[i+1,j]+property[4, m]*wtmi1j
                RYSUM_ver[i+1,j]=RYSUM_ver[i+1,j]+property[5, m]*wtmi1j
                WTYSUM_ver[i+1,j]=WTYSUM_ver[i+1,j]+wtmi1j
                # i;j+1 Node
                RHOYSUM_ver[i,j+1]=RHOYSUM_ver[i,j+1]+property[1, m]*wtmij1
                RHOFYSUM_ver[i,j+1]=RHOFYSUM_ver[i,j+1]+property[2, m]*wtmij1
                KYSUM_ver[i,j+1]=KYSUM_ver[i,j+1]+property[3, m]*wtmij1
                PHIYSUM_ver[i,j+1]=PHIYSUM_ver[i,j+1]+property[4, m]*wtmij1
                RYSUM_ver[i,j+1]=RYSUM_ver[i,j+1]+property[5, m]*wtmij1
                WTYSUM_ver[i,j+1]=WTYSUM_ver[i,j+1]+wtmij1
                # i+1;j+1 Node
                RHOYSUM_ver[i+1,j+1]=RHOYSUM_ver[i+1,j+1]+property[1, m]*wtmi1j1
                RHOFYSUM_ver[i+1,j+1]=RHOFYSUM_ver[i+1,j+1]+property[2, m]*wtmi1j1
                KYSUM_ver[i+1,j+1]=KYSUM_ver[i+1,j+1]+property[3, m]*wtmi1j1
                PHIYSUM_ver[i+1,j+1]=PHIYSUM_ver[i+1,j+1]+property[4, m]*wtmi1j1
                RYSUM_ver[i+1,j+1]=RYSUM_ver[i+1,j+1]+property[5, m]*wtmi1j1
                WTYSUM_ver[i+1,j+1]=WTYSUM_ver[i+1,j+1]+wtmi1j1
            end
            for j=1:1:Nx1
                for i=1:1:Ny1
                    if WTYSUM_ver[i,j]>0 
                        RHOY_ver[i,j]=RHOYSUM_ver[i,j]/WTYSUM_ver[i,j]
                        RHOFY_ver[i,j]=RHOFYSUM_ver[i,j]/WTYSUM_ver[i,j]
                        KY_ver[i,j]=KYSUM_ver[i,j]/WTYSUM_ver[i,j]
                        PHIY_ver[i,j]=PHIYSUM_ver[i,j]/WTYSUM_ver[i,j]
                        RY_ver[i,j]=RYSUM_ver[i,j]/WTYSUM_ver[i,j]
                    end
                end
            end
            #test
            for j=1:1:Nx1, i=1:1:Ny1
                @test RHOY[i,j] == RHOY_ver[i,j]
                @test RHOFY[i,j] == RHOFY_ver[i,j]
                @test KY[i,j] == KY_ver[i,j]
                @test PHIY[i,j] == PHIY_ver[i,j]
                @test RY[i,j] == RY_ver[i,j]
            end
        end # testset "compute_vy_node_properties!()"

        @testset "compute_p_node_properties!()" begin
            jmin, jmax = sp.jmin_p, sp.jmax_p
            imin, imax = sp.imin_p, sp.imax_p
            RHOSUM = zeros(Ny1, Nx1, Base.Threads.nthreads())
            RHOCPSUM = zeros(Ny1, Nx1, Base.Threads.nthreads())
            ALPHASUM = zeros(Ny1, Nx1, Base.Threads.nthreads())
            ALPHAFSUM = zeros(Ny1, Nx1, Base.Threads.nthreads())
            HRSUM = zeros(Ny1, Nx1, Base.Threads.nthreads())
            GGGPSUM = zeros(Ny1, Nx1, Base.Threads.nthreads())
            SXXSUM = zeros(Ny1, Nx1, Base.Threads.nthreads())
            TKSUM = zeros(Ny1, Nx1, Base.Threads.nthreads())
            PHISUM = zeros(Ny1, Nx1, Base.Threads.nthreads())
            WTPSUM = zeros(Ny1, Nx1, Base.Threads.nthreads())
            RHO = zeros(Float64, Ny1, Nx1)
            RHOCP = zeros(Float64, Ny1, Nx1)
            ALPHA = zeros(Float64, Ny1, Nx1)
            ALPHAF = zeros(Float64, Ny1, Nx1)
            HR = zeros(Float64, Ny1, Nx1)
            GGGP = zeros(Float64, Ny1, Nx1)
            SXX0 = zeros(Float64, Ny1, Nx1)
            tk1 = zeros(Float64, Ny1, Nx1)
            PHI = zeros(Float64, Ny1, Nx1)
            BETTAPHI = zeros(Float64, Ny1, Nx1)
            RHOSUM_ver = zeros(Ny1, Nx1, Base.Threads.nthreads())
            RHOCPSUM_ver = zeros(Ny1, Nx1, Base.Threads.nthreads())
            ALPHASUM_ver = zeros(Ny1, Nx1, Base.Threads.nthreads())
            ALPHAFSUM_ver = zeros(Ny1, Nx1, Base.Threads.nthreads())
            HRSUM_ver = zeros(Ny1, Nx1, Base.Threads.nthreads())
            GGGPSUM_ver = zeros(Ny1, Nx1, Base.Threads.nthreads())
            SXXSUM_ver = zeros(Ny1, Nx1, Base.Threads.nthreads())
            TKSUM_ver = zeros(Ny1, Nx1, Base.Threads.nthreads())
            PHISUM_ver = zeros(Ny1, Nx1, Base.Threads.nthreads())
            WTPSUM_ver = zeros(Ny1, Nx1, Base.Threads.nthreads())
            RHO_ver = zeros(Float64, Ny1, Nx1)
            RHOCP_ver = zeros(Float64, Ny1, Nx1)
            ALPHA_ver = zeros(Float64, Ny1, Nx1)
            ALPHAF_ver = zeros(Float64, Ny1, Nx1)
            HR_ver = zeros(Float64, Ny1, Nx1)
            GGGP_ver = zeros(Float64, Ny1, Nx1)
            SXX0_ver = zeros(Float64, Ny1, Nx1)
            tk1_ver = zeros(Float64, Ny1, Nx1)
            PHI_ver = zeros(Float64, Ny1, Nx1)
            BETTAPHI_ver = zeros(Float64, Ny1, Nx1)
            # simulate markers
            xm = rand(-xp[1]:0.1:xp[end]+dx, num_markers)
            ym = rand(-yp[1]:0.1:yp[end]+dy, num_markers)
            property = rand(9, num_markers)
            # calculate grid properties
            for m=1:1:num_markers
                i, j, weights = HydrologyPlanetesimals.fix_weights(
                    xm[m], ym[m], xp, yp, dx, dy, jmin, jmax, imin, imax)
                HydrologyPlanetesimals.interpolate!(
                    i, j, weights, property[1, m], RHOSUM)
                HydrologyPlanetesimals.interpolate!(
                    i, j, weights, property[2, m], RHOCPSUM)
                HydrologyPlanetesimals.interpolate!(
                    i, j, weights, property[3, m], ALPHASUM)
                HydrologyPlanetesimals.interpolate!(
                    i, j, weights, property[4, m], ALPHAFSUM)
                HydrologyPlanetesimals.interpolate!(
                    i, j, weights, property[5, m], HRSUM)
                HydrologyPlanetesimals.interpolate!(
                    i, j, weights, inv(property[6, m]), GGGPSUM)
                HydrologyPlanetesimals.interpolate!(
                    i, j, weights, property[7, m], SXXSUM)
                HydrologyPlanetesimals.interpolate!(
                    i, j, weights, property[2, m] * property[8, m], TKSUM)
                HydrologyPlanetesimals.interpolate!(
                    i, j, weights, property[9, m], PHISUM)
                HydrologyPlanetesimals.interpolate!(
                    i, j, weights, 1.0, WTPSUM)
            end
            HydrologyPlanetesimals.compute_p_node_properties!(
                RHOSUM,
                RHOCPSUM,
                ALPHASUM,
                ALPHAFSUM,
                HRSUM,
                GGGPSUM,
                SXXSUM,
                TKSUM,
                PHISUM,
                WTPSUM,
                RHO,
                RHOCP,
                ALPHA,
                ALPHAF,
                HR,
                GGGP,
                SXX0,
                tk1,
                PHI,
                BETTAPHI
            )
            # verification properties, from madcph.m, lines 538ff, 648ff
            for m=1:1:num_markers
                j=trunc(Int, (xm[m]-xp[1])/dx)+1
                i=trunc(Int, (ym[m]-yp[1])/dy)+1
                if j<1 
                    j=1
                elseif j>Nx
                    j=Nx
                end
                if i<1 
                    i=1
                elseif i>Ny 
                    i=Ny
                end
                # Compute distances
                dxmj=xm[m]-xp[j]
                dymi=ym[m]-yp[i]
                # Compute weights
                wtmij=(1-dxmj/dx)*(1-dymi/dy)
                wtmi1j=(1-dxmj/dx)*(dymi/dy);    
                wtmij1=(dxmj/dx)*(1-dymi/dy)
                wtmi1j1=(dxmj/dx)*(dymi/dy)
                # Update properties
                # i;j Node
                GGGPSUM_ver[i,j]=GGGPSUM_ver[i,j]+1/property[6, m]*wtmij
                SXXSUM_ver[i,j]=SXXSUM_ver[i,j]+property[7, m]*wtmij
                RHOSUM_ver[i,j]=RHOSUM_ver[i,j]+property[1, m]*wtmij
                RHOCPSUM_ver[i,j]=RHOCPSUM_ver[i,j]+property[2, m]*wtmij
                ALPHASUM_ver[i,j]=ALPHASUM_ver[i,j]+property[3, m]*wtmij
                ALPHAFSUM_ver[i,j]=ALPHAFSUM_ver[i,j]+property[4, m]*wtmij
                HRSUM_ver[i,j]=HRSUM_ver[i,j]+property[5, m]*wtmij
                TKSUM_ver[i,j]=TKSUM_ver[i,j]+property[8, m]*
                    property[2, m]*wtmij
                PHISUM_ver[i,j]=PHISUM_ver[i,j]+property[9, m]*wtmij
                WTPSUM_ver[i,j]=WTPSUM_ver[i,j]+wtmij
                # i+1;j Node
                GGGPSUM_ver[i+1,j]=GGGPSUM_ver[i+1,j]+1/property[6, m]*wtmi1j
                SXXSUM_ver[i+1,j]=SXXSUM_ver[i+1,j]+property[7, m]*wtmi1j
                RHOSUM_ver[i+1,j]=RHOSUM_ver[i+1,j]+property[1, m]*wtmi1j
                RHOCPSUM_ver[i+1,j]=RHOCPSUM_ver[i+1,j]+property[2, m]*wtmi1j
                ALPHASUM_ver[i+1,j]=ALPHASUM_ver[i+1,j]+property[3, m]*wtmi1j
                ALPHAFSUM_ver[i+1,j]=ALPHAFSUM_ver[i+1,j]+property[4, m]*wtmi1j
                HRSUM_ver[i+1,j]=HRSUM_ver[i+1,j]+property[5, m]*wtmi1j
                TKSUM_ver[i+1,j]=TKSUM_ver[i+1,j]+property[8, m]*
                    property[2, m]*wtmi1j
                PHISUM_ver[i+1,j]=PHISUM_ver[i+1,j]+property[9, m]*wtmi1j
                WTPSUM_ver[i+1,j]=WTPSUM_ver[i+1,j]+wtmi1j
                # i;j+1 Node
                GGGPSUM_ver[i,j+1]=GGGPSUM_ver[i,j+1]+1/property[6, m]*wtmij1
                SXXSUM_ver[i,j+1]=SXXSUM_ver[i,j+1]+property[7, m]*wtmij1
                RHOSUM_ver[i,j+1]=RHOSUM_ver[i,j+1]+property[1, m]*wtmij1
                RHOCPSUM_ver[i,j+1]=RHOCPSUM_ver[i,j+1]+property[2, m]*wtmij1
                ALPHASUM_ver[i,j+1]=ALPHASUM_ver[i,j+1]+property[3, m]*wtmij1
                ALPHAFSUM_ver[i,j+1]=ALPHAFSUM_ver[i,j+1]+property[4, m]*wtmij1
                HRSUM_ver[i,j+1]=HRSUM_ver[i,j+1]+property[5, m]*wtmij1
                TKSUM_ver[i,j+1]=TKSUM_ver[i,j+1]+property[8, m]*
                    property[2, m]*wtmij1
                PHISUM_ver[i,j+1]=PHISUM_ver[i,j+1]+property[9, m]*wtmij1
                WTPSUM_ver[i,j+1]=WTPSUM_ver[i,j+1]+wtmij1
                # i+1;j+1 Node
                GGGPSUM_ver[i+1,j+1]=GGGPSUM_ver[i+1,j+1]+1/property[6, m]*
                    wtmi1j1
                SXXSUM_ver[i+1,j+1]=SXXSUM_ver[i+1,j+1]+property[7, m]*wtmi1j1
                RHOSUM_ver[i+1,j+1]=RHOSUM_ver[i+1,j+1]+property[1, m]*wtmi1j1
                RHOCPSUM_ver[i+1,j+1]=RHOCPSUM_ver[i+1,j+1]+
                    property[2, m]*wtmi1j1
                ALPHASUM_ver[i+1,j+1]=ALPHASUM_ver[i+1,j+1]+
                    property[3, m]*wtmi1j1
                ALPHAFSUM_ver[i+1,j+1]=ALPHAFSUM_ver[i+1,j+1]+
                    property[4, m]*wtmi1j1
                HRSUM_ver[i+1,j+1]=HRSUM_ver[i+1,j+1]+property[5, m]*wtmi1j1
                TKSUM_ver[i+1,j+1]=TKSUM_ver[i+1,j+1]+property[8, m]*
                    property[2, m]*wtmi1j1
                PHISUM_ver[i+1,j+1]=PHISUM_ver[i+1,j+1]+property[9, m]*wtmi1j1
                WTPSUM_ver[i+1,j+1]=WTPSUM_ver[i+1,j+1]+wtmi1j1
            end
            for j=1:1:Nx1
                for i=1:1:Ny1
                    if WTPSUM_ver[i,j]>0
                        GGGP_ver[i,j]=1/(GGGPSUM_ver[i,j]/WTPSUM_ver[i,j])
                        SXX0_ver[i,j]=SXXSUM_ver[i,j]/WTPSUM_ver[i,j]
                        RHO_ver[i,j]=RHOSUM_ver[i,j]/WTPSUM_ver[i,j]
                        RHOCP_ver[i,j]=RHOCPSUM_ver[i,j]/WTPSUM_ver[i,j]
                        ALPHA_ver[i,j]=ALPHASUM_ver[i,j]/WTPSUM_ver[i,j]
                        ALPHAF_ver[i,j]=ALPHAFSUM_ver[i,j]/WTPSUM_ver[i,j]
                        HR_ver[i,j]=HRSUM_ver[i,j]/WTPSUM_ver[i,j]
                        PHI_ver[i,j]=PHISUM_ver[i,j]/WTPSUM_ver[i,j]
                        BETTAPHI_ver[i,j]=1/GGGP_ver[i,j]*PHI_ver[i,j]
                        tk1_ver[i,j]=TKSUM_ver[i,j]/RHOCPSUM_ver[i,j]
                    end
                end
            end
            # test
            for j=1:1:Nx, i=1:1:Ny
                @test RHO[i, j] == RHO_ver[i, j]
                @test RHOCP[i, j] == RHOCP_ver[i, j]
                @test ALPHA[i, j] == ALPHA_ver[i, j]
                @test ALPHAF[i, j] == ALPHAF_ver[i, j]
                @test HR[i, j] == HR_ver[i, j]
                @test GGGP[i, j] ≈ GGGP_ver[i, j]
                @test SXX0[i, j] == SXX0_ver[i, j]
                @test tk1[i, j] == tk1_ver[i, j]
                @test PHI[i, j] == PHI_ver[i, j]
                @test BETTAPHI[i, j] ≈ BETTAPHI_ver[i, j]
            end
        end # testset "compute_p_node_properties!()"
    end # testset "compute node properties" 

    @testset "apply_insulating_boundary_conditions!()" begin
        max_size = 10
        for j=3:1:max_size, i=3:1:max_size
            t = rand(i, j)
            HydrologyPlanetesimals.apply_insulating_boundary_conditions!(t)
            @test t[1, 2:j-1] == t[2, 2:j-1]
            @test t[i, 2:j-1] == t[i-1, 2:j-1]
            @test t[:, 1] == t[:, 2]
            @test t[:, j] == t[:, j-1]
        end
    end # testset "apply_insulating_boundary_conditions!()"

    @testset "compute_gravity_solution!()" begin
        xsize = 35_000.0
        ysize = 35_000.0
        rplanet = 12_500.0
        rcrust = 12_000.0
        Nx = 35
        Ny = 35
        sp = HydrologyPlanetesimals.StaticParameters(
            xsize=xsize,
            ysize=ysize,
            rplanet=rplanet,
            rcrust=rcrust,
            Nx=Nx,
            Ny=Ny
        )
        Nx1, Ny1 = sp.Nx1, sp.Ny1
        dx, dy = sp.dx, sp.dy
        xsize, ysize = sp.xsize, sp.ysize
        G = sp.G
        # P nodes
        xp=-dx/2:dx:xsize+dx/2
        yp=-dy/2:dy:ysize+dy/2
        # LP = ExtendableSparseMatrix(Nx1*Ny1, Nx1*Ny1)
        SP = zeros(Float64, Nx1*Ny1)
        RP = zeros(Float64, Nx1*Ny1)
        gx = zeros(Float64, Ny1, Nx1)
        gy = zeros(Float64, Ny1, Nx1)
        LP_ver = zeros(Nx1*Ny1, Nx1*Ny1)
        RP_ver = zeros(Float64, Nx1*Ny1)
        FI_ver = zeros(Float64, Ny1, Nx1)
        gx_ver = zeros(Float64, Ny1, Nx1)
        gy_ver = zeros(Float64, Ny1, Nx1)
        # simulate density field RHO
        RHO = rand(1:0.1:7000, Ny1, Nx1)
        # compute gravity solution
        HydrologyPlanetesimals.compute_gravity_solution!(
            SP,
            RP,
            RHO,
            xp,
            yp,
            gx,
            gy,
            sp
        )
        # verification, from madcph.m, lines 680ff
        for j=1:1:Nx1
            for i=1:1:Ny1
                # Define global index in algebraic space
                gk=(j-1)*Ny1+i
                # Distance from the model centre
                rnode=((xp[j]-xsize/2)^2+(yp[i]-ysize/2)^2)^0.5
                # External points
                if rnode>xsize/2 || i==1 || i==Ny1 || j==1 || j==Nx1
                    # Boundary Condition
                    # PHI=0
                    LP_ver[gk,gk]=1; # Left part
                    RP_ver[gk]=0; # Right part
                else
                    # Internal points: Temperature eq.
                    # d2PHI/dx^2+d2PHI/dy^2=2/3*4*G*pi*RHO
                    #          PHI2
                    #           |
                    #           |
                    #  PHI1----PHI3----PHI5
                    #           |
                    #           |
                    #          PHI4
                    #
                    # Density gradients
                    dRHOdx=(RHO[i,j+1]-RHO[i,j-1])/2/dx
                    dRHOdy=(RHO[i+1,j]-RHO[i-1,j])/2/dy
                    # Left part
                    LP_ver[gk,gk-Ny1]=1/dx^2; # PHI1
                    LP_ver[gk,gk-1]=1/dy^2; # PHI2
                    LP_ver[gk,gk]=-2/dx^2-2/dy^2; # PHI3
                    LP_ver[gk,gk+1]=1/dy^2; # PHI4
                    LP_ver[gk,gk+Ny1]=1/dx^2; # PHI5
                    # Right part
                    RP_ver[gk]=2/3*4*G*pi*RHO[i,j]
                end
            end
        end
        # Solving matrixes
        SP_ver=LP_ver\RP_ver # Obtaining algebraic vector of solutions SP[]
        # Reload solutions SP[] to geometrical array PHI[]
        # Going through all grid points
        for j=1:1:Nx1
            for i=1:1:Ny1
                # Compute global index
                gk=(j-1)*Ny1+i
                # Reload solution
                FI_ver[i,j]=SP_ver[gk]
            end
        end
        # Compute gravity acceleration
        # gx
        for j=1:1:Nx
            for i=1:1:Ny1
                # gx=-dPHI/dx
                gx_ver[i,j]=-(FI_ver[i,j+1]-FI_ver[i,j])/dx
            end
        end
        # gy
        for j=1:1:Nx1
            for i=1:1:Ny
                # gy=-dPHI/dy
                gy_ver[i,j]=-(FI_ver[i+1,j]-FI_ver[i,j])/dy
            end
        end
        # test
        for j=1:1:Nx, i=1:1:Ny
            @test gx[i, j] ≈ gx_ver[i, j] rtol=1e-6
            @test gy[i, j] ≈ gy_ver[i, j] rtol=1e-6
        end
    end # testset "compute_gravity_solution!()"

    @testset "recompute_bulk_viscosity!()" begin
        sp = HydrologyPlanetesimals.StaticParameters()
        Nx, Ny = sp.Nx, sp.Ny
        Nx1, Ny1 = sp.Nx1, sp.Ny1 
        etaphikoef = sp.etaphikoef
        ETAP = zeros(Ny1, Nx1)
        ETAPHI = zeros(Ny1, Nx1)
        ETAP_ver = zeros(Ny1, Nx1)
        ETAPHI_ver = zeros(Ny1, Nx1)
        # simulate data
        ETA = rand(Ny, Nx)
        PHI = rand(Ny1, Nx1)
        # compute bulk viscosity
        HydrologyPlanetesimals.recompute_bulk_viscosity!(
            ETA,
            ETAP,
            ETAPHI,
            PHI,
            etaphikoef
        )
        # verification, from madcph.m, lines 771ff
        for i=2:1:Ny
            for j=2:1:Nx
                ETAP_ver[i,j]=1/((1/ETA[i-1,j-1]+1/ETA[i,j-1]+1/ETA[i-1,j]+1/ETA[i,j])/4)
                ETAPHI_ver[i,j]=etaphikoef*ETAP_ver[i,j]/PHI[i,j]
            end
        end       
        # test
        for j=1:1:Nx, i=1:1:Ny
            @test ETAP[i, j] ≈ ETAP_ver[i, j] rtol=1e-6
            @test ETAPHI[i, j] ≈ ETAPHI_ver[i, j] rtol=1e-6
        end
    end # testset "recompute_bulk_viscosity!()"

    @testset "get_viscosities_stresses_density_gradients()" begin
        sp = HydrologyPlanetesimals.StaticParameters()
        dx, dy, dt = sp.dx, sp.dy, sp.dtelastic
        Nx, Ny = sp.Nx, sp.Ny
        Nx1, Ny1 = sp.Nx1, sp.Ny1
        # simulate data
        ETA = rand(Ny, Nx)
        ETAP = rand(Ny1, Nx1)
        GGG = rand(Ny, Nx)
        GGGP = rand(Ny1, Nx1)
        SXY0 = rand(Ny, Nx)
        SXX0 = rand(Ny, Nx)
        RHOX = rand(Ny1, Nx1)
        RHOY = rand(Ny1, Nx1)
        ETAcomp = zeros(Ny, Nx)
        ETAPcomp = zeros(Ny1, Nx1)
        SXYcomp = zeros(Ny, Nx)
        SXXcomp = zeros(Ny, Nx)
        SYYcomp = zeros(Ny, Nx)
        dRHOXdx = zeros(Ny1, Nx1)
        dRHOXdy = zeros(Ny1, Nx1)
        dRHOYdx = zeros(Ny1, Nx1)
        dRHOYdy = zeros(Ny1, Nx1)
        # compute viscosities, stresses, density gradients
        HydrologyPlanetesimals.get_viscosities_stresses_density_gradients!(
            ETA,
            ETAP,
            GGG,
            GGGP,
            SXY0,
            SXX0,
            RHOX,
            RHOY,
            dx,
            dy,
            dt,
            Nx,
            Ny,
            Nx1,
            Ny1,
            ETAcomp,
            ETAPcomp,
            SXYcomp,
            SXXcomp,
            SYYcomp,
            dRHOXdx,
            dRHOXdy,
            dRHOYdx,
            dRHOYdy
        )
        # verification, from madcph.m, lines 832ff, 905ff
        for j=1:1:Nx, i=1:1:Ny
            # x-Stokes
            if i==1 || i==Ny1 || j==1 || j==Nx || j==Nx1
                # pass: external points
            else
                # x-Stokes internal points
                # Computational viscosity
                ETA1=ETA[i-1,j]*GGG[i-1,j]*dt/(GGG[i-1,j]*dt+ETA[i-1,j])
                ETA2=ETA[i,j]*GGG[i,j]*dt/(GGG[i,j]*dt+ETA[i,j])
                ETAP1=ETAP[i,j]*GGGP[i,j]*dt/(GGGP[i,j]*dt+ETAP[i,j])
                ETAP2=ETAP[i,j+1]*GGGP[i,j+1]*dt/(GGGP[i,j+1]*dt+ETAP[i,j+1])
                # Old stresses
                SXY1=SXY0[i-1,j]*ETA[i-1,j]/(GGG[i-1,j]*dt+ETA[i-1,j])
                SXY2=SXY0[i,j]*ETA[i,j]/(GGG[i,j]*dt+ETA[i,j])
                SXX1=SXX0[i,j]*ETAP[i,j]/(GGGP[i,j]*dt+ETAP[i,j])
                SXX2=SXX0[i,j+1]*ETAP[i,j+1]/(GGGP[i,j+1]*dt+ETAP[i,j+1])
                # Density gradients
                dRHOdx=(RHOX[i,j+1]-RHOX[i,j-1])/2/dx
                dRHOdy=(RHOX[i+1,j]-RHOX[i-1,j])/2/dy
                # test
                @test ETAcomp[i-1, j] ≈ ETA1 rtol=1e-6
                @test ETAcomp[i, j] ≈ ETA2 rtol=1e-6
                @test ETAPcomp[i, j] ≈ ETAP1 rtol=1e-6
                @test ETAPcomp[i, j+1] ≈ ETAP2 rtol=1e-6
                @test SXYcomp[i-1, j] ≈ SXY1 rtol=1e-6
                @test SXYcomp[i, j] ≈ SXY2 rtol=1e-6
                @test SXXcomp[i, j] ≈ SXX1 rtol=1e-6
                @test SXXcomp[i, j+1] ≈ SXX2 rtol=1e-6
                @test dRHOXdx[i, j] ≈ dRHOdx rtol=1e-6
                @test dRHOXdy[i, j] ≈ dRHOdy rtol=1e-6        
            end
            # y-Stokes
            if j==1 || j==Nx1 || i==1 || i==Ny || i==Ny1
                # pass: external points
            else
                # Computational viscosity
                ETA1=ETA[i,j-1]*GGG[i,j-1]*dt/(GGG[i,j-1]*dt+ETA[i,j-1])
                ETA2=ETA[i,j]*GGG[i,j]*dt/(GGG[i,j]*dt+ETA[i,j])
                ETAP1=ETAP[i,j]*GGGP[i,j]*dt/(GGGP[i,j]*dt+ETAP[i,j])
                ETAP2=ETAP[i+1,j]*GGGP[i+1,j]*dt/(GGGP[i+1,j]*dt+ETAP[i+1,j])
                # Old stresses
                SXY1=SXY0[i,j-1]*ETA[i,j-1]/(GGG[i,j-1]*dt+ETA[i,j-1])
                SXY2=SXY0[i,j]*ETA[i,j]/(GGG[i,j]*dt+ETA[i,j])
                SYY1=-SXX0[i,j]*ETAP[i,j]/(GGGP[i,j]*dt+ETAP[i,j])
                SYY2=-SXX0[i+1,j]*ETAP[i+1,j]/(GGGP[i+1,j]*dt+ETAP[i+1,j])
                # Density gradients
                dRHOdx=(RHOY[i,j+1]-RHOY[i,j-1])/2/dx
                dRHOdy=(RHOY[i+1,j]-RHOY[i-1,j])/2/dy
                # test
                @test ETAcomp[i, j-1] ≈ ETA1 rtol=1e-6
                @test ETAcomp[i, j] ≈ ETA2 rtol=1e-6
                @test ETAPcomp[i, j] ≈ ETAP1 rtol=1e-6
                @test ETAPcomp[i+1, j] ≈ ETAP2 rtol=1e-6
                @test SXYcomp[i, j-1] ≈ SXY1 rtol=1e-6
                @test SXYcomp[i, j] ≈ SXY2 rtol=1e-6
                @test SYYcomp[i, j] ≈ SYY1 rtol=1e-6
                @test SYYcomp[i+1, j] ≈ SYY2 rtol=1e-6
                @test dRHOYdx[i, j] ≈ dRHOdx rtol=1e-6
                @test dRHOYdy[i, j] ≈ dRHOdy rtol=1e-6     
            end       
        end
    end # testset "get_viscosities_stresses_density_gradients()"

    @testset "assemble_hydromechanical_lse()" begin
        xsize = 35_000.0
        ysize = 35_000.0
        rplanet = 12_500.0
        rcrust = 12_000.0
        Nx = 35
        Ny = 35
        sp = HydrologyPlanetesimals.StaticParameters(
            xsize=xsize,
            ysize=ysize,
            rplanet=rplanet,
            rcrust=rcrust,
            Nx=Nx,
            Ny=Ny
        )
        Nx1, Ny1 = sp.Nx1, sp.Ny1
        dx, dy = sp.dx, sp.dy
        xsize, ysize = sp.xsize, sp.ysize
        vxleft = sp.vxleft
        vxright = sp.vxright
        vytop = sp.vytop
        vybottom = sp.vybottom
        bctop = sp.bctop
        bcbottom = sp.bcbottom
        bcleft = sp.bcleft
        bcright = sp.bcright
        bcftop = sp.bcftop
        bcfbottom = sp.bcfbottom
        bcfleft = sp.bcfleft
        bcfright = sp.bcfright
        pscale  = sp.pscale
        psurface = sp.psurface
        etaphikoef = sp.etaphikoef
        dt = sp.dtelastic
        # simulate data
        ETA = rand(Ny, Nx)
        ETAP = rand(Ny1, Nx1)
        GGG = rand(Ny, Nx)
        GGGP = rand(Ny1, Nx1)
        SXY0 = rand(Ny, Nx)
        SXX0 = rand(Ny, Nx)
        RHOX = rand(Ny1, Nx1)
        RHOY = rand(Ny1, Nx1)
        RHOFX = rand(Ny1, Nx1)
        RHOFY = rand(Ny1, Nx1)
        RX = rand(Ny1, Nx1)
        RY = rand(Ny1, Nx1)
        ETAPHI = rand(Ny1, Nx1)
        BETTAPHI = rand(Ny1, Nx1)
        PHI = rand(Ny1, Nx1)
        gx = rand(Ny1, Nx1)
        gy = rand(Ny1, Nx1) 
        pr0 = rand(Ny1, Nx1)
        pf0 = rand(Ny1, Nx1)
        ETAcomp = zeros(Ny, Nx)
        ETAPcomp = zeros(Ny1, Nx1)
        SXYcomp = zeros(Ny, Nx)
        SXXcomp = zeros(Ny, Nx)
        SYYcomp = zeros(Ny, Nx)
        dRHOXdx = zeros(Ny1, Nx1)
        dRHOXdy = zeros(Ny1, Nx1)
        dRHOYdx = zeros(Ny1, Nx1)
        dRHOYdy = zeros(Ny1, Nx1)
        # LSE
        L = ExtendableSparseMatrix(Nx1*Ny1*6, Nx1*Ny1*6)
        R = zeros(Nx1*Ny1*6)
        L_ver = zeros(Nx1*Ny1*6, Nx1*Ny1*6)
        R_ver = zeros(Nx1*Ny1*6)
        # assemble hydromechanical LSE
        HydrologyPlanetesimals.assemble_hydromechanical_lse!(
            ETAcomp,
            ETAPcomp,
            SXYcomp,
            SXXcomp,
            SYYcomp,
            dRHOXdx,
            dRHOXdy,
            dRHOYdx,
            dRHOYdy,
            RHOX,
            RHOY,
            RHOFX,
            RHOFY,
            RX,
            RY,
            ETAPHI,
            BETTAPHI,
            PHI,
            gx,
            gy,
            pr0,
            pf0,
            dt,
            L,
            R,
            sp
        )
        # verification
        # from madcph.m, lines 779ff
        # Hydro-Mechanical Solution
        # Composing global matrixes L_ver[], R_ver[] for Stokes & continuity equations
        for j=1:1:Nx1
            for i=1:1:Ny1
                # Define global indexes in algebraic space
                kvx=((j-1)*Ny1+i-1)*6+1; # Vx solid
                kvy=kvx+1; # Vy solid
                kpm=kvx+2; # Ptotal
                kqx=kvx+3; # qx Darcy
                kqy=kvx+4; # qy Darcy
                kpf=kvx+5; # P fluid
                
                # Vx equation External points
                if i==1 || i==Ny1 || j==1 || j==Nx || j==Nx1
                    # Boundary Condition 
                    # Ghost unknowns 1*Vx=0
                    if j==Nx1
                        L_ver[kvx,kvx]=1; # Left part
                        R_ver[kvx]=0; # Right part
                    end
                    # Left Boundary
                    if j==1
                        L_ver[kvx,kvx]=1; # Left part
                        R_ver[kvx]=vxleft; # Right part
                    end
                    # Right Boundary
                    if j==Nx 
                        L_ver[kvx,kvx]=1; # Left part
                        R_ver[kvx]=vxright; # Right part
                    end
                    # Top boundary
                    if i==1 && j>1 && j<Nx
                        L_ver[kvx,kvx]=1; # Left part
                        L_ver[kvx,kvx+6]=bctop; # Left part
                        R_ver[kvx]=0; # Right part
                    end
                    # Top boundary
                    if i==Ny1 && j>1 && j<Nx
                        L_ver[kvx,kvx]=1; # Left part
                        L_ver[kvx,kvx-6]=bcbottom; # Left part
                        R_ver[kvx]=0; # Right part
                    end
                else
                # Internal points: x-Stokes eq.
                #            Vx2
                #             |
                #        Vy1  |  Vy3
                #             |
                #     Vx1-P1-Vx3-P2-Vx5
                #             |
                #        Vy2  |  Vy4
                #             |
                #            Vx4
                #
                # Computational viscosity
                ETA1=ETA[i-1,j]*GGG[i-1,j]*dt/(GGG[i-1,j]*dt+ETA[i-1,j])
                ETA2=ETA[i,j]*GGG[i,j]*dt/(GGG[i,j]*dt+ETA[i,j])
                ETAP1=ETAP[i,j]*GGGP[i,j]*dt/(GGGP[i,j]*dt+ETAP[i,j])
                ETAP2=ETAP[i,j+1]*GGGP[i,j+1]*dt/(GGGP[i,j+1]*dt+ETAP[i,j+1])
                # Old stresses
                SXY1=SXY0[i-1,j]*ETA[i-1,j]/(GGG[i-1,j]*dt+ETA[i-1,j])
                SXY2=SXY0[i,j]*ETA[i,j]/(GGG[i,j]*dt+ETA[i,j])
                SXX1=SXX0[i,j]*ETAP[i,j]/(GGGP[i,j]*dt+ETAP[i,j])
                SXX2=SXX0[i,j+1]*ETAP[i,j+1]/(GGGP[i,j+1]*dt+ETAP[i,j+1])
                # Density gradients
                dRHOdx=(RHOX[i,j+1]-RHOX[i,j-1])/2/dx
                dRHOdy=(RHOX[i+1,j]-RHOX[i-1,j])/2/dy
                # Left part
                L_ver[kvx,kvx-Ny1*6]=ETAP1/dx^2; # Vx1
                L_ver[kvx,kvx-6]=ETA1/dy^2; # Vx2
                L_ver[kvx,kvx]=-(ETAP1+ETAP2)/dx^2-  (ETA1+ETA2)/dy^2-  dRHOdx*gx[i,j]*dt; # Vx3
                L_ver[kvx,kvx+6]=ETA2/dy^2; # Vx4
                L_ver[kvx,kvx+Ny1*6]=ETAP2/dx^2; # Vx5
                L_ver[kvx,kvy]=ETAP1/dx/dy-ETA2/dx/dy-dRHOdy*gx[i,j]*dt/4;  # Vy2
                L_ver[kvx,kvy+Ny1*6]=-ETAP2/dx/dy+ETA2/dx/dy-dRHOdy*gx[i,j]*dt/4;  # Vy4
                L_ver[kvx,kvy-6]=-ETAP1/dx/dy+ETA1/dx/dy-dRHOdy*gx[i,j]*dt/4;  # Vy1
                L_ver[kvx,kvy+Ny1*6-6]=ETAP2/dx/dy-ETA1/dx/dy-dRHOdy*gx[i,j]*dt/4;  # Vy3
                L_ver[kvx,kpm]=pscale/dx; # P1
                L_ver[kvx,kpm+Ny1*6]=-pscale/dx; # P2
                # Right part
                R_ver[kvx]=-RHOX[i,j]*gx[i,j]-(SXY2-SXY1)/dy-(SXX2-SXX1)/dx
                end
                
                # Vy equation External points
                if j==1 || j==Nx1 || i==1 || i==Ny || i==Ny1
                    # Boundary Condition
                    # Ghost unknowns 1*Vx=0
                    if i==Ny1
                        L_ver[kvy,kvy]=1; # Left part
                        R_ver[kvy]=0; # Right part
                    end
                    # Top boundary
                    if i==1
                        L_ver[kvy,kvy]=1; # Left part
                        R_ver[kvy]=vytop; # Right part
                    end
                    # Bottom boundary
                    if i==Ny
                        L_ver[kvy,kvy]=1; # Left part
                        R_ver[kvy]=vybottom; # Right part
                    end
                    # Left boundary
                    if j==1 && i>1 && i<Ny
                        L_ver[kvy,kvy]=1; # Left part
                        L_ver[kvy,kvy+6*Ny1]=bcleft; # Left part
                        R_ver[kvy]=0; # Right part
                    end
                    # Right boundary
                    if j==Nx1 && i>1 && i<Ny
                        L_ver[kvy,kvy]=1; # Left part
                        L_ver[kvy,kvy-6*Ny1]=bcright; # Left part
                        R_ver[kvy]=0; # Right part
                    end
                else
                # Internal points: y-Stokes eq.
                #            Vy2
                #             |
                #         Vx1 P1 Vx3
                #             |
                #     Vy1----Vy3----Vy5
                #             |
                #         Vx2 P2 Vx4
                #             |
                #            Vy4
                #
                # Computational viscosity
                ETA1=ETA[i,j-1]*GGG[i,j-1]*dt/(GGG[i,j-1]*dt+ETA[i,j-1])
                ETA2=ETA[i,j]*GGG[i,j]*dt/(GGG[i,j]*dt+ETA[i,j])
                ETAP1=ETAP[i,j]*GGGP[i,j]*dt/(GGGP[i,j]*dt+ETAP[i,j])
                ETAP2=ETAP[i+1,j]*GGGP[i+1,j]*dt/(GGGP[i+1,j]*dt+ETAP[i+1,j])
                # Old stresses
                SXY1=SXY0[i,j-1]*ETA[i,j-1]/(GGG[i,j-1]*dt+ETA[i,j-1])
                SXY2=SXY0[i,j]*ETA[i,j]/(GGG[i,j]*dt+ETA[i,j])
                SYY1=-SXX0[i,j]*ETAP[i,j]/(GGGP[i,j]*dt+ETAP[i,j])
                SYY2=-SXX0[i+1,j]*ETAP[i+1,j]/(GGGP[i+1,j]*dt+ETAP[i+1,j])
                # Density gradients
                dRHOdx=(RHOY[i,j+1]-RHOY[i,j-1])/2/dx
                dRHOdy=(RHOY[i+1,j]-RHOY[i-1,j])/2/dy
                # Left part
                L_ver[kvy,kvy-Ny1*6]=ETA1/dx^2; # Vy1
                L_ver[kvy,kvy-6]=ETAP1/dy^2; # Vy2
                L_ver[kvy,kvy]=-(ETAP1+ETAP2)/dy^2-  (ETA1+ETA2)/dx^2-  dRHOdy*gy[i,j]*dt; # Vy3
                L_ver[kvy,kvy+6]=ETAP2/dy^2; # Vy4
                L_ver[kvy,kvy+Ny1*6]=ETA2/dx^2; # Vy5
                L_ver[kvy,kvx]=ETAP1/dx/dy-ETA2/dx/dy-dRHOdx*gy[i,j]*dt/4; #Vx3
                L_ver[kvy,kvx+6]=-ETAP2/dx/dy+ETA2/dx/dy-dRHOdx*gy[i,j]*dt/4; #Vx4
                L_ver[kvy,kvx-Ny1*6]=-ETAP1/dx/dy+ETA1/dx/dy-dRHOdx*gy[i,j]*dt/4; #Vx1
                L_ver[kvy,kvx+6-Ny1*6]=ETAP2/dx/dy-ETA1/dx/dy-dRHOdx*gy[i,j]*dt/4; #Vx2
                L_ver[kvy,kpm]=pscale/dy; # P1
                L_ver[kvy,kpm+6]=-pscale/dy; # P2
                
                # Right part
                R_ver[kvy]=-RHOY[i,j]*gy[i,j]-(SXY2-SXY1)/dx-(SYY2-SYY1)/dy
                end
                
                # P equation External points
                if i==1 || j==1 || i==Ny1 || j==Nx1
                    # Boundary Condition
                    # 1*P=0
                    L_ver[kpm,kpm]=1; # Left part
                    R_ver[kpm]=0; # Right part
                else
                # Internal points: continuity eq.
                # dVx/dx+dVy/dy=0
                #            Vy1
                #             |
                #        Vx1--P--Vx2
                #             |
                #            Vy2
                #
                # Left part
                L_ver[kpm,kvx-Ny1*6]=-1/dx; # Vx1
                L_ver[kpm,kvx]=1/dx; # Vx2
                L_ver[kpm,kvy-6]=-1/dy; # Vy1
                L_ver[kpm,kvy]=1/dy; # Vy2
                L_ver[kpm,kpm]= pscale/(1-PHI[i,j])*(1/ETAPHI[i,j]+BETTAPHI[i,j]/dt); # Ptotal
                L_ver[kpm,kpf]=-pscale/(1-PHI[i,j])*(1/ETAPHI[i,j]+BETTAPHI[i,j]/dt); # Pfluid
                # Right part
                R_ver[kpm]=(pr0[i,j]-pf0[i,j])/(1-PHI[i,j])*BETTAPHI[i,j]/dt
                end

                # qxDarcy equation External points
                if i==1 || i==Ny1 || j==1 || j==Nx || j==Nx1
                    # Boundary Condition
                    # 1*qx=0
                    L_ver[kqx,kqx]=1; # Left part
                    R_ver[kqx]=0; # Right part
                    # Top boundary
                    if i==1 && j>1 && j<Nx
                        L_ver[kqx,kqx+6]=bcftop; # Left part
                    end
                    # Bottom boundary
                    if i==Ny1 && j>1 && j<Nx
                        L_ver[kqx,kqx-6]=bcfbottom; # Left part
                    end
                else
                # Internal points: x-Darcy eq.
                # Rx*qxDarcy+dP/dx=RHOfluid*gx
                #     P1-qxD-P2
                # Left part
                L_ver[kqx,kqx]=RX[i,j]; # qxD
                L_ver[kqx,kpf]=-pscale/dx; # P1
                L_ver[kqx,kpf+Ny1*6]=pscale/dx; # P2
                # Right part
                R_ver[kqx]=RHOFX[i,j]*gx[i,j]
                end
                
                # qyDarcy equation External points
                if j==1 || j==Nx1 || i==1 || i==Ny || i==Ny1
                    # Boundary Condition
                    # 1*Vy=0
                    L_ver[kqy,kqy]=1; # Left part
                    R_ver[kqy]=0; # Right part
                    # Left boundary
                    if j==1 && i>1 && i<Ny
                        L_ver[kqy,kqy+6*Ny1]=bcfleft; # Left part
                    end
                    # Right boundary
                    if j==Nx1 && i>1 && i<Ny
                        L_ver[kqy,kqy-6*Ny1]=bcfright; # Left part
                    end
                else
                # Internal points: y-Stokes eq.
                # Internal points: x-Darcy eq.
                # Rx*qxDarcy+dP/dx=RHOfluid*gx
                #      P1
                #      |
                #     qxD
                #      |
                #      P2
                # Left part
                L_ver[kqy,kqy]=RY[i,j]; # qxD
                L_ver[kqy,kpf]=-pscale/dy; # P1
                L_ver[kqy,kpf+6]=pscale/dy; # P
                # Right part
                R_ver[kqy]=RHOFY[i,j]*gy[i,j]
                end
                
                # Pfluid equation External points
                if i==1 || j==1 || i==Ny1 || j==Nx1 || (i==2 && j==2)
                    # Boundary Condition
                    # 1*Pfluid=0
                    L_ver[kpf,kpf]=1; # Left part
                    R_ver[kpf]=0; # Right part
                    # Real BC
                    if i==2 && j==2
                        L_ver[kpf,kpf]=1*pscale; #Left part
                        R_ver[kpf]=psurface; # Right part
                    end
                else
                # Internal points: continuity eq.
                # dqxD/dx+dqyD/dy-(Ptotal-Pfluid)/ETHAphi=0
                #            qyD1
                #              |
                #        qxD1--P--qxD2
                #              |
                #            qyD2
                #
                # Left part
                L_ver[kpf,kqx-Ny1*6]=-1/dx; # qxD1
                L_ver[kpf,kqx]=1/dx; # qxD2
                L_ver[kpf,kqy-6]=-1/dy; # qyD1
                L_ver[kpf,kqy]=1/dy; # qyD2
                L_ver[kpf,kpm]=-pscale/(1-PHI[i,j])*(1/ETAPHI[i,j]+BETTAPHI[i,j]/dt); # Ptotal
                L_ver[kpf,kpf]= pscale/(1-PHI[i,j])*(1/ETAPHI[i,j]+BETTAPHI[i,j]/dt); # Pfluid
                # Right part
                R_ver[kpf]=-(pr0[i,j]-pf0[i,j])/(1-PHI[i,j])*BETTAPHI[i,j]/dt
                end
            end
        end
        # test
        for j=1:1:Nx1*6, i=1:1:Ny1*6
            @test L[i, j] ≈ L_ver[i, j] rtol=1e-6
            @test R[i] ≈ R_ver[i] rtol=1e-6
        end
    end # testset "assemble_hydromechanical_lse()"

    @testset "process_hydromechanical_solution!()" begin
        sp = HydrologyPlanetesimals.StaticParameters()
        Nx1, Ny1 = sp.Nx1, sp.Ny1
        pscale = sp.pscale
        # simulate data
        S = rand(Nx1*Ny1*6)
        vx = zeros(Ny1, Nx1)
        vy = zeros(Ny1, Nx1)
        pr = zeros(Ny1, Nx1)
        qxD = zeros(Ny1, Nx1)
        qyD = zeros(Ny1, Nx1)
        pf = zeros(Ny1, Nx1)
        vx_ver = zeros(Ny1, Nx1)
        vy_ver = zeros(Ny1, Nx1)
        pr_ver = zeros(Ny1, Nx1)
        qxD_ver = zeros(Ny1, Nx1)
        qyD_ver = zeros(Ny1, Nx1)
        pf_ver = zeros(Ny1, Nx1)
        # process solution
        HydrologyPlanetesimals.process_hydromechanical_solution!(
            S,
            vx,
            vy,
            pr,
            qxD,
            qyD,
            pf,
            pscale,
            Nx1,
            Ny1
        )
        # verification, from madcph.m, line 1058ff
        for j=1:1:Nx1
            for i=1:1:Ny1
                # Define global indexes in algebraic space
                kvx=((j-1)*Ny1+i-1)*6+1; # Vx solid
                kvy=kvx+1; # Vy solid
                kpm=kvx+2; # Ptotal
                kqx=kvx+3; # qx Darcy
                kqy=kvx+4; # qy Darcy
                kpf=kvx+5; # P fluid
                # Reload solution
                vx_ver[i,j]=S[kvx]
                vy_ver[i,j]=S[kvy]
                pr_ver[i,j]=S[kpm]*pscale
                qxD_ver[i,j]=S[kqx]
                qyD_ver[i,j]=S[kqy]
                pf_ver[i,j]=S[kpf]*pscale
            end
        end
        # test
        for j=1:1:Nx1, i=1:1:Ny1
            @test vx[i, j] ≈ vx_ver[i, j] rtol=1e-6
            @test vy[i, j] ≈ vy_ver[i, j] rtol=1e-6
            @test pr[i, j] ≈ pr_ver[i, j] rtol=1e-6
            @test qxD[i, j] ≈ qxD_ver[i, j] rtol=1e-6
            @test qyD[i, j] ≈ qyD_ver[i, j] rtol=1e-6
            @test pf[i, j] ≈ pf_ver[i, j] rtol=1e-6
        end
    end # testset "process_hydromechanical_solution!()"

    @testset "compute_Aϕ!()" begin
        sp = HydrologyPlanetesimals.StaticParameters()
        Nx, Ny = sp.Nx, sp.Ny
        Nx1, Ny1 = sp.Nx1, sp.Ny1
        dt = sp.dtelastic
        # simulate data
        APHI = rand(Ny1, Nx1)
        APHI_ver = rand(Ny1, Nx1)
        ETAPHI = rand(Ny1, Nx1)
        BETTAPHI = rand(Ny1, Nx1)
        PHI = rand(Ny1, Nx1)
        pr = rand(Ny1, Nx1)
        pf = rand(Ny1, Nx1)
        pr0 = rand(Ny1, Nx1)
        pf0 = rand(Ny1, Nx1)
        # compute Aϕ
        aphimax = HydrologyPlanetesimals.compute_Aϕ!(
            APHI,
            ETAPHI,
            BETTAPHI,
            PHI,
            pr,
            pf,
            pr0,
            pf0,
            dt
        )
        # verification, from madcph.m, line 1078ff
        APHI_ver = zeros(Ny1, Nx1)
        aphimax_ver=0
        for j=2:1:Nx
            for i=2:1:Ny
                APHI_ver[i,j]=((pr[i,j]-pf[i,j])/ETAPHI[i,j]+  ((pr[i,j]-pr0[i,j])-(pf[i,j]-pf0[i,j]))/dt*BETTAPHI[i,j])/(1-PHI[i,j])/PHI[i,j]
                aphimax_ver=max(aphimax_ver,abs(APHI_ver[i,j]))
            end
        end
        # test
        for j=2:1:Nx, i=2:1:Ny
            @test APHI[i, j] ≈ APHI_ver[i, j] rtol=1e-6
        end
        @test aphimax ≈ aphimax_ver rtol=1e-6
    end # testset "compute_Aϕ!()"

    @testset "compute_fluid_velocity!()" begin
        sp = HydrologyPlanetesimals.StaticParameters()
        Nx, Ny = sp.Nx, sp.Ny
        Nx1, Ny1 = sp.Nx1, sp.Ny1
        bcftop, bcfbottom = sp.bcftop, sp.bcfbottom
        bcfleft, bcfright = sp.bcfleft, sp.bcfright
        # simulate data
        PHIX = rand(Ny1, Nx1)
        PHIY = rand(Ny1, Nx1)
        qxD = rand(Ny1, Nx1)
        qyD = rand(Ny1, Nx1)
        vx = rand(Ny1, Nx1)
        vy = rand(Ny1, Nx1)
        vxf = zeros(Ny1, Nx1)
        vyf = zeros(Ny1, Nx1)
        vxf_ver = zeros(Ny1, Nx1)
        vyf_ver = zeros(Ny1, Nx1)
        # compute fluid velocities
        HydrologyPlanetesimals.compute_fluid_velocities!(
            PHIX,
            PHIY,
            qxD,
            qyD,
            vx,
            vy,
            vxf,
            vyf,
            sp
        )
        # verification, from madcph.m line 1090ff
        for j=1:1:Nx
            for i=2:1:Ny
                vxf_ver[i,j]=qxD[i,j]/PHIX[i,j]
            end
        end
        # Apply BC
        # Top
        vxf_ver[1,:]= -bcftop*vxf_ver[2,:];    
        # Bottom
        vxf_ver[Ny1,:]= -bcfbottom*vxf_ver[Ny,:];    
        # Vy fluid
        for j=2:1:Nx
            for i=1:1:Ny
                vyf_ver[i,j]=qyD[i,j]/PHIY[i,j]
            end
        end
        # Apply BC
        # Left
        vyf_ver[:,1]= -bcfleft*vyf_ver[:,2];    
        # Right
        vyf_ver[:, Nx1]= -bcfright*vyf_ver[:, Nx];     
        # Add solid velocity
        # vxf0=vxf; vxf=vxf+vx
        vxf_ver.=vxf_ver.+vx
        # vyf0=vyf; vyf=vyf+vy
        vyf_ver.=vyf_ver.+vy
        # test
        for j=1:1:Nx1, i=1:1:Ny1
            @test vxf[i, j] ≈ vxf_ver[i, j] rtol=1e-6
            @test vyf[i, j] ≈ vyf_ver[i, j] rtol=1e-6
        end
    end # testset "compute_fluid_velocity!()"

    @testset "compute_displacement_timestep()" begin
        sp = HydrologyPlanetesimals.StaticParameters()
        Nx, Ny = sp.Nx, sp.Ny
        Nx1, Ny1 = sp.Nx1, sp.Ny1
        dt = sp.dtelastic
        dx, dy = sp.dx, sp.dy
        dxymax, dphimax = sp.dxymax, sp.dphimax        
        # simulate data
        aphimax = rand()
        vx = rand(Ny1, Nx1)
        vy = rand(Ny1, Nx1)
        vxf = rand(Ny1, Nx1)
        vyf = rand(Ny1, Nx1)
        # compute displacement timestep
        dtm = HydrologyPlanetesimals.compute_displacement_timestep(
            vx,
            vy,
            vxf,
            vyf,
            dt,
            dx,
            dy,
            dxymax,
            aphimax,
            dphimax
        )
        # verification, from madcph.m, line 1117ff
        dtm_ver=dt
        maxvx=maximum(abs.(vx))
        maxvy=maximum(abs.(vy))
        if dtm_ver*maxvx>dxymax*dx
            dtm_ver=dxymax*dx/maxvx
        end
        if dtm_ver*maxvy>dxymax*dy
            dtm_ver=dxymax*dy/maxvy
        end
        # Fluid velocity
        maxvxf=maximum(abs.(vxf))
        maxvyf=maximum(abs.(vyf))
        if dtm_ver*maxvxf>dxymax*dx
            dtm_ver=dxymax*dx/maxvxf
        end
        if dtm_ver*maxvyf>dxymax*dy
            dtm_ver=dxymax*dy/maxvyf
        end
        # Porosity change
        if aphimax*dtm_ver>dphimax
            dtm_ver=dphimax/aphimax
        end
        # test
        @test dtm ≈ dtm_ver rtol=1e-6
    end # testset "compute_displacement_timestep()"

    @testset "compute_stress_strainrate!()" begin
        sp = HydrologyPlanetesimals.StaticParameters()
        Nx, Ny = sp.Nx, sp.Ny
        Nx1, Ny1 = sp.Nx1, sp.Ny1
        dtm = sp.dtelastic
        dx, dy = sp.dx, sp.dy
        # simulate data
        vx = rand(Ny1, Nx1)
        vy = rand(Ny1, Nx1)
        ETA = rand(Ny, Nx)
        GGG = rand(Ny, Nx)
        ETAP = rand(Ny1, Nx1)
        GGGP = rand(Ny1, Nx1)
        SXX0 = rand(Ny1, Nx1)
        SXY0 = rand(Ny, Nx)
        EXY = rand(Ny, Nx)
        SXY = rand(Ny, Nx)
        DSXY = rand(Ny, Nx)
        EXX = rand(Ny1, Nx1)
        SXX = rand(Ny1, Nx1)
        DSXX = rand(Ny1, Nx1)
        EII = zeros(Ny1, Nx1)
        SII = zeros(Ny1, Nx1)
        # compute stress, strainrate
        HydrologyPlanetesimals.compute_stress_strainrate!(
            vx,
            vy,
            ETA,
            GGG,
            ETAP,
            GGGP,
            SXX0,
            SXY0,
            EXX,
            EXY,
            SXX,
            SXY,
            DSXX,
            DSXY,
            EII,
            SII,
            dtm,
            sp
        )
        # verification, from madcph.m, line 1144ff
        EXY_ver = zeros(Ny, Nx); # Strain rate EPSILONxy, 1/s
        SXY_ver = zeros(Ny, Nx); # Stress SIGMAxy, Pa
        DSXY_ver = zeros(Ny, Nx); # Stress change SIGMAxy, Pa
        for j=1:1:Nx
            for i=1:1:Ny
                # EXY;SXY; DSXY
                EXY_ver[i,j]=0.5*((vx[i+1,j]-vx[i,j])/dy+(vy[i,j+1]-vy[i,j])/dx)
                SXY_ver[i,j]=2*ETA[i,j]*EXY_ver[i,j]*GGG[i,j]*dtm/(GGG[i,j]*dtm+ETA[i,j])+SXY0[i,j]*ETA[i,j]/(GGG[i,j]*dtm+ETA[i,j])
                DSXY_ver[i,j]=SXY_ver[i,j]-SXY0[i,j]
            end
        end
        # Compute EPSILONxx; SIGMA'xx in pressure nodes
        EXX_ver = zeros(Ny1, Nx1); # Strain rate EPSILONxx, 1/s
        EII_ver = zeros(Ny1, Nx1); # Second strain rate invariant, 1/s
        SXX_ver = zeros(Ny1, Nx1); # Stress SIGMA'xx, Pa
        SII_ver = zeros(Ny1, Nx1); # Second stress invariant, Pa
        DSXX_ver = zeros(Ny1, Nx1); # Stress change SIGMA'xx, Pa
        DIVV_ver = zeros(Ny1, Nx1); # div[v]
        for j=2:1:Nx
            for i=2:1:Ny
                # DIVV
                DIVV_ver[i,j]=(vx[i,j]-vx[i,j-1])/dx+(vy[i,j]-vy[i-1,j])/dy
                # EXX
                EXX_ver[i,j]=((vx[i,j]-vx[i,j-1])/dx-(vy[i,j]-vy[i-1,j])/dy)/2
                # SXX
                SXX_ver[i,j]=2*ETAP[i,j]*EXX_ver[i,j]*GGGP[i,j]*dtm/(GGGP[i,j]*dtm+ETAP[i,j])+SXX0[i,j]*ETAP[i,j]/(GGGP[i,j]*dtm+ETAP[i,j])
                DSXX_ver[i,j]=SXX_ver[i,j]-SXX0[i,j]
                # EII
                EII_ver[i,j]=(EXX_ver[i,j]^2+((EXY_ver[i,j]+EXY_ver[i-1,j]+EXY_ver[i,j-1]+EXY_ver[i-1,j-1])/4)^2)^0.5
                # SII
                SII_ver[i,j]=(SXX_ver[i,j]^2+((SXY_ver[i,j]+SXY_ver[i-1,j]+SXY_ver[i,j-1]+SXY_ver[i-1,j-1])/4)^2)^0.5
            end
        end
        # test
        for j=1:1:Nx, i=1:1:Ny
            @test EXY[i,j] ≈ EXY_ver[i,j] rtol=1e-6
            @test SXY[i,j] ≈ SXY_ver[i,j] rtol=1e-6
            @test DSXY[i,j] ≈ DSXY_ver[i,j] rtol=1e-6
        end
        for j=2:1:Nx, i=2:1:Ny
            @test EXX[i,j] ≈ EXX_ver[i,j] rtol=1e-6
            @test SXX[i,j] ≈ SXX_ver[i,j] rtol=1e-6
            # @test DSXX[i,j] ≈ DSXX_ver[i,j] rtol=1e-6
            @test EII[i,j] ≈ EII_ver[i,j] rtol=1e-6
            @test SII[i,j] ≈ SII_ver[i,j] rtol=1e-6
        end
    end # testset "compute_stress_strainrate!()"

    @testset "symmetrize_p_node_observables!()" begin
        sp = HydrologyPlanetesimals.StaticParameters()
        Nx, Ny = sp.Nx, sp.Ny
        Nx1, Ny1 = sp.Nx1, sp.Ny1
        # simulate data
        SXX = rand(Ny1, Nx1)
        APHI = rand(Ny1, Nx1)
        PHI = rand(Ny1, Nx1)
        pr = rand(Ny1, Nx1)
        pf = rand(Ny1, Nx1)
        ps = zeros(Ny1, Nx1)
        SXX_ver = copy(SXX)
        APHI_ver = copy(APHI)
        PHI_ver = copy(PHI)
        pr_ver = copy(pr)
        pf_ver = copy(pf)
        ps_ver = zeros(Ny1, Nx1)
        # symmetrize p node variables
        HydrologyPlanetesimals.symmetrize_p_node_observables!(
            SXX,
            APHI,
            PHI,
            pr,
            pf,
            ps,
            Nx,
            Ny,
            Nx1,
            Ny1
        )
        # verification, from madcph.m, line 1196ff
        # Apply Symmetry to Pressure nodes
        # External P-nodes: symmetry
        # Top
        SXX_ver[1,2:Nx]=SXX_ver[2,2:Nx]
        APHI_ver[1,2:Nx]=APHI_ver[2,2:Nx];    
        PHI_ver[1,2:Nx]=PHI_ver[2,2:Nx];    
        pr_ver[1,2:Nx]=pr_ver[2,2:Nx];    
        pf_ver[1,2:Nx]=pf_ver[2,2:Nx];    
        # Bottom
        SXX_ver[Ny1,2:Nx]=SXX_ver[Ny,2:Nx]
        APHI_ver[Ny1,2:Nx]=APHI_ver[Ny,2:Nx];    
        PHI_ver[Ny1,2:Nx]=PHI_ver[Ny,2:Nx];    
        pr_ver[Ny1,2:Nx]=pr_ver[Ny,2:Nx];    
        pf_ver[Ny1,2:Nx]=pf_ver[Ny,2:Nx];    
        # Left
        SXX_ver[:,1]=SXX_ver[:,2]
        APHI_ver[:,1]=APHI_ver[:,2];    
        PHI_ver[:,1]=PHI_ver[:,2];    
        pr_ver[:,1]=pr_ver[:,2];    
        pf_ver[:,1]=pf_ver[:,2];    
        # Right
        SXX_ver[:, Nx1]=SXX_ver[:, Nx]
        APHI_ver[:, Nx1]=APHI_ver[:, Nx];    
        PHI_ver[:, Nx1]=PHI_ver[:, Nx];    
        pr_ver[:, Nx1]=pr_ver[:, Nx];    
        pf_ver[:, Nx1]=pf_ver[:, Nx]; 
        # Compute solid pressure
        ps_ver=(pr_ver .- pf_ver.*PHI_ver)./(1 .- PHI_ver)
        # test
        @test SXX[1, 2:Nx] == SXX_ver[1, 2:Nx]
        @test APHI[1, 2:Nx] == APHI_ver[1, 2:Nx]
        @test PHI[1, 2:Nx] == PHI_ver[1, 2:Nx]
        @test pr[1, 2:Nx] == pr_ver[1, 2:Nx]
        @test pf[1, 2:Nx] == pf_ver[1, 2:Nx]
        @test SXX[Ny1, 2:Nx] == SXX_ver[Ny1, 2:Nx]
        @test APHI[Ny1, 2:Nx] == APHI_ver[Ny1, 2:Nx]
        @test PHI[Ny1, 2:Nx] == PHI_ver[Ny1, 2:Nx]
        @test pr[Ny1, 2:Nx] == pr_ver[Ny1, 2:Nx]
        @test pf[Ny1, 2:Nx] == pf_ver[Ny1, 2:Nx]
        @test SXX[:, 1] == SXX_ver[:, 1]
        @test APHI[:, 1] == APHI_ver[:, 1]
        @test PHI[:, 1] == PHI_ver[:, 1]
        @test pr[:, 1] == pr_ver[:, 1]
        @test pf[:, 1] == pf_ver[:, 1]
        @test SXX[:, Nx1] == SXX_ver[:, Nx1]
        @test APHI[:, Nx1] == APHI_ver[:, Nx1]
        @test PHI[:, Nx1] == PHI_ver[:, Nx1]
        @test pr[:, Nx1] == pr_ver[:, Nx1]
        @test pf[:, Nx1] == pf_ver[:, Nx1]
        @test ps == ps_ver
    end # testset "symmetrize_p_node_observables!()"

    @testset "positive_max()" begin
        # simulate data
        A = rand(-100:0.1:100, 1000, 1000)
        B = rand(-100:0.1:100, 1000, 1000)
        R = zeros(1000, 1000)
        # compute positive max
        HydrologyPlanetesimals.positive_max!(A, B, R)
        # test
        for i in eachindex(R)
            @test R[i] == max(A[i], B[i], 0.0)
        end
    end # testset "positive_max()"
end
