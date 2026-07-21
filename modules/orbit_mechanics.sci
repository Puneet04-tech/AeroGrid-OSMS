// =============================================================================
// AeroGrid-OSMS - Orbital Mechanics Module
// Solves orbital differential equations using ODE solver
// =============================================================================

// Global constants
G = 6.674e-11;           // Gravitational constant (m³/kg·s²)
M_earth = 5.972e24;      // Mass of Earth (kg)
R_earth = 6.371e6;       // Radius of Earth (m)
mu = G * M_earth;        // Standard gravitational parameter (m³/s²)

// Spacecraft constants (ISS-like)
SPACECRAFT_MASS_DRY = 420000;      // Dry mass (kg)
SPACECRAFT_CROSS_SECTION = 100;    // Cross-sectional area (m²)
DRAG_COEFFICIENT = 2.2;            // Drag coefficient
THRUSTER_ISP = 320;                // Specific impulse (s)
STANDARD_GRAVITY = 9.81;           // Standard gravity (m/s²)

// Orbital thresholds
CRITICAL_ALTITUDE = 350e3;         // Critical altitude for atmospheric drag (m)
MIN_SAFE_ALTITUDE = 200e3;         // Minimum safe altitude (m)
MAX_SAFE_ALTITUDE = 2000e3;        // Maximum safe altitude (m)

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
    // y = [x, y, vx, vy] - state vector
    // Returns [vx, vy, ax, ay] - derivatives
    
    x = y(1);
    y_pos = y(2);
    vx = y(3);
    vy = y(4);
    
    // Calculate distance from Earth's center
    r = sqrt(x^2 + y_pos^2);
    
    // Prevent division by zero
    if r < 1000 then
        printf("WARNING: Satellite too close to Earth center! r = %.2f m\n", r);
        r = 1000;
    end
    
    // Gravitational acceleration (Newton's law of gravitation)
    // a = -GM/r³ * r_vector
    ax = -mu * x / r^3;
    ay = -mu * y_pos / r^3;
    
    // Add atmospheric drag (exponential atmosphere model)
    // Only significant below 500 km altitude
    if r < R_earth + 500e3 then
        // Atmospheric density: ρ = ρ₀ * exp(-h/H)
        // ρ₀ = 1.225 kg/m³ (sea level), H = 8500 m (scale height)
        altitude = r - R_earth;
        rho = 1.225 * exp(-altitude / 8500);
        
        // Drag force: F_d = 0.5 * ρ * v² * Cd * A
        v = sqrt(vx^2 + vy^2);
        drag_force = 0.5 * rho * v^2 * DRAG_COEFFICIENT * SPACECRAFT_CROSS_SECTION;
        
        // Drag acceleration: a_d = F_d / m
        drag_accel_x = drag_force * vx / (SPACECRAFT_MASS_DRY * v);
        drag_accel_y = drag_force * vy / (SPACECRAFT_MASS_DRY * v);
        
        ax = ax - drag_accel_x;
        ay = ay - drag_accel_y;
    end
    
    dydt = [vx; vy; ax; ay];
endfunction

// =============================================================================
// Calculate Orbital Parameters
// =============================================================================

function [period, eccentricity, semi_major_axis] = calculate_orbital_elements(r, v)
    // Calculate orbital elements from current state
    // r: distance from Earth center (m)
    // v: orbital velocity magnitude (m/s)
    
    // Specific orbital energy: ε = v²/2 - μ/r
    energy = 0.5 * v^2 - mu / r;
    
    // Check for valid orbit (negative energy = bound orbit)
    if energy >= 0 then
        printf("WARNING: Unbound orbit detected (energy >= 0)!\n");
        semi_major_axis = %inf;
        eccentricity = 1;  // Parabolic trajectory
        period = %inf;
        return;
    end
    
    // Semi-major axis: a = -μ/(2ε)
    semi_major_axis = -mu / (2 * energy);
    
    // Eccentricity: e = sqrt(1 + 2εh²/μ²)
    // For circular orbit, h = r*v (simplified)
    h = r * v;  // Specific angular momentum
    eccentricity = sqrt(1 + 2 * energy * h^2 / mu^2);
    
    // Orbital period (Kepler's third law): T = 2π√(a³/μ)
    period = 2 * %pi * sqrt(semi_major_axis^3 / mu);
endfunction

// =============================================================================
// Update Orbital State
// =============================================================================

function update_orbit_state(dt)
    global orbit_state;
    
    // Current state vector
    y0 = [orbit_state.position_x; orbit_state.position_y; ..
          orbit_state.velocity_x; orbit_state.velocity_y];
    
    // Solve ODE for time step dt using Runge-Kutta method
    t = 0:dt:dt;
    y = ode(y0, 0, t, orbit_ode);
    
    // Update orbital state from ODE solution
    orbit_state.position_x = y(1, 2);
    orbit_state.position_y = y(2, 2);
    orbit_state.velocity_x = y(3, 2);
    orbit_state.velocity_y = y(4, 2);
    orbit_state.time = orbit_state.time + dt;
    
    // Calculate current altitude and velocity
    r = sqrt(orbit_state.position_x^2 + orbit_state.position_y^2);
    orbit_state.altitude = r - R_earth;
    orbit_state.velocity = sqrt(orbit_state.velocity_x^2 + orbit_state.velocity_y^2);
    
    // Check for critical conditions
    // 1. Critical attrition: altitude too low for stable orbit
    orbit_state.critical_attrition = (orbit_state.altitude < CRITICAL_ALTITUDE);
    
    // 2. Eclipse mode: satellite in Earth's shadow
    // Simplified model: eclipse when satellite is on negative X side
    // (assumes Sun at +X infinity, Earth at origin)
    orbit_state.eclipse_mode = (orbit_state.position_x < 0);
    
    // 3. Force eclipse mode at very low altitudes for testing purposes
    // This demonstrates power grid behavior during eclipse
    if orbit_state.altitude < CRITICAL_ALTITUDE then
        orbit_state.eclipse_mode = %t;
    end
    
    // 4. Check for collision with Earth
    if orbit_state.altitude < 0 then
        printf("CRITICAL: Satellite has collided with Earth!\n");
        orbit_state.velocity = 0;
        orbit_state.velocity_x = 0;
        orbit_state.velocity_y = 0;
    end
endfunction

// =============================================================================
// Fire Thrusters (Prograde Burn)
// =============================================================================

function [delta_v, fuel_used] = fire_thrusters(burn_duration, thrust)
    // Fire thrusters in prograde direction (along velocity vector)
    // burn_duration: burn time in seconds
    // thrust: thrust force in Newtons
    // Returns: delta_v (m/s), fuel_used (kg)
    
    global orbit_state;
    
    // Calculate total mass (dry + fuel)
    // Note: This should use actual fuel remaining from finance_state
    // For now, use constant fuel mass
    m_total = SPACECRAFT_MASS_DRY + 100000;  // kg
    
    // Calculate thrust acceleration: a = F/m
    accel = thrust / m_total;
    
    // Delta-v for this burn: Δv = a * t
    delta_v = accel * burn_duration;
    
    // Fuel consumption rate: ṁ = F/(Isp * g₀)
    mdot = thrust / (THRUSTER_ISP * STANDARD_GRAVITY);
    fuel_used = mdot * burn_duration;
    
    // Apply delta-v in direction of velocity (prograde burn)
    // This increases orbital energy and altitude
    v_mag = sqrt(orbit_state.velocity_x^2 + orbit_state.velocity_y^2);
    
    if v_mag > 0 then
        orbit_state.velocity_x = orbit_state.velocity_x + delta_v * (orbit_state.velocity_x / v_mag);
        orbit_state.velocity_y = orbit_state.velocity_y + delta_v * (orbit_state.velocity_y / v_mag);
    else
        // If velocity is zero, apply thrust in +Y direction
        orbit_state.velocity_y = orbit_state.velocity_y + delta_v;
    end
    
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
    // Calculate fraction of orbit spent in Earth's shadow
    // altitude: orbital altitude above Earth's surface (m)
    // Returns: fraction (0 to 1) of orbital period in eclipse
    
    r = R_earth + altitude;
    
    // Earth's angular radius as seen from satellite
    // θ = arcsin(R_earth / r)
    theta_earth = asin(R_earth / r);
    
    // Eclipse fraction (simplified geometric model)
    // Assumes circular orbit and Sun at infinity
    eclipse_fraction = theta_earth / %pi;
    
    // Clamp to valid range
    eclipse_fraction = max(0, min(1, eclipse_fraction));
endfunction

// =============================================================================
// Initialize Orbital State with Custom Parameters
// =============================================================================

function init_orbit(altitude_km, velocity_ms)
    // Initialize orbital state with custom parameters
    // altitude_km: initial altitude in kilometers
    // velocity_ms: initial orbital velocity in m/s
    
    global orbit_state;
    
    // Convert altitude to meters
    altitude_m = altitude_km * 1000;
    
    // Initialize orbital state
    orbit_state.altitude = altitude_m;
    orbit_state.velocity = velocity_ms;
    orbit_state.position_x = R_earth + altitude_m;
    orbit_state.position_y = 0;
    orbit_state.velocity_x = 0;
    orbit_state.velocity_y = velocity_ms;
    orbit_state.time = 0;
    orbit_state.critical_attrition = %f;
    orbit_state.eclipse_mode = %f;
    
    // Validate initial conditions
    if altitude_m < MIN_SAFE_ALTITUDE then
        printf("WARNING: Initial altitude below minimum safe altitude!\n");
    elseif altitude_m > MAX_SAFE_ALTITUDE then
        printf("WARNING: Initial altitude above maximum safe altitude!\n");
    end
endfunction
