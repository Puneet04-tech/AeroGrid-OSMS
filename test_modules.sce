// =============================================================================
// AeroGrid-OSMS - Module Validation Test Script
// Tests all modules to ensure they load and function correctly
// =============================================================================

// Clear workspace
clear;
clc;

printf("========================================\n");
printf("   AeroGrid-OSMS Module Testing\n");
printf("========================================\n\n");

test_passed = 0;
test_failed = 0;

// =============================================================================
// Test 1: Orbital Mechanics Module
// =============================================================================
printf("Test 1: Loading Orbital Mechanics Module...\n");
try
    exec("modules/orbit_mechanics.sci", -1);
    printf("  [PASS] Module loaded successfully\n");
    
    // Test orbital calculations
    init_orbit(400, 7660);
    printf("  [PASS] Orbit initialized at 400 km\n");
    
    // Test ODE solver
    update_orbit_state(1);
    printf("  [PASS] Orbit state updated\n");
    
    // Test thruster function
    [delta_v, cost] = fire_thrusters(10, 50000);
    printf("  [PASS] Thruster test: delta_v = %.2f m/s, cost = $%.2f\n", delta_v, cost);
    
    test_passed = test_passed + 4;
catch
    printf("  [FAIL] Error: %s\n", lasterror());
    test_failed = test_failed + 1;
end
printf("\n");

// =============================================================================
// Test 2: DSP Filter Module
// =============================================================================
printf("Test 2: Loading DSP Filter Module...\n");
try
    exec("modules/dsp_filter.sci", -1);
    printf("  [PASS] Module loaded successfully\n");
    
    // Test signal generation
    generate_test_signals(60, 0.5, %f);
    printf("  [PASS] Test signals generated\n");
    
    // Test moving average filter
    set_filter_parameters("moving_average", 5, 0.1);
    printf("  [PASS] Moving average filter applied\n");
    
    // Test Butterworth filter
    set_filter_parameters("butterworth", 5, 0.1);
    printf("  [PASS] Butterworth filter applied\n");
    
    // Test emergency noise injection
    inject_emergency_noise();
    printf("  [PASS] Emergency noise injected\n");
    
    test_passed = test_passed + 4;
catch
    printf("  [FAIL] Error: %s\n", lasterror());
    test_failed = test_failed + 1;
end
printf("\n");

// =============================================================================
// Test 3: Power Grid Module
// =============================================================================
printf("Test 3: Loading Power Grid Module...\n");
try
    exec("modules/power_grid.sci", -1);
    printf("  [PASS] Module loaded successfully\n");
    
    // Test power grid initialization
    init_power_grid(80, 100);
    printf("  [PASS] Power grid initialized\n");
    
    // Test consumer load calculation
    calculate_consumer_load();
    printf("  [PASS] Consumer load calculated\n");
    
    // Test power grid update
    update_power_grid(250, 1);
    printf("  [PASS] Power grid updated\n");
    
    // Test subsystem toggle
    toggle_subsystem("oxygen");
    printf("  [PASS] Subsystem toggled\n");
    
    test_passed = test_passed + 4;
catch
    printf("  [FAIL] Error: %s\n", lasterror());
    test_failed = test_failed + 1;
end
printf("\n");

// =============================================================================
// Test 4: Finance Tracker Module
// =============================================================================
printf("Test 4: Loading Finance Tracker Module...\n");
try
    exec("modules/finance_tracker.sci", -1);
    printf("  [PASS] Module loaded successfully\n");
    
    // Test finance initialization
    init_finance_tracker(10000000, 100000);
    printf("  [PASS] Finance tracker initialized\n");
    
    // Test burn cost recording
    record_burn_cost(100, 1000, 10);
    printf("  [PASS] Burn cost recorded\n");
    
    // Test energy cost recording
    record_energy_cost(100, 50);
    printf("  [PASS] Energy cost recorded\n");
    
    // Test cost efficiency calculation
    calculate_cost_efficiency();
    printf("  [PASS] Cost efficiency calculated\n");
    
    test_passed = test_passed + 4;
catch
    printf("  [FAIL] Error: %s\n", lasterror());
    test_failed = test_failed + 1;
end
printf("\n");

// =============================================================================
// Test 5: Data Logger Module
// =============================================================================
printf("Test 5: Loading Data Logger Module...\n");
try
    exec("modules/data_logger.sci", -1);
    printf("  [PASS] Module loaded successfully\n");
    
    // Test data logger initialization
    init_data_logger();
    printf("  [PASS] Data logger initialized\n");
    
    // Test telemetry logging
    log_telemetry(0, 250, rand(100,1)*10, rand(100,1)*5);
    printf("  [PASS] Telemetry logged\n");
    
    // Test orbital data logging
    log_orbital_data(0, 400000, 7660, 6771000, 0, %f);
    printf("  [PASS] Orbital data logged\n");
    
    // Test power data logging
    log_power_data(0, 80, 250, 45, 205, 100);
    printf("  [PASS] Power data logged\n");
    
    // Test finance data logging
    log_finance_data(0, 10000000, 0, 0, 100000, 100);
    printf("  [PASS] Finance data logged\n");
    
    test_passed = test_passed + 5;
catch
    printf("  [FAIL] Error: %s\n", lasterror());
    test_failed = test_failed + 1;
end
printf("\n");

// =============================================================================
// Test 6: GUI Builder Module
// =============================================================================
printf("Test 6: Loading GUI Builder Module...\n");
try
    exec("gui/gui_builder.sci", -1);
    printf("  [PASS] Module loaded successfully\n");
    
    // Test simulation parameter initialization
    init_simulation_parameters();
    printf("  [PASS] Simulation parameters initialized\n");
    
    // Note: We don't actually launch the GUI in automated testing
    // as it requires user interaction
    printf("  [INFO] GUI launch skipped in automated test\n");
    
    test_passed = test_passed + 2;
catch
    printf("  [FAIL] Error: %s\n", lasterror());
    test_failed = test_failed + 1;
end
printf("\n");

// =============================================================================
// Test 7: Panel GUIs
// =============================================================================
printf("Test 7: Loading Panel GUIs...\n");
try
    exec("gui/panel_flight_dynamics.sci", -1);
    printf("  [PASS] Flight Dynamics Panel loaded\n");
    
    exec("gui/panel_telemetry.sci", -1);
    printf("  [PASS] Telemetry Panel loaded\n");
    
    exec("gui/panel_power_grid.sci", -1);
    printf("  [PASS] Power Grid Panel loaded\n");
    
    test_passed = test_passed + 3;
catch
    printf("  [FAIL] Error: %s\n", lasterror());
    test_failed = test_failed + 1;
end
printf("\n");

// =============================================================================
// Test Summary
// =============================================================================
printf("========================================\n");
printf("   Test Summary\n");
printf("========================================\n");
printf("Tests Passed: %d\n", test_passed);
printf("Tests Failed: %d\n", test_failed);
printf("Total Tests: %d\n", test_passed + test_failed);

if test_failed == 0 then
    printf("\n✓ ALL TESTS PASSED!\n");
else
    printf("\n✗ SOME TESTS FAILED - Please review errors above\n");
end
printf("========================================\n");
