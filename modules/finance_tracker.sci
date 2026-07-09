// =============================================================================
// AeroGrid-OSMS - Financial Tracking Module
// Cost per burn optimization and mission financial management
// =============================================================================

// Global financial state
global finance_state;
finance_state = struct(..
    "total_budget", 10000000, ..     // $10 million initial budget
    "remaining_budget", 10000000, ..
    "fuel_cost_total", 0, ..
    "energy_cost_total", 0, ..
    "thruster_burns", 0, ..
    "total_delta_v", 0, ..
    "fuel_remaining", 100000, ..    // kg
    "cost_efficiency", 100, ..       // percentage
    "mission_time", 0 ..
);

// Cost constants
COST_PER_KG_FUEL = 5000;           // $5000 per kg of fuel
COST_PER_KWH_ENERGY = 0.50;        // $0.50 per kWh (battery)
COST_PER_KWH_SOLAR = 0.05;         // $0.05 per kWh (solar)

// =============================================================================
// Record Thruster Burn Cost
// =============================================================================

function record_burn_cost(delta_v, fuel_used, duration)
    global finance_state;
    
    // Calculate fuel cost
    burn_fuel_cost = fuel_used * COST_PER_KG_FUEL;
    
    // Update totals
    finance_state.fuel_cost_total = finance_state.fuel_cost_total + burn_fuel_cost;
    finance_state.thruster_burns = finance_state.thruster_burns + 1;
    finance_state.total_delta_v = finance_state.total_delta_v + delta_v;
    finance_state.fuel_remaining = finance_state.fuel_remaining - fuel_used;
    
    // Update remaining budget
    finance_state.remaining_budget = finance_state.remaining_budget - burn_fuel_cost;
    
    // Recalculate cost efficiency
    calculate_cost_efficiency();
endfunction

// =============================================================================
// Record Energy Cost
// =============================================================================

function record_energy_cost(solar_kwh, battery_kwh)
    global finance_state;
    
    // Calculate energy costs
    solar_cost = solar_kwh * COST_PER_KWH_SOLAR;
    battery_cost = battery_kwh * COST_PER_KWH_ENERGY;
    total_energy_cost = solar_cost + battery_cost;
    
    // Update totals
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
    global finance_state;
    
    // Total spent
    total_spent = finance_state.fuel_cost_total + finance_state.energy_cost_total;
    
    // Budget utilization percentage
    budget_used = (total_spent / finance_state.total_budget) * 100;
    
    // Efficiency score (inverse of budget used, adjusted by mission time)
    // More time = better efficiency (more science per dollar)
    if finance_state.mission_time > 0 then
        time_factor = log(finance_state.mission_time + 1) / 10;
        finance_state.cost_efficiency = max(0, 100 - budget_used + time_factor * 10);
    else
        finance_state.cost_efficiency = 100 - budget_used;
    end
    
    // Clamp to reasonable values
    finance_state.cost_efficiency = max(0, min(finance_state.cost_efficiency, 150));
endfunction

// =============================================================================
// Update Mission Time
// =============================================================================

function update_mission_time(dt)
    global finance_state;
    
    finance_state.mission_time = finance_state.mission_time + dt;
    
    // Recalculate efficiency with new time
    calculate_cost_efficiency();
endfunction

// =============================================================================
// Calculate Cost per Delta-V
// Important metric for orbital maneuver planning
// =============================================================================

function cost_per_dv = get_cost_per_delta_v()
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
    global finance_state;
    
    // Estimate fuel needed for this delta-v
    // Using rocket equation: delta_v = Isp * g0 * ln(m0/mf)
    Isp = 320;  // Specific impulse
    g0 = 9.81;  // Standard gravity
    m_dry = 420000;  // Dry mass
    m_fuel = finance_state.fuel_remaining;
    m_total = m_dry + m_fuel;
    
    // Solve for fuel needed
    mass_ratio = exp(required_delta_v / (Isp * g0));
    final_mass = m_total / mass_ratio;
    fuel_needed = m_total - final_mass;
    
    // Calculate cost
    burn_cost = fuel_needed * COST_PER_KG_FUEL;
    
    // Check if affordable
    if burn_cost > finance_state.remaining_budget then
        is_economical = %f;
        reason = "Insufficient budget for this maneuver";
        return;
    end
    
    // Check if enough fuel
    if fuel_needed > finance_state.fuel_remaining then
        is_economical = %f;
        reason = "Insufficient fuel for this maneuver";
        return;
    end
    
    // Cost-benefit analysis
    // If benefit score > cost factor, it's economical
    cost_factor = burn_cost / 100000;  // Normalize to reasonable scale
    
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
    global finance_state;
    
    total_spent = finance_state.fuel_cost_total + finance_state.energy_cost_total;
    budget_remaining_pct = (finance_state.remaining_budget / finance_state.total_budget) * 100;
    cost_per_dv = get_cost_per_delta_v();
    
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
        finance_state.mission_time / 3600 ..
    );
endfunction

// =============================================================================
// Initialize Financial Tracker
// =============================================================================

function init_finance_tracker(initial_budget, initial_fuel)
    global finance_state;
    
    finance_state.total_budget = initial_budget;
    finance_state.remaining_budget = initial_budget;
    finance_state.fuel_remaining = initial_fuel;
    finance_state.fuel_cost_total = 0;
    finance_state.energy_cost_total = 0;
    finance_state.thruster_burns = 0;
    finance_state.total_delta_v = 0;
    finance_state.cost_efficiency = 100;
    finance_state.mission_time = 0;
endfunction

// =============================================================================
// Get Cost Breakdown by Category
// Useful for financial reporting
// =============================================================================

function [fuel_pct, energy_pct] = get_cost_breakdown()
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
