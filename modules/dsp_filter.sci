// =============================================================================
// AeroGrid-OSMS - Digital Signal Processing Module
// Cosmic static filtering for telemetry data
// =============================================================================

// Global signal processing state
global signal_state;
signal_state = struct(..
    "raw_signal", [], ..
    "filtered_signal", [], ..
    "noise_level", 0.5, ..
    "filter_type", "moving_average", ..
    "filter_window", 5, ..
    "cutoff_frequency", 0.1, ..
    "sampling_rate", 1000 ..
);

// =============================================================================
// Generate Clean Solar Signal
// Simulates solar panel output with realistic variations
// =============================================================================

function clean_signal = generate_solar_signal(duration, sampling_rate, eclipse_mode)
    // Time vector
    t = linspace(0, duration, duration * sampling_rate);
    
    // Base solar power (kW) - typical for ISS solar arrays
    base_power = 250;  
    
    // Add realistic variations
    // 1. Diurnal cycle (simplified)
    if eclipse_mode then
        // During eclipse: minimal power from batteries
        diurnal = 0.1 * base_power * (1 + 0.1 * sin(2 * %pi * t / 3600));
    else
        // During sunlight: full power with small variations
        diurnal = base_power * (1 + 0.05 * sin(2 * %pi * t / 3600));
    end
    
    // 2. Thermal variations (slower)
    thermal = 0.02 * base_power * sin(2 * %pi * t / 7200);
    
    // 3. Panel degradation effects (very slow)
    degradation = 0.01 * base_power * (1 - exp(-t / 86400));
    
    // Combine all components
    clean_signal = diurnal + thermal - degradation;
    
    // Ensure non-negative
    clean_signal = max(clean_signal, 0);
endfunction

// =============================================================================
// Add Cosmic Noise to Signal
// Simulates radiation-induced static in telemetry
// =============================================================================

function noisy_signal = add_cosmic_noise(clean_signal, noise_level)
    // Gaussian noise (thermal noise)
    gaussian_noise = noise_level * 20 * rand(clean_signal, "normal");
    
    // Impulse noise (cosmic ray hits)
    impulse_noise = zeros(clean_signal);
    num_impulses = floor(length(clean_signal) * 0.01);  // 1% of samples
    impulse_indices = grand(1, num_impulses, "uin", 1, length(clean_signal));
    impulse_noise(impulse_indices) = noise_level * 100 * (rand(1, num_impulses, "normal") > 0);
    
    // Periodic interference (from station systems)
    periodic_noise = noise_level * 5 * sin(2 * %pi * 50 * (1:length(clean_signal)) / 1000);
    
    // Combine all noise sources
    noisy_signal = clean_signal + gaussian_noise + impulse_noise + periodic_noise;
    
    // Ensure non-negative
    noisy_signal = max(noisy_signal, 0);
endfunction

// =============================================================================
// Moving Average Filter
// Simple time-domain filter for noise reduction
// =============================================================================

function filtered = moving_average_filter(signal, window_size)
    n = length(signal);
    filtered = zeros(n, 1);
    
    // Handle edge cases
    if window_size < 1 then
        window_size = 1;
    end
    if window_size > n then
        window_size = n;
    end
    
    // Apply moving average
    for i = 1:n
        start_idx = max(1, i - floor(window_size/2));
        end_idx = min(n, i + floor(window_size/2));
        filtered(i) = mean(signal(start_idx:end_idx));
    end
endfunction

// =============================================================================
// Butterworth Low-pass Filter
// Frequency-domain filter for removing high-frequency noise
// =============================================================================

function filtered = butterworth_filter(signal, cutoff_freq, sampling_rate)
    // Normalize cutoff frequency
    nyquist = sampling_rate / 2;
    normalized_cutoff = cutoff_freq / nyquist;
    
    // Ensure cutoff is valid
    if normalized_cutoff >= 1 then
        normalized_cutoff = 0.99;
    end
    if normalized_cutoff <= 0 then
        normalized_cutoff = 0.01;
    end
    
    // Use ffilt for FIR filter design (more compatible)
    // Design a low-pass FIR filter
    order = 50;  // Filter order
    hz = ffilt("lp", order, normalized_cutoff);
    
    // Apply filter using convolution
    filtered = conv(hz, signal);
    
    // Trim to original length
    filtered = filtered(1:length(signal));
    
    // Handle initial transient
    filtered(1:10) = signal(1:10);  // Keep first few samples unchanged
endfunction

// =============================================================================
// Apply Selected Filter
// =============================================================================

function apply_filter()
    global signal_state;
    
    if isempty(signal_state.raw_signal) then
        return;
    end
    
    select signal_state.filter_type
    case "moving_average" then
        signal_state.filtered_signal = moving_average_filter(..
            signal_state.raw_signal, signal_state.filter_window);
    case "butterworth" then
        signal_state.filtered_signal = butterworth_filter(..
            signal_state.raw_signal, signal_state.cutoff_frequency, ..
            signal_state.sampling_rate);
    else
        signal_state.filtered_signal = signal_state.raw_signal;
    end
endfunction

// =============================================================================
// Generate Signal Processing Test Data
// =============================================================================

function generate_test_signals(duration, noise_level, eclipse_mode)
    global signal_state;
    
    signal_state.sampling_rate = 1000;
    
    // Generate clean signal
    clean_sig = generate_solar_signal(duration, signal_state.sampling_rate, eclipse_mode);
    
    // Add noise
    signal_state.raw_signal = add_cosmic_noise(clean_sig, noise_level);
    signal_state.noise_level = noise_level;
    
    // Apply current filter
    apply_filter();
endfunction

// =============================================================================
// Calculate Signal Quality Metrics
// =============================================================================

function [snr, rms_error, correlation] = calculate_signal_metrics(clean_signal, filtered_signal)
    // Signal-to-Noise Ratio
    signal_power = mean(clean_signal.^2);
    noise_power = mean((filtered_signal - clean_signal).^2);
    snr = 10 * log10(signal_power / (noise_power + 1e-10));
    
    // Root Mean Square Error
    rms_error = sqrt(mean((filtered_signal - clean_signal).^2));
    
    // Correlation coefficient
    correlation = corr(clean_signal, filtered_signal);
endfunction

// =============================================================================
// Emergency Noise Injection
// Simulates space debris collision or solar flare
// =============================================================================

function inject_emergency_noise()
    global signal_state;
    
    if isempty(signal_state.raw_signal) then
        return;
    end
    
    // Massive noise spike
    emergency_noise = 200 * rand(signal_state.raw_signal, "normal");
    
    // Add to raw signal
    signal_state.raw_signal = signal_state.raw_signal + emergency_noise;
    
    // Ensure non-negative
    signal_state.raw_signal = max(signal_state.raw_signal, 0);
    
    // Re-apply filter
    apply_filter();
endfunction

// =============================================================================
// Set Filter Parameters
// =============================================================================

function set_filter_parameters(filter_type, window_size, cutoff_freq)
    global signal_state;
    
    signal_state.filter_type = filter_type;
    signal_state.filter_window = window_size;
    signal_state.cutoff_frequency = cutoff_freq;
    
    // Re-apply filter with new parameters
    if ~isempty(signal_state.raw_signal) then
        apply_filter();
    end
endfunction
