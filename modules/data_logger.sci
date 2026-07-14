// =============================================================================
// AeroGrid-OSMS - Data Logging Module
// CSV export for telemetry and mission data
// =============================================================================

// Global data logging state
global log_state;
log_state = struct(..
    "telemetry_data", [], ..
    "orbital_data", [], ..
    "power_data", [], ..
    "finance_data", [], ..
    "session_start_time", 0, ..
    "logging_enabled", %t ..
);

// =============================================================================
// Initialize Data Logger
// =============================================================================

function init_data_logger()
    global log_state;
    
    log_state.telemetry_data = [];
    log_state.orbital_data = [];
    log_state.power_data = [];
    log_state.finance_data = [];
    log_state.session_start_time = getdate();
    log_state.logging_enabled = %t;
endfunction

// =============================================================================
// Log Telemetry Data
// Records solar power and filtered signal data
// =============================================================================

function log_telemetry(timestamp, solar_power, raw_signal, filtered_signal)
    global log_state;
    
    if ~log_state.logging_enabled then
        return;
    end
    
    // Create data row
    // Calculate statistics
    if ~isempty(raw_signal) then
        raw_mean = mean(raw_signal);
        raw_std = stdev(raw_signal);
    else
        raw_mean = 0;
        raw_std = 0;
    end
    
    if ~isempty(filtered_signal) then
        filtered_mean = mean(filtered_signal);
        filtered_std = stdev(filtered_signal);
    else
        filtered_mean = 0;
        filtered_std = 0;
    end
    
    data_row = [timestamp, solar_power, raw_mean, raw_std, filtered_mean, filtered_std];
    
    // Append to telemetry data
    if isempty(log_state.telemetry_data) then
        log_state.telemetry_data = data_row;
    else
        log_state.telemetry_data = [log_state.telemetry_data; data_row];
    end
endfunction

// =============================================================================
// Log Orbital Data
// Records position, velocity, and orbital parameters
// =============================================================================

function log_orbital_data(timestamp, altitude, velocity, position_x, position_y, eclipse_mode)
    global log_state;
    
    if ~log_state.logging_enabled then
        return;
    end
    
    // Create data row
    data_row = [timestamp, altitude, velocity, position_x, position_y, eclipse_mode];
    
    // Append to orbital data
    if isempty(log_state.orbital_data) then
        log_state.orbital_data = data_row;
    else
        log_state.orbital_data = [log_state.orbital_data; data_row];
    end
endfunction

// =============================================================================
// Log Power Grid Data
// Records battery state and power consumption
// =============================================================================

function log_power_data(timestamp, battery_charge, solar_input, consumer_load, net_power, battery_health)
    global log_state;
    
    if ~log_state.logging_enabled then
        return;
    end
    
    // Create data row
    data_row = [timestamp, battery_charge, solar_input, consumer_load, net_power, battery_health];
    
    // Append to power data
    if isempty(log_state.power_data) then
        log_state.power_data = data_row;
    else
        log_state.power_data = [log_state.power_data; data_row];
    end
endfunction

// =============================================================================
// Log Financial Data
// Records costs and budget status
// =============================================================================

function log_finance_data(timestamp, remaining_budget, fuel_cost, energy_cost, fuel_remaining, cost_efficiency)
    global log_state;
    
    if ~log_state.logging_enabled then
        return;
    end
    
    // Create data row
    data_row = [timestamp, remaining_budget, fuel_cost, energy_cost, fuel_remaining, cost_efficiency];
    
    // Append to finance data
    if isempty(log_state.finance_data) then
        log_state.finance_data = data_row;
    else
        log_state.finance_data = [log_state.finance_data; data_row];
    end
endfunction

// =============================================================================
// Export Telemetry Data to CSV
// =============================================================================

function filename = export_telemetry_csv()
    global log_state;
    
    if isempty(log_state.telemetry_data) then
        printf("No telemetry data to export.\n");
        filename = "";
        return;
    end
    
    // Generate filename with timestamp
    current_time = getdate();
    timestamp_str = sprintf("%04d%02d%02d_%02d%02d%02d", ..
        current_time(1), current_time(2), current_time(6), ..
        current_time(7), current_time(8), current_time(9));
    filename = "data/telemetry_" + timestamp_str + ".csv";
    
    // Create header
    header = ["Timestamp", "Solar_Power_kW", "Raw_Signal_Mean", "Raw_Signal_Std", ..
              "Filtered_Signal_Mean", "Filtered_Signal_Std"];
    
    // Write to CSV
    csvWrite(header, filename, ";");
    csvWrite(log_state.telemetry_data, filename, ";", "append");
    
    printf("Telemetry data exported to: %s\n", filename);
endfunction

// =============================================================================
// Export Orbital Data to CSV
// =============================================================================

function filename = export_orbital_csv()
    global log_state;
    
    if isempty(log_state.orbital_data) then
        printf("No orbital data to export.\n");
        filename = "";
        return;
    end
    
    // Generate filename with timestamp
    current_time = getdate();
    timestamp_str = sprintf("%04d%02d%02d_%02d%02d%02d", ..
        current_time(1), current_time(2), current_time(6), ..
        current_time(7), current_time(8), current_time(9));
    filename = "data/orbital_" + timestamp_str + ".csv";
    
    // Create header
    header = ["Timestamp", "Altitude_m", "Velocity_m_s", "Position_X_m", ..
              "Position_Y_m", "Eclipse_Mode"];
    
    // Write to CSV
    csvWrite(header, filename, ";");
    csvWrite(log_state.orbital_data, filename, ";", "append");
    
    printf("Orbital data exported to: %s\n", filename);
endfunction

// =============================================================================
// Export Power Grid Data to CSV
// =============================================================================

function filename = export_power_csv()
    global log_state;
    
    if isempty(log_state.power_data) then
        printf("No power data to export.\n");
        filename = "";
        return;
    end
    
    // Generate filename with timestamp
    current_time = getdate();
    timestamp_str = sprintf("%04d%02d%02d_%02d%02d%02d", ..
        current_time(1), current_time(2), current_time(6), ..
        current_time(7), current_time(8), current_time(9));
    filename = "data/power_" + timestamp_str + ".csv";
    
    // Create header
    header = ["Timestamp", "Battery_Charge_kWh", "Solar_Input_kW", ..
              "Consumer_Load_kW", "Net_Power_kW", "Battery_Health_Percent"];
    
    // Write to CSV
    csvWrite(header, filename, ";");
    csvWrite(log_state.power_data, filename, ";", "append");
    
    printf("Power grid data exported to: %s\n", filename);
endfunction

// =============================================================================
// Export Financial Data to CSV
// =============================================================================

function filename = export_finance_csv()
    global log_state;
    
    if isempty(log_state.finance_data) then
        printf("No financial data to export.\n");
        filename = "";
        return;
    end
    
    // Generate filename with timestamp
    current_time = getdate();
    timestamp_str = sprintf("%04d%02d%02d_%02d%02d%02d", ..
        current_time(1), current_time(2), current_time(6), ..
        current_time(7), current_time(8), current_time(9));
    filename = "data/finance_" + timestamp_str + ".csv";
    
    // Create header
    header = ["Timestamp", "Remaining_Budget_USD", "Fuel_Cost_USD", ..
              "Energy_Cost_USD", "Fuel_Remaining_kg", "Cost_Efficiency_Percent"];
    
    // Write to CSV
    csvWrite(header, filename, ";");
    csvWrite(log_state.finance_data, filename, ";", "append");
    
    printf("Financial data exported to: %s\n", filename);
endfunction

// =============================================================================
// Export All Data to CSV
// Exports all data types in a single operation
// =============================================================================

function export_all_data()
    printf("Exporting all mission data...\n");
    
    // If no historical data, export current state
    global log_state, orbit_state, power_state, finance_state;
    
    if isempty(log_state.telemetry_data) then
        printf("No historical telemetry data, exporting current state...\n");
        // Log current state
        log_telemetry(getdate()(9), power_state.solar_input, [], []);
    end
    
    if isempty(log_state.orbital_data) then
        printf("No historical orbital data, exporting current state...\n");
        // Log current state
        log_orbital_data(getdate()(9), orbit_state.altitude, orbit_state.velocity);
    end
    
    if isempty(log_state.power_data) then
        printf("No historical power data, exporting current state...\n");
        // Log current state
        log_power_data(getdate()(9), power_state.battery_charge, power_state.solar_input, ..
                      power_state.consumer_load, power_state.net_power, power_state.battery_health);
    end
    
    if isempty(log_state.finance_data) then
        printf("No historical financial data, exporting current state...\n");
        // Log current state
        log_financial_data(getdate()(9), finance_state.remaining_budget, finance_state.fuel_cost_total, ..
                          finance_state.energy_cost_total, finance_state.fuel_remaining);
    end
    
    telemetry_file = export_telemetry_csv();
    orbital_file = export_orbital_csv();
    power_file = export_power_csv();
    finance_file = export_finance_csv();
    
    printf("\nExport complete!\n");
endfunction

// =============================================================================
// Load Baseline Solar Data
// Imports baseline solar radiation data for comparison
// =============================================================================

function baseline_data = load_baseline_solar(filename)
    if fileinfo(filename) == [] then
        printf("Baseline file not found: %s\n", filename);
        baseline_data = [];
        return;
    end
    
    // Read CSV file (skip header)
    baseline_data = csvRead(filename, ";", [], [], "string");
    
    // Convert to numeric (skip header row)
    baseline_data = evstr(baseline_data(2:$, :));
    
    printf("Baseline solar data loaded from: %s\n", filename);
endfunction

// =============================================================================
// Create Session Summary Report
// Generates a text summary of the session
// =============================================================================

function create_session_summary()
    global log_state;
    
    // Generate filename
    current_time = getdate();
    timestamp_str = sprintf("%04d%02d%02d_%02d%02d%02d", ..
        current_time(1), current_time(2), current_time(6), ..
        current_time(7), current_time(8), current_time(9));
    filename = "data/session_summary_" + timestamp_str + ".txt";
    
    // Create file
    fd = mopen(filename, "w");
    
    // Write header
    mfprintf(fd, "========================================\n");
    mfprintf(fd, "   AeroGrid-OSMS Session Summary\n");
    mfprintf(fd, "========================================\n\n");
    
    // Write session info
    mfprintf(fd, "Session Start: %04d-%02d-%02d %02d:%02d:%02d\n", ..
        log_state.session_start_time(1), log_state.session_start_time(2), ..
        log_state.session_start_time(6), log_state.session_start_time(7), ..
        log_state.session_start_time(8), log_state.session_start_time(9));
    
    mfprintf(fd, "Session End: %04d-%02d-%02d %02d:%02d:%02d\n\n", ..
        current_time(1), current_time(2), current_time(6), ..
        current_time(7), current_time(8), current_time(9));
    
    // Write data counts
    mfprintf(fd, "Data Points Logged:\n");
    mfprintf(fd, "  Telemetry: %d\n", size(log_state.telemetry_data, 1));
    mfprintf(fd, "  Orbital: %d\n", size(log_state.orbital_data, 1));
    mfprintf(fd, "  Power: %d\n", size(log_state.power_data, 1));
    mfprintf(fd, "  Financial: %d\n\n", size(log_state.finance_data, 1));
    
    // Write statistics if data exists
    if ~isempty(log_state.orbital_data) then
        mfprintf(fd, "Orbital Statistics:\n");
        altitudes = log_state.orbital_data(:, 2);
        mfprintf(fd, "  Min Altitude: %.2f km\n", min(altitudes) / 1000);
        mfprintf(fd, "  Max Altitude: %.2f km\n", max(altitudes) / 1000);
        mfprintf(fd, "  Mean Altitude: %.2f km\n\n", mean(altitudes) / 1000);
    end
    
    if ~isempty(log_state.power_data) then
        mfprintf(fd, "Power Statistics:\n");
        battery_levels = log_state.power_data(:, 2);
        mfprintf(fd, "  Min Battery: %.2f kWh\n", min(battery_levels));
        mfprintf(fd, "  Max Battery: %.2f kWh\n", max(battery_levels));
        mfprintf(fd, "  Mean Battery: %.2f kWh\n\n", mean(battery_levels));
    end
    
    mfprintf(fd, "========================================\n");
    
    mclose(fd);
    
    printf("Session summary saved to: %s\n", filename);
endfunction

// =============================================================================
// Clear Logged Data
// Resets all logged data (use with caution)
// =============================================================================

function clear_logged_data()
    global log_state;
    
    log_state.telemetry_data = [];
    log_state.orbital_data = [];
    log_state.power_data = [];
    log_state.finance_data = [];
    
    printf("All logged data has been cleared.\n");
endfunction
