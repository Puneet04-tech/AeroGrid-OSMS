// =============================================================================
// AeroGrid-OSMS - Power Grid Management Module
// Battery charging/discharging and life support systems
// =============================================================================

// Power Grid Constants
DEFAULT_BATTERY_CAPACITY = 100;   // Default battery capacity (kWh)
DEFAULT_INITIAL_CHARGE = 80;       // Default initial charge (kWh)
BASE_STATION_LOAD = 20;           // Base station load (kW) - always on
BATTERY_CRITICAL_THRESHOLD = 5;   // Critical battery level (kWh)
BATTERY_WARNING_THRESHOLD = 20;   // Warning battery level (kWh)
HIGH_DRAIN_THRESHOLD = -30;        // High power drain threshold (kW)
DISCHARGE_HEALTH_DEGRADATION = 0.001;  // Health loss per second during discharge
OVERCHARGE_HEALTH_DEGRADATION = 0.005;  // Health loss per second during overcharge
SOLAR_COST_PER_KWH = 0.05;        // Cost of solar energy ($/kWh)
BATTERY_COST_PER_KWH = 0.50;       // Cost of battery energy ($/kWh)
BASE_SOLAR_EFFICIENCY = 0.20;      // Base solar panel efficiency (20%)
MIN_SOLAR_EFFICIENCY = 0.05;       // Minimum solar efficiency (5%)
MAX_SOLAR_EFFICIENCY = 0.35;       // Maximum solar efficiency (35%)

// Subsystem power requirements (kW)
SUBSYSTEM_POWER = struct(..
    "oxygen", 15, ..      // Oxygen generation system
    "comms", 10, ..       // Communications system
    "cryo_labs", 25 ..    // Cryogenic laboratories
);

// Global power grid state
global power_state;
power_state = struct(..
    "battery_capacity", DEFAULT_BATTERY_CAPACITY, ..
    "battery_charge", DEFAULT_INITIAL_CHARGE, ..
    "solar_input", 0, ..
    "consumer_load", 0, ..
    "net_power", 0, ..
    "battery_health", 100, ..
    "mission_status", "NORMAL", ..
    "subsystems", struct(..
        "oxygen", %t, ..
        "comms", %t, ..
        "cryo_labs", %f ..
    ) ..
);

// =============================================================================
// Calculate Consumer Load Based on Active Subsystems
// =============================================================================

function load = calculate_consumer_load()
    // Calculate total power consumption based on active subsystems
    // Returns: total load in kW
    
    global power_state;
    
    load = 0;
    
    // Add power from active subsystems
    if power_state.subsystems.oxygen then
        load = load + SUBSYSTEM_POWER.oxygen;
    end
    
    if power_state.subsystems.comms then
        load = load + SUBSYSTEM_POWER.comms;
    end
    
    if power_state.subsystems.cryo_labs then
        load = load + SUBSYSTEM_POWER.cryo_labs;
    end
    
    // Add base station load (always on - life support, computers, etc.)
    load = load + BASE_STATION_LOAD;
    
    power_state.consumer_load = load;
endfunction

// =============================================================================
// Update Power Grid State
// =============================================================================

function update_power_grid(solar_power, dt)
    // Update power grid state for one time step
    // solar_power: current solar input (kW)
    // dt: time step in seconds
    
    global power_state;
    
    // Update solar input
    power_state.solar_input = solar_power;
    
    // Calculate consumer load from active subsystems
    calculate_consumer_load();
    
    // Calculate net power (positive = charging, negative = discharging)
    power_state.net_power = power_state.solar_input - power_state.consumer_load;
    
    // Update battery charge based on net power
    // ΔE = P_net * Δt
    power_state.battery_charge = power_state.battery_charge + power_state.net_power * dt;
    
    // Clamp battery charge to valid range [0, capacity]
    power_state.battery_charge = max(0, min(power_state.battery_charge, power_state.battery_capacity));
    
    // Update battery health based on charge/discharge cycles
    // Discharging causes slight degradation
    if power_state.net_power < 0 then
        power_state.battery_health = power_state.battery_health - DISCHARGE_HEALTH_DEGRADATION * dt;
    // Overcharging (>90%) causes faster degradation
    elseif power_state.battery_charge > power_state.battery_capacity * 0.9 then
        power_state.battery_health = power_state.battery_health - OVERCHARGE_HEALTH_DEGRADATION * dt;
    end
    
    // Clamp battery health to valid range [0, 100]
    power_state.battery_health = max(0, min(power_state.battery_health, 100));
    
    // Update mission status based on current conditions
    update_mission_status();
endfunction

// =============================================================================
// Update Mission Status Based on Power Grid State
// =============================================================================

function update_mission_status()
    // Update mission status based on power grid conditions
    // Priority: FAILED > CRITICAL > WARNING > NORMAL
    
    global power_state;
    
    if power_state.battery_health <= 0 then
        power_state.mission_status = "MISSION FAILED - BATTERY DEPLETED";
    elseif power_state.battery_charge <= BATTERY_CRITICAL_THRESHOLD then
        power_state.mission_status = "CRITICAL - LOW BATTERY";
    elseif power_state.battery_charge <= BATTERY_WARNING_THRESHOLD then
        power_state.mission_status = "WARNING - BATTERY LOW";
    elseif power_state.net_power < HIGH_DRAIN_THRESHOLD then
        power_state.mission_status = "WARNING - HIGH DRAIN";
    else
        power_state.mission_status = "NORMAL";
    end
endfunction

// =============================================================================
// Toggle Subsystem
// =============================================================================

function toggle_subsystem(subsystem_name)
    // Toggle a subsystem on/off
    // subsystem_name: "oxygen", "comms", or "cryo_labs"
    
    global power_state;
    
    select subsystem_name
    case "oxygen" then
        power_state.subsystems.oxygen = ~power_state.subsystems.oxygen;
    case "comms" then
        power_state.subsystems.comms = ~power_state.subsystems.comms;
    case "cryo_labs" then
        power_state.subsystems.cryo_labs = ~power_state.subsystems.cryo_labs;
    else
        printf("WARNING: Unknown subsystem: %s\n", subsystem_name);
    end
endfunction

// =============================================================================
// Calculate Energy Cost
// =============================================================================

function [energy_cost_kwh, total_cost] = calculate_energy_cost(solar_power, consumer_load, duration)
    // Calculate energy cost for a time period
    // solar_power: solar input (kW)
    // consumer_load: power consumption (kW)
    // duration: time period (seconds)
    // Returns: battery energy used (kWh), total cost ($)
    
    // Energy consumed (kWh)
    energy_consumed = consumer_load * duration;
    
    // Energy generated (kWh)
    energy_generated = solar_power * duration;
    
    // Net energy from battery (positive = discharging, negative = charging)
    net_battery_energy = energy_consumed - energy_generated;
    
    // Cost calculation
    // Solar energy is cheap ($0.05/kWh)
    // Battery energy is expensive due to wear ($0.50/kWh)
    
    if net_battery_energy > 0 then
        // Using battery energy
        energy_cost_kwh = net_battery_energy;
        total_cost = solar_power * duration * SOLAR_COST_PER_KWH + net_battery_energy * BATTERY_COST_PER_KWH;
    else
        // Excess solar energy (charging battery)
        energy_cost_kwh = 0;
        total_cost = energy_consumed * SOLAR_COST_PER_KWH;
    end
endfunction

// =============================================================================
// Get Solar Panel Efficiency
// Based on orbital altitude and eclipse fraction
// =============================================================================

function efficiency = calculate_solar_efficiency(altitude, eclipse_fraction)
    // Calculate solar panel efficiency based on altitude and eclipse
    // altitude: orbital altitude (m)
    // eclipse_fraction: fraction of orbit in shadow (0 to 1)
    // Returns: efficiency (0 to 1)
    
    // Altitude effect: higher altitude = less atmospheric attenuation
    // Reference altitude: 400 km (ISS orbit)
    altitude_factor = 1 + (altitude - 400e3) / 1e6;
    
    // Eclipse effect: time in shadow reduces average efficiency
    eclipse_factor = 1 - eclipse_fraction;
    
    // Combined efficiency
    efficiency = BASE_SOLAR_EFFICIENCY * altitude_factor * eclipse_factor;
    
    // Clamp to reasonable physical limits
    efficiency = max(MIN_SOLAR_EFFICIENCY, min(efficiency, MAX_SOLAR_EFFICIENCY));
endfunction

// =============================================================================
// Initialize Power Grid
// =============================================================================

function init_power_grid(initial_charge, battery_capacity)
    // Initialize power grid with custom parameters
    // initial_charge: initial battery charge (kWh)
    // battery_capacity: total battery capacity (kWh)
    
    global power_state;
    
    // Validate parameters
    if initial_charge > battery_capacity then
        printf("WARNING: Initial charge exceeds capacity, clamping to capacity\n");
        initial_charge = battery_capacity;
    end
    if initial_charge < 0 then
        printf("WARNING: Initial charge negative, setting to 0\n");
        initial_charge = 0;
    end
    
    // Initialize power state
    power_state.battery_capacity = battery_capacity;
    power_state.battery_charge = initial_charge;
    power_state.battery_health = 100;
    power_state.mission_status = "NORMAL";
    power_state.solar_input = 0;  // Will be set by simulation
    power_state.consumer_load = 0;
    power_state.net_power = 0;
    
    // Calculate initial consumer load from active subsystems
    calculate_consumer_load();
    
    // Calculate initial net power (will be updated when solar input is set)
    power_state.net_power = power_state.solar_input - power_state.consumer_load;
endfunction

// =============================================================================
// Emergency Power Shutdown
// Disable non-essential subsystems
// =============================================================================

function emergency_power_shutdown()
    // Emergency power conservation: disable non-essential subsystems
    // Keeps only oxygen and comms (essential for survival)
    
    global power_state;
    
    printf("EMERGENCY: Initiating power conservation mode\n");
    
    // Disable cryo-labs (non-essential)
    power_state.subsystems.cryo_labs = %f;
    
    // Keep oxygen and comms (essential for survival)
    // These remain enabled
    
    // Recalculate load with reduced subsystems
    calculate_consumer_load();
    
    printf("Power conservation: Load reduced to %.1f kW\n", power_state.consumer_load);
endfunction

// =============================================================================
// Get Power Grid Summary
// Returns formatted string with current status
// =============================================================================

function summary = get_power_grid_summary()
    // Get formatted summary of current power grid status
    // Returns: formatted string
    
    global power_state;
    
    battery_pct = (power_state.battery_charge / power_state.battery_capacity) * 100;
    
    summary = sprintf(..
        "Battery: %.1f/%.1f kWh (%.1f%%)\n" + ..
        "Solar Input: %.1f kW\n" + ..
        "Consumer Load: %.1f kW\n" + ..
        "Net Power: %.1f kW\n" + ..
        "Battery Health: %.1f%%\n" + ..
        "Status: %s", ..
        power_state.battery_charge, ..
        power_state.battery_capacity, ..
        battery_pct, ..
        power_state.solar_input, ..
        power_state.consumer_load, ..
        power_state.net_power, ..
        power_state.battery_health, ..
        power_state.mission_status ..
    );
endfunction
