// =============================================================================
// AeroGrid-OSMS - GUI Builder Module
// Main window layout and GUI component management
// =============================================================================

// Global GUI handles
global gui_handles;
gui_handles = struct(..
    "main_window", [], ..
    "panel_flight", [], ..
    "panel_telemetry", [], ..
    "panel_power", [], ..
    "status_bar", [], ..
    "emergency_button", [], ..
    "export_button", [] ..
);

// Global simulation parameters
global sim_params;
sim_params = struct(..
    "running", %f, ..
    "time_step", 1, ..
    "simulation_time", 0, ..
    "update_interval", 0.1 ..
);

// =============================================================================
// Initialize Global Simulation Parameters
// =============================================================================

function init_simulation_parameters()
    global sim_params;
    
    sim_params.running = %f;
    sim_params.time_step = 1;  // 1 second per step
    sim_params.simulation_time = 0;
    sim_params.update_interval = 0.1;  // GUI update interval (seconds)
    
    // Initialize all modules
    init_orbit(400, 7660);  // 400 km altitude, 7660 m/s velocity
    init_power_grid(80, 100);  // 80 kWh charge, 100 kWh capacity
    init_finance_tracker(10000000, 100000);  // $10M budget, 100000 kg fuel
    init_data_logger();
    
    // Generate initial test signals
    generate_test_signals(60, 0.5, %f);  // 60 seconds, 0.5 noise, no eclipse
endfunction

// =============================================================================
// Launch Main GUI Window
// =============================================================================

function launch_main_gui()
    global gui_handles;
    
    // Create main figure
    fig_width = 1400;
    fig_height = 900;
    
    gui_handles.main_window = figure(..
        "figure_name", "AeroGrid-OSMS - Mission Control", ..
        "position", [50, 50, fig_width, fig_height], ..
        "background", [0.15, 0.15, 0.2], ..
        "tag", "main_window" ..
    );
    
    // Create main title
    uicontrol(..
        "parent", gui_handles.main_window, ..
        "style", "text", ..
        "string", "AeroGrid-OSMS: Orbital Space Station Mission Control & Energy Grid Simulator", ..
        "position", [20, fig_height - 50, fig_width - 40, 30], ..
        "background", [0.15, 0.15, 0.2], ..
        "foreground", [1, 1, 1], ..
        "fontsize", 14, ..
        "fontweight", "bold" ..
    );
    
    // Create three main panels (using frames)
    panel_width = (fig_width - 80) / 3;
    panel_height = fig_height - 150;
    
    // Panel 1: Flight Dynamics (Left)
    gui_handles.panel_flight = uicontrol(..
        "parent", gui_handles.main_window, ..
        "style", "frame", ..
        "position", [20, 80, panel_width, panel_height], ..
        "background", [0.2, 0.2, 0.25], ..
        "tag", "panel_flight" ..
    );
    
    // Panel 2: Telemetry DSP (Center)
    gui_handles.panel_telemetry = uicontrol(..
        "parent", gui_handles.main_window, ..
        "style", "frame", ..
        "position", [20 + panel_width + 20, 80, panel_width, panel_height], ..
        "background", [0.2, 0.2, 0.25], ..
        "tag", "panel_telemetry" ..
    );
    
    // Panel 3: Power Grid & Finance (Right)
    gui_handles.panel_power = uicontrol(..
        "parent", gui_handles.main_window, ..
        "style", "frame", ..
        "position", [20 + 2 * (panel_width + 20), 80, panel_width, panel_height], ..
        "background", [0.2, 0.2, 0.25], ..
        "tag", "panel_power" ..
    );
    
    // Build individual panels
    build_flight_dynamics_panel(gui_handles.panel_flight, panel_width, panel_height);
    build_telemetry_panel(gui_handles.panel_telemetry, panel_width, panel_height);
    build_power_grid_panel(gui_handles.panel_power, panel_width, panel_height);
    
    // Create control buttons at bottom
    create_control_buttons(fig_width);
    
    // Create status bar
    gui_handles.status_bar = uicontrol(..
        "parent", gui_handles.main_window, ..
        "style", "text", ..
        "string", "System Ready - Initialize simulation to begin", ..
        "position", [20, 20, fig_width - 40, 30], ..
        "background", [0.1, 0.1, 0.15], ..
        "foreground", [0, 1, 0], ..
        "fontsize", 10, ..
        "horizontalalignment", "left" ..
    );
    
    printf("Main GUI launched successfully!\n");
endfunction

// =============================================================================
// Create Control Buttons
// =============================================================================

function create_control_buttons(fig_width)
    global gui_handles;
    
    button_y = 50;
    button_width = 150;
    button_height = 25;
    
    // Start/Stop Simulation Button
    uicontrol(..
        "parent", gui_handles.main_window, ..
        "style", "pushbutton", ..
        "string", "Start Simulation", ..
        "position", [20, button_y, button_width, button_height], ..
        "callback", "toggle_simulation()", ..
        "background", [0.3, 0.6, 0.3], ..
        "foreground", [1, 1, 1] ..
    );
    
    // Emergency Button
    gui_handles.emergency_button = uicontrol(..
        "parent", gui_handles.main_window, ..
        "style", "pushbutton", ..
        "string", "⚠ SPACE DEBRIS EMERGENCY", ..
        "position", [20 + button_width + 20, button_y, button_width + 50, button_height], ..
        "callback", "trigger_emergency()", ..
        "background", [0.8, 0.2, 0.2], ..
        "foreground", [1, 1, 1], ..
        "fontsize", 9, ..
        "fontweight", "bold" ..
    );
    
    // Export Data Button
    gui_handles.export_button = uicontrol(..
        "parent", gui_handles.main_window, ..
        "style", "pushbutton", ..
        "string", "Export Telemetry", ..
        "position", [20 + 2 * (button_width + 20) + 50, button_y, button_width, button_height], ..
        "callback", "export_all_data()", ..
        "background", [0.3, 0.3, 0.6], ..
        "foreground", [1, 1, 1] ..
    );
    
    // Reset Button
    uicontrol(..
        "parent", gui_handles.main_window, ..
        "style", "pushbutton", ..
        "string", "Reset Simulation", ..
        "position", [fig_width - button_width - 20, button_y, button_width, button_height], ..
        "callback", "reset_simulation()", ..
        "background", [0.6, 0.6, 0.3], ..
        "foreground", [1, 1, 1] ..
    );
endfunction

// =============================================================================
// Toggle Simulation
// =============================================================================

function toggle_simulation()
    global sim_params;
    
    sim_params.running = ~sim_params.running;
    
    if sim_params.running then
        update_status("Simulation Running", "green");
        run_simulation_step();
    else
        update_status("Simulation Paused", "yellow");
    end
endfunction

// =============================================================================
// Run Single Simulation Step
// =============================================================================

function run_simulation_step()
    global sim_params;
    
    if ~sim_params.running then
        return;
    end
    
    // Update orbital mechanics
    update_orbit_state(sim_params.time_step);
    
    // Get eclipse status
    global orbit_state;
    eclipse_mode = orbit_state.eclipse_mode;
    
    // Update signal processing based on eclipse
    global signal_state;
    if ~isempty(signal_state.raw_signal) then
        // Regenerate signals for current eclipse state
        generate_test_signals(60, signal_state.noise_level, eclipse_mode);
    end
    
    // Update power grid
    global power_state;
    solar_power = 0;
    if ~isempty(signal_state.filtered_signal) then
        solar_power = mean(signal_state.filtered_signal);
    end
    update_power_grid(solar_power, sim_params.time_step);
    
    // Update financial tracker
    global finance_state;
    update_mission_time(sim_params.time_step);
    
    // Log data
    global log_state, orbit_state, power_state, finance_state;
    log_telemetry(sim_params.simulation_time, solar_power, ..
                  signal_state.raw_signal, signal_state.filtered_signal);
    log_orbital_data(sim_params.simulation_time, orbit_state.altitude, ..
                     orbit_state.velocity, orbit_state.position_x, ..
                     orbit_state.position_y, orbit_state.eclipse_mode);
    log_power_data(sim_params.simulation_time, power_state.battery_charge, ..
                   power_state.solar_input, power_state.consumer_load, ..
                   power_state.net_power, power_state.battery_health);
    log_finance_data(sim_params.simulation_time, finance_state.remaining_budget, ..
                     finance_state.fuel_cost_total, finance_state.energy_cost_total, ..
                     finance_state.fuel_remaining, finance_state.cost_efficiency);
    
    // Update simulation time
    sim_params.simulation_time = sim_params.simulation_time + sim_params.time_step;
    
    // Update GUI displays
    update_all_displays();
    
    // Check for critical conditions
    check_critical_conditions();
    
    // Schedule next update
    if sim_params.running then
        sleep(sim_params.update_interval * 1000);  // Convert to milliseconds
        run_simulation_step();
    end
endfunction

// =============================================================================
// Update All GUI Displays
// =============================================================================

function update_all_displays()
    // Update flight dynamics panel
    update_flight_display();
    
    // Update telemetry panel
    update_telemetry_display();
    
    // Update power grid panel
    update_power_display();
endfunction

// =============================================================================
// Check Critical Conditions
// =============================================================================

function check_critical_conditions()
    global orbit_state, power_state;
    
    if orbit_state.critical_attrition then
        update_status("CRITICAL: Orbital Attrition Detected!", "red");
    elseif power_state.battery_health <= 0 then
        update_status("MISSION FAILED: Battery Depleted!", "red");
    elseif power_state.battery_charge <= 10 then
        update_status("WARNING: Critical Battery Level!", "red");
    end
endfunction

// =============================================================================
// Update Status Bar
// =============================================================================

function update_status(message, color)
    global gui_handles;
    
    select color
    case "red" then
        fg_color = [1, 0.3, 0.3];
    case "green" then
        fg_color = [0.3, 1, 0.3];
    case "yellow" then
        fg_color = [1, 1, 0.3];
    case "blue" then
        fg_color = [0.3, 0.3, 1];
    else
        fg_color = [1, 1, 1];
    end
    
    gui_handles.status_bar.string = message;
    gui_handles.status_bar.foreground = fg_color;
endfunction

// =============================================================================
// Trigger Emergency Mode
// =============================================================================

function trigger_emergency()
    global orbit_state, signal_state;
    
    // Inject massive noise
    inject_emergency_noise();
    
    // Reduce orbital velocity (simulate collision)
    orbit_state.velocity_x = orbit_state.velocity_x * 0.95;
    orbit_state.velocity_y = orbit_state.velocity_y * 0.95;
    orbit_state.velocity = orbit_state.velocity * 0.95;
    
    update_status("EMERGENCY: Space Debris Collision Detected!", "red");
    
    printf("Emergency triggered: Noise injected and orbit degraded!\n");
endfunction

// =============================================================================
// Reset Simulation
// =============================================================================

function reset_simulation()
    global sim_params;
    
    // Stop simulation
    sim_params.running = %f;
    
    // Reinitialize all parameters
    init_simulation_parameters();
    
    // Update displays
    update_all_displays();
    
    update_status("Simulation Reset - Ready to start", "green");
    
    printf("Simulation reset to initial conditions.\n");
endfunction

// =============================================================================
// Get Panel Position Helper
// =============================================================================

function [x, y] = get_panel_position(parent_handle, rel_x, rel_y, width, height)
    // Get parent position
    parent_pos = parent_handle.position;
    
    // Calculate absolute position
    x = parent_pos(1) + rel_x;
    y = parent_pos(2) + rel_y;
endfunction
