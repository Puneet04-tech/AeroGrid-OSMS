// =============================================================================
// AeroGrid-OSMS - Main Execution File
// Orbital Space Station Mission Control & Energy Grid Simulator
// =============================================================================
// This is the main entry point for the application
// =============================================================================

// Clear workspace
clear;
clc;

printf("========================================\n");
printf("   AeroGrid-OSMS Initialization\n");
printf("========================================\n\n");

// Load all modules
printf("Loading modules...\n");

// Load orbital mechanics module
exec("modules/orbit_mechanics.sci", -1);
printf("  [✓] Orbital Mechanics Module\n");

// Load DSP filter module
exec("modules/dsp_filter.sci", -1);
printf("  [✓] DSP Filter Module\n");

// Load power grid module
exec("modules/power_grid.sci", -1);
printf("  [✓] Power Grid Module\n");

// Load finance tracker module
exec("modules/finance_tracker.sci", -1);
printf("  [✓] Finance Tracker Module\n");

// Load data logger module
exec("modules/data_logger.sci", -1);
printf("  [✓] Data Logger Module\n");

// Load GUI builder
exec("gui/gui_builder.sci", -1);
printf("  [✓] GUI Builder\n");

// Load panel GUIs
exec("gui/panel_flight_dynamics.sci", -1);
printf("  [✓] Flight Dynamics Panel\n");

exec("gui/panel_telemetry.sci", -1);
printf("  [✓] Telemetry Panel\n");

exec("gui/panel_power_grid.sci", -1);
printf("  [✓] Power Grid Panel\n");

printf("\nAll modules loaded successfully!\n\n");

// Initialize global simulation parameters
init_simulation_parameters();

// Launch main GUI
printf("Launching AeroGrid-OSMS GUI...\n");
launch_main_gui();

printf("\n========================================\n");
printf("   AeroGrid-OSMS Running\n");
printf("========================================\n");
