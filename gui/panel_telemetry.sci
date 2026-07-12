// =============================================================================
// AeroGrid-OSMS - Telemetry Panel
// Panel 2: Deep-Space Telemetry DSP Filter
// =============================================================================

// Global handles for telemetry panel
global telemetry_handles;
telemetry_handles = struct(..
    "title", [], ..
    "filter_type_radio", [], ..
    "filter_slider", [], ..
    "filter_label", [], ..
    "noise_slider", [], ..
    "noise_label", [], ..
    "input_axes", [], ..
    "output_axes", [], ..
    "snr_display", [], ..
    "filter_info", [], ..
    "apply_filter_button", [] ..
);

// =============================================================================
// Build Telemetry Panel
// =============================================================================

function build_telemetry_panel(parent, panel_width, panel_height)
    global telemetry_handles;
    
    // Panel title
    telemetry_handles.title = uicontrol(..
        "parent", parent, ..
        "style", "text", ..
        "string", "Panel 2: Deep-Space Telemetry DSP Filter", ..
        "position", [10, panel_height - 40, panel_width - 20, 30], ..
        "background", [0.2, 0.2, 0.25], ..
        "foreground", [1, 1, 1], ..
        "fontsize", 12, ..
        "fontweight", "bold", ..
        "horizontalalignment", "center" ..
    );
    
    // Filter type selection
    uicontrol(..
        "parent", parent, ..
        "style", "text", ..
        "string", "Filter Type:", ..
        "position", [10, panel_height - 70, panel_width - 20, 20], ..
        "background", [0.2, 0.2, 0.25], ..
        "foreground", [0.8, 0.8, 0.8], ..
        "fontsize", 9 ..
    );
    
    // Radio buttons for filter type
    telemetry_handles.filter_type_radio = uicontrol(..
        "parent", parent, ..
        "style", "radiobutton", ..
        "string", "Moving Average Filter", ..
        "position", [10, panel_height - 95, panel_width - 20, 20], ..
        "value", 1, ..
        "callback", "on_filter_type_change()", ..
        "background", [0.2, 0.2, 0.25], ..
        "foreground", [1, 1, 1], ..
        "fontsize", 9, ..
        "tag", "radio_moving_avg" ..
    );
    
    uicontrol(..
        "parent", parent, ..
        "style", "radiobutton", ..
        "string", "Low-pass Butterworth Filter", ..
        "position", [10, panel_height - 120, panel_width - 20, 20], ..
        "value", 0, ..
        "callback", "on_filter_type_change()", ..
        "background", [0.2, 0.2, 0.25], ..
        "foreground", [1, 1, 1], ..
        "fontsize", 9, ..
        "tag", "radio_butterworth" ..
    );
    
    // Filter parameter slider
    uicontrol(..
        "parent", parent, ..
        "style", "text", ..
        "string", "Filter Parameter (Window Size / Cutoff Freq)", ..
        "position", [10, panel_height - 150, panel_width - 20, 20], ..
        "background", [0.2, 0.2, 0.25], ..
        "foreground", [0.8, 0.8, 0.8], ..
        "fontsize", 9 ..
    );
    
    telemetry_handles.filter_slider = uicontrol(..
        "parent", parent, ..
        "style", "slider", ..
        "min", 1, ..
        "max", 50, ..
        "value", 5, ..
        "position", [10, panel_height - 175, panel_width - 20, 25], ..
        "callback", "on_filter_param_change()", ..
        "background", [0.3, 0.3, 0.35], ..
        "sliderstep", [1, 5] ..
    );
    
    telemetry_handles.filter_label = uicontrol(..
        "parent", parent, ..
        "style", "text", ..
        "string", "Window Size: 5", ..
        "position", [10, panel_height - 200, panel_width - 20, 20], ..
        "background", [0.2, 0.2, 0.25], ..
        "foreground", [1, 0.8, 0.3], ..
        "fontsize", 10, ..
        "horizontalalignment", "center" ..
    );
    
    // Noise level slider
    uicontrol(..
        "parent", parent, ..
        "style", "text", ..
        "string", "Noise Level (Cosmic Radiation)", ..
        "position", [10, panel_height - 230, panel_width - 20, 20], ..
        "background", [0.2, 0.2, 0.25], ..
        "foreground", [0.8, 0.8, 0.8], ..
        "fontsize", 9 ..
    );
    
    telemetry_handles.noise_slider = uicontrol(..
        "parent", parent, ..
        "style", "slider", ..
        "min", 0, ..
        "max", 2, ..
        "value", 0.5, ..
        "position", [10, panel_height - 255, panel_width - 20, 25], ..
        "callback", "on_noise_change()", ..
        "background", [0.3, 0.3, 0.35], ..
        "sliderstep", [0.1, 0.5] ..
    );
    
    telemetry_handles.noise_label = uicontrol(..
        "parent", parent, ..
        "style", "text", ..
        "string", "Noise Level: 0.5", ..
        "position", [10, panel_height - 280, panel_width - 20, 20], ..
        "background", [0.2, 0.2, 0.25], ..
        "foreground", [1, 0.8, 0.3], ..
        "fontsize", 10, ..
        "horizontalalignment", "center" ..
    );
    
    // Input signal axes (Noisy) - store parent handle
    telemetry_handles.input_axes = parent;
    
    // Output signal axes (Filtered) - store parent handle
    telemetry_handles.output_axes = parent;
    
    // Skip initial signal plots to avoid parent issues
    // plot_signals();
    
    // SNR display
    telemetry_handles.snr_display = uicontrol(..
        "parent", parent, ..
        "style", "text", ..
        "string", "SNR: Calculating...", ..
        "position", [10, panel_height * 0.07, (panel_width - 20) / 2 - 5, 20], ..
        "background", [0.2, 0.2, 0.25], ..
        "foreground", [0.3, 1, 0.8], ..
        "fontsize", 9 ..
    );
    
    // Filter info
    telemetry_handles.filter_info = uicontrol(..
        "parent", parent, ..
        "style", "text", ..
        "string", "Filter: Moving Average (Window: 5)", ..
        "position", [panel_width / 2, panel_height * 0.07, (panel_width - 20) / 2 - 5, 20], ..
        "background", [0.2, 0.2, 0.25], ..
        "foreground", [0.8, 0.8, 1], ..
        "fontsize", 9 ..
    );
    
    // Apply Filter button
    telemetry_handles.apply_filter_button = uicontrol(..
        "parent", parent, ..
        "style", "pushbutton", ..
        "string", "Apply Filter", ..
        "position", [10, panel_height * 0.07 + 25, panel_width - 20, 25], ..
        "callback", "on_apply_filter()", ..
        "background", [0.4, 0.4, 0.6], ..
        "foreground", [1, 1, 1], ..
        "fontsize", 9 ..
    );
endfunction

// =============================================================================
// Plot Signals
// =============================================================================

function plot_signals()
    global telemetry_handles, signal_state;
    
    if isempty(signal_state.raw_signal) then
        return;
    end
    
    // Time vector
    n = length(signal_state.raw_signal);
    t = linspace(0, 60, n);  // 60 seconds
    
    // Create new figure for signals (use figure 100 to avoid conflict with main GUI)
    scf(100);
    clf();
    
    // Plot noisy input signal (top subplot)
    subplot(2, 1, 1);
    plot(t, signal_state.raw_signal, "r-", "linewidth", 1);
    a = gca();
    a.background = [0.1, 0.1, 0.15];
    a.foreground = [1, 1, 1];
    a.font_size = 7;
    a.title.text = "Noisy Input Signal (Cosmic Radiation)";
    a.title.font_size = 8;
    a.y_label.text = "Power (kW)";
    a.x_label.text = "Time (s)";
    a.box = "on";
    
    // Plot filtered output signal (bottom subplot)
    subplot(2, 1, 2);
    plot(t, signal_state.filtered_signal, "g-", "linewidth", 1.5);
    a = gca();
    a.background = [0.1, 0.1, 0.15];
    a.foreground = [1, 1, 1];
    a.font_size = 7;
    a.title.text = "Filtered Output Signal";
    a.title.font_size = 8;
    a.y_label.text = "Power (kW)";
    a.x_label.text = "Time (s)";
    a.box = "on";
endfunction

// =============================================================================
// Update Telemetry Display
// =============================================================================

function update_telemetry_display()
    global telemetry_handles, signal_state;
    
    if isempty(signal_state.raw_signal) then
        return;
    end
    
    // Re-plot signals
    plot_signals();
    
    // Calculate SNR
    clean_sig = generate_solar_signal(60, signal_state.sampling_rate, %f);
    [snr, rms_err, corr] = calculate_signal_metrics(clean_sig, signal_state.filtered_signal);
    
    // Update SNR display with handle validation
    if ~isempty(telemetry_handles.snr_display) then
        try
            telemetry_handles.snr_display.string = sprintf("SNR: %.2f dB", snr);
        catch
            // Handle is invalid, skip update
        end
    end
    
    // Update filter info with handle validation
    if ~isempty(telemetry_handles.filter_info) then
        try
            select signal_state.filter_type
            case "moving_average" then
                telemetry_handles.filter_info.string = sprintf(..
                    "Filter: Moving Average (Window: %d)", signal_state.filter_window);
            case "butterworth" then
                telemetry_handles.filter_info.string = sprintf(..
                    "Filter: Butterworth (Cutoff: %.2f Hz)", signal_state.cutoff_frequency);
            else
                telemetry_handles.filter_info.string = "Filter: None";
            end
        catch
            // Handle is invalid, skip update
        end
    end
endfunction

// =============================================================================
// On Filter Type Change Callback
// =============================================================================

function on_filter_type_change()
    global telemetry_handles, signal_state;
    
    // Check which radio button is selected
    // Note: In Scilab, we need to check the value property
    // This is a simplified implementation
    
    // Get all radio buttons
    fig = gcf();
    radio_buttons = findobj(fig, "style", "radiobutton");
    
    for i = 1:size(radio_buttons)
        if radio_buttons(i).tag == "radio_moving_avg" & radio_buttons(i).value == 1 then
            signal_state.filter_type = "moving_average";
            telemetry_handles.filter_label.string = sprintf("Window Size: %d", signal_state.filter_window);
        elseif radio_buttons(i).tag == "radio_butterworth" & radio_buttons(i).value == 1 then
            signal_state.filter_type = "butterworth";
            telemetry_handles.filter_label.string = sprintf("Cutoff Freq: %.2f Hz", signal_state.cutoff_frequency);
        end
    end
    
    // Re-apply filter
    apply_filter();
    
    // Update display
    update_telemetry_display();
    
    printf("Filter type changed to: %s\n", signal_state.filter_type);
endfunction

// =============================================================================
// On Filter Parameter Change Callback
// =============================================================================

function on_filter_param_change()
    global telemetry_handles, signal_state;
    
    // Check if handle is valid
    if isempty(telemetry_handles.filter_slider) then
        return;
    end
    
    // Get new parameter value with error handling
    try
        param_value = telemetry_handles.filter_slider.value;
    catch
        return;
    end
    
    // Update based on filter type
    select signal_state.filter_type
    case "moving_average" then
        signal_state.filter_window = param_value;
        if ~isempty(telemetry_handles.filter_label) then
            telemetry_handles.filter_label.string = sprintf("Window Size: %d", param_value);
        end
    case "butterworth" then
        signal_state.cutoff_frequency = param_value / 100;  // Scale to reasonable frequency
        if ~isempty(telemetry_handles.filter_label) then
            telemetry_handles.filter_label.string = sprintf("Cutoff Freq: %.2f Hz", signal_state.cutoff_frequency);
        end
    end
    
    // Re-apply filter
    apply_filter();
    
    // Update display
    update_telemetry_display();
endfunction

// =============================================================================
// On Noise Change Callback
// =============================================================================

function on_noise_change()
    global telemetry_handles, signal_state, orbit_state;
    
    // Check if handle is valid
    if isempty(telemetry_handles.noise_slider) then
        return;
    end
    
    // Get new noise level with error handling
    try
        new_noise = telemetry_handles.noise_slider.value;
    catch
        return;
    end
    
    signal_state.noise_level = new_noise;
    
    if ~isempty(telemetry_handles.noise_label) then
        telemetry_handles.noise_label.string = sprintf("Noise Level: %.2f", new_noise);
    end
    
    // Regenerate signals with new noise level
    generate_test_signals(60, new_noise, orbit_state.eclipse_mode);
    
    // Update display
    update_telemetry_display();
    
    printf("Noise level changed to: %.2f\n", new_noise);
endfunction

// =============================================================================
// On Apply Filter Callback
// =============================================================================

function on_apply_filter()
    global signal_state;
    
    // Re-apply filter
    apply_filter();
    
    // Update display
    update_telemetry_display();
    
    printf("Filter applied manually\n");
endfunction
