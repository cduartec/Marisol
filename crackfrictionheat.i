[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 10
  ny = 10
  xmin = 0.0
  xmax = 10.0
  ymin = 0.0
  ymax = 10.0
  displacements = 'disp_x disp_y'
[]

[Variables]
  [./disp_x]
  [../]
  [./disp_y]
  [../]
  [./initialc]
  [../]
  [./b]
  [../]
  [./temp]
  [../]
[]

[AuxVariables]
  [./stress_xx]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./stress_yy]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./stress_xy]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./e_xx]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./e_yy]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./e_xy]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./c]
    order = SECOND
    family = MONOMIAL
  [../]
  [./damage]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./x_bracket]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./dcdx]
    order = FIRST
    family = MONOMIAL
  [../]
  [./dcdy]
    order = FIRST
    family = MONOMIAL
  [../]
[]

[ICs]
  [./cIC]
    type = FunctionIC
    variable = initialc
    function = initialDamage
  [../]
  [./tempIC]
    type = FunctionIC
    variable = temp
    function = initialTemp
  [../]
[]

[Functions]
  [./tfunc]
    type = ParsedFunction
    value = -t
  [../]
  [./initialDamage]
    type = ParsedFunction
    value = 'exp(-abs(y-5.0)/1.0)*if(x/10.0,0,1)'
  [../]
  [./initialTemp]
    type = ParsedFunction
    value = '293'
  [../]
[]

[Kernels]
  [./TensorMechanics]
    displacements = 'disp_x disp_y'
    use_displaced_mesh = true
  [../]
  [./dcdt]
    type = TimeDerivative
    variable = initialc
  [../]
  [./pfintvar]
    type = Reaction
    variable = b
  [../]
  [./pfintcoupled]
    type = PFFracCoupledInterface
    variable = b
    c = c
  [../]
  [./hc]
    type = HeatConduction
    variable = temp
    diffusion_coefficient = thermal_conductivity
  [../]
  [./hct]
    type = HeatConductionTimeDerivative
    variable = temp
    specific_heat = specific_heat
    density_name = density
  [../]
  [./friction]
    type = CrackFrictionHeatSource
    variable = temp
    friction_coefficient = 100.0
    dcdx = dcdx
    dcdy = dcdy
  [../]
[]

[UserObjects]
  [./prop_read]
    type = ElementPropertyReadFile
    prop_file_name = 'euler_ang_file_beamorientation0.txt'
    nprop = 3
    read_type = element
  [../]
[]

[AuxKernels]
  [./stress_xx]
    type = RankTwoAux
    variable = stress_xx
    rank_two_tensor = stress
    index_j = 0
    index_i = 0
    execute_on = timestep_end
    #block = 0
  [../]
  [./stress_yy]
    type = RankTwoAux
    variable = stress_yy
    rank_two_tensor = stress
    index_j = 1
    index_i = 1
    execute_on = timestep_end
    #block = 0
  [../]
  [./stress_xy]
    type = RankTwoAux
    variable = stress_xy
    rank_two_tensor = stress
    index_j = 1
    index_i = 0
    execute_on = timestep_end
    #block = 0
  [../]
  [./e_xx]
    type = RankTwoAux
    variable = e_xx
    rank_two_tensor = strain_rate
    index_j = 0
    index_i = 0
    execute_on = timestep_end
    #block = 0
  [../]
  [./e_yy]
    type = RankTwoAux
    variable = e_yy
    rank_two_tensor = strain_rate
    index_j = 1
    index_i = 1
    execute_on = timestep_end
    #block = 0
  [../]
  [./e_xy]
    type = RankTwoAux
    variable = e_xy
    rank_two_tensor = strain_rate
    index_j = 1
    index_i = 0
    execute_on = timestep_end
    #block = 0
  [../]
  [./c]
    type = MaterialRealAux
    variable = c
    property = c
  [../]
  [./damage]
    type = MaterialRealAux
    variable = damage
    property = damage
  [../]
  [./x_bracket]
    type = MaterialRealAux
    variable = x_bracket
    property = x_bracket
  [../]
  [./dcdx]
    type = VariableGradientComponent
    variable = dcdx
    gradient_variable = c
    component = 'x'
  [../]
  [./dcdy]
    type = VariableGradientComponent
    variable = dcdy
    gradient_variable = c
    component = 'y'
  [../]
  #[./crack_normal]
  #  type = MaterialRealVectorValueAux
  #[../]
[]

[BCs]
  [./ydisp]
    type = FunctionPresetBC
    variable = disp_y
    boundary = top
    function = tfunc
  [../]
  [./yfix]
    type = PresetBC
    variable = disp_y
    boundary = bottom
    value = 0
  [../]
  [./xfix]
    type = PresetBC
    variable = disp_x
    boundary = left
    value = 0
  [../]
  [./tright]
    type = DirichletBC
    variable = temp
    boundary = right
    value = 293
  [../]
  [./tbottom]
    type = DirichletBC
    variable = temp
    boundary = bottom
    value = 293
  [../]
  [./ttop]
    type = DirichletBC
    variable = temp
    boundary = top
    value = 293
  [../]
[]

[Materials]
  [./crysp]
    type = CrystalPlasticityPFDamageMiehe
    block = 0
    gtol = 1e-2
    abs_tol = 1e-4
    slip_incr_tol = 0.0025
    maximum_substep_iteration = 1
    gen_random_stress_flag = false
    slip_sys_file_name = input_slip_sys_HMX_austin.txt
    nss = 10
    num_slip_sys_flowrate_props = 2 #Number of properties in a slip system
    flowprops = '1 1 1.0e-3 0.1 2 3 1.46e-3 0.1 4 4 2.0e-3 0.1 5 5 5.6e-6 0.1 6 6 17.7 0.1 7 8 2.04e-3 0.1 9 10 34.9e-3 0.1'
    hprops = '1.0 9.34e-3 0.10303 0.15573 2.5'
    gprops = '1 10 0.10303'
    tan_mod_type = exact
    l = 1.0
    visco = 100.0
    Wc = 0.1
    gc_prop_var = 'gc_prop'
    kdamage = 1e-6
    C0 = 0.0
    C1 = 0.0
    n_Murnaghan = 6.6
    bulk_modulus_ref = 15.588
    b = b
    initialc = initialc
  [../]
  [./strain]
    type = ComputeFiniteStrain
    block = 0
    displacements = 'disp_x disp_y'
  [../]
  [./elasticity_tensor]
    type = ComputeElasticityTensorCP
    block = 0
    C_ijkl = '22.2 9.6 13.2 0.0 0.1 0.0 23.9 13.0 0.0 -4.7 0.0 23.4 0.0 -1.6 0.0 9.2 0.0 -2.5 11.1 0.0 10.1'
    fill_method = symmetric21
    read_prop_user_object = prop_read
  [../]
  [./density]
    type = GenericConstantMaterial
    block = 0
    prop_names = 'density'
    prop_values = '1.9'
  [../]
  [./thermal_conductivity]
    type = GenericConstantMaterial
    block = 0
    prop_names = 'thermal_conductivity'
    prop_values = '1.0'
  [../]
  [./specific_heat]
    type = GenericConstantMaterial
    block = 0
    prop_names = 'specific_heat'
    prop_values = '0.001'
  [../]
  [./pfbulkmat]
    type = PFFracBulkRateMaterial
    gc = 0.01
  [../]
  [./crackfrictionheatenergy]
    type = ComputeCrackFrictionHeatEnergy
    friction_coefficient = 100.0
    dcdx = dcdx
    dcdy = dcdy
  [../]
[]

[Postprocessors]
[]

[Preconditioning]
  active = 'smp'
  [./smp]
    type = SMP
    full = true
  [../]
[]

[Executioner]
  type = Transient

  solve_type = PJFNK
  petsc_options_iname = '-pc_type -ksp_gmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap'
  petsc_options_value = 'asm      101                  preonly       lu           1'

  nl_rel_tol = 1e-6
  #nl_abs_tol = 1e-9
  l_max_its = 20
  nl_max_its = 20

  dt = 1e-3
  dtmin = 1e-7
  num_steps = 10
[]

[Outputs]
  exodus = true
[]
