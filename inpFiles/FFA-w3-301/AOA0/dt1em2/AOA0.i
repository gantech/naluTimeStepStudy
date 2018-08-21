Simulations:
  - name: sim1
    time_integrator: ti_1
    optimizer: opt1

linear_solvers:

  - name: solve_scalar
    type: tpetra
    method: gmres
    preconditioner: sgs
    tolerance: 1e-5
    max_iterations: 150
    kspace: 150
    output_level: 0

  - name: hypre_mom
    type: hypre
    method: hypre_gmres
    preconditioner: boomerAMG
    tolerance: 1.0e-3
    max_iterations: 100
    kspace: 10
    output_level: 0
    absolute_tolerance: 1.0e-12
    segregated_solver: yes
    bamg_coarsen_type: 8
    bamg_interp_type: 6
    bamg_relax_type: 3
    bamg_strong_threshold: 0.25
    bamg_num_sweeps: 1
    bamg_max_levels: 1

  - name: solve_cont_hypre
    type: hypre
    method: hypre_gmres
    preconditioner: boomerAMG
    tolerance: 1.0e-3
    max_iterations: 200
    kspace: 10
    output_level: 0
    absolute_tolerance: 1.0e-8
    segregated_solver: yes
    bamg_output_level: 0
    bamg_coarsen_type: 8
    bamg_interp_type: 6
    #bamg_interp_type: 13
    bamg_cycle_type:  1
    bamg_relax_type: 3
    #bamg_relax_type: 8
    bamg_relax_order: 1
    #bamg_relax_order: 0
    #bamg_num_sweeps: 2
    bamg_num_sweeps: 2
    bamg_keep_transpose: 1
    bamg_max_levels: 9
    #bamg_trunc_factor: 0.1
    bamg_trunc_factor: 0.5
    #bamg_trunc_factor: 0.25
    #bamg_agg_num_levels: 2
    bamg_agg_num_levels: 2
    bamg_agg_interp_type: 4
    bamg_agg_pmax_elmts: 2
    bamg_pmax_elmts: 2
    #bamg_strong_threshold: 0.25
    bamg_strong_threshold: 0.25
    #bamg_non_galerkin_tol: 0.05
    bamg_non_galerkin_tol: 0.1
    bamg_non_galerkin_level_tols:
      #tolerances: [0.0, 0.01, 0.01]
       levels: [0, 1, 2]
       tolerances: [0.0, 0.01, 0.03 ]

  - name: solve_cont
    type: tpetra
    method: gmres
    preconditioner: muelu
    tolerance: 1e-3
    max_iterations: 75
    kspace: 75
    output_level: 0
    recompute_preconditioner: no
    muelu_xml_file_name: ../../mesh/milestone.xml

realms:

  - name: realm_1
    mesh: ../../mesh/FFA-w3-301-DTU_ndtw.exo
    automatic_decomposition_type: rcb
    use_edges: yes


    time_step_control:
     target_courant: 100.0
     time_step_change_factor: 1.05
   
    equation_systems:
      name: theEqSys
      max_iterations: 1

      solver_system_specification:
        velocity: solve_scalar
        turbulent_ke: solve_scalar
        specific_dissipation_rate: solve_scalar
        pressure: solve_cont

      systems:

        - LowMachEOM:
            name: myLowMach
            n_corr: 1
            non_orth_corr: 2
            max_iterations: 1
            convergence_tolerance: 1e-5

        - ShearStressTransport:
            name: mySST 
            max_iterations: 1
            convergence_tolerance: 1e-5

    initial_conditions:
      - constant: ic_1
        target_name: [interior-QUAD,interior-TRIANGLE]
        value:
          pressure: 0
          velocity: [25.1817553002169,0.0]
          turbulent_ke: 0.095118
          specific_dissipation_rate: 2266.4

    material_properties:
      target_name: [interior-QUAD, interior-TRIANGLE]
      specifications:
        - name: density
          type: constant
          value: 1.225
        - name: viscosity
          type: constant
          value: 2.57063752023048e-06

    boundary_conditions:

    - wall_boundary_condition: bc_wall
      target_name: Airfoil
      wall_user_data:
        velocity: [0,0]
        use_wall_function: no
        turbulent_ke: 0.0


    - inflow_boundary_condition: bc_inflow
      target_name: Inlet
      inflow_user_data:
        velocity: [25.1817553002169,0.0]
        turbulent_ke: 0.095118
        specific_dissipation_rate: 2266.4

    - open_boundary_condition: bc_open
      target_name: Outlet
      open_user_data:
        velocity: [0,0]
        pressure: 0.0
        turbulent_ke: 0.095118
        specific_dissipation_rate: 2266.4

    - symmetry_boundary_condition: bc_symBottom
      target_name: Bottom
      symmetry_user_data:

    - symmetry_boundary_condition: bc_symTop
      target_name: Top
      symmetry_user_data:

    solution_options:
      name: myOptions
      turbulence_model: sst
      activate_open_mdot_correction: no

      fix_pressure_at_node:
        value: 0.0
        node_lookup_type: spatial_location
        location: [200.0, 100.0, 0.0]
        search_target_part: [interior-QUAD,interior-TRIANGLE]
        search_method: stk_kdtree

      options:
        - hybrid_factor:
            velocity: 1.00
            turbulent_ke: 1.0
            specific_dissipation_rate: 1.0

        - alpha_upw:
            velocity: 1.0
            turbulent_ke: 1.0
            specific_dissipation_rate: 1.0

        - upw_factor:
            velocity: 0.0
            turbulent_ke: 0.0
            specific_dissipation_rate: 0.0
            
        - limiter:
            pressure: no
            velocity: yes
            turbulent_ke: yes
            specific_dissipation_rate: yes

        - projected_nodal_gradient:
            velocity: element
            pressure: element 
            turbulent_ke: element
            specific_dissipation_rate: element
    
        - input_variables_from_file:
            minimum_distance_to_wall: ndtw


    post_processing:
    
    - type: surface
      physics: surface_force_and_moment
      output_file_name: results/tiny.dat
      frequency: 10 
      parameters: [0,0]
      target_name: Airfoil

    output:
      output_data_base_name: results/tiny.e
      output_frequency: 10
      output_node_set: no 
      output_variables:
       - velocity
       - pressure
       - pressure_force
       - tau_wall 
       - y_plus
       - turbulent_ke
       - specific_dissipation_rate
       - minimum_distance_to_wall
       - sst_f_one_blending
       - turbulent_viscosity
       - udiag_field

    restart:
      restart_data_base_name: restart/tiny.rst
      restart_frequency: 100
      restart_start: 100
      
Time_Integrators:
  - StandardTimeIntegrator:
      name: ti_1
      start_time: 0
      time_step: 1e-2
#termination_time: 1.0 
      termination_step_count: 500
      time_stepping_type: fixed
      time_step_count: 0
      second_order_accuracy: no

      realms: 
        - realm_1


