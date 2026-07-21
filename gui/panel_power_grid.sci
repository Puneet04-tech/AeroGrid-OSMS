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
    "mission_status", [], ..
    "emergency_button", [], ..
    "export_button", [] ..
);

// =============================================================================
// Build Power Grid Panel
// =============================================================================

function build_power_grid_panel(parent, panel_width, panel_height)
    global power_handles;
    
    // Panel title with description
    power_handles.title = uicontrol(..
        "parent", parent, ..
        "style", "text", ..
        "string", "Panel 3: Power Grid & Financial Calculator - Resource Management", ..
        "position", [10, panel_height - 40, panel_width - 20, 30], ..
        "background", [0.2, 0.2, 0.25], ..
        "foreground", [1, 1, 1], ..
        "fontsize", 11, ..
        "fontweight", "bold", ..
        "horizontalalignment", "center" ..
    );
    
    // Subsystem controls with description
    uicontrol(..
        "parent", parent, ..
        "style", "text", ..
        "string", "=== Station Subsystems (Toggle Power Usage) ===", ..
        "position", [10, panel_height - 70, panel_width - 20, 20], ..
        "background", [0.2, 0.2, 0.25], ..
        "foreground", [0.8, 0.8, 0.8], ..
        "fontsize", 9, ..
        "horizontalalignment", "center" ..
    );
    
    // Oxygen checkbox with description
    power_handles.subsystem_checkboxes.oxygen = uicontrol(..
        "parent", parent, ..
        "style", "checkbox", ..
        "string", "Oxygen Generation - Essential (15 kW)", ..
        "position", [10, panel_height - 95, panel_width - 20, 20], ..
        "value", 1, ..
        "callback", 'on_subsystem_toggle("oxygen")', ..
        "background", [0.2, 0.2, 0.25], ..
        "foreground", [1, 1, 1], ..
        "fontsize", 9 ..
    );
    
    // Comms checkbox with description
    power_handles.subsystem_checkboxes.comms = uicontrol(..
        "parent", parent, ..
        "style", "checkbox", ..
        "string", "Communications - Essential (10 kW)", ..
        "position", [10, panel_height - 120, panel_width - 20, 20], ..
        "value", 1, ..
        "callback", 'on_subsystem_toggle("comms")', ..
        "background", [0.2, 0.2, 0.25], ..
        "foreground", [1, 1, 1], ..
        "fontsize", 9 ..
    );
    
    // Cryo Labs checkbox with description
    power_handles.subsystem_checkboxes.cryo_labs = uicontrol(..
        "parent", parent, ..
        "style", "checkbox", ..
        "string", "Cryogenic Labs - Non-Essential (25 kW)", ..
        "position", [10, panel_height - 145, panel_width - 20, 20], ..
        "value", 0, ..
        "callback", 'on_subsystem_toggle("cryo_labs")', ..
        "background", [0.2, 0.2, 0.25], ..
        "foreground", [1, 1, 1], ..
        "fontsize", 9 ..
    );
    
    // Power table section header
    uicontrol(..
        "parent", parent, ..
        "style", "text", ..
        "string", "=== Power Grid Status ===", ..
        "position", [10, panel_height - 175, panel_width - 20, 20], ..
        "background", [0.2, 0.2, 0.25], ..
        "foreground", [0.8, 0.8, 0.8], ..
        "fontsize", 9, ..
        "horizontalalignment", "center" ..
    );
    
    // Battery charge display with status
    power_handles.battery_bar = uicontrol(..
        "parent", parent, ..
        "style", "text", ..
        "string", "Battery: 80.0/100.0 kWh (80.0% - Good)", ..
        "position", [10, panel_height - 200, panel_width - 20, 20], ..
        "background", [0.15, 0.15, 0.2], ..
        "foreground", [0.3, 1, 0.8], ..
        "fontsize", 9 ..
    );
    
    // Solar input display with status
    power_handles.solar_display = uicontrol(..
        "parent", parent, ..
        "style", "text", ..
        "string", "Solar Input: 0.0 kW (Eclipse Mode)", ..
        "position", [10, panel_height - 225, panel_width - 20, 20], ..
        "background", [0.15, 0.15, 0.2], ..
        "foreground", [1, 0.8, 0.3], ..
        "fontsize", 9 ..
    );
    
    // Consumer load display with description
    power_handles.load_display = uicontrol(..
        "parent", parent, ..
        "style", "text", ..
        "string", "Consumer Load: 45.0 kW (Active Subsystems)", ..
        "position", [10, panel_height - 250, panel_width - 20, 20], ..
        "background", [0.15, 0.15, 0.2], ..
        "foreground", [1, 0.5, 0.5], ..
        "fontsize", 9 ..
    );
    
    // Net power display with description
    power_handles.net_display = uicontrol(..
        "parent", parent, ..
        "style", "text", ..
        "string", "Net Power: -45.0 kW (Discharging)", ..
        "position", [10, panel_height - 275, panel_width - 20, 20], ..
        "background", [0.15, 0.15, 0.2], ..
        "foreground", [0.8, 0.8, 1], ..
        "fontsize", 9 ..
    );
    
    // Battery health display with status
    power_handles.health_display = uicontrol(..
        "parent", parent, ..
        "style", "text", ..
        "string", "Battery Health: 100.0% (Excellent)", ..
        "position", [10, panel_height - 300, panel_width - 20, 20], ..
        "background", [0.15, 0.15, 0.2], ..
        "foreground", [0.3, 1, 0.3], ..
        "fontsize", 9 ..
    );
    
    // Financial section header
    uicontrol(..
        "parent", parent, ..
        "style", "text", ..
        "string", "=== Financial Tracker ===", ..
        "position", [10, panel_height * 0.32, panel_width - 20, 20], ..
        "background", [0.2, 0.2, 0.25], ..
        "foreground", [0.8, 0.8, 0.8], ..
        "fontsize", 9, ..
        "horizontalalignment", "center" ..
    );
    
    // Budget display with percentage
    power_handles.budget_display = uicontrol(..
        "parent", parent, ..
        "style", "text", ..
        "string", "Budget: $10.00M (100% Remaining)", ..
        "position", [10, panel_height * 0.32 - 25, panel_width - 20, 20], ..
        "background", [0.15, 0.15, 0.2], ..
        "foreground", [0.3, 0.8, 1], ..
        "fontsize", 9 ..
    );
    
    // Fuel cost display with description
    power_handles.fuel_cost_display = uicontrol(..
        "parent", parent, ..
        "style", "text", ..
        "string", "Fuel Cost: $0.00M (Thruster Burns)", ..
        "position", [10, panel_height * 0.32 - 50, panel_width - 20, 20], ..
        "background", [0.15, 0.15, 0.2], ..
        "foreground", [1, 0.6, 0.3], ..
        "fontsize", 9 ..
    );
    
    // Thruster burns display with description
    power_handles.burns_display = uicontrol(..
        "parent", parent, ..
        "style", "text", ..
        "string", "Thruster Burns: 0 (Orbital Maneuvers)", ..
        "position", [10, panel_height * 0.32 - 75, panel_width - 20, 20], ..
        "background", [0.15, 0.15, 0.2], ..
        "foreground", [0.8, 0.8, 0.8], ..
        "fontsize", 9 ..
    );
    
    // Fuel remaining display with percentage
    power_handles.fuel_display = uicontrol(..
        "parent", parent, ..
        "style", "text", ..
        "string", "Fuel Remaining: 100000 kg (100%)", ..
        "position", [10, panel_height * 0.32 - 100, panel_width - 20, 20], ..
        "background", [0.15, 0.15, 0.2], ..
        "foreground", [0.3, 1, 0.3], ..
        "fontsize", 9 ..
    );
    
    // Cost efficiency display with rating
    power_handles.efficiency_display = uicontrol(..
        "parent", parent, ..
        "style", "text", ..
        "string", "Cost Efficiency: 100.0% (Excellent)", ..
        "position", [10, panel_height * 0.32 - 125, panel_width - 20, 20], ..
        "background", [0.15, 0.15, 0.2], ..
        "foreground", [1, 0.8, 0.3], ..
        "fontsize", 9 ..
    );
    
    // Mission status with clearer messaging
    power_handles.mission_status = uicontrol(..
        "parent", parent, ..
        "style", "text", ..
        "string", "Mission Status: NORMAL - All Systems Operational", ..
        "position", [10, 75, panel_width - 20, 25], ..
        "background", [0.15, 0.15, 0.2], ..
        "foreground", [0.3, 1, 0.3], ..
        "fontsize", 10, ..
        "fontweight", "bold", ..
        "horizontalalignment", "center" ..
    );
    
    // Add power equation display with explanation
    uicontrol(..
        "parent", parent, ..
        "style", "text", ..
        "string", "Physics: Energy Balance - dE = integral(P_solar - P_load) dt", ..
        "position", [10, panel_height * 0.32 - 150, panel_width - 20, 20], ..
        "background", [0.2, 0.2, 0.25], ..
        "foreground", [0.6, 0.6, 0.8], ..
        "fontsize", 8, ..
        "horizontalalignment", "center" ..
    );
    
    // Emergency Noise Injection button with description
    power_handles.emergency_button = uicontrol(..
        "parent", parent, ..
        "style", "pushbutton", ..
        "string", "Emergency: Space Debris Collision (Inject Noise)", ..
        "position", [10, 45, panel_width - 20, 25], ..
        "callback", "trigger_emergency()", ..
        "background", [0.8, 0.2, 0.2], ..
        "foreground", [1, 1, 1], ..
        "fontsize", 9 ..
    );
    
    // Export Data button with description
    power_handles.export_button = uicontrol(..
        "parent", parent, ..
        "style", "pushbutton", ..
        "string", "Export Telemetry to CSV Files", ..
        "position", [10, 15, panel_width - 20, 25], ..
        "callback", "export_all_data()", ..
        "background", [0.3, 0.3, 0.6], ..
        "foreground", [1, 1, 1], ..
        "fontsize", 9 ..
    );
endfunction

// =============================================================================
// Update Power Display
// =============================================================================

function update_power_display()
    global power_handles, power_state, finance_state;
    
    // Update battery bar with handle validation
    if ~isempty(power_handles.battery_bar) then
        try
            battery_pct = (power_state.battery_charge / power_state.battery_capacity) * 100;
            // Add battery status description
            if battery_pct > 80 then
                status = "Excellent";
            elseif battery_pct > 50 then
                status = "Good";
            elseif battery_pct > 20 then
                status = "Low";
            else
                status = "Critical";
            end
            power_handles.battery_bar.string = sprintf(..
                "Battery: %.1f/%.1f kWh (%.1f%% - %s)", ..
                power_state.battery_charge, power_state.battery_capacity, battery_pct, status);
            
            // Color code battery level (with try-catch for foreground property)
            try
                if battery_pct < 20 then
                    power_handles.battery_bar.foreground = [1, 0.3, 0.3];
                elseif battery_pct < 50 then
                    power_handles.battery_bar.foreground = [1, 0.8, 0.3];
                else
                    power_handles.battery_bar.foreground = [0.3, 1, 0.8];
                end
            catch
                // Foreground property not supported, skip color coding
            end
        catch
            // Handle is invalid, skip update
        end
    end
    
    // Update solar input with handle validation
    if ~isempty(power_handles.solar_display) then
        try
            // Add solar status description
            if power_state.solar_input > 0 then
                solar_status = "Sunlight Active";
            else
                solar_status = "Eclipse Mode";
            end
            power_handles.solar_display.string = sprintf(..
                "Solar Input: %.1f kW (%s)", power_state.solar_input, solar_status);
        catch
            // Handle is invalid, skip update
        end
    end
    
    // Update consumer load with handle validation
    if ~isempty(power_handles.load_display) then
        try
            power_handles.load_display.string = sprintf(..
                "Consumer Load: %.1f kW (%d subsystems active)", ..
                power_state.consumer_load, ..
                power_state.subsystems.oxygen + power_state.subsystems.comms + power_state.subsystems.cryo_labs);
        catch
            // Handle is invalid, skip update
        end
    end
    
    // Update net power with handle validation
    if ~isempty(power_handles.net_display) then
        try
            // Add net power status description
            if power_state.net_power > 0 then
                net_status = "Charging";
            elseif power_state.net_power < 0 then
                net_status = "Discharging";
            else
                net_status = "Balanced";
            end
            power_handles.net_display.string = sprintf(..
                "Net Power: %.1f kW (%s)", power_state.net_power, net_status);
            
            // Color code net power (with try-catch for foreground property)
            try
                if power_state.net_power < 0 then
                    power_handles.net_display.foreground = [1, 0.5, 0.5];
                else
                    power_handles.net_display.foreground = [0.3, 1, 0.8];
                end
            catch
                // Foreground property not supported, skip color coding
            end
        catch
            // Handle is invalid, skip update
        end
    end
    
    // Update battery health with handle validation
    if ~isempty(power_handles.health_display) then
        try
            // Add health status description
            if power_state.battery_health > 80 then
                health_status = "Excellent";
            elseif power_state.battery_health > 50 then
                health_status = "Good";
            elseif power_state.battery_health > 20 then
                health_status = "Fair";
            else
                health_status = "Poor";
            end
            power_handles.health_display.string = sprintf(..
                "Battery Health: %.1f%% (%s)", power_state.battery_health, health_status);
            
            // Color code battery health (with try-catch for foreground property)
            try
                if power_state.battery_health < 50 then
                    power_handles.health_display.foreground = [1, 0.3, 0.3];
                elseif power_state.battery_health < 80 then
                    power_handles.health_display.foreground = [1, 0.8, 0.3];
                else
                    power_handles.health_display.foreground = [0.3, 1, 0.3];
                end
            catch
                // Foreground property not supported, skip color coding
            end
        catch
            // Handle is invalid, skip update
        end
    end
    
    // Update financial displays with handle validation
    if ~isempty(power_handles.budget_display) then
        try
            budget_remaining = finance_state.remaining_budget / 1e6;
            budget_pct = (finance_state.remaining_budget / finance_state.total_budget) * 100;
            power_handles.budget_display.string = sprintf(..
                "Budget: $%.2fM (%.1f%% Remaining)", budget_remaining, budget_pct);
        catch
            // Handle is invalid, skip update
        end
    end
    
    if ~isempty(power_handles.fuel_cost_display) then
        try
            fuel_cost = finance_state.fuel_cost_total / 1e6;
            power_handles.fuel_cost_display.string = sprintf(..
                "Fuel Cost: $%.2fM (%d burns)", fuel_cost, finance_state.thruster_burns);
        catch
            // Handle is invalid, skip update
        end
    end
    
    if ~isempty(power_handles.burns_display) then
        try
            power_handles.burns_display.string = sprintf(..
                "Thruster Burns: %d", finance_state.thruster_burns);
        catch
            // Handle is invalid, skip update
        end
    end
    
    if ~isempty(power_handles.fuel_display) then
        try
            fuel_pct = (finance_state.fuel_remaining / 100000) * 100;
            power_handles.fuel_display.string = sprintf(..
                "Fuel Remaining: %.1f kg (%.1f%%)", finance_state.fuel_remaining, fuel_pct);
        catch
            // Handle is invalid, skip update
        end
    end
    
    if ~isempty(power_handles.efficiency_display) then
        try
            // Add efficiency rating
            if finance_state.cost_efficiency > 80 then
                eff_rating = "Excellent";
            elseif finance_state.cost_efficiency > 50 then
                eff_rating = "Good";
            elseif finance_state.cost_efficiency > 20 then
                eff_rating = "Fair";
            else
                eff_rating = "Poor";
            end
            power_handles.efficiency_display.string = sprintf(..
                "Cost Efficiency: %.1f%% (%s)", finance_state.cost_efficiency, eff_rating);
            
            // Color code efficiency (with try-catch for foreground property)
            try
                if finance_state.cost_efficiency < 50 then
                    power_handles.efficiency_display.foreground = [1, 0.3, 0.3];
                elseif finance_state.cost_efficiency < 80 then
                    power_handles.efficiency_display.foreground = [1, 0.8, 0.3];
                else
                    power_handles.efficiency_display.foreground = [0.3, 1, 0.3];
                end
            catch
                // Foreground property not supported, skip color coding
            end
        catch
            // Handle is invalid, skip update
        end
    end
    
    // Update mission status with handle validation
    if ~isempty(power_handles.mission_status) then
        try
            // Add clearer mission status messaging
            select power_state.mission_status
            case "NORMAL" then
                status_msg = "Mission Status: NORMAL - All Systems Operational";
            case "WARNING - BATTERY LOW" then
                status_msg = "Mission Status: WARNING - Battery Below 20%";
            case "WARNING - HIGH DRAIN" then
                status_msg = "Mission Status: WARNING - High Power Drain";
            case "CRITICAL - LOW BATTERY" then
                status_msg = "Mission Status: CRITICAL - Battery Below 5%";
            case "MISSION FAILED - BATTERY DEPLETED" then
                status_msg = "Mission Status: FAILED - Battery Depleted";
            else
                status_msg = "Mission Status: " + power_state.mission_status;
            end
            power_handles.mission_status.string = status_msg;
            
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
        catch
            // Handle is invalid, skip update
        end
    end
endfunction

// =============================================================================
// On Subsystem Toggle Callback
// =============================================================================

function on_subsystem_toggle(subsystem_name)
    global power_handles, power_state, orbit_state;
    
    // Toggle the subsystem in power state
    toggle_subsystem(subsystem_name);
    
    // Recalculate load
    calculate_consumer_load();
    
    // Update solar input based on eclipse mode (even without simulation running)
    if orbit_state.eclipse_mode then
        power_state.solar_input = 0;  // No solar power during eclipse
    else
        power_state.solar_input = 50;  // Base solar power during sunlight
    end
    
    // Recalculate net power
    power_state.net_power = power_state.solar_input - power_state.consumer_load;
    
    // Update display
    update_power_display();
    
    printf("Subsystem %s toggled - Load: %.1f kW, Net: %.1f kW\n", ..
           subsystem_name, power_state.consumer_load, power_state.net_power);
endfunction
