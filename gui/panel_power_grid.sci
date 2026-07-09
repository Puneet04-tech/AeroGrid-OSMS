// =============================================================================
// AeroGrid-OSMS - Power Grid Panel
// Panel 3: Power Grid & Life Support Financial Calculator
// =============================================================================

// Global handles for power grid panel
global power_handles;
power_handles = struct(..
    "title", [], ..
    "subsystem_checkboxes", struct(..
        "oxygen", [], ..
        "comms", [], ..
        "cryo_labs", [] ..
    ), ..
    "power_table", [], ..
    "battery_bar", [], ..
    "finance_display", [], ..
    "efficiency_meter", [], ..
    "mission_status", [] ..
);

// =============================================================================
// Build Power Grid Panel
// =============================================================================

function build_power_grid_panel(parent, panel_width, panel_height)
    global power_handles;
    
    // Panel title
    power_handles.title = uicontrol(..
        "parent", parent, ..
        "style", "text", ..
        "string", "Panel 3: Power Grid & Financial Calculator", ..
        "position", [10, panel_height - 40, panel_width - 20, 30], ..
        "background", [0.2, 0.2, 0.25], ..
        "foreground", [1, 1, 1], ..
        "fontsize", 12, ..
        "fontweight", "bold", ..
        "horizontalalignment", "center" ..
    );
    
    // Subsystem controls
    uicontrol(..
        "parent", parent, ..
        "style", "text", ..
        "string", "Station Subsystems:", ..
        "position", [10, panel_height - 70, panel_width - 20, 20], ..
        "background", [0.2, 0.2, 0.25], ..
        "foreground", [0.8, 0.8, 0.8], ..
        "fontsize", 9 ..
    );
    
    // Oxygen checkbox
    power_handles.subsystem_checkboxes.oxygen = uicontrol(..
        "parent", parent, ..
        "style", "checkbox", ..
        "string", "Oxygen Generation (15 kW)", ..
        "position", [10, panel_height - 95, panel_width - 20, 20], ..
        "value", 1, ..
        "callback", "on_subsystem_toggle(""oxygen"")", ..
        "background", [0.2, 0.2, 0.25], ..
        "foreground", [1, 1, 1], ..
        "fontsize", 9 ..
    );
    
    // Comms checkbox
    power_handles.subsystem_checkboxes.comms = uicontrol(..
        "parent", parent, ..
        "style", "checkbox", ..
        "string", "Communications (10 kW)", ..
        "position", [10, panel_height - 120, panel_width - 20, 20], ..
        "value", 1, ..
        "callback", "on_subsystem_toggle(""comms"")", ..
        "background", [0.2, 0.2, 0.25], ..
        "foreground", [1, 1, 1], ..
        "fontsize", 9 ..
    );
    
    // Cryo Labs checkbox
    power_handles.subsystem_checkboxes.cryo_labs = uicontrol(..
        "parent", parent, ..
        "style", "checkbox", ..
        "string", "Cryogenic Labs (25 kW)", ..
        "position", [10, panel_height - 145, panel_width - 20, 20], ..
        "value", 0, ..
        "callback", "on_subsystem_toggle(""cryo_labs"")", ..
        "background", [0.2, 0.2, 0.25], ..
        "foreground", [1, 1, 1], ..
        "fontsize", 9 ..
    );
    
    // Power table (simulated with text labels)
    uicontrol(..
        "parent", parent, ..
        "style", "text", ..
        "string", "Energy Costs & Status:", ..
        "position", [10, panel_height - 175, panel_width - 20, 20], ..
        "background", [0.2, 0.2, 0.25], ..
        "foreground", [0.8, 0.8, 0.8], ..
        "fontsize", 9 ..
    );
    
    // Battery charge display
    power_handles.battery_bar = uicontrol(..
        "parent", parent, ..
        "style", "text", ..
        "string", "Battery: 80.0/100.0 kWh (80.0%)", ..
        "position", [10, panel_height - 200, panel_width - 20, 20], ..
        "background", [0.15, 0.15, 0.2], ..
        "foreground", [0.3, 1, 0.8], ..
        "fontsize", 9 ..
    );
    
    // Solar input display
    power_handles.solar_display = uicontrol(..
        "parent", parent, ..
        "style", "text", ..
        "string", "Solar Input: 0.0 kW", ..
        "position", [10, panel_height - 225, panel_width - 20, 20], ..
        "background", [0.15, 0.15, 0.2], ..
        "foreground", [1, 0.8, 0.3], ..
        "fontsize", 9 ..
    );
    
    // Consumer load display
    power_handles.load_display = uicontrol(..
        "parent", parent, ..
        "style", "text", ..
        "string", "Consumer Load: 45.0 kW", ..
        "position", [10, panel_height - 250, panel_width - 20, 20], ..
        "background", [0.15, 0.15, 0.2], ..
        "foreground", [1, 0.5, 0.5], ..
        "fontsize", 9 ..
    );
    
    // Net power display
    power_handles.net_display = uicontrol(..
        "parent", parent, ..
        "style", "text", ..
        "string", "Net Power: -45.0 kW", ..
        "position", [10, panel_height - 275, panel_width - 20, 20], ..
        "background", [0.15, 0.15, 0.2], ..
        "foreground", [0.8, 0.8, 1], ..
        "fontsize", 9 ..
    );
    
    // Battery health display
    power_handles.health_display = uicontrol(..
        "parent", parent, ..
        "style", "text", ..
        "string", "Battery Health: 100.0%", ..
        "position", [10, panel_height - 300, panel_width - 20, 20], ..
        "background", [0.15, 0.15, 0.2], ..
        "foreground", [0.3, 1, 0.3], ..
        "fontsize", 9 ..
    );
    
    // Financial section
    uicontrol(..
        "parent", parent, ..
        "style", "text", ..
        "string", "Financial Tracker:", ..
        "position", [10, panel_height * 0.32, panel_width - 20, 20], ..
        "background", [0.2, 0.2, 0.25], ..
        "foreground", [0.8, 0.8, 0.8], ..
        "fontsize", 9 ..
    );
    
    // Budget display
    power_handles.budget_display = uicontrol(..
        "parent", parent, ..
        "style", "text", ..
        "string", "Budget: $10.00M", ..
        "position", [10, panel_height * 0.32 - 25, panel_width - 20, 20], ..
        "background", [0.15, 0.15, 0.2], ..
        "foreground", [0.3, 0.8, 1], ..
        "fontsize", 9 ..
    );
    
    // Fuel cost display
    power_handles.fuel_cost_display = uicontrol(..
        "parent", parent, ..
        "style", "text", ..
        "string", "Fuel Cost: $0.00M", ..
        "position", [10, panel_height * 0.32 - 50, panel_width - 20, 20], ..
        "background", [0.15, 0.15, 0.2], ..
        "foreground", [1, 0.6, 0.3], ..
        "fontsize", 9 ..
    );
    
    // Thruster burns display
    power_handles.burns_display = uicontrol(..
        "parent", parent, ..
        "style", "text", ..
        "string", "Thruster Burns: 0", ..
        "position", [10, panel_height * 0.32 - 75, panel_width - 20, 20], ..
        "background", [0.15, 0.15, 0.2], ..
        "foreground", [0.8, 0.8, 0.8], ..
        "fontsize", 9 ..
    );
    
    // Fuel remaining display
    power_handles.fuel_display = uicontrol(..
        "parent", parent, ..
        "style", "text", ..
        "string", "Fuel Remaining: 100000 kg", ..
        "position", [10, panel_height * 0.32 - 100, panel_width - 20, 20], ..
        "background", [0.15, 0.15, 0.2], ..
        "foreground", [0.3, 1, 0.3], ..
        "fontsize", 9 ..
    );
    
    // Cost efficiency display
    power_handles.efficiency_display = uicontrol(..
        "parent", parent, ..
        "style", "text", ..
        "string", "Cost Efficiency: 100.0%", ..
        "position", [10, panel_height * 0.32 - 125, panel_width - 20, 20], ..
        "background", [0.15, 0.15, 0.2], ..
        "foreground", [1, 0.8, 0.3], ..
        "fontsize", 9 ..
    );
    
    // Mission status
    power_handles.mission_status = uicontrol(..
        "parent", parent, ..
        "style", "text", ..
        "string", "Mission Status: NORMAL", ..
        "position", [10, 10, panel_width - 20, 25], ..
        "background", [0.15, 0.15, 0.2], ..
        "foreground", [0.3, 1, 0.3], ..
        "fontsize", 10, ..
        "fontweight", "bold", ..
        "horizontalalignment", "center" ..
    );
    
    // Add power equation display (LaTeX-style)
    uicontrol(..
        "parent", parent, ..
        "style", "text", ..
        "string", "Power Balance: ∫(Solar - Load) dt", ..
        "position", [10, panel_height * 0.32 - 150, panel_width - 20, 20], ..
        "background", [0.2, 0.2, 0.25], ..
        "foreground", [0.6, 0.6, 0.8], ..
        "fontsize", 8, ..
        "horizontalalignment", "center" ..
    );
endfunction

// =============================================================================
// Update Power Display
// =============================================================================

function update_power_display()
    global power_handles, power_state, finance_state;
    
    // Update battery bar
    battery_pct = (power_state.battery_charge / power_state.battery_capacity) * 100;
    power_handles.battery_bar.string = sprintf(..
        "Battery: %.1f/%.1f kWh (%.1f%%)", ..
        power_state.battery_charge, power_state.battery_capacity, battery_pct);
    
    // Color code battery level
    if battery_pct < 20 then
        power_handles.battery_bar.foreground = [1, 0.3, 0.3];
    elseif battery_pct < 50 then
        power_handles.battery_bar.foreground = [1, 0.8, 0.3];
    else
        power_handles.battery_bar.foreground = [0.3, 1, 0.8];
    end
    
    // Update solar input
    power_handles.solar_display.string = sprintf(..
        "Solar Input: %.1f kW", power_state.solar_input);
    
    // Update consumer load
    power_handles.load_display.string = sprintf(..
        "Consumer Load: %.1f kW", power_state.consumer_load);
    
    // Update net power
    power_handles.net_display.string = sprintf(..
        "Net Power: %.1f kW", power_state.net_power);
    
    // Color code net power
    if power_state.net_power < 0 then
        power_handles.net_display.foreground = [1, 0.5, 0.5];
    else
        power_handles.net_display.foreground = [0.3, 1, 0.8];
    end
    
    // Update battery health
    power_handles.health_display.string = sprintf(..
        "Battery Health: %.1f%%", power_state.battery_health);
    
    // Color code battery health
    if power_state.battery_health < 50 then
        power_handles.health_display.foreground = [1, 0.3, 0.3];
    elseif power_state.battery_health < 80 then
        power_handles.health_display.foreground = [1, 0.8, 0.3];
    else
        power_handles.health_display.foreground = [0.3, 1, 0.3];
    end
    
    // Update financial displays
    budget_remaining = finance_state.remaining_budget / 1e6;
    power_handles.budget_display.string = sprintf(..
        "Budget: $%.2fM", budget_remaining);
    
    fuel_cost = finance_state.fuel_cost_total / 1e6;
    power_handles.fuel_cost_display.string = sprintf(..
        "Fuel Cost: $%.2fM", fuel_cost);
    
    power_handles.burns_display.string = sprintf(..
        "Thruster Burns: %d", finance_state.thruster_burns);
    
    power_handles.fuel_display.string = sprintf(..
        "Fuel Remaining: %.1f kg", finance_state.fuel_remaining);
    
    power_handles.efficiency_display.string = sprintf(..
        "Cost Efficiency: %.1f%%", finance_state.cost_efficiency);
    
    // Color code efficiency
    if finance_state.cost_efficiency < 50 then
        power_handles.efficiency_display.foreground = [1, 0.3, 0.3];
    elseif finance_state.cost_efficiency < 80 then
        power_handles.efficiency_display.foreground = [1, 0.8, 0.3];
    else
        power_handles.efficiency_display.foreground = [0.3, 1, 0.3];
    end
    
    // Update mission status
    power_handles.mission_status.string = "Mission Status: " + power_state.mission_status;
    
    // Color code mission status
    select power_state.mission_status
    case "NORMAL" then
        power_handles.mission_status.foreground = [0.3, 1, 0.3];
        power_handles.mission_status.background = [0.15, 0.15, 0.2];
    case "WARNING - BATTERY LOW" then
        power_handles.mission_status.foreground = [1, 0.8, 0.3];
        power_handles.mission_status.background = [0.2, 0.15, 0.1];
    case "WARNING - HIGH DRAIN" then
        power_handles.mission_status.foreground = [1, 0.8, 0.3];
        power_handles.mission_status.background = [0.2, 0.15, 0.1];
    case "CRITICAL - LOW BATTERY" then
        power_handles.mission_status.foreground = [1, 0.3, 0.3];
        power_handles.mission_status.background = [0.2, 0.1, 0.1];
    case "MISSION FAILED" then
        power_handles.mission_status.foreground = [1, 0.2, 0.2];
        power_handles.mission_status.background = [0.3, 0.05, 0.05];
        // Blink effect
        if modulo(getdate()(9), 2) == 0 then
            power_handles.mission_status.background = [0.5, 0.1, 0.1];
        end
    else
        power_handles.mission_status.foreground = [1, 1, 1];
        power_handles.mission_status.background = [0.15, 0.15, 0.2];
    end
endfunction

// =============================================================================
// On Subsystem Toggle Callback
// =============================================================================

function on_subsystem_toggle(subsystem_name)
    global power_handles;
    
    // Toggle the subsystem in power state
    toggle_subsystem(subsystem_name);
    
    // Recalculate load
    calculate_consumer_load();
    
    // Update display
    update_power_display();
    
    printf("Subsystem %s toggled\n", subsystem_name);
endfunction
