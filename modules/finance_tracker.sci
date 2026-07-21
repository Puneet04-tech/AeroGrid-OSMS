// =============================================================================
// AeroGrid-OSMS - Financial Tracking Module
// Cost per burn optimization and mission financial management
// =============================================================================

// Financial Constants
DEFAULT_BUDGET = 10000000;         // Default mission budget ($10M)
DEFAULT_FUEL = 100000;             // Default initial fuel (kg)
COST_PER_KG_FUEL = 5000;           // Cost per kg of fuel ($)
COST_PER_KWH_ENERGY = 0.50;        // Cost per kWh of battery energy ($)
COST_PER_KWH_SOLAR = 0.05;         // Cost per kWh of solar energy ($)
DEFAULT_EFFICIENCY = 100;          // Default cost efficiency (%)
MAX_EFFICIENCY = 150;             // Maximum cost efficiency (%)
MIN_EFFICIENCY = 0;               // Minimum cost efficiency (%)
THRUSTER_ISP = 320;                // Thruster specific impulse (s)
STANDARD_GRAVITY = 9.81;           // Standard gravity (m/s²)
SPACECRAFT_DRY_MASS = 420000;     // Spacecraft dry mass (kg)

// Global financial state
global finance_state;
finance_state = struct(..
    "total_budget", DEFAULT_BUDGET, ..
    "remaining_budget", DEFAULT_BUDGET, ..
    "fuel_cost_total", 0, ..
    "energy_cost_total", 0, ..
    "thruster_burns", 0, ..
    "total_delta_v", 0, ..
    "fuel_remaining", DEFAULT_FUEL, ..
    "cost_efficiency", DEFAULT_EFFICIENCY, ..
    "mission_time", 0 ..
);

// =============================================================================
// Record Thruster Burn Cost
// =============================================================================

function [updated_fuel_cost, updated_fuel_remaining] = record_burn_cost(delta_v, fuel_used, duration)
    // Record cost of thruster burn operation
    // delta_v: velocity change from burn (m/s)
    // fuel_used: fuel consumed (kg)
    // duration: burn duration (s)
    // Returns: updated fuel cost ($), updated fuel remaining (kg)
    
    global finance_state;
    
    // Calculate fuel cost
    burn_fuel_cost = fuel_used * COST_PER_KG_FUEL;
    
    // Update financial totals
    finance_state.fuel_cost_total = finance_state.fuel_cost_total + burn_fuel_cost;
    finance_state.thruster_burns = finance_state.thruster_burns + 1;
    finance_state.total_delta_v = finance_state.total_delta_v + delta_v;
    finance_state.fuel_remaining = finance_state.fuel_remaining - fuel_used;
    
    // Update remaining budget
    finance_state.remaining_budget = finance_state.remaining_budget - burn_fuel_cost;
    
    // Clamp fuel remaining to non-negative
    finance_state.fuel_remaining = max(0, finance_state.fuel_remaining);
    
    // Recalculate cost efficiency
    calculate_cost_efficiency();
    
    // Return updated values
    updated_fuel_cost = finance_state.fuel_cost_total;
    updated_fuel_remaining = finance_state.fuel_remaining;
endfunction

// =============================================================================
// Record Energy Cost
// =============================================================================

function record_energy_cost(solar_kwh, battery_kwh)
    // Record energy consumption costs
    // solar_kwh: solar energy consumed (kWh)
    // battery_kwh: battery energy consumed (kWh)
    
    global finance_state;
    
    // Calculate energy costs
    solar_cost = solar_kwh * COST_PER_KWH_SOLAR;
    battery_cost = battery_kwh * COST_PER_KWH_ENERGY;
    total_energy_cost = solar_cost + battery_cost;
    
    // Update financial totals
    finance_state.energy_cost_total = finance_state.energy_cost_total + total_energy_cost;
    
    // Update remaining budget
    finance_state.remaining_budget = finance_state.remaining_budget - total_energy_cost;
    
    // Recalculate cost efficiency
    calculate_cost_efficiency();
endfunction

// =============================================================================
// Calculate Cost Efficiency
// Based on budget usage vs mission progress
// =============================================================================

function calculate_cost_efficiency()
    // Calculate cost efficiency based on budget usage and mission time
    // Higher efficiency = more mission time per dollar spent
    
    global finance_state;
    
    // Total spent on fuel and energy
    total_spent = finance_state.fuel_cost_total + finance_state.energy_cost_total;
    
    // Budget utilization percentage
    budget_used_pct = (total_spent / finance_state.total_budget) * 100;
    
    // Efficiency score calculation
    // Base: 100% - budget used (less budget used = higher efficiency)
    // Bonus: mission time factor (longer missions = more science per dollar)
    if finance_state.mission_time > 0 then
        // Logarithmic time factor rewards longer missions
        time_factor = log(finance_state.mission_time + 1) / 10;
        finance_state.cost_efficiency = max(0, 100 - budget_used_pct + time_factor * 10);
    else
        finance_state.cost_efficiency = 100 - budget_used_pct;
    end
    
    // Clamp to reasonable range [0, 150]
    finance_state.cost_efficiency = max(MIN_EFFICIENCY, min(finance_state.cost_efficiency, MAX_EFFICIENCY));
endfunction

// =============================================================================
// Update Mission Time
// =============================================================================

function update_mission_time(dt)
    // Update mission elapsed time
    // dt: time increment (seconds)
    
    global finance_state;
    
    finance_state.mission_time = finance_state.mission_time + dt;
    
    // Recalculate efficiency with new mission time
    calculate_cost_efficiency();
endfunction

// =============================================================================
// Calculate Cost per Delta-V
// Important metric for orbital maneuver planning
// =============================================================================

function cost_per_dv = get_cost_per_delta_v()
    // Calculate cost per unit delta-v (important metric for maneuver planning)
    // Returns: cost per m/s of delta-v ($/m/s)
    
    global finance_state;
    
    if finance_state.total_delta_v > 0 then
        cost_per_dv = finance_state.fuel_cost_total / finance_state.total_delta_v;
    else
        cost_per_dv = 0;
    end
endfunction

// =============================================================================
// Calculate Burn Economics
// Helps user decide if a burn is worth the cost
// =============================================================================

function [is_economical, reason] = evaluate_burn_economics(required_delta_v, benefit_score)
    // Evaluate if a proposed burn is economically viable
    // required_delta_v: delta-v needed for maneuver (m/s)
    // benefit_score: estimated benefit of maneuver (0-100 scale)
    // Returns: economical (boolean), reason (string)
    
    global finance_state;
    
    // Estimate fuel needed using Tsiolkovsky rocket equation
    // Δv = Isp * g₀ * ln(m₀/mf)
    m_dry = SPACECRAFT_DRY_MASS;
    m_fuel = finance_state.fuel_remaining;
    m_total = m_dry + m_fuel;
    
    // Solve for fuel needed: m_fuel_needed = m_total * (1 - exp(-Δv/(Isp*g₀)))
    mass_ratio = exp(required_delta_v / (THRUSTER_ISP * STANDARD_GRAVITY));
    final_mass = m_total / mass_ratio;
    fuel_needed = m_total - final_mass;
    
    // Calculate cost
    burn_cost = fuel_needed * COST_PER_KG_FUEL;
    
    // Check affordability constraints
    if burn_cost > finance_state.remaining_budget then
        is_economical = %f;
        reason = sprintf("Insufficient budget: Need $%.2f, Have $%.2f", burn_cost, finance_state.remaining_budget);
        return;
    end
    
    if fuel_needed > finance_state.fuel_remaining then
        is_economical = %f;
        reason = sprintf("Insufficient fuel: Need %.1f kg, Have %.1f kg", fuel_needed, finance_state.fuel_remaining);
        return;
    end
    
    // Cost-benefit analysis
    // Normalize cost to 0-100 scale for comparison with benefit score
    cost_factor = burn_cost / 100000;
    
    if benefit_score > cost_factor then
        is_economical = %t;
        reason = sprintf("Burn is economical: Benefit %.2f > Cost %.2f", benefit_score, cost_factor);
    else
        is_economical = %f;
        reason = sprintf("Burn not economical: Benefit %.2f <= Cost %.2f", benefit_score, cost_factor);
    end
endfunction

// =============================================================================
// Get Financial Summary
// Returns formatted string with current financial status
// =============================================================================

function summary = get_financial_summary()
    // Get formatted summary of current financial status
    // Returns: formatted string
    
    global finance_state;
    
    total_spent = finance_state.fuel_cost_total + finance_state.energy_cost_total;
    budget_remaining_pct = (finance_state.remaining_budget / finance_state.total_budget) * 100;
    cost_per_dv = get_cost_per_delta_v();
    mission_hours = finance_state.mission_time / 3600;
    
    summary = sprintf(..
        "Total Budget: $%.2f M\n" + ..
        "Remaining: $%.2f M (%.1f%%)\n" + ..
        "Fuel Cost: $%.2f M\n" + ..
        "Energy Cost: $%.2f M\n" + ..
        "Thruster Burns: %d\n" + ..
        "Total Delta-V: %.1f m/s\n" + ..
        "Cost per Delta-V: $%.2f /m/s\n" + ..
        "Fuel Remaining: %.1f kg\n" + ..
        "Cost Efficiency: %.1f%%\n" + ..
        "Mission Time: %.1f hours", ..
        finance_state.total_budget / 1e6, ..
        finance_state.remaining_budget / 1e6, ..
        budget_remaining_pct, ..
        finance_state.fuel_cost_total / 1e6, ..
        finance_state.energy_cost_total / 1e6, ..
        finance_state.thruster_burns, ..
        finance_state.total_delta_v, ..
        cost_per_dv, ..
        finance_state.fuel_remaining, ..
        finance_state.cost_efficiency, ..
        mission_hours ..
    );
endfunction

// =============================================================================
// Initialize Financial Tracker
// =============================================================================

function init_finance_tracker(initial_budget, initial_fuel)
    // Initialize financial tracker with custom parameters
    // initial_budget: total mission budget ($)
    // initial_fuel: initial fuel quantity (kg)
    
    global finance_state;
    
    // Validate parameters
    if initial_budget <= 0 then
        printf("WARNING: Invalid budget, using default\n");
        initial_budget = DEFAULT_BUDGET;
    end
    if initial_fuel <= 0 then
        printf("WARNING: Invalid fuel, using default\n");
        initial_fuel = DEFAULT_FUEL;
    end
    
    // Initialize financial state
    finance_state.total_budget = initial_budget;
    finance_state.remaining_budget = initial_budget;
    finance_state.fuel_remaining = initial_fuel;
    finance_state.fuel_cost_total = 0;
    finance_state.energy_cost_total = 0;
    finance_state.thruster_burns = 0;
    finance_state.total_delta_v = 0;
    finance_state.cost_efficiency = DEFAULT_EFFICIENCY;
    finance_state.mission_time = 0;
endfunction

// =============================================================================
// Get Cost Breakdown by Category
// Useful for financial reporting
// =============================================================================

function [fuel_pct, energy_pct] = get_cost_breakdown()
    // Get cost breakdown by category (fuel vs energy)
    // Returns: fuel percentage, energy percentage
    
    global finance_state;
    
    total_spent = finance_state.fuel_cost_total + finance_state.energy_cost_total;
    
    if total_spent > 0 then
        fuel_pct = (finance_state.fuel_cost_total / total_spent) * 100;
        energy_pct = (finance_state.energy_cost_total / total_spent) * 100;
    else
        fuel_pct = 0;
        energy_pct = 0;
    end
endfunction
