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
    "eclipse_display", [] ..
);

// =============================================================================
// Build Flight Dynamics Panel
// =============================================================================

function build_flight_dynamics_panel(parent, panel_width, panel_height)
    global flight_handles;
    
    // Panel title
    flight_handles.title = uicontrol(..
        "parent", parent, ..
        "style", "text", ..
        "string", "Panel 1: Flight Dynamics Simulator", ..
        "position", [10, panel_height - 40, panel_width - 20, 30], ..
        "background", [0.2, 0.2, 0.25], ..
        "foreground", [1, 1, 1], ..
        "fontsize", 12, ..
        "fontweight", "bold", ..
        "horizontalalignment", "center" ..
    );
    
    // Altitude slider
    uicontrol(..
        "parent", parent, ..
        "style", "text", ..
        "string", "Orbital Altitude (km)", ..
        "position", [10, panel_height - 80, panel_width - 20, 20], ..
        "background", [0.2, 0.2, 0.25], ..
        "foreground", [0.8, 0.8, 0.8], ..
        "fontsize", 9 ..
    );
    
    flight_handles.altitude_slider = uicontrol(..
        "parent", parent, ..
        "style", "slider", ..
        "min", 200, ..
        "max", 1000, ..
        "value", 400, ..
        "position", [10, panel_height - 110, panel_width - 20, 25], ..
        "callback", "on_altitude_change()", ..
        "background", [0.3, 0.3, 0.35], ..
        "sliderstep", [10, 50] ..
    );
    
    flight_handles.altitude_label = uicontrol(..
        "parent", parent, ..
        "style", "text", ..
        "string", "400 km", ..
        "position", [10, panel_height - 135, panel_width - 20, 20], ..
        "background", [0.2, 0.2, 0.25], ..
        "foreground", [1, 0.8, 0.3], ..
        "fontsize", 10, ..
        "horizontalalignment", "center" ..
    );
    
    // Thruster button
    flight_handles.thruster_button = uicontrol(..
        "parent", parent, ..
        "style", "pushbutton", ..
        "string", "🔥 Fire Thrusters (Prograde Burn)", ..
        "position", [10, panel_height - 170, panel_width - 20, 30], ..
        "callback", "on_thruster_fire()", ..
        "background", [0.6, 0.4, 0.2], ..
        "foreground", [1, 1, 1], ..
        "fontsize", 9 ..
    );
    
    // Orbit display axes
    flight_handles.orbit_axes = axes(..
        "parent", parent, ..
        "position", [0.05, 0.35, 0.9, 0.35], ..
        "tag", "orbit_axes" ..
    );
    
    // Initial orbit plot
    plot_orbit();
    
    // Status displays
    uicontrol(..
        "parent", parent, ..
        "style", "text", ..
        "string", "Orbital Parameters:", ..
        "position", [10, panel_height * 0.32 - 20, panel_width - 20, 20], ..
        "background", [0.2, 0.2, 0.25], ..
        "foreground", [0.8, 0.8, 0.8], ..
        "fontsize", 9 ..
    );
    
    flight_handles.velocity_display = uicontrol(..
        "parent", parent, ..
        "style", "text", ..
        "string", "Velocity: 7660 m/s", ..
        "position", [10, panel_height * 0.32 - 45, panel_width - 20, 20], ..
        "background", [0.2, 0.2, 0.25], ..
        "foreground", [0.3, 1, 0.8], ..
        "fontsize", 9 ..
    );
    
    flight_handles.period_display = uicontrol(..
        "parent", parent, ..
        "style", "text", ..
        "string", "Orbital Period: 92.6 min", ..
        "position", [10, panel_height * 0.32 - 70, panel_width - 20, 20], ..
        "background", [0.2, 0.2, 0.25], ..
        "foreground", [0.3, 1, 0.8], ..
        "fontsize", 9 ..
    );
    
    flight_handles.eclipse_display = uicontrol(..
        "parent", parent, ..
        "style", "text", ..
        "string", "Eclipse Mode: OFF", ..
        "position", [10, panel_height * 0.32 - 95, panel_width - 20, 20], ..
        "background", [0.2, 0.2, 0.25], ..
        "foreground", [1, 1, 0.3], ..
        "fontsize", 9 ..
    );
    
    // Status text
    flight_handles.status_text = uicontrol(..
        "parent", parent, ..
        "style", "text", ..
        "string", "Status: NOMINAL", ..
        "position", [10, 10, panel_width - 20, 25], ..
        "background", [0.15, 0.15, 0.2], ..
        "foreground", [0.3, 1, 0.3], ..
        "fontsize", 10, ..
        "fontweight", "bold", ..
        "horizontalalignment", "center" ..
    );
    
    // Add differential equation display (LaTeX-style)
    uicontrol(..
        "parent", parent, ..
        "style", "text", ..
        "string", "Orbital Equation: d²r/dt² = -GM/r²", ..
        "position", [10, panel_height * 0.32 - 120, panel_width - 20, 20], ..
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
    
    // Get current axes
    axes(flight_handles.orbit_axes);
    
    // Clear previous plot
    clf(flight_handles.orbit_axes);
    
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
    axes(flight_handles.orbit_axes);
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
    
    // Update altitude label
    altitude_km = orbit_state.altitude / 1000;
    flight_handles.altitude_label.string = sprintf("%.1f km", altitude_km);
    
    // Update velocity display
    flight_handles.velocity_display.string = sprintf("Velocity: %.1f m/s", orbit_state.velocity);
    
    // Calculate and update orbital period
    r = sqrt(orbit_state.position_x^2 + orbit_state.position_y^2);
    v = orbit_state.velocity;
    [period, ~, ~] = calculate_orbital_elements(r, v);
    period_min = period / 60;
    flight_handles.period_display.string = sprintf("Orbital Period: %.1f min", period_min);
    
    // Update eclipse display
    if orbit_state.eclipse_mode then
        flight_handles.eclipse_display.string = "Eclipse Mode: ON";
        flight_handles.eclipse_display.foreground = [1, 0.5, 0.5];
    else
        flight_handles.eclipse_display.string = "Eclipse Mode: OFF";
        flight_handles.eclipse_display.foreground = [1, 1, 0.3];
    end
    
    // Update status text
    if orbit_state.critical_attrition then
        flight_handles.status_text.string = "CRITICAL ATTRITION DETECTED";
        flight_handles.status_text.foreground = [1, 0.2, 0.2];
        // Blink effect (simplified)
        if modulo(getdate()(9), 2) == 0 then
            flight_handles.status_text.background = [0.5, 0.1, 0.1];
        else
            flight_handles.status_text.background = [0.15, 0.15, 0.2];
        end
    else
        flight_handles.status_text.string = "Status: NOMINAL";
        flight_handles.status_text.foreground = [0.3, 1, 0.3];
        flight_handles.status_text.background = [0.15, 0.15, 0.2];
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
    record_burn_cost(delta_v, fuel_used, burn_duration);
    
    printf("Thrusters fired: Delta-V = %.1f m/s, Cost = $%.2f\n", ..
           delta_v, fuel_cost);
    
    // Update display
    update_flight_display();
endfunction
