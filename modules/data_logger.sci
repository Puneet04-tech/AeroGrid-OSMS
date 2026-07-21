// =============================================================================
// AeroGrid-OSMS - Data Logging Module
// CSV export for telemetry and mission data
// =============================================================================

// Data Logger Constants
DATA_DIRECTORY = "data";           // Directory for exported files
CSV_DELIMITER = ";";              // CSV field delimiter
MAX_LOG_SIZE = 100000;             // Maximum log entries to prevent memory issues

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
    // Initialize data logger with empty state
    // Creates data directory if it doesn't exist
    
    global log_state;
    
    // Reset all data arrays
    log_state.telemetry_data = [];
    log_state.orbital_data = [];
    log_state.power_data = [];
    log_state.finance_data = [];
    log_state.session_start_time = getdate();
    log_state.logging_enabled = %t;
    
    // Ensure data directory exists
    if fileinfo(DATA_DIRECTORY) == [] then
        mkdir(DATA_DIRECTORY);
        printf("Created data directory: %s\n", DATA_DIRECTORY);
    end
endfunction

// =============================================================================
// Log Telemetry Data
// Records solar power and filtered signal data
// =============================================================================

function log_telemetry(timestamp, solar_power, raw_signal, filtered_signal)
    // Log telemetry data with signal statistics
    // timestamp: simulation time (seconds)
    // solar_power: current solar input (kW)
    // raw_signal: raw telemetry signal array
    // filtered_signal: filtered telemetry signal array
    
    global log_state;
    
    if ~log_state.logging_enabled then
        return;
    end
    
    // Calculate signal statistics
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
    
    // Create data row
    data_row = [timestamp, solar_power, raw_mean, raw_std, filtered_mean, filtered_std];
    
    // Append to telemetry data
    if isempty(log_state.telemetry_data) then
        log_state.telemetry_data = data_row;
    else
        log_state.telemetry_data = [log_state.telemetry_data; data_row];
    end
    
    // Prevent memory overflow
    if size(log_state.telemetry_data, 1) > MAX_LOG_SIZE then
        printf("WARNING: Telemetry log size limit reached, oldest data discarded\n");
        log_state.telemetry_data = log_state.telemetry_data(2:$, :);
    end
endfunction

// =============================================================================
// Log Orbital Data
// Records position, velocity, and orbital parameters
// =============================================================================

function log_orbital_data(timestamp, altitude, velocity, position_x, position_y, eclipse_mode)
    // Log orbital state data
    // timestamp: simulation time (seconds)
    // altitude: orbital altitude (m)
    // velocity: orbital velocity (m/s)
    // position_x, position_y: orbital position (m)
    // eclipse_mode: %t if in Earth's shadow
    
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
    
    // Prevent memory overflow
    if size(log_state.orbital_data, 1) > MAX_LOG_SIZE then
        printf("WARNING: Orbital log size limit reached, oldest data discarded\n");
        log_state.orbital_data = log_state.orbital_data(2:$, :);
    end
endfunction

// =============================================================================
// Log Power Grid Data
// Records battery state and power consumption
// =============================================================================

function log_power_data(timestamp, battery_charge, solar_input, consumer_load, net_power, battery_health)
    // Log power grid state data
    // timestamp: simulation time (seconds)
    // battery_charge: current battery charge (kWh)
    // solar_input: solar power input (kW)
    // consumer_load: power consumption (kW)
    // net_power: net power (kW, positive = charging)
    // battery_health: battery health percentage
    
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
    
    // Prevent memory overflow
    if size(log_state.power_data, 1) > MAX_LOG_SIZE then
        printf("WARNING: Power log size limit reached, oldest data discarded\n");
        log_state.power_data = log_state.power_data(2:$, :);
    end
endfunction

// =============================================================================
// Log Financial Data
// Records costs and budget status
// =============================================================================

function log_finance_data(timestamp, remaining_budget, fuel_cost, energy_cost, fuel_remaining, cost_efficiency)
    // Log financial state data
    // timestamp: simulation time (seconds)
    // remaining_budget: remaining mission budget ($)
    // fuel_cost: total fuel cost ($)
    // energy_cost: total energy cost ($)
    // fuel_remaining: remaining fuel (kg)
    // cost_efficiency: cost efficiency percentage
    
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
    
    // Prevent memory overflow
    if size(log_state.finance_data, 1) > MAX_LOG_SIZE then
        printf("WARNING: Finance log size limit reached, oldest data discarded\n");
        log_state.finance_data = log_state.finance_data(2:$, :);
    end
endfunction

// =============================================================================
// Export Telemetry Data to CSV
// =============================================================================

function filename = export_telemetry_csv()
    // Export telemetry data to CSV file
    // Returns: filename of exported file, or empty string if failed
    
    global log_state;
    
    if isempty(log_state.telemetry_data) then
        printf("No telemetry data to export.\n");
        filename = "";
        return;
    end
    
    // Ensure data directory exists
    if fileinfo(DATA_DIRECTORY) == [] then
        mkdir(DATA_DIRECTORY);
    end
    
    // Generate filename with timestamp
    current_time = getdate();
    timestamp_str = sprintf("%04d%02d%02d_%02d%02d%02d", ..
        current_time(1), current_time(2), current_time(6), ..
        current_time(7), current_time(8), current_time(9));
    filename = DATA_DIRECTORY + "/telemetry_" + timestamp_str + ".csv";
    
    // Create header
    header = ["Timestamp", "Solar_Power_kW", "Raw_Signal_Mean", "Raw_Signal_Std", ..
              "Filtered_Signal_Mean", "Filtered_Signal_Std"];
    
    // Combine header + data and write to CSV
    full_data = [header; string(log_state.telemetry_data)];
    
    try
        csvWrite(full_data, filename, CSV_DELIMITER);
        printf("Telemetry data exported to: %s\n", filename);
    catch
        printf("ERROR: Failed to export telemetry data to %s\n", filename);
        filename = "";
    end
endfunction

// =============================================================================
// Export Orbital Data to CSV
// =============================================================================

function filename = export_orbital_csv()
    // Export orbital data to CSV file
    // Returns: filename of exported file, or empty string if failed
    
    global log_state;
    
    if isempty(log_state.orbital_data) then
        printf("No orbital data to export.\n");
        filename = "";
        return;
    end
    
    // Ensure data directory exists
    if fileinfo(DATA_DIRECTORY) == [] then
        mkdir(DATA_DIRECTORY);
    end
    
    // Generate filename with timestamp
    current_time = getdate();
    timestamp_str = sprintf("%04d%02d%02d_%02d%02d%02d", ..
        current_time(1), current_time(2), current_time(6), ..
        current_time(7), current_time(8), current_time(9));
    filename = DATA_DIRECTORY + "/orbital_" + timestamp_str + ".csv";
    
    // Create header
    header = ["Timestamp", "Altitude_m", "Velocity_m_s", "Position_X_m", ..
              "Position_Y_m", "Eclipse_Mode"];
    
    // Combine header + data and write to CSV
    full_data = [header; string(log_state.orbital_data)];
    
    try
        csvWrite(full_data, filename, CSV_DELIMITER);
        printf("Orbital data exported to: %s\n", filename);
    catch
        printf("ERROR: Failed to export orbital data to %s\n", filename);
        filename = "";
    end
endfunction

// =============================================================================
// Export Power Grid Data to CSV
// =============================================================================

function filename = export_power_csv()
    // Export power grid data to CSV file
    // Returns: filename of exported file, or empty string if failed
    
    global log_state;
    
    if isempty(log_state.power_data) then
        printf("No power data to export.\n");
        filename = "";
        return;
    end
    
    // Ensure data directory exists
    if fileinfo(DATA_DIRECTORY) == [] then
        mkdir(DATA_DIRECTORY);
    end
    
    // Generate filename with timestamp
    current_time = getdate();
    timestamp_str = sprintf("%04d%02d%02d_%02d%02d%02d", ..
        current_time(1), current_time(2), current_time(6), ..
        current_time(7), current_time(8), current_time(9));
    filename = DATA_DIRECTORY + "/power_" + timestamp_str + ".csv";
    
    // Create header
    header = ["Timestamp", "Battery_Charge_kWh", "Solar_Input_kW", ..
              "Consumer_Load_kW", "Net_Power_kW", "Battery_Health_Percent"];
    
    // Combine header + data and write to CSV
    full_data = [header; string(log_state.power_data)];
    
    try
        csvWrite(full_data, filename, CSV_DELIMITER);
        printf("Power grid data exported to: %s\n", filename);
    catch
        printf("ERROR: Failed to export power data to %s\n", filename);
        filename = "";
    end
endfunction

// =============================================================================
// Export Financial Data to CSV
// =============================================================================

function filename = export_finance_csv()
    // Export financial data to CSV file
    // Returns: filename of exported file, or empty string if failed
    
    global log_state;
    
    if isempty(log_state.finance_data) then
        printf("No financial data to export.\n");
        filename = "";
        return;
    end
    
    // Ensure data directory exists
    if fileinfo(DATA_DIRECTORY) == [] then
        mkdir(DATA_DIRECTORY);
    end
    
    // Generate filename with timestamp
    current_time = getdate();
    timestamp_str = sprintf("%04d%02d%02d_%02d%02d%02d", ..
        current_time(1), current_time(2), current_time(6), ..
        current_time(7), current_time(8), current_time(9));
    filename = DATA_DIRECTORY + "/finance_" + timestamp_str + ".csv";
    
    // Create header
    header = ["Timestamp", "Remaining_Budget_USD", "Fuel_Cost_USD", ..
              "Energy_Cost_USD", "Fuel_Remaining_kg", "Cost_Efficiency_Percent"];
    
    // Combine header + data and write to CSV
    full_data = [header; string(log_state.finance_data)];
    
    try
        csvWrite(full_data, filename, CSV_DELIMITER);
        printf("Financial data exported to: %s\n", filename);
    catch
        printf("ERROR: Failed to export financial data to %s\n", filename);
        filename = "";
    end
endfunction

// =============================================================================
// Export All Data to CSV
// Exports all data types in a single operation
// =============================================================================

function export_all_data()
    // Export all mission data to CSV files
    // If no historical data exists, exports current state
    
    printf("Exporting all mission data...\n");
    
    global log_state, orbit_state, power_state, finance_state, signal_state;
    
    // If no historical data, log current state before export
    if isempty(log_state.telemetry_data) then
        printf("No historical telemetry data, exporting current state...\n");
        current_time = getdate()(9);
        solar_power = power_state.solar_input;
        raw_sig = [];
        filtered_sig = [];
        if ~isempty(signal_state.raw_signal) then
            raw_sig = signal_state.raw_signal;
        end
        if ~isempty(signal_state.filtered_signal) then
            filtered_sig = signal_state.filtered_signal;
        end
        log_telemetry(current_time, solar_power, raw_sig, filtered_sig);
    end
    
    if isempty(log_state.orbital_data) then
        printf("No historical orbital data, exporting current state...\n");
        current_time = getdate()(9);
        log_orbital_data(current_time, orbit_state.altitude, orbit_state.velocity, ..
                         orbit_state.position_x, orbit_state.position_y, orbit_state.eclipse_mode);
    end
    
    if isempty(log_state.power_data) then
        printf("No historical power data, exporting current state...\n");
        current_time = getdate()(9);
        log_power_data(current_time, power_state.battery_charge, power_state.solar_input, ..
                      power_state.consumer_load, power_state.net_power, power_state.battery_health);
    end
    
    if isempty(log_state.finance_data) then
        printf("No historical financial data, exporting current state...\n");
        current_time = getdate()(9);
        log_finance_data(current_time, finance_state.remaining_budget, finance_state.fuel_cost_total, ..
                          finance_state.energy_cost_total, finance_state.fuel_remaining, finance_state.cost_efficiency);
    end
    
    // Export all data types
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
    // Load baseline solar radiation data from CSV file
    // filename: path to baseline data file
    // Returns: numeric data matrix, or empty if failed
    
    if fileinfo(filename) == [] then
        printf("Baseline file not found: %s\n", filename);
        baseline_data = [];
        return;
    end
    
    try
        // Read CSV file
        baseline_data = csvRead(filename, CSV_DELIMITER, [], [], "string");
        
        // Convert to numeric (skip header row)
        if size(baseline_data, 1) > 1 then
            baseline_data = evstr(baseline_data(2:$, :));
            printf("Baseline solar data loaded from: %s (%d rows)\n", filename, size(baseline_data, 1));
        else
            printf("WARNING: Baseline file has no data rows\n");
            baseline_data = [];
        end
    catch
        printf("ERROR: Failed to load baseline data from %s\n", filename);
        baseline_data = [];
    end
endfunction

// =============================================================================
// Create Session Summary Report
// Generates a text summary of the session
// =============================================================================

function create_session_summary()
    // Generate a text summary of the current session
    // Includes data counts and key statistics
    
    global log_state;
    
    // Ensure data directory exists
    if fileinfo(DATA_DIRECTORY) == [] then
        mkdir(DATA_DIRECTORY);
    end
    
    // Generate filename with timestamp
    current_time = getdate();
    timestamp_str = sprintf("%04d%02d%02d_%02d%02d%02d", ..
        current_time(1), current_time(2), current_time(6), ..
        current_time(7), current_time(8), current_time(9));
    filename = DATA_DIRECTORY + "/session_summary_" + timestamp_str + ".txt";
    
    try
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
        
        // Write orbital statistics if data exists
        if ~isempty(log_state.orbital_data) then
            mfprintf(fd, "Orbital Statistics:\n");
            altitudes = log_state.orbital_data(:, 2);
            velocities = log_state.orbital_data(:, 3);
            mfprintf(fd, "  Min Altitude: %.2f km\n", min(altitudes) / 1000);
            mfprintf(fd, "  Max Altitude: %.2f km\n", max(altitudes) / 1000);
            mfprintf(fd, "  Mean Altitude: %.2f km\n", mean(altitudes) / 1000);
            mfprintf(fd, "  Min Velocity: %.2f m/s\n", min(velocities));
            mfprintf(fd, "  Max Velocity: %.2f m/s\n", max(velocities));
            mfprintf(fd, "  Mean Velocity: %.2f m/s\n\n", mean(velocities));
        end
        
        // Write power statistics if data exists
        if ~isempty(log_state.power_data) then
            mfprintf(fd, "Power Statistics:\n");
            battery_levels = log_state.power_data(:, 2);
            solar_inputs = log_state.power_data(:, 3);
            net_powers = log_state.power_data(:, 5);
            mfprintf(fd, "  Min Battery: %.2f kWh\n", min(battery_levels));
            mfprintf(fd, "  Max Battery: %.2f kWh\n", max(battery_levels));
            mfprintf(fd, "  Mean Battery: %.2f kWh\n", mean(battery_levels));
            mfprintf(fd, "  Min Solar Input: %.2f kW\n", min(solar_inputs));
            mfprintf(fd, "  Max Solar Input: %.2f kW\n", max(solar_inputs));
            mfprintf(fd, "  Mean Solar Input: %.2f kW\n", mean(solar_inputs));
            mfprintf(fd, "  Min Net Power: %.2f kW\n", min(net_powers));
            mfprintf(fd, "  Max Net Power: %.2f kW\n", max(net_powers));
            mfprintf(fd, "  Mean Net Power: %.2f kW\n\n", mean(net_powers));
        end
        
        mfprintf(fd, "========================================\n");
        
        mclose(fd);
        
        printf("Session summary saved to: %s\n", filename);
    catch
        printf("ERROR: Failed to create session summary\n");
        if ~isvoid(fd) then
            mclose(fd);
        end
    end
endfunction

// =============================================================================
// Clear Logged Data
// Resets all logged data (use with caution)
// =============================================================================

function clear_logged_data()
    // Clear all logged data (use with caution)
    // Resets all data arrays to empty
    
    global log_state;
    
    log_state.telemetry_data = [];
    log_state.orbital_data = [];
    log_state.power_data = [];
    log_state.finance_data = [];
    
    printf("All logged data has been cleared.\n");
endfunction
