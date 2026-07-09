// =============================================================================
// AeroGrid-OSMS - Orbital Mechanics Module
// Solves orbital differential equations using ODE solver
// =============================================================================

// Global constants
G = 6.674e-11;           // Gravitational constant (m³/kg·s²)
M_earth = 5.972e24;      // Mass of Earth (kg)
R_earth = 6.371e6;       // Radius of Earth (m)
mu = G * M_earth;        // Standard gravitational parameter

// Global orbital state
global orbit_state;
orbit_state = struct(..
    "altitude", 400e3, ..      // Initial altitude (m) - 400 km (ISS orbit)
    "velocity", 7660, ..       // Initial velocity (m/s)
    "position_x", R_earth + 400e3, ..
    "position_y", 0, ..
    "velocity_x", 0, ..
    "velocity_y", 7660, ..
    "time", 0, ..
    "critical_attrition", %f, ..
    "eclipse_mode", %f ..
);

// =============================================================================
// Orbital Differential Equation Solver
// Solves: d²r/dt² = -GM/r² * r̂
// =============================================================================

function dydt = orbit_ode(t, y)
    // y = [x, y, vx, vy]
    x = y(1);
    y_pos = y(2);
    vx = y(3);
    vy = y(4);
    
    // Calculate distance from Earth's center
    r = sqrt(x^2 + y_pos^2);
    
    // Gravitational acceleration
    ax = -mu * x / r^3;
    ay = -mu * y_pos / r^3;
    
    // Add atmospheric drag (simplified model)
    if r < R_earth + 500e3  // Below 500 km
        rho = 1.225 * exp(-(r - R_earth) / 8500);  // Exponential atmosphere
        Cd = 2.2;  // Drag coefficient
        A = 100;   // Cross-sectional area (m²)
        m = 420000;  // Mass (kg) - similar to ISS
        v = sqrt(vx^2 + vy^2);
        drag_force = 0.5 * rho * v^2 * Cd * A;
        ax = ax - (drag_force * vx / m);
        ay = ay - (drag_force * vy / m);
    end
    
    dydt = [vx; vy; ax; ay];
endfunction

// =============================================================================
// Calculate Orbital Parameters
// =============================================================================

function [period, eccentricity, semi_major_axis] = calculate_orbital_elements(r, v)
    // Calculate specific orbital energy
    energy = 0.5 * v^2 - mu / r;
    
    // Semi-major axis
    semi_major_axis = -mu / (2 * energy);
    
    // Eccentricity (simplified for circular orbits)
    h = r * v;  // Specific angular momentum
    eccentricity = sqrt(1 + 2 * energy * h^2 / mu^2);
    
    // Orbital period (Kepler's third law)
    period = 2 * %pi * sqrt(semi_major_axis^3 / mu);
endfunction

// =============================================================================
// Update Orbital State
// =============================================================================

function update_orbit_state(dt)
    global orbit_state;
    
    // Current state
    y0 = [orbit_state.position_x; orbit_state.position_y; ..
          orbit_state.velocity_x; orbit_state.velocity_y];
    
    // Solve ODE for time step dt
    t = 0:dt:dt;
    y = ode(y0, 0, t, orbit_ode);
    
    // Update state
    orbit_state.position_x = y(1, 2);
    orbit_state.position_y = y(2, 2);
    orbit_state.velocity_x = y(3, 2);
    orbit_state.velocity_y = y(4, 2);
    orbit_state.time = orbit_state.time + dt;
    
    // Calculate current altitude
    r = sqrt(orbit_state.position_x^2 + orbit_state.position_y^2);
    orbit_state.altitude = r - R_earth;
    
    // Calculate current velocity
    orbit_state.velocity = sqrt(orbit_state.velocity_x^2 + orbit_state.velocity_y^2);
    
    // Check for critical attrition
    if orbit_state.altitude < 200e3  // Below 200 km
        orbit_state.critical_attrition = %t;
    else
        orbit_state.critical_attrition = %f;
    end
    
    // Check for eclipse (simplified: when satellite is behind Earth)
    // This is a simplified model - assumes Earth is at origin
    orbit_state.eclipse_mode = (orbit_state.position_x < 0);
endfunction

// =============================================================================
// Fire Thrusters (Prograde Burn)
// =============================================================================

function [delta_v, fuel_cost] = fire_thrusters(burn_duration, thrust)
    global orbit_state;
    
    // Spacecraft parameters
    m_dry = 420000;      // Dry mass (kg)
    m_fuel = 100000;     // Fuel mass (kg)
    Isp = 320;           // Specific impulse (s)
    g0 = 9.81;           // Standard gravity
    
    // Total mass
    m_total = m_dry + m_fuel;
    
    // Calculate thrust acceleration
    accel = thrust / m_total;
    
    // Delta-v for this burn
    delta_v = accel * burn_duration;
    
    // Fuel consumption
    mdot = thrust / (Isp * g0);
    fuel_used = mdot * burn_duration;
    
    // Calculate cost (simplified: $5000 per kg of fuel)
    fuel_cost = fuel_used * 5000;
    
    // Apply delta-v in direction of velocity (prograde)
    v_mag = sqrt(orbit_state.velocity_x^2 + orbit_state.velocity_y^2);
    orbit_state.velocity_x = orbit_state.velocity_x + delta_v * (orbit_state.velocity_x / v_mag);
    orbit_state.velocity_y = orbit_state.velocity_y + delta_v * (orbit_state.velocity_y / v_mag);
    
    // Update velocity magnitude
    orbit_state.velocity = sqrt(orbit_state.velocity_x^2 + orbit_state.velocity_y^2);
endfunction

// =============================================================================
// Get Orbital Position Array for Plotting
// =============================================================================

function orbit_path = generate_orbit_path(num_points, time_span)
    global orbit_state;
    
    // Current state
    y0 = [orbit_state.position_x; orbit_state.position_y; ..
          orbit_state.velocity_x; orbit_state.velocity_y];
    
    // Time vector
    t = linspace(0, time_span, num_points);
    
    // Solve ODE
    y = ode(y0, 0, t, orbit_ode);
    
    // Extract position
    orbit_path = [y(1, :); y(2, :)]';
endfunction

// =============================================================================
// Calculate Eclipse Duration
// =============================================================================

function eclipse_fraction = calculate_eclipse_fraction(altitude)
    // Simplified calculation of eclipse fraction based on altitude
    // Higher altitude = longer orbital period but similar eclipse duration
    r = R_earth + altitude;
    
    // Earth's angular radius as seen from satellite
    theta_earth = asin(R_earth / r);
    
    // Eclipse fraction (simplified)
    eclipse_fraction = theta_earth / %pi;
endfunction

// =============================================================================
// Initialize Orbital State with Custom Parameters
// =============================================================================

function init_orbit(altitude_km, velocity_ms)
    global orbit_state;
    
    orbit_state.altitude = altitude_km * 1000;
    orbit_state.velocity = velocity_ms;
    orbit_state.position_x = R_earth + altitude_km * 1000;
    orbit_state.position_y = 0;
    orbit_state.velocity_x = 0;
    orbit_state.velocity_y = velocity_ms;
    orbit_state.time = 0;
    orbit_state.critical_attrition = %f;
    orbit_state.eclipse_mode = %f;
endfunction
