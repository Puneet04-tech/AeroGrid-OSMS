// =============================================================================
// AeroGrid-OSMS - Power Grid Management Module
// Battery charging/discharging and life support systems
// =============================================================================

// Global power grid state
global power_state;
power_state = struct(..
    "battery_capacity", 100, ..      // kWh
    "battery_charge", 80, ..         // Current charge (kWh)
    "solar_input", 0, ..             // Current solar input (kW)
    "consumer_load", 50, ..          // Current consumer load (kW)
    "net_power", 0, ..               // Net power (kW)
    "battery_health", 100, ..        // Battery health percentage
    "mission_status", "NORMAL", ..
    "subsystems", struct(..
        "oxygen", %t, ..
        "comms", %t, ..
        "cryo_labs", %f ..
    ) ..
);

// Subsystem power requirements (kW)
subsystem_power = struct(..
    "oxygen", 15, ..
    "comms", 10, ..
    "cryo_labs", 25 ..
);

// =============================================================================
// Calculate Consumer Load Based on Active Subsystems
// =============================================================================

function load = calculate_consumer_load()
    global power_state;
    
    load = 0;
    
    if power_state.subsystems.oxygen then
        load = load + subsystem_power.oxygen;
    end
    
    if power_state.subsystems.comms then
        load = load + subsystem_power.comms;
    end
    
    if power_state.subsystems.cryo_labs then
        load = load + subsystem_power.cryo_labs;
    end
    
    // Base station load (always on)
    load = load + 20;  // Life support, computers, etc.
    
    power_state.consumer_load = load;
endfunction

// =============================================================================
// Update Power Grid State
// =============================================================================

function update_power_grid(solar_power, dt)
    global power_state;
    
    // Update solar input
    power_state.solar_input = solar_power;
    
    // Calculate consumer load
    calculate_consumer_load();
    
    // Calculate net power
    power_state.net_power = power_state.solar_input - power_state.consumer_load;
    
    // Update battery charge
    // If net power positive: charging
    // If net power negative: discharging
    power_state.battery_charge = power_state.battery_charge + power_state.net_power * dt;
    
    // Clamp battery charge
    power_state.battery_charge = max(0, min(power_state.battery_charge, power_state.battery_capacity));
    
    // Update battery health based on charge/discharge cycles
    if power_state.net_power < 0 then
        // Discharging - slight health degradation
        power_state.battery_health = power_state.battery_health - 0.001 * dt;
    elseif power_state.battery_charge > power_state.battery_capacity * 0.9 then
        // Overcharging - faster health degradation
        power_state.battery_health = power_state.battery_health - 0.005 * dt;
    end
    
    // Clamp battery health
    power_state.battery_health = max(0, min(power_state.battery_health, 100));
    
    // Update mission status
    update_mission_status();
endfunction

// =============================================================================
// Update Mission Status Based on Power Grid State
// =============================================================================

function update_mission_status()
    global power_state;
    
    if power_state.battery_health <= 0 then
        power_state.mission_status = "MISSION FAILED - BATTERY DEPLETED";
    elseif power_state.battery_charge <= 5 then
        power_state.mission_status = "CRITICAL - LOW BATTERY";
    elseif power_state.battery_charge <= 20 then
        power_state.mission_status = "WARNING - BATTERY LOW";
    elseif power_state.net_power < -30 then
        power_state.mission_status = "WARNING - HIGH DRAIN";
    else
        power_state.mission_status = "NORMAL";
    end
endfunction

// =============================================================================
// Toggle Subsystem
// =============================================================================

function toggle_subsystem(subsystem_name)
    global power_state;
    
    select subsystem_name
    case "oxygen" then
        power_state.subsystems.oxygen = ~power_state.subsystems.oxygen;
    case "comms" then
        power_state.subsystems.comms = ~power_state.subsystems.comms;
    case "cryo_labs" then
        power_state.subsystems.cryo_labs = ~power_state.subsystems.cryo_labs;
    end
endfunction

// =============================================================================
// Calculate Energy Cost
// =============================================================================

function [energy_cost_kwh, total_cost] = calculate_energy_cost(solar_power, consumer_load, duration)
    // Energy consumed (kWh)
    energy_consumed = consumer_load * duration;
    
    // Energy generated (kWh)
    energy_generated = solar_power * duration;
    
    // Net energy from battery (kWh)
    net_battery_energy = energy_consumed - energy_generated;
    
    // Cost calculation (simplified)
    // Solar energy: $0.05/kWh (very cheap in space)
    // Battery energy: $0.50/kWh (expensive due to battery wear)
    
    if net_battery_energy > 0 then
        // Using battery energy
        energy_cost_kwh = net_battery_energy;
        total_cost = solar_power * duration * 0.05 + net_battery_energy * 0.50;
    else
        // Excess solar energy
        energy_cost_kwh = 0;
        total_cost = energy_consumed * 0.05;
    end
endfunction

// =============================================================================
// Get Solar Panel Efficiency
// Based on orbital altitude and eclipse fraction
// =============================================================================

function efficiency = calculate_solar_efficiency(altitude, eclipse_fraction)
    // Base efficiency
    base_efficiency = 0.20;  // 20% for modern solar panels
    
    // Altitude effect: higher altitude = less atmosphere = higher efficiency
    // (simplified model)
    altitude_factor = 1 + (altitude - 400e3) / 1e6;
    
    // Eclipse effect: time in eclipse reduces average efficiency
    eclipse_factor = 1 - eclipse_fraction;
    
    // Combined efficiency
    efficiency = base_efficiency * altitude_factor * eclipse_factor;
    
    // Clamp to reasonable values
    efficiency = max(0.05, min(efficiency, 0.35));
endfunction

// =============================================================================
// Initialize Power Grid
// =============================================================================

function init_power_grid(initial_charge, battery_capacity)
    global power_state;
    
    power_state.battery_capacity = battery_capacity;
    power_state.battery_charge = initial_charge;
    power_state.battery_health = 100;
    power_state.mission_status = "NORMAL";
    power_state.solar_input = 50;  // Initial solar input (kW)
    power_state.consumer_load = 0;
    power_state.net_power = 0;
    
    // Calculate initial consumer load
    calculate_consumer_load();
    
    // Calculate initial net power
    power_state.net_power = power_state.solar_input - power_state.consumer_load;
endfunction

// =============================================================================
// Emergency Power Shutdown
// Disable non-essential subsystems
// =============================================================================

function emergency_power_shutdown()
    global power_state;
    
    // Disable cryo-labs (non-essential)
    power_state.subsystems.cryo_labs = %f;
    
    // Keep oxygen and comms (essential)
    // These are kept on for survival
    
    // Recalculate load
    calculate_consumer_load();
endfunction

// =============================================================================
// Get Power Grid Summary
// Returns formatted string with current status
// =============================================================================

function summary = get_power_grid_summary()
    global power_state;
    
    summary = sprintf(..
        "Battery: %.1f/%.1f kWh (%.1f%%)\n" + ..
        "Solar Input: %.1f kW\n" + ..
        "Consumer Load: %.1f kW\n" + ..
        "Net Power: %.1f kW\n" + ..
        "Battery Health: %.1f%%\n" + ..
        "Status: %s", ..
        power_state.battery_charge, ..
        power_state.battery_capacity, ..
        (power_state.battery_charge / power_state.battery_capacity) * 100, ..
        power_state.solar_input, ..
        power_state.consumer_load, ..
        power_state.net_power, ..
        power_state.battery_health, ..
        power_state.mission_status ..
    );
endfunction
