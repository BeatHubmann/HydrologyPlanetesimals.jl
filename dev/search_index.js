var documenterSearchIndex = {"docs":
[{"location":"","page":"Home","title":"Home","text":"CurrentModule = HydrologyPlanetesimals","category":"page"},{"location":"#HydrologyPlanetesimals","page":"Home","title":"HydrologyPlanetesimals","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Documentation for HydrologyPlanetesimals.","category":"page"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"","page":"Home","title":"Home","text":"Modules = [HydrologyPlanetesimals]","category":"page"},{"location":"#HydrologyPlanetesimals.StaticParameters","page":"Home","title":"HydrologyPlanetesimals.StaticParameters","text":"Static parameters: Grids, markers, switches, constants, etc. which remain constant throughout the simulation.\n\nhr_al::Bool\nradioactive heating from 26Al active Default: true\nhr_fe::Bool\nradioactive heating from 60Fe active Default: true\nxsize::Float64\nhorizontal model size [m] Default: 140000.0\nysize::Float64\nvertical model size [m] Default: 140000.0\nxcenter::Float64\nhorizontal center of model Default: xsize / 2\nycenter::Float64\nvertical center of model Default: ysize / 2\nNx::Int64\nbasic grid resolution in x direction (horizontal) Default: 141\nNy::Int64\nbasic grid resolution in y direction (vertical) Default: 141\nNx1::Int64\nVx, Vy, P grid resolution in x direction (horizontal) Default: Nx + 1\nNy1::Int64\nVx/Vy/P grid resolution in y direction (vertical) Default: Ny + 1\ndx::Float64\nhorizontal grid step [m] Default: xsize / (Nx - 1)\ndy::Float64\nvertical grid step [m] Default: ysize / (Ny - 1)\njmin_basic::Int64\nminimum assignable basic grid index in x direction Default: 1\nimin_basic::Int64\nminimum assignable basic grid index in y direction Default: 1\njmax_basic::Int64\nmaximum assignable basic grid index in x direction Default: Nx - 1\nimax_basic::Int64\nmaximum assignable basic grid index in y direction Default: Ny - 1\njmin_vx::Int64\nminimum assignable Vx grid index in x direction Default: 1\nimin_vx::Int64\nminimum assignable Vx grid index in y direction Default: 1\njmax_vx::Int64\nmaximum assignable Vx grid index in x direction Default: Nx - 1\nimax_vx::Int64\nmaximum assignable Vx grid index in y direction Default: Ny\njmin_vy::Int64\nminimum assignable Vy grid index in x direction Default: 1\nimin_vy::Int64\nminimum assignable Vy grid index in y direction Default: 1\njmax_vy::Int64\nmaximum assignable Vy grid index in x direction Default: Nx\nimax_vy::Int64\nmaximum assignable Vy grid index in y direction Default: Ny - 1\njmin_p::Int64\nminimum assignable P grid index in x direction Default: 1\nimin_p::Int64\nminimum assignable P grid index in y direction Default: 1\njmax_p::Int64\nmaximum assignable P grid index in x direction Default: Nx\nimax_p::Int64\nmaximum assignable P grid index in y direction Default: Ny\nrplanet::Float64\nplanetary radius [m] Default: 50000.0\nrcrust::Float64\ncrust radius [m] Default: 48000.0\npsurface::Float64\nsurface pressure [Pa] Default: 1000.0\nNxmc::Int64\nnumber of markers per cell in horizontal direction Default: 4\nNymc::Int64\nnumber of markers per cell in vertical direction Default: 4\nNxm::Int64\nmarker grid resolution in horizontal direction Default: (Nx - 1) * Nxmc\nNym::Int64\nmarker grid resolution in vertical direction Default: (Ny - 1) * Nymc\ndxm::Float64\nmarker grid step in horizontal direction Default: xsize / Nxm\ndym::Float64\nmarker grid step in vertical direction Default: ysize / Nym\nstart_marknum::Int64\nnumber of markers at start Default: Nxm * Nym\nG::Float64\ngravitational constant [m^3kg^-1s^-2] Default: 6.672e-11\npscale::Float64\nscaled pressure Default: 1.0e23 / dx\nrhosolidm::StaticArrays.SVector{3, Float64}\nsolid Density [kg/m^3] Default: [3300.0, 3300.0, 1.0]\nrhofluidm::StaticArrays.SVector{3, Float64}\nfluid density [kg/m^3] Default: [7000.0, 7000.0, 1000.0]\netasolidm::StaticArrays.SVector{3, Float64}\nsolid viscosity [Pa*s] Default: [1.0e16, 1.0e16, 1.0e14]\netasolidmm::StaticArrays.SVector{3, Float64}\nmolten solid viscosity [Pa*s] Default: [1.0e14, 1.0e14, 1.0e14]\netafluidm::StaticArrays.SVector{3, Float64}\nfluid viscosity [Pa*s] Default: [0.01, 0.01, 1.0e12]\netafluidmm::StaticArrays.SVector{3, Float64}\nmolten fluid viscosity [Pa*s] Default: [0.01, 0.01, 1.0e12]\nrhocpsolidm::StaticArrays.SVector{3, Float64}\nsolid volumetric heat capacity [kg/m^3] Default: [3.3e6, 3.3e6, 3.0e6]\nrhocpfluidm::StaticArrays.SVector{3, Float64}\nfluid volumetric heat capacity [kg/m^3] Default: [7.0e6, 7.0e6, 3.0e6]\nalphasolidm::StaticArrays.SVector{3, Float64}\nsolid thermal expansion [1/K] Default: [3.0e-5, 3.0e-5, 0.0]\nalphafluidm::StaticArrays.SVector{3, Float64}\nfluid thermal expansion [1/K] Default: [5.0e-5, 5.0e-5, 0.0]\nksolidm::StaticArrays.SVector{3, Float64}\nsolid thermal conductivity [W/m/K] Default: [3.0, 3.0, 3000.0]\nkfluidm::StaticArrays.SVector{3, Float64}\nfluid thermal conductivity [W/m/K] Default: [50.0, 50.0, 3000.0]\nstart_hrsolidm::StaticArrays.SVector{3, Float64}\nsolid radiogenic heat production [W/m^3] Default: [0.0, 0.0, 0.0]\nstart_hrfluidm::StaticArrays.SVector{3, Float64}\nfluid radiogenic heat production [W/m^3] Default: [0.0, 0.0, 0.0]\ngggsolidm::StaticArrays.SVector{3, Float64}\nsolid shear modulus [Pa] Default: [1.0e10, 1.0e10, 1.0e10]\nfrictsolidm::StaticArrays.SVector{3, Float64}\nsolid friction coefficient Default: [0.6, 0.6, 0.0]\ncohessolidm::StaticArrays.SVector{3, Float64}\nsolid compressive strength [Pa] Default: [1.0e8, 1.0e8, 1.0e8]\ntenssolidm::StaticArrays.SVector{3, Float64}\nsolid tensile strength [Pa] Default: [6.0e7, 6.0e7, 6.0e7]\nkphim0::StaticArrays.SVector{3, Float64}\nstandard permeability [m^2] Default: [1.0e-13, 1.0e-13, 1.0e-17]\ntkm0::StaticArrays.SVector{3, Float64}\ninitial temperature [K] Default: [300.0, 300.0, 273.0]\netaphikoef::Float64\nCoefficient to compute compaction viscosity from shear viscosity Default: 0.0001\nt_half_al::Float64\n26Al half life [s] Default: 717000 * 31540000\ntau_al::Float64\n26Al decay constant Default: thalfal / log(2)\nratio_al::Float64\ninitial ratio of 26Al and 27Al isotopes Default: 5.0e-5\nE_al::Float64\nE 26Al [J] Default: 5.047e-13\nf_al::Float64\n26Al atoms/kg Default: 1.9e23\nt_half_fe::Float64\n60Fe half life [s] Default: 2620000 * 31540000\ntau_fe::Float64\n60Fe decay constant Default: thalffe / log(2)\nratio_fe::Float64\ninitial ratio of 60Fe and 56Fe isotopes Default: 1.0e-6\nE_fe::Float64\nE 60Fe [J] Default: 4.34e-13\nf_fe::Float64\n60Fe atoms/kg Default: 1.957e24\ntmsilicate::Float64\nsilicate melting temperature [K] Default: 1.0e6\ntmiron::Float64\niron melting temperature [K] Default: 1273\nphim0::Float64\nstandard Fe fraction [porosity] Default: 0.2\nphimin::Float64\nmin porosity Default: 0.0001\nphimax::Float64\nmax porosity Default: 1 - phimin\nbcleft::Float64\nmechanical boundary condition left Default: -1\nbcright::Float64\nmechanical boundary condition right Default: -1\nbctop::Float64\nmechanical boundary condition top Default: -1\nbcbottom::Float64\nmechanical boundary condition bottom Default: -1\nbcfleft::Float64\nhydraulic boundary condition left Default: -1\nbcfright::Float64\nhydraulic boundary condition right Default: -1\nbcftop::Float64\nhydraulic boundary condition top Default: -1\nbcfbottom::Float64\nhydraulic boundary condition bottom Default: -1\nstrainrate::Float64\nshortening strain rate Default: 0.0\nvxleft::Float64\nx extension/shortening velocity left Default: (strainrate * xsize) / 2\nvxright::Float64\nx extension/shortening velocity right Default: (-strainrate * xsize) / 2\nvytop::Float64\ny extension/shortening velocity top Default: (-strainrate * ysize) / 2\nvybottom::Float64\ny extension/shortening velocity bottom Default: (strainrate * ysize) / 2\nnname::String\nmat filename Default: madcph_\nsavematstep::Int64\n.mat storage periodicity Default: 50\ndtelastic::Float64\nMaximal computational timestep [s] Default: 1.0e11\ndtkoef::Float64\nCoefficient to decrease computational timestep Default: 2\ndtkoefup::Float64\nCoefficient to increase computational timestep Default: 1.1\ndtstep::Int64\nNumber of iterations before changing computational timestep Default: 200\ndxymax::Float64\nMax marker movement per time step [grid steps] Default: 0.05\nvpratio::Float64\nWeight of averaged velocity for moving markers Default: 1 / 3\nDTmax::Float64\nMax temperature change per time step [K] Default: 20\ndsubgridt::Float64\nSubgrid temperature diffusion parameter Default: 0\ndsubgrids::Float64\nSubgrid stress diffusion parameter Default: 0\nyearlength::Float64\nlength of year [s] Default: 365.25 * 24 * 3600\nstart_time::Float64\nTime sum (start) [s] Default: 1.0e6yearlength\nendtime::Float64\nTime sum (end) [s] Default: 15 * 1000000 * yearlength\netamin::Float64\nLower viscosity cut-off [Pa s] Default: 1.0e12\netamax::Float64\nUpper viscosity cut-off [Pa s] Default: 1.0e23\nnplast::Int64\nNumber of plastic iterations Default: 100000\nvisstep::Int64\nPeriodicity of visualization Default: 1\nyerrmax::Float64\nTolerance level for yielding error() Default: 100.0\netawt::Float64\nWeight for old viscosity Default: 0\ndphimax::Float64\nmax porosity ratio change per time step Default: 0.01\nstart_step::Int64\nstarting timestep Default: 1\nnsteps::Int64\nnumber of timesteps to run Default: 30000\n\n\n\n\n\n","category":"type"},{"location":"#HydrologyPlanetesimals.Q_radiogenic-NTuple{5, Any}","page":"Home","title":"HydrologyPlanetesimals.Q_radiogenic","text":"Compute radiogenic heat production of isotope mixture.\n\nQ_radiogenic(f, ratio, E, tau, time)\n\n\nDetails\n\n- f: fraction of radioactive matter [atoms/kg]\n- ratio: initial ratio of radioactive to non-radioactive isotopes\n- E: heat energy [J]\n- tau: exp decay mean lifetime ``\\tau=\\frac{t_{1/2}}{\\log{2}}`` [s]\n- time: time elapsed since start of radioactive decay [s]\n\nReturns\n\n- Q: radiogenic heat production [W/kg]\n\n\n\n\n\n","category":"method"},{"location":"#HydrologyPlanetesimals.apply_insulating_boundary_conditions!-Tuple{Any}","page":"Home","title":"HydrologyPlanetesimals.apply_insulating_boundary_conditions!","text":"Apply insulating boundary conditions to given array.\n\n[x x x x x x        [a a b c d d\n\nx a b c d x         a a b c d d\n\nx e f g h x   ->    e e f g h h\n\nx x x x x x]        e e f g h h]\n\nDetails\n\n- t: array to apply insulating boundary conditions to\n\nReturns\n\n- nothing\n\n\n\n\n\n","category":"method"},{"location":"#HydrologyPlanetesimals.assemble_hydromechanical_lse!-NTuple{21, Any}","page":"Home","title":"HydrologyPlanetesimals.assemble_hydromechanical_lse!","text":"Assemble hydromechanical system of equations.\n\nassemble_hydromechanical_lse!(ETAcomp, ETAPcomp, SXYcomp, SXXcomp, SYYcomp, dRHOXdx, dRHOXdy, dRHOYdx, dRHOYdy, RHOX, RHOY, ETAPHI, BETTAPHI, PHI, gx, gy, pr0, pf0, L, R, sp)\n\n\nDetails\n\n- ETAcomp: computational viscosity at basic nodes\n- ETAPcomp: computational viscosity at P nodes\n- SXYcomp: computational previous XY stress at basic nodes\n- SXXcomp: computational previous XX stress at P nodes\n- SYYcomp: computational previous YY stress at P nodes\n- dRHOXdx: total density gradient in x direction at Vx nodes\n- dRHOXdy: total density gradient in y direction at Vx nodes\n- dRHOYdx: total density gradient in x direction at Vy nodes\n- dRHOYdy: total density gradient in y direction at Vy nodes\n- RHOX: total density at Vx nodes\n- RHOY: total density at Vy nodes\n- ETAPHI: bulk viscosity at P nodes\n- BETTAPHI: bulk compressibility at P nodes\n- PHI: porosity at P nodes\n- gx: x gravitational acceleration at Vx nodes\n- gy: y gravitational acceleration at Vy nodes\n- pr0: previous total pressure at P nodes\n- pf0: previous fluid pressure at P nodes\n- L: ExtendableSparse matrix to store LHS coefficients\n- R: vector to store RHS coefficients\n- sp: simulation parameters\n\nReturns\n\n- nothing\n\n\n\n\n\n","category":"method"},{"location":"#HydrologyPlanetesimals.calculate_radioactive_heating-Tuple{Any, HydrologyPlanetesimals.StaticParameters}","page":"Home","title":"HydrologyPlanetesimals.calculate_radioactive_heating","text":"Compute radiogenic heat production of 26Al and 60Fe isotopes.\n\ncalculate_radioactive_heating(timesum, sp)\n\n\nDetails\n\n- timesum: time elapsed since initial conditions at start of simulation\n- sp: static simulation parameters\n\nReturns\n\n- hrsolidm: radiogenic heat production of 26Al [W/m^3]\n- hrfluidm: radiogenic heat production of 60Fe [W/m^3]\n\n\n\n\n\n","category":"method"},{"location":"#HydrologyPlanetesimals.compute_basic_node_properties!-NTuple{16, Any}","page":"Home","title":"HydrologyPlanetesimals.compute_basic_node_properties!","text":"Compute properties of basic nodes based on interpolation arrays.\n\ncompute_basic_node_properties!(ETA0SUM, ETASUM, GGGSUM, SXYSUM, COHSUM, TENSUM, FRISUM, WTSUM, ETA0, ETA, GGG, SXY0, COH, TEN, FRI, YNY)\n\n\nDetails\n\n- ETA0SUM: ETA0 interpolation array\n- ETASUM: ETA interpolation array\n- GGGSUM: GGG interpolation array\n- SXYSUM: SXY interpolation array\n- COHSUM: COH interpolation array\n- TENSUM: TEN interpolation array\n- FRISUM: FRI interpolation array\n- WTSUM: WT interpolation array\n- ETA0: ETA0 basic node array\n- ETA: ETA basic node array\n- GGG: GGG basic node array\n- SXY0: SXY basic node array\n- COH: COH basic node array\n- TEN: TEN basic node array\n- FRI: FRI basic node array\n- YNY: YNY basic node array\n\nReturns\n\n- nothing\n\n\n\n\n\n","category":"method"},{"location":"#HydrologyPlanetesimals.compute_hydromechanical_solution!-NTuple{14, Any}","page":"Home","title":"HydrologyPlanetesimals.compute_hydromechanical_solution!","text":"Compute hydromechanical solution.\n\ncompute_hydromechanical_solution!(ETA, ETAP, ETAPHI, BETTAPHI, PHI, SXX0, SXY0, vx, vy, pr, qxD, qyD, pf, sp)\n\n\nDetails\n\n- ETA: viscoplastic viscosity at basic nodes\n- ETAP: viscosity at P nodes \n- ETAPHI: bulk viscosity at P nodes\n- BETTAPHI: bulk compresibility at P nodes\n- PHI: porosity at P nodes\n- SXX0: σxx₀′ at P nodes\n- SXY0: σxy₀′ at basic nodes\n- vx: solid Vx-velocity at Vx nodes\n- vy: solid Vy-velocity at Vy nodes\n- pr: total pressure at P nodes\n- qxD: qx Darcy flux at Vx nodes\n- qyD: qy Darcy flux at Vy nodes\n- pf: fluid pressure at P nodes\n- sp: simulation parameters\n\nReturns\n\n- nothing\n\n\n\n\n\n","category":"method"},{"location":"#HydrologyPlanetesimals.compute_marker_properties!-Tuple{Any, Any, Any, Any, Any, Any, Any, Any, Any, Any, Any, Any, Any, Any, Any, HydrologyPlanetesimals.StaticParameters}","page":"Home","title":"HydrologyPlanetesimals.compute_marker_properties!","text":"Computers properties of given marker and saves them to corresponding arrays.\n\ncompute_marker_properties!(m, tm, tkm, rhototalm, rhocptotalm, etasolidcur, etafluidcur, etatotalm, hrtotalm, ktotalm, tkm_rhocptotalm, etafluidcur_inv_kphim, hrsolidm, hrfluidm, phim, sp)\n\n\nDetails\n\n- m: marker number\n- tm: array of type of markers\n- tkm: array of temperature of markers\n- rhototalm: array of total density of markers\n- rhocptotalm: array of total volumetric heat capacity of markers\n- etasolidcur: array of solid viscosity of markers\n- etafluidcur: array of fluid viscosity of markers\n- etatotalm: array of total viscosity of markers\n- hrtotalm: array of total radiogenic heat production of markers\n- ktotalm: array of total thermal conductivity of markers\n- tkm_rhocptotalm: array of total thermal energy of markers\n- etafluidcur_inv_kphim: array of (fluid viscosity)/permeability of markers\n- phim: array of porosity of markers\n- hrsolidm: vector of radiogenic heat production of solid materials\n- hrfluidm: vector of radiogenic heat production of fluid materials\n- sp: static simulation parameters\n\nReturns\n\n- nothing\n\n\n\n\n\n","category":"method"},{"location":"#HydrologyPlanetesimals.compute_p_node_properties!-NTuple{20, Any}","page":"Home","title":"HydrologyPlanetesimals.compute_p_node_properties!","text":"Compute properties of P nodes based on interpolation arrays.\n\ncompute_p_node_properties!(RHOSUM, RHOCPSUM, ALPHASUM, ALPHAFSUM, HRSUM, GGGPSUM, SXXSUM, TKSUM, PHISUM, WTPSUM, RHO, RHOCP, ALPHA, ALPHAF, HR, GGGP, SXX0, tk1, PHI, BETTAPHI)\n\n\nDetails\n\n- GGGPSUM: GGGP interpolation array\n- SXX0SUM: SXX0 interpolation array\n- RHOSUM: RHO interpolation array\n- RHOCPSUM: RHOCP interpolation array\n- ALPHASUM: ALPHA interpolation array\n- ALPHAFSUM: ALPHAF interpolation array\n- HRSUM: HR interpolation array\n- PHISUM: PHI interpolation array\n- TKSUM: TK interpolation array\n- WTPSUM: WTP interpolation array\n- GGGP: GGGP P node array\n- SXX0: SXX0 P node array\n- RHO: RHO P node array\n- RHOCP: RHOCP P node array\n- ALPHA: ALPHA P node array\n- ALPHAF: ALPHAF P node array\n- HR: HR P node array\n- PHI: PHI P node array\n- BETTAPHI: BETTAPHI P node array\n- tk1: tk1 P node array\n\nReturns\n\n- nothing\n\n\n\n\n\n","category":"method"},{"location":"#HydrologyPlanetesimals.compute_vx_node_properties!-NTuple{11, Any}","page":"Home","title":"HydrologyPlanetesimals.compute_vx_node_properties!","text":"Compute properties of Vx nodes based on interpolation arrays.\n\ncompute_vx_node_properties!(RHOXSUM, RHOFXSUM, KXSUM, PHIXSUM, RXSUM, WTXSUM, RHOX, RHOFX, KX, PHIX, RX)\n\n\nDetails\n\n- RHOXSUM: RHOX interpolation array\n- RHOFXSUM: RHOFX interpolation array\n- KXSUM: KX interpolation array\n- PHIXSUM: PHIX interpolation array\n- RXSUM: RX interpolation array\n- WTXSUM: WTX interpolation array\n- RHOX: RHOX Vx node array\n- RHOFX: RHOFX Vx node array\n- KX: KX Vx node array\n- PHIX: PHIX Vx node array\n- RX: RX Vx node array\n\nReturns\n\n- nothing\n\n\n\n\n\n","category":"method"},{"location":"#HydrologyPlanetesimals.compute_vy_node_properties!-NTuple{11, Any}","page":"Home","title":"HydrologyPlanetesimals.compute_vy_node_properties!","text":"Compute properties of Vy nodes based on interpolation arrays.\n\ncompute_vy_node_properties!(RHOYSUM, RHOFYSUM, KYSUM, PHIYSUM, RYSUM, WTYSUM, RHOY, RHOFY, KY, PHIY, RY)\n\n\nDetails\n\n- RHOYSUM: RHOY interpolation array\n- RHOFYSUM: RHOFY interpolation array\n- KYSUM: KY interpolation array\n- PHIYSUM: PHIY interpolation array\n- RYSUM: RY interpolation array\n- WTYSUM: WTY interpolation array\n- RHOY: RHOY Vy node array\n- RHOFY: RHOFY Vy node array\n- KY: KY Vy node array\n- PHIY: PHIY Vy node array\n- RY: RY Vy node array\n\nReturns\n\n- nothing\n\n\n\n\n\n","category":"method"},{"location":"#HydrologyPlanetesimals.define_markers!-Tuple{Any, Any, Any, Any, Any, Any, Any, Any, Any, Any, Any, Any, Any, Any, Any, Any, Any, Any, Any, HydrologyPlanetesimals.StaticParameters}","page":"Home","title":"HydrologyPlanetesimals.define_markers!","text":"Define initial set of markers according to model parameters\n\ndefine_markers!(xm, ym, tm, phim, etavpm, rhototalm, rhocptotalm, etatotalm, hrtotalm, ktotalm, etafluidcur, tkm, inv_gggtotalm, fricttotalm, cohestotalm, tenstotalm, rhofluidcur, alphasolidcur, alphafluidcur, sp)\n\n\nDetails\n\n- xm: array of x coordinates of markers\n- ym: array of y coordinates of markers\n- tm: array of material type of markers\n- phim: array of porosity of markers\n- etavpm: array of matrix viscosity of markers\n- rhototalm: array of total density of markers\n- rhocptotalm: array of total volumetric heat capacity of markers\n- etatotalm: array of total viscosity of markers\n- hrtotalm: array of total radiogenic heat production of markers\n- ktotalm: array of total thermal conductivity of markers\n- etafluidcur: array of fluid viscosity of markers\n- tkm: array of temperature of markers \n- inv_gggtotalm: array of inverse of total shear modulus of markers\n- fricttotalm: array of total friction coefficient of markers\n- cohestotalm: array of total compressive strength of markers\n- tenstotalm: array of total tensile strength of markers\n- rhofluidcur: array of fluid density of markers\n- alphasolidcur: array of solid thermal expansion coefficient of markers\n- alphafluidcur: array of fluid thermal expansion coefficient of markers\n- sp: static simulation parameters\n\nReturns\n\n- nothing\n\n\n\n\n\n","category":"method"},{"location":"#HydrologyPlanetesimals.distance-NTuple{4, Any}","page":"Home","title":"HydrologyPlanetesimals.distance","text":"Calculate Euclidean distance between two point coordinates.\n\ndistance(x1, y1, x2, y2)\n\n\nDetails\n\n- x1: x-coordinate of point 1 [m]\n- y1: y-coordinate of point 1 [m]\n- x2: x-coordinate of point 2 [m]\n- y2: y-coordinate of point 2 [m]\n\nReturns\n\n- Euclidean distance between point 1 and point 2 [m]\n\n\n\n\n\n","category":"method"},{"location":"#HydrologyPlanetesimals.fix_weights-NTuple{10, Any}","page":"Home","title":"HydrologyPlanetesimals.fix_weights","text":"Compute top and left grid nodes indices and bilinear interpolation weigths to nearest four grid nodes for given (x, y) position and grid axes.\n\nfix_weights(x, y, x_axis, y_axis, dx, dy, jmin, jmax, imin, imax)\n\n\nDetails\n\n- x: x-position [m]\n- y: y-position [m]\n- x_axis: x-grid reference axis array [m]\n- y_axis: y-grid reference axis array [m]\n- dx: x-grid axis mesh width [m]\n- dy: y-grid axis mesh width [m]\n- jmin: minimum assignable index on x-grid axis (basic/Vx/Vy/P)\n- jmax: maximum assignable index on x-grid axis (basic/Vx/Vy/P)\n- imin: minimum assignable index on y-grid axis (basic/Vx/Vy/P)\n- imax: maximum assignable index on y-grid axis (basic/Vx/Vy/P)\n\nReturns\n\n- i: top (with reference to y) node index on y-grid axis\n- j: left (with reference to x) node index on x-grid axis\n- bilinear_weights: vector of 4 bilinear interpolation weights to\n  nearest four grid nodes:\n    [wtmij  : i  , j   node,\n    wtmi1j : i+1, j   node,\n    wtmij1 : i  , j+1 node,\n    wtmi1j1: i+1, j+1 node]\n\n\n\n\n\n","category":"method"},{"location":"#HydrologyPlanetesimals.get_viscosities_stresses_density_gradients!-NTuple{24, Any}","page":"Home","title":"HydrologyPlanetesimals.get_viscosities_stresses_density_gradients!","text":"Compute viscosities, stresses, and density gradients for hydromechanical solver.\n\nget_viscosities_stresses_density_gradients!(ETA, ETAP, GGG, GGGP, SXY0, SXX0, RHOX, RHOY, dx, dy, dt, Nx, Ny, Nx1, Ny1, ETAcomp, ETAPcomp, SXYcomp, SXXcomp, SYYcomp, dRHOXdx, dRHOXdy, dRHOYdx, dRHOYdy)\n\n\nDetails\n\nIn\n\n- ETA: viscoplastic viscosity at basic nodes\n- ETAP: viscosity at P nodes\n- GGG: shear modulus at basic nodes\n- GGGP: shear modulus at P nodes\n- SXY0: σ₀xy XY stress at basic nodes\n- SXX0: σ₀′xx XX stress at P nodes\n- RHOX: density at Vx nodes\n- RHOY: density at Vy nodes\n- dx: horizontal grid spacing\n- dy: vertical grid spacing\n- dt: time step\n- Nx: number of horizontal basic grid points\n- Ny: number of vertical basic grid points\n- Nx1: number of horizontal Vx/Vy/P grid points\n- Ny1: number of vertical Vx/Vy/P grid points\n\nOut\n\n- ETAcomp: computational viscosity at basic nodes\n- ETAPcomp: computational viscosity at P nodes\n- SXYcomp: previous XY stresses at basic nodes\n- SXXcomp: previous XX stresses at P nodes\n- SYYcomp: previous YY stresses at P nodes\n- dRHOXdx: density gradient at Vx nodes in x direction\n- dRHOXdy: density gradient at Vx nodes in y direction\n- dRHOYdx: density gradient at Vy nodes in x direction\n- dRHOYdy: density gradient at Vy nodes in y direction\n\nReturns\n\n- nothing\n\n\n\n\n\n","category":"method"},{"location":"#HydrologyPlanetesimals.interpolate!-NTuple{5, Any}","page":"Home","title":"HydrologyPlanetesimals.interpolate!","text":"Interpolate a property to neareast four nodes on a given grid location using given bilinear interpolation weights.\n\nDetails\n\n- i: top (with reference to y) node index on y-grid axis\n- j: left (with reference to x) node index on x-grid axis\n- weights: vector of 4 bilinear interpolation weights to\n  nearest four grid nodes:\n    [wtmij  : i  , j   node,\n    wtmi1j : i+1, j   node,\n    wtmij1 : i  , j+1 node,\n    wtmi1j1: i+1, j+1 node]\n- property: property to be interpolated to grid using weights\n- grid: threaded grid array on which to interpolate property\n\n\n\n\n\n","category":"method"},{"location":"#HydrologyPlanetesimals.kphi-Tuple{Any, Any, Any}","page":"Home","title":"HydrologyPlanetesimals.kphi","text":"Compute iron porosity-dependent permeability.\n\nkphi(kphim0, phim, phim0)\n\n\nDetails\n\n- kphim0: standard permeability [m^2]\n- phim: actual (marker) porosity\n- phim0: standard iron fraction (porosity)\n\nReturns\n\n- kphim: iron porosity-dependent permeability [m^2]\n\n\n\n\n\n","category":"method"},{"location":"#HydrologyPlanetesimals.ktotal-Tuple{Any, Any, Any}","page":"Home","title":"HydrologyPlanetesimals.ktotal","text":"Compute total thermal conductivity of two-phase material.\n\nktotal(ksolid, kfluid, phi)\n\n\nDetails\n\n- ksolid: solid thermal conductivity [W/m/K]\n- kfluid: fluid thermal conductivity [W/m/K]\n- phi: fraction of solid\n\nReturns\n\n- ktotal: total thermal conductivity of mixed phase [W/m/K]\n\n\n\n\n\n","category":"method"},{"location":"#HydrologyPlanetesimals.perform_plastic_iterations!-NTuple{15, Any}","page":"Home","title":"HydrologyPlanetesimals.perform_plastic_iterations!","text":"Perform plastic iterations on nodes.\n\nperform_plastic_iterations!(ETA, ETAP, ETAPHI, BETTAPHI, PHI, SXX0, SXY0, vx, vy, pr, qxD, qyD, pf, timestep, sp)\n\n\nDetails\n\n- timestep: current time step\n- ETA\n- ETAP\n- ETAPHI\n\n\n- sp: simulation parameters\n\nReturns\n\n- nothing\n\n\n\n\n\n","category":"method"},{"location":"#HydrologyPlanetesimals.recompute_bulk_viscosity!-NTuple{5, Any}","page":"Home","title":"HydrologyPlanetesimals.recompute_bulk_viscosity!","text":"Recompute bulk viscosity at P nodes.\n\nDetails\n\n- ETA: viscoplastic viscosity at basic nodes\n- ETAP: viscosity at P Nodes\n- ETAPHI: bulk viscosity at P Nodes\n- PHI: porosity at P Nodes\n- etaphikoef: coefficient: shear viscosity -> compaction viscosity\n\nReturns\n\n- nothing\n\n\n\n\n\n","category":"method"},{"location":"#HydrologyPlanetesimals.run_simulation","page":"Home","title":"HydrologyPlanetesimals.run_simulation","text":"Runs the simulation with the given parameters.\n\nDetails\n\n- xsize: size of the domain in horizontal x direction [m]\n- ysize: size of the domain in vertical y direction [m]\n- rplanet: radius of the planet [m]\n- rcrust: radius of the crust [m]\n- Nx: number of basic grid nodes in horizontal x direction\n- Ny: number of basic grid nodes in vertical y direction\n- Nxmc: initial number of markers per cell in horizontal x direction\n- Nymc: initial number of markers per cell in vertical y direction\n\nReturns\n\n- exit code\n\n\n\n\n\n","category":"function"},{"location":"#HydrologyPlanetesimals.simulation_loop-Tuple{HydrologyPlanetesimals.StaticParameters}","page":"Home","title":"HydrologyPlanetesimals.simulation_loop","text":"Main simulation loop: run calculations with timestepping.\n\nsimulation_loop(sp)\n\n\nDetails\n\n- markers: arrays containing all marker properties\n- sp: static simulation parameters\n\nReturns\n\n- nothing\n\n\n\n\n\n","category":"method"},{"location":"#HydrologyPlanetesimals.total-Tuple{Any, Any, Any}","page":"Home","title":"HydrologyPlanetesimals.total","text":"Compute convex combination of fluid and solid properties to get total property.\n\ntotal(solid, fluid, phi)\n\n\nDetails\n\n- fluid: fluid properties\n- solid: solid properties\n- phi: fraction of fluid\n\nReturns\n\n- total: computed total property\n\n\n\n\n\n","category":"method"}]
}