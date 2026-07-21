// =============================================================================
// AeroGrid-OSMS - GUI Builder Module
// Main window layout and GUI component management
// =============================================================================

// GUI Builder Constants
GUI_WINDOW_WIDTH = 1400;           // Main window width in pixels
GUI_WINDOW_HEIGHT = 900;          // Main window height in pixels
GUI_PANEL_MARGIN = 20;            // Margin between panels
GUI_BUTTON_WIDTH = 150;           // Standard button width
GUI_BUTTON_HEIGHT = 25;           // Standard button height
GUI_STATUS_BAR_HEIGHT = 30;       // Status bar height
GUI_TITLE_HEIGHT = 50;            // Title bar height

// Simulation Constants
DEFAULT_TIME_STEP = 1;            // Simulation time step (seconds)
DEFAULT_UPDATE_INTERVAL = 0.1;    // GUI update interval (seconds)
INITIAL_ALTITUDE = 400;           // Initial orbital altitude (km)
INITIAL_VELOCITY = 7660;          // Initial orbital velocity (m/s)
INITIAL_BATTERY_CHARGE = 80;      // Initial battery charge (kWh)
INITIAL_BATTERY_CAPACITY = 100;  // Initial battery capacity (kWh)
INITIAL_BUDGET = 10000000;        // Initial mission budget ($)
INITIAL_FUEL = 100000;           // Initial fuel (kg)
DEFAULT_SIGNAL_DURATION = 60;    // Default signal duration (seconds)
DEFAULT_NOISE_LEVEL = 0.5;        // Default noise level

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
    "time_step", DEFAULT_TIME_STEP, ..
    "simulation_time", 0, ..
    "update_interval", DEFAULT_UPDATE_INTERVAL ..
);

// =============================================================================
// Initialize Global Simulation Parameters
// =============================================================================

function init_simulation_parameters()
    // Initialize all simulation parameters and modules
    // Sets up the initial state for the entire simulation
    
    global sim_params;
    
    // Reset simulation state
    sim_params.running = %f;
    sim_params.time_step = DEFAULT_TIME_STEP;
    sim_params.simulation_time = 0;
    sim_params.update_interval = DEFAULT_UPDATE_INTERVAL;
    
    // Initialize all modules with default parameters
    init_orbit(INITIAL_ALTITUDE, INITIAL_VELOCITY);
    init_power_grid(INITIAL_BATTERY_CHARGE, INITIAL_BATTERY_CAPACITY);
    init_finance_tracker(INITIAL_BUDGET, INITIAL_FUEL);
    init_data_logger();
    
    // Generate initial test signals for telemetry
    generate_test_signals(DEFAULT_SIGNAL_DURATION, DEFAULT_NOISE_LEVEL, %f);
    
    printf("Simulation parameters initialized.\n");
endfunction

// =============================================================================
// Launch Main GUI Window
// =============================================================================

function launch_main_gui()
    // Launch the main GUI window with three panels
    // Creates the main figure, panels, and control buttons
    
    global gui_handles;
    
    // Use constants for window dimensions
    fig_width = GUI_WINDOW_WIDTH;
    fig_height = GUI_WINDOW_HEIGHT;
    
    // Create main figure with dark theme
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
    
    // Calculate panel dimensions with margins
    panel_width = (fig_width - 4 * GUI_PANEL_MARGIN) / 3;
    panel_height = fig_height - GUI_TITLE_HEIGHT - GUI_STATUS_BAR_HEIGHT - GUI_PANEL_MARGIN;
    
    // Panel 1: Flight Dynamics (Left)
    gui_handles.panel_flight = uicontrol(..
        "parent", gui_handles.main_window, ..
        "style", "frame", ..
        "position", [GUI_PANEL_MARGIN, GUI_STATUS_BAR_HEIGHT + GUI_PANEL_MARGIN, ..
                     panel_width, panel_height], ..
        "background", [0.2, 0.2, 0.25], ..
        "tag", "panel_flight" ..
    );
    
    // Panel 2: Telemetry DSP (Center)
    gui_handles.panel_telemetry = uicontrol(..
        "parent", gui_handles.main_window, ..
        "style", "frame", ..
        "position", [GUI_PANEL_MARGIN + panel_width + GUI_PANEL_MARGIN, ..
                     GUI_STATUS_BAR_HEIGHT + GUI_PANEL_MARGIN, panel_width, panel_height], ..
        "background", [0.2, 0.2, 0.25], ..
        "tag", "panel_telemetry" ..
    );
    
    // Panel 3: Power Grid & Finance (Right)
    gui_handles.panel_power = uicontrol(..
        "parent", gui_handles.main_window, ..
        "style", "frame", ..
        "position", [GUI_PANEL_MARGIN + 2 * (panel_width + GUI_PANEL_MARGIN), ..
                     GUI_STATUS_BAR_HEIGHT + GUI_PANEL_MARGIN, panel_width, panel_height], ..
        "background", [0.2, 0.2, 0.25], ..
        "tag", "panel_power" ..
    );
    
    // Build individual panels
    build_flight_dynamics_panel(gui_handles.panel_flight, panel_width, panel_height);
    build_telemetry_panel(gui_handles.panel_telemetry, panel_width, panel_height);
    build_power_grid_panel(gui_handles.panel_power, panel_width, panel_height);
    
    // Create control buttons at bottom
    create_control_buttons(fig_width);
    
    // Create status bar with initial message
    gui_handles.status_bar = uicontrol(..
        "parent", gui_handles.main_window, ..
        "style", "text", ..
        "string", "System Ready - Initialize simulation to begin", ..
        "position", [GUI_PANEL_MARGIN, GUI_PANEL_MARGIN, ..
                     fig_width - 2 * GUI_PANEL_MARGIN, GUI_STATUS_BAR_HEIGHT], ..
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
    // Create control buttons at the bottom of the main window
    // Includes Start/Stop, Emergency, Export, and Reset buttons
    
    global gui_handles;
    
    button_y = GUI_STATUS_BAR_HEIGHT + GUI_PANEL_MARGIN;
    button_width = GUI_BUTTON_WIDTH;
    button_height = GUI_BUTTON_HEIGHT;
    
    // Start/Stop Simulation Button
    uicontrol(..
        "parent", gui_handles.main_window, ..
        "style", "pushbutton", ..
        "string", "Start Simulation", ..
        "position", [GUI_PANEL_MARGIN, button_y, button_width, button_height], ..
        "callback", "toggle_simulation()", ..
        "background", [0.3, 0.6, 0.3], ..
        "foreground", [1, 1, 1] ..
    );
    
    // Emergency Button
    gui_handles.emergency_button = uicontrol(..
        "parent", gui_handles.main_window, ..
        "style", "pushbutton", ..
        "string", "Space Debris Emergency", ..
        "position", [GUI_PANEL_MARGIN + button_width + GUI_PANEL_MARGIN, button_y, ..
                     button_width + 50, button_height], ..
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
        "position", [GUI_PANEL_MARGIN + 2 * (button_width + GUI_PANEL_MARGIN) + 50, ..
                     button_y, button_width, button_height], ..
        "callback", "export_all_data()", ..
        "background", [0.3, 0.3, 0.6], ..
        "foreground", [1, 1, 1] ..
    );
    
    // Reset Button
    uicontrol(..
        "parent", gui_handles.main_window, ..
        "style", "pushbutton", ..
        "string", "Reset Simulation", ..
        "position", [fig_width - button_width - GUI_PANEL_MARGIN, button_y, ..
                     button_width, button_height], ..
        "callback", "reset_simulation()", ..
        "background", [0.6, 0.6, 0.3], ..
        "foreground", [1, 1, 1] ..
    );
endfunction

// =============================================================================
// Toggle Simulation
// =============================================================================

function toggle_simulation()
    // Toggle simulation running state
    // Starts or pauses the simulation loop
    
    global sim_params;
    
    sim_params.running = ~sim_params.running;
    
    if sim_params.running then
        update_status("Simulation Running - Orbital mechanics active", "green");
        run_simulation_step();
    else
        update_status("Simulation Paused - Press Start to continue", "yellow");
    end
endfunction

// =============================================================================
// Run Single Simulation Step
// =============================================================================

function run_simulation_step()
    // Execute a single simulation step
    // Updates all modules and logs data
    
    global sim_params;
    
    if ~sim_params.running then
        return;
    end
    
    // Update orbital mechanics
    update_orbit_state(sim_params.time_step);
    
    // Get eclipse status for signal processing
    global orbit_state;
    eclipse_mode = orbit_state.eclipse_mode;
    
    // Update signal processing based on eclipse mode
    global signal_state;
    if ~isempty(signal_state.raw_signal) then
        generate_test_signals(DEFAULT_SIGNAL_DURATION, signal_state.noise_level, eclipse_mode);
    end
    
    // Update power grid with solar input from filtered signal
    global power_state;
    solar_power = 0;
    if ~isempty(signal_state.filtered_signal) then
        solar_power = mean(signal_state.filtered_signal);
    end
    update_power_grid(solar_power, sim_params.time_step);
    
    // Update financial tracker with mission time
    global finance_state;
    update_mission_time(sim_params.time_step);
    
    // Log all data types
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
    
    // Advance simulation time
    sim_params.simulation_time = sim_params.simulation_time + sim_params.time_step;
    
    // Update all GUI displays
    update_all_displays();
    
    // Check for critical conditions and warnings
    check_critical_conditions();
    
    // Schedule next update if still running
    if sim_params.running then
        sleep(sim_params.update_interval * 1000);  // Convert to milliseconds
        run_simulation_step();
    end
endfunction

// =============================================================================
// Update All GUI Displays
// =============================================================================

function update_all_displays()
    // Update all GUI panel displays
    // Refreshes flight dynamics, telemetry, and power grid panels
    
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
    // Check for critical mission conditions
    // Updates status bar with warnings or failures
    
    global orbit_state, power_state;
    
    if orbit_state.critical_attrition then
        update_status("CRITICAL: Orbital Attrition Detected! Altitude too low!", "red");
    elseif power_state.battery_health <= 0 then
        update_status("MISSION FAILED: Battery Depleted! System shutdown imminent.", "red");
    elseif power_state.battery_charge <= 10 then
        update_status("WARNING: Critical Battery Level! Below 10 kWh.", "red");
    end
endfunction

// =============================================================================
// Update Status Bar
// =============================================================================

function update_status(message, color)
    // Update the status bar with a colored message
    // message: status text to display
    // color: "red", "green", "yellow", "blue", or "white"
    
    global gui_handles;
    
    // Map color names to RGB values
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
    
    // Update status bar with handle validation
    if ~isempty(gui_handles.status_bar) then
        try
            gui_handles.status_bar.string = message;
            gui_handles.status_bar.foreground = fg_color;
        catch
            // Handle is invalid, skip update
        end
    end
endfunction

// =============================================================================
// Trigger Emergency Mode
// =============================================================================

function trigger_emergency()
    // Trigger emergency mode simulating space debris collision
    // Injects noise and degrades orbital velocity
    
    global orbit_state, signal_state;
    
    // Inject massive noise into telemetry
    inject_emergency_noise();
    
    // Reduce orbital velocity by 5% (simulate collision impact)
    orbit_state.velocity_x = orbit_state.velocity_x * 0.95;
    orbit_state.velocity_y = orbit_state.velocity_y * 0.95;
    orbit_state.velocity = orbit_state.velocity * 0.95;
    
    update_status("EMERGENCY: Space Debris Collision Detected! Orbit degraded!", "red");
    
    printf("Emergency triggered: Noise injected and orbit degraded by 5%%.\n");
endfunction

// =============================================================================
// Reset Simulation
// =============================================================================

function reset_simulation()
    // Reset simulation to initial conditions
    // Stops simulation and reinitializes all modules
    
    global sim_params;
    
    // Stop simulation if running
    sim_params.running = %f;
    
    // Reinitialize all parameters to defaults
    init_simulation_parameters();
    
    // Update all GUI displays
    update_all_displays();
    
    update_status("Simulation Reset - All systems restored to initial state", "green");
    
    printf("Simulation reset to initial conditions.\n");
endfunction

// =============================================================================
// Get Panel Position Helper
// =============================================================================

function [x, y] = get_panel_position(parent_handle, rel_x, rel_y, width, height)
    // Calculate absolute position from parent-relative coordinates
    // parent_handle: parent frame handle
    // rel_x, rel_y: relative coordinates within parent
    // width, height: dimensions (unused but kept for interface consistency)
    // Returns: absolute x, y coordinates
    
    // Get parent position
    parent_pos = parent_handle.position;
    
    // Calculate absolute position
    x = parent_pos(1) + rel_x;
    y = parent_pos(2) + rel_y;
endfunction
