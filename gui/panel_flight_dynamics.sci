// =============================================================================
// AeroGrid-OSMS - Flight Dynamics Panel
// Panel 1: Interactive Flight Dynamics Simulator
// =============================================================================

// Global handles for flight dynamics panel
global flight_handles;
flight_handles = struct(..
    "title", [], ..
    "altitude_slider", [], ..
    "altitude_label", [], ..
    "thruster_button", [], ..
    "orbit_axes", [], ..
    "status_text", [], ..
    "velocity_display", [], ..
    "period_display", [], ..
    "eclipse_display", [], ..
    "eclipse_toggle", [] ..
);

// =============================================================================
// Build Flight Dynamics Panel
// =============================================================================

function build_flight_dynamics_panel(parent, panel_width, panel_height)
    global flight_handles;
    
    // Panel title with description
    flight_handles.title = uicontrol(..
        "parent", parent, ..
        "style", "text", ..
        "string", "Panel 1: Flight Dynamics Simulator - Orbital Mechanics Control", ..
        "position", [10, panel_height - 40, panel_width - 20, 30], ..
        "background", [0.2, 0.2, 0.25], ..
        "foreground", [1, 1, 1], ..
        "fontsize", 11, ..
        "fontweight", "bold", ..
        "horizontalalignment", "center" ..
    );
    
    // Altitude slider with range info
    uicontrol(..
        "parent", parent, ..
        "style", "text", ..
        "string", "Orbital Altitude (Range: 300-700 km)", ..
        "position", [10, panel_height - 80, panel_width - 20, 20], ..
        "background", [0.2, 0.2, 0.25], ..
        "foreground", [0.8, 0.8, 0.8], ..
        "fontsize", 9 ..
    );
    
    flight_handles.altitude_slider = uicontrol(..
        "parent", parent, ..
        "style", "slider", ..
        "min", 300, ..
        "max", 700, ..
        "value", 400, ..
        "position", [10, panel_height - 110, panel_width - 20, 25], ..
        "callback", "on_altitude_change()", ..
        "background", [0.3, 0.3, 0.35], ..
        "sliderstep", [10, 50] ..
    );
    
    flight_handles.altitude_label = uicontrol(..
        "parent", parent, ..
        "style", "text", ..
        "string", "Current Altitude: 400 km (ISS Orbit)", ..
        "position", [10, panel_height - 135, panel_width - 20, 20], ..
        "background", [0.2, 0.2, 0.25], ..
        "foreground", [1, 0.8, 0.3], ..
        "fontsize", 10, ..
        "fontweight", "bold", ..
        "horizontalalignment", "center" ..
    );
    
    // Thruster button with cost info
    flight_handles.thruster_button = uicontrol(..
        "parent", parent, ..
        "style", "pushbutton", ..
        "string", "🔥 Fire Thrusters - Prograde Burn (Cost: ~$800k)", ..
        "position", [10, panel_height - 170, panel_width - 20, 30], ..
        "callback", "on_thruster_fire()", ..
        "background", [0.6, 0.4, 0.2], ..
        "foreground", [1, 1, 1], ..
        "fontsize", 9 ..
    );
    
    // Orbit display axes - store parent handle
    flight_handles.orbit_axes = parent;
    
    // Skip initial orbit plot to avoid parent issues
    // plot_orbit();
    
    // Status displays section header
    uicontrol(..
        "parent", parent, ..
        "style", "text", ..
        "string", "=== Orbital Parameters ===", ..
        "position", [10, panel_height * 0.32 - 20, panel_width - 20, 20], ..
        "background", [0.2, 0.2, 0.25], ..
        "foreground", [0.8, 0.8, 0.8], ..
        "fontsize", 9, ..
        "horizontalalignment", "center" ..
    );
    
    flight_handles.velocity_display = uicontrol(..
        "parent", parent, ..
        "style", "text", ..
        "string", "Orbital Velocity: 7660 m/s (27,576 km/h)", ..
        "position", [10, panel_height * 0.32 - 45, panel_width - 20, 20], ..
        "background", [0.2, 0.2, 0.25], ..
        "foreground", [0.3, 1, 0.8], ..
        "fontsize", 9 ..
    );
    
    flight_handles.period_display = uicontrol(..
        "parent", parent, ..
        "style", "text", ..
        "string", "Orbital Period: 92.6 min (~15.4 orbits/day)", ..
        "position", [10, panel_height * 0.32 - 70, panel_width - 20, 20], ..
        "background", [0.2, 0.2, 0.25], ..
        "foreground", [0.3, 1, 0.8], ..
        "fontsize", 9 ..
    );
    
    flight_handles.eclipse_display = uicontrol(..
        "parent", parent, ..
        "style", "text", ..
        "string", "Eclipse Mode: OFF (Sunlight - Solar Active)", ..
        "position", [10, panel_height * 0.32 - 95, panel_width - 20, 20], ..
        "background", [0.2, 0.2, 0.25], ..
        "foreground", [1, 1, 0.3], ..
        "fontsize", 9 ..
    );
    
    // Eclipse mode toggle button with description
    flight_handles.eclipse_toggle = uicontrol(..
        "parent", parent, ..
        "style", "pushbutton", ..
        "string", "🌑 Toggle Eclipse Mode (Simulate Earth Shadow)", ..
        "position", [10, panel_height * 0.32 - 120, panel_width - 20, 20], ..
        "callback", "on_eclipse_toggle()", ..
        "background", [0.4, 0.4, 0.5], ..
        "foreground", [1, 1, 1], ..
        "fontsize", 9 ..
    );
    
    // Status text with clearer messaging
    flight_handles.status_text = uicontrol(..
        "parent", parent, ..
        "style", "text", ..
        "string", "Mission Status: NOMINAL - All Systems Operational", ..
        "position", [10, 10, panel_width - 20, 25], ..
        "background", [0.15, 0.15, 0.2], ..
        "foreground", [0.3, 1, 0.3], ..
        "fontsize", 10, ..
        "fontweight", "bold", ..
        "horizontalalignment", "center" ..
    );
    
    // Add differential equation display with explanation
    uicontrol(..
        "parent", parent, ..
        "style", "text", ..
        "string", "Physics: Newton's Law of Gravitation - F = GMm/r^2", ..
        "position", [10, panel_height * 0.32 - 145, panel_width - 20, 20], ..
        "background", [0.2, 0.2, 0.25], ..
        "foreground", [0.6, 0.6, 0.8], ..
        "fontsize", 8, ..
        "horizontalalignment", "center" ..
    );
endfunction

// =============================================================================
// Plot Orbit
// =============================================================================

function plot_orbit()
    global flight_handles, orbit_state;
    
    // Create new figure for orbit plot (use figure 101 to avoid conflict with main GUI)
    scf(101);
    clf();
    
    // Draw Earth
    theta = linspace(0, 2*%pi, 100);
    earth_x = R_earth * cos(theta);
    earth_y = R_earth * sin(theta);
    plot(earth_x, earth_y, "b-", "linewidth", 2);
    
    // Fill Earth
    xpoly(earth_x, earth_y);
    gce().background = 66;  // Blue color
    gce().line_mode = "off";
    
    // Generate orbit path
    orbit_path = generate_orbit_path(100, 5400);  // 90 minutes
    
    // Plot orbit path
    plot(orbit_path(:, 1), orbit_path(:, 2), "g--", "linewidth", 1);
    
    // Plot current satellite position
    plot(orbit_state.position_x, orbit_state.position_y, "ro", "markersize", 8, ..
         "markerfacecolor", "r");
    
    // Set axes properties
    a = gca();
    a.data_bounds = [-R_earth * 1.5, -R_earth * 1.5; R_earth * 1.5, R_earth * 1.5];
    a.box = "on";
    a.foreground = [1, 1, 1];
    a.background = [0.1, 0.1, 0.15];
    a.font_size = 8;
    a.x_label.text = "Position X (m)";
    a.y_label.text = "Position Y (m)";
    a.title.text = "Orbital Trajectory";
    a.title.font_size = 10;
    
    // Equal aspect ratio
    a.isoview = "on";
endfunction

// =============================================================================
// Update Flight Display
// =============================================================================

function update_flight_display()
    global flight_handles, orbit_state;
    
    // Update altitude label with context
    altitude_km = orbit_state.altitude / 1000;
    if altitude_km < 350 then
        status_str = " (WARNING: Low Altitude)";
    elseif altitude_km > 600 then
        status_str = " (High Altitude)";
    else
        status_str = " (Nominal)";
    end
    flight_handles.altitude_label.string = sprintf("Current Altitude: %.1f km%s", altitude_km, status_str);
    
    // Update velocity display with multiple units
    velocity_ms = orbit_state.velocity;
    velocity_kmh = velocity_ms * 3.6;
    flight_handles.velocity_display.string = sprintf("Orbital Velocity: %.1f m/s (%.0f km/h)", velocity_ms, velocity_kmh);
    
    // Calculate and update orbital period with additional info
    r = sqrt(orbit_state.position_x^2 + orbit_state.position_y^2);
    v = orbit_state.velocity;
    [period, ecc, sma] = calculate_orbital_elements(r, v);
    period_min = period / 60;
    orbits_per_day = 1440 / period_min;
    flight_handles.period_display.string = sprintf("Orbital Period: %.1f min (%.1f orbits/day)", period_min, orbits_per_day);
    
    // Update eclipse display with handle validation and detailed status
    if ~isempty(flight_handles.eclipse_display) then
        try
            if orbit_state.eclipse_mode then
                flight_handles.eclipse_display.string = "Eclipse Mode: ON (Earth Shadow - Battery Only)";
                flight_handles.eclipse_display.foreground = [1, 0.5, 0.5];
            else
                flight_handles.eclipse_display.string = "Eclipse Mode: OFF (Sunlight - Solar Active)";
                flight_handles.eclipse_display.foreground = [1, 1, 0.3];
            end
        catch
            // Handle is invalid, skip update
        end
    end
    
    // Update status text with handle validation and detailed messaging
    if ~isempty(flight_handles.status_text) then
        try
            if orbit_state.critical_attrition then
                flight_handles.status_text.string = "Mission Status: CRITICAL - Atmospheric Drag Hazard!";
                flight_handles.status_text.foreground = [1, 0.2, 0.2];
                // Blink effect (simplified)
                if modulo(getdate()(9), 2) == 0 then
                    flight_handles.status_text.background = [0.5, 0.1, 0.1];
                else
                    flight_handles.status_text.background = [0.15, 0.15, 0.2];
                end
            else
                flight_handles.status_text.string = "Mission Status: NOMINAL - All Systems Operational";
                flight_handles.status_text.foreground = [0.3, 1, 0.3];
                flight_handles.status_text.background = [0.15, 0.15, 0.2];
            end
        catch
            // Handle is invalid, skip update
        end
    end
    
    // Update orbit plot
    plot_orbit();
endfunction

// =============================================================================
// On Altitude Change Callback
// =============================================================================

function on_altitude_change()
    global flight_handles, orbit_state;
    
    // Get new altitude from slider
    new_altitude_km = flight_handles.altitude_slider.value;
    
    // Calculate required velocity for circular orbit at this altitude
    r = R_earth + new_altitude_km * 1000;
    new_velocity = sqrt(mu / r);
    
    // Update orbit state
    init_orbit(new_altitude_km, new_velocity);
    
    // Update orbital state to calculate eclipse and critical attrition
    update_orbit_state(1);
    
    // Update display
    update_flight_display();
    
    printf("Altitude changed to %.1f km, velocity adjusted to %.1f m/s\n", ..
           new_altitude_km, new_velocity);
endfunction

// =============================================================================
// On Thruster Fire Callback
// =============================================================================

function on_thruster_fire()
    global orbit_state, finance_state;
    
    // Burn parameters
    burn_duration = 10;  // seconds
    thrust = 50000;      // Newtons
    
    // Fire thrusters
    [delta_v, fuel_cost] = fire_thrusters(burn_duration, thrust);
    
    // Record cost
    fuel_used = (thrust / (320 * 9.81)) * burn_duration;
    
    [updated_fuel_cost, updated_fuel_remaining] = record_burn_cost(delta_v, fuel_used, burn_duration);
    
    // Explicitly update finance_state with returned values
    finance_state.fuel_cost_total = updated_fuel_cost;
    finance_state.fuel_remaining = updated_fuel_remaining;
    
    printf("Thrusters fired: Delta-V = %.1f m/s, Cost = $%.2f\n", ..
           delta_v, fuel_cost);
    
    // Update displays
    update_flight_display();
    update_power_display();
endfunction

// =============================================================================
// On Eclipse Toggle Callback
// =============================================================================

function on_eclipse_toggle()
    global orbit_state, power_state;
    
    // Toggle eclipse mode
    orbit_state.eclipse_mode = ~orbit_state.eclipse_mode;
    
    // Update solar input based on eclipse mode
    if orbit_state.eclipse_mode then
        power_state.solar_input = 0;  // No solar power during eclipse
    else
        power_state.solar_input = 50;  // Base solar power during sunlight
    end
    
    // Recalculate net power
    power_state.net_power = power_state.solar_input - power_state.consumer_load;
    
    // Update displays
    update_flight_display();
    update_power_display();
    
    if orbit_state.eclipse_mode then
        printf("Eclipse mode toggled ON - Solar power disabled\n");
    else
        printf("Eclipse mode toggled OFF - Solar power enabled\n");
    end
endfunction
