// =============================================================================
// AeroGrid-OSMS - Digital Signal Processing Module
// Cosmic static filtering for telemetry data
// =============================================================================

// DSP Constants
BASE_SOLAR_POWER = 250;           // Base solar power output (kW) - ISS-like
MAX_SAMPLES = 10000;              // Maximum samples to prevent memory issues
DEFAULT_SAMPLING_RATE = 1000;     // Default sampling rate (Hz)
DEFAULT_WINDOW_SIZE = 5;          // Default moving average window
DEFAULT_CUTOFF_FREQ = 0.1;        // Default Butterworth cutoff (normalized)
FILTER_ORDER = 50;                // FIR filter order

// Noise parameters
GAUSSIAN_NOISE_SCALE = 20;        // Gaussian noise multiplier
IMPULSE_NOISE_SCALE = 100;       // Impulse noise multiplier
IMPULSE_NOISE_RATE = 0.01;        // Fraction of samples with impulse noise
PERIODIC_NOISE_SCALE = 5;         // Periodic interference multiplier
PERIODIC_NOISE_FREQ = 50;         // Periodic interference frequency (Hz)
EMERGENCY_NOISE_SCALE = 200;      // Emergency noise injection multiplier

// Global signal processing state
global signal_state;
signal_state = struct(..
    "raw_signal", [], ..
    "filtered_signal", [], ..
    "clean_signal", [], ..
    "noise_level", 0.5, ..
    "filter_type", "moving_average", ..
    "filter_window", DEFAULT_WINDOW_SIZE, ..
    "cutoff_frequency", DEFAULT_CUTOFF_FREQ, ..
    "sampling_rate", DEFAULT_SAMPLING_RATE, ..
    "snr_db", 0, ..
    "rms_error", 0, ..
    "correlation", 0 ..
);

// =============================================================================
// Generate Clean Solar Signal
// Simulates solar panel output with realistic variations
// =============================================================================

function clean_signal = generate_solar_signal(duration, sampling_rate, eclipse_mode)
    // Generate realistic solar panel output signal
    // duration: signal duration in seconds
    // sampling_rate: samples per second
    // eclipse_mode: %t if in Earth's shadow, %f otherwise
    // Returns: clean solar power signal (kW)
    
    // Limit samples to prevent memory issues
    actual_samples = min(duration * sampling_rate, MAX_SAMPLES);
    
    // Time vector
    t = linspace(0, duration, actual_samples);
    
    // Base solar power with realistic variations
    // 1. Diurnal cycle (orbital period ~90 minutes = 5400 seconds)
    if eclipse_mode then
        // During eclipse: minimal power from batteries (10% of base)
        diurnal = 0.1 * BASE_SOLAR_POWER * (1 + 0.1 * sin(2 * %pi * t / 5400));
    else
        // During sunlight: full power with small variations (5%)
        diurnal = BASE_SOLAR_POWER * (1 + 0.05 * sin(2 * %pi * t / 5400));
    end
    
    // 2. Thermal variations (slower, 2-hour period)
    thermal = 0.02 * BASE_SOLAR_POWER * sin(2 * %pi * t / 7200);
    
    // 3. Panel degradation effects (very slow, 24-hour timescale)
    degradation = 0.01 * BASE_SOLAR_POWER * (1 - exp(-t / 86400));
    
    // 4. High-frequency panel noise (very small)
    panel_noise = 0.005 * BASE_SOLAR_POWER * rand(1, actual_samples, "normal");
    
    // Combine all components
    clean_signal = diurnal + thermal - degradation + panel_noise;
    
    // Ensure non-negative (power can't be negative)
    clean_signal = max(clean_signal, 0);
endfunction

// =============================================================================
// Add Cosmic Noise to Signal
// Simulates radiation-induced static in telemetry
// =============================================================================

function noisy_signal = add_cosmic_noise(clean_signal, noise_level)
    // Add realistic cosmic noise to clean signal
    // clean_signal: input clean signal
    // noise_level: noise intensity multiplier (0 to 1)
    // Returns: noisy signal
    
    n = length(clean_signal);
    
    // 1. Gaussian noise (thermal noise from electronics)
    gaussian_noise = noise_level * GAUSSIAN_NOISE_SCALE * rand(clean_signal, "normal");
    
    // 2. Impulse noise (cosmic ray hits - sudden spikes)
    impulse_noise = zeros(clean_signal);
    num_impulses = floor(n * IMPULSE_NOISE_RATE);
    if num_impulses > 0 then
        impulse_indices = grand(1, num_impulses, "uin", 1, n);
        // Impulse magnitude: positive spikes only
        impulse_noise(impulse_indices) = noise_level * IMPULSE_NOISE_SCALE * abs(rand(1, num_impulses, "normal"));
    end
    
    // 3. Periodic interference (from station systems at 50 Hz)
    t = (1:n) / DEFAULT_SAMPLING_RATE;
    periodic_noise = noise_level * PERIODIC_NOISE_SCALE * sin(2 * %pi * PERIODIC_NOISE_FREQ * t);
    
    // Combine all noise sources
    noisy_signal = clean_signal + gaussian_noise + impulse_noise + periodic_noise;
    
    // Ensure non-negative (power can't be negative)
    noisy_signal = max(noisy_signal, 0);
endfunction

// =============================================================================
// Moving Average Filter
// Simple time-domain filter for noise reduction
// =============================================================================

function filtered = moving_average_filter(signal, window_size)
    // Apply moving average filter for noise reduction
    // signal: input signal
    // window_size: number of samples in averaging window
    // Returns: filtered signal
    
    n = length(signal);
    filtered = zeros(n, 1);
    
    // Validate and clamp window size
    if window_size < 1 then
        window_size = 1;
    end
    if window_size > n then
        window_size = n;
    end
    
    // Apply symmetric moving average
    half_window = floor(window_size / 2);
    for i = 1:n
        start_idx = max(1, i - half_window);
        end_idx = min(n, i + half_window);
        filtered(i) = mean(signal(start_idx:end_idx));
    end
endfunction

// =============================================================================
// Butterworth Low-pass Filter
// Frequency-domain filter for removing high-frequency noise
// =============================================================================

function filtered = butterworth_filter(signal, cutoff_freq, sampling_rate)
    // Apply low-pass Butterworth filter for high-frequency noise removal
    // signal: input signal
    // cutoff_freq: cutoff frequency in Hz
    // sampling_rate: sampling rate in Hz
    // Returns: filtered signal
    
    // Normalize cutoff frequency to Nyquist range
    nyquist = sampling_rate / 2;
    normalized_cutoff = cutoff_freq / nyquist;
    
    // Clamp cutoff to valid range (0, 1)
    if normalized_cutoff >= 1 then
        normalized_cutoff = 0.99;
    end
    if normalized_cutoff <= 0 then
        normalized_cutoff = 0.01;
    end
    
    // Design FIR low-pass filter using ffilt
    hz = ffilt("lp", FILTER_ORDER, normalized_cutoff);
    
    // Apply filter using convolution
    filtered = conv(hz, signal);
    
    // Trim to original length (remove convolution tail)
    filtered = filtered(1:length(signal));
    
    // Handle initial transient by keeping first samples unchanged
    transient_length = min(10, length(signal));
    filtered(1:transient_length) = signal(1:transient_length);
endfunction

// =============================================================================
// Apply Selected Filter
// =============================================================================

function apply_filter()
    // Apply currently selected filter to raw signal
    // Updates signal_state.filtered_signal and metrics
    
    global signal_state;
    
    if isempty(signal_state.raw_signal) then
        printf("WARNING: No raw signal to filter\n");
        return;
    end
    
    // Apply selected filter
    select signal_state.filter_type
    case "moving_average" then
        signal_state.filtered_signal = moving_average_filter(..
            signal_state.raw_signal, signal_state.filter_window);
    case "butterworth" then
        signal_state.filtered_signal = butterworth_filter(..
            signal_state.raw_signal, signal_state.cutoff_frequency, ..
            signal_state.sampling_rate);
    case "none" then
        signal_state.filtered_signal = signal_state.raw_signal;
    else
        printf("WARNING: Unknown filter type: %s\n", signal_state.filter_type);
        signal_state.filtered_signal = signal_state.raw_signal;
    end
    
    // Calculate signal quality metrics
    if ~isempty(signal_state.clean_signal) then
        [snr, rms_err, corr] = calculate_signal_metrics(..
            signal_state.clean_signal, signal_state.filtered_signal);
        signal_state.snr_db = snr;
        signal_state.rms_error = rms_err;
        signal_state.correlation = corr;
    end
endfunction

// =============================================================================
// Generate Signal Processing Test Data
// =============================================================================

function generate_test_signals(duration, noise_level, eclipse_mode)
    // Generate test signals for DSP demonstration
    // duration: signal duration in seconds
    // noise_level: noise intensity (0 to 1)
    // eclipse_mode: %t for eclipse, %f for sunlight
    
    global signal_state;
    
    // Set sampling rate
    signal_state.sampling_rate = DEFAULT_SAMPLING_RATE;
    
    // Generate clean signal
    signal_state.clean_signal = generate_solar_signal(duration, ..
        signal_state.sampling_rate, eclipse_mode);
    
    // Add cosmic noise
    signal_state.raw_signal = add_cosmic_noise(signal_state.clean_signal, noise_level);
    signal_state.noise_level = noise_level;
    
    // Apply current filter
    apply_filter();
endfunction

// =============================================================================
// Calculate Signal Quality Metrics
// =============================================================================

function [snr, rms_error, correlation] = calculate_signal_metrics(clean_signal, filtered_signal)
    // Calculate signal quality metrics
    // clean_signal: original clean signal
    // filtered_signal: processed signal
    // Returns: SNR (dB), RMS error, correlation coefficient
    
    n = length(clean_signal);
    if n == 0 then
        snr = 0;
        rms_error = 0;
        correlation = 0;
        return;
    end
    
    // Signal-to-Noise Ratio (SNR) in dB
    // SNR = 10 * log10(P_signal / P_noise)
    signal_power = mean(clean_signal.^2);
    noise = filtered_signal - clean_signal;
    noise_power = mean(noise.^2);
    snr = 10 * log10(signal_power / (noise_power + 1e-10));
    
    // Root Mean Square Error (RMSE)
    rms_error = sqrt(mean(noise.^2));
    
    // Pearson correlation coefficient
    // Measures similarity between clean and filtered signals
    mean_x = mean(clean_signal);
    mean_y = mean(filtered_signal);
    
    numerator = sum((clean_signal - mean_x) .* (filtered_signal - mean_y));
    denominator = sqrt(sum((clean_signal - mean_x).^2) * sum((filtered_signal - mean_y).^2));
    
    if denominator == 0 then
        correlation = 0;
    else
        correlation = numerator / denominator;
    end
endfunction

// =============================================================================
// Emergency Noise Injection
// Simulates space debris collision or solar flare
// =============================================================================

function inject_emergency_noise()
    // Simulate emergency event (space debris collision or solar flare)
    // Injects massive noise spike into signal
    
    global signal_state;
    
    if isempty(signal_state.raw_signal) then
        printf("WARNING: No signal to inject noise into\n");
        return;
    end
    
    // Generate massive noise spike (simulates collision/flare)
    emergency_noise = EMERGENCY_NOISE_SCALE * rand(signal_state.raw_signal, "normal");
    
    // Add to raw signal
    signal_state.raw_signal = signal_state.raw_signal + emergency_noise;
    
    // Ensure non-negative
    signal_state.raw_signal = max(signal_state.raw_signal, 0);
    
    printf("EMERGENCY: Massive noise injected!\n");
    
    // Re-apply filter to show effect
    apply_filter();
endfunction

// =============================================================================
// Set Filter Parameters
// =============================================================================

function set_filter_parameters(filter_type, window_size, cutoff_freq)
    // Update filter parameters and re-apply filter
    // filter_type: "moving_average", "butterworth", or "none"
    // window_size: window size for moving average
    // cutoff_freq: cutoff frequency for Butterworth filter
    
    global signal_state;
    
    // Validate filter type
    valid_filters = ["moving_average", "butterworth", "none"];
    if ~or(filter_type == valid_filters) then
        printf("WARNING: Invalid filter type: %s\n", filter_type);
        return;
    end
    
    // Update parameters
    signal_state.filter_type = filter_type;
    signal_state.filter_window = window_size;
    signal_state.cutoff_frequency = cutoff_freq;
    
    // Re-apply filter with new parameters
    if ~isempty(signal_state.raw_signal) then
        apply_filter();
    end
endfunction
