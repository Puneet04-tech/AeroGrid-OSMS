# AeroGrid-OSMS User Guide

## Table of Contents
1. [Introduction](#introduction)
2. [Getting Started](#getting-started)
3. [Panel 1: Flight Dynamics Simulator](#panel-1-flight-dynamics-simulator)
4. [Panel 2: Telemetry DSP Filter](#panel-2-telemetry-dsp-filter)
5. [Panel 3: Power Grid & Financial Calculator](#panel-3-power-grid--financial-calculator)
6. [Emergency Mode](#emergency-mode)
7. [Data Export](#data-export)
8. [Tips for Competition Success](#tips-for-competition-success)
9. [Troubleshooting](#troubleshooting)

---

## Introduction

AeroGrid-OSMS is a comprehensive simulation system that integrates orbital mechanics, digital signal processing, and power grid management. The system demonstrates the interconnected nature of space station operations where orbital parameters affect solar power generation, and cosmic radiation impacts telemetry accuracy.

### Key Features
- **Real-time Orbital Simulation**: Solves differential equations for satellite motion
- **Digital Signal Processing**: Filters cosmic noise from telemetry data
- **Power Grid Management**: Balances solar generation with station consumption
- **Financial Tracking**: Optimizes mission costs and resource usage
- **Emergency Scenarios**: Simulates space debris collisions and solar flares

---

## Getting Started

### Prerequisites
- Scilab 6.0 or higher installed
- GUI Builder Toolbox (optional but recommended)
- Signal Processing Toolbox (for advanced filters)

### Installation

1. **Clone or download the repository**
   ```bash
   git clone <repository-url>
   cd AeroGrid-OSMS
   ```

2. **Install Scilab toolboxes** (if not already installed)
   ```scilab
   atomsInstall('guibuilder')
   atomsInstall('signal')
   ```

3. **Run the application**
   - Open Scilab
   - Navigate to the project directory
   - Execute: `exec('main.sce', -1)`

4. **Run module tests** (optional, to verify installation)
   ```scilab
   exec('test_modules.sce', -1)
   ```

### First Launch

When you first launch AeroGrid-OSMS, you will see:
- A main window with three panels
- Control buttons at the bottom
- A status bar showing system status

The simulation starts in a paused state. Click "Start Simulation" to begin.

---

## Panel 1: Flight Dynamics Simulator

### Overview
This panel simulates the orbital mechanics of the space station around Earth. It uses real gravitational constants and solves differential equations in real-time.

### Controls

#### Altitude Slider
- **Range**: 200 km to 1000 km
- **Default**: 400 km (ISS-like orbit)
- **Effect**: Changes orbital altitude and automatically adjusts velocity for circular orbit
- **Physics**: Lower altitude = faster orbital period, higher atmospheric drag

#### Fire Thrusters Button
- **Purpose**: Increases orbital velocity (prograde burn)
- **Effect**: Raises orbital altitude over time
- **Cost**: Consumes fuel and budget
- **Use Case**: Restore orbit after decay or emergency

### Displays

#### Orbital Trajectory Plot
- **Blue circle**: Earth
- **Green dashed line**: Predicted orbital path
- **Red dot**: Current satellite position

#### Orbital Parameters
- **Velocity**: Current orbital speed in m/s
- **Orbital Period**: Time to complete one orbit
- **Eclipse Mode**: Shows when satellite is in Earth's shadow

#### Status Indicators
- **NOMINAL**: Normal operation
- **CRITICAL ATTRITION**: Altitude below 200 km (immediate action required)

### Mathematical Background

The simulation solves the orbital differential equation:
```
d²r/dt² = -GM/r² * r̂
```

Where:
- G = Gravitational constant (6.674×10⁻¹¹ m³/kg·s²)
- M = Mass of Earth (5.972×10²⁴ kg)
- r = Position vector from Earth's center

Atmospheric drag is modeled using:
```
F_drag = ½ρv²C_dA
```

### Tips
- Keep altitude above 300 km to minimize atmospheric drag
- Use thrusters sparingly to conserve budget
- Monitor eclipse duration - it affects solar power generation

---

## Panel 2: Telemetry DSP Filter

### Overview
This panel simulates cosmic radiation interference in telemetry signals and provides digital filtering to clean the data.

### Controls

#### Filter Type selection
- **Moving Average Filter**: Simple time-domain smoothing
  - Good for: Slow-varying signals, real-time processing
  - Parameter: Window size (1-50 samples)
  
- **Butterworth Low-pass Filter**: Frequency-domain filtering
  - Good for: Removing high-frequency noise
  - Parameter: Cutoff frequency (0.01-0.5 Hz)

#### Filter Parameter Slider
- **Moving Average**: Controls window size
  - Small window (1-5): Fast response, less smoothing
  - Large window (20-50): Slow response, more smoothing
  
- **Butterworth**: Controls cutoff frequency
  - Low cutoff (0.01-0.05): Removes most noise, slow response
  - High cutoff (0.2-0.5): Preserves signal, less noise removal

#### Noise Level Slider
- **Range**: 0.0 to 2.0
- **Default**: 0.5
- **Effect**: Simulates different levels of cosmic radiation
- **Impact**: Higher noise requires stronger filtering

### Displays

#### Noisy Input Signal (Top Plot)
- Shows raw telemetry data with cosmic noise
- Red line indicates noisy signal
- Y-axis: Power in kW
- X-axis: Time in seconds

#### Filtered Output Signal (Bottom Plot)
- Shows cleaned telemetry data
- Green line indicates filtered signal
- Compare with input to assess filter performance

#### Signal Quality Metrics
- **SNR**: Signal-to-Noise Ratio in dB
  - Higher is better (>20 dB is good)
- **Filter Info**: Current filter type and parameters

### Mathematical Background

**Moving Average Filter:**
```
y[n] = (1/N) × Σ(x[n-k]) for k = 0 to N-1
```

**Butterworth Filter:**
Designed using IIR filter design with maximally flat frequency response.

### Tips
- Start with Moving Average filter for simplicity
- Increase window size if noise is high
- Switch to Butterworth for precise frequency control
- Monitor SNR to optimize filter settings
- Emergency mode adds massive noise - adjust filter accordingly

---

## Panel 3: Power Grid & Financial Calculator

### Overview
This panel manages the space station's power systems and tracks mission finances. It demonstrates the interconnected nature of power generation and consumption.

### Controls

#### Subsystem Checkboxes
- **Oxygen Generation (15 kW)**: Essential for life support
- **Communications (10 kW)**: Essential for mission operations
- **Cryogenic Labs (25 kW)**: Optional research facility

### Displays

#### Power Status
- **Battery**: Current charge / total capacity (percentage)
  - Color-coded: Green (>50%), Yellow (20-50%), Red (<20%)
  
- **Solar Input**: Power from solar panels in kW
  - Varies with eclipse mode and filter output
  
- **Consumer Load**: Total power consumption in kW
  - Sum of enabled subsystems + base load (20 kW)
  
- **Net Power**: Solar - Consumer Load
  - Positive: Charging battery
  - Negative: Discharging battery
  
- **Battery Health**: Long-term battery condition
  - Decreases with deep discharges and overcharging

#### Financial Tracker
- **Budget**: Remaining mission budget in millions USD
- **Fuel Cost**: Total spent on propellant
- **Thruster Burns**: Number of orbital maneuvers
- **Fuel Remaining**: Propellant left in kg

#### Cost Efficiency
- **Efficiency Score**: 0-150%
  - Accounts for budget usage vs mission time
  - Higher is better

#### Mission Status
- **NORMAL**: All systems operational
- **WARNING - BATTERY LOW**: Battery below 20%
- **WARNING - HIGH DRAIN**: Excessive power consumption
- **CRITICAL - LOW BATTERY**: Battery below 10%
- **MISSION FAILED**: Battery depleted

### Mathematical Background

**Power Balance:**
```
∫(Solar Power - Consumer Load) dt = Battery Energy Change
```

**Cost Calculation:**
- Solar energy: $0.05/kWh
- Battery energy: $0.50/kWh (accounts for battery wear)
- Fuel cost: $5,000/kg

### Tips
- Keep battery above 50% for emergency reserve
- Disable non-essential subsystems during eclipse
- Monitor cost efficiency - optimize fuel usage
- Use thrusters only when necessary
- Balance power generation with consumption

---

## Emergency Mode

### Triggering Emergency
Click the red "⚠ SPACE DEBRIS EMERGENCY" button to simulate:
- Space debris collision
- Solar flare event
- Sudden orbital perturbation

### Emergency Effects
1. **Massive noise injection** in telemetry
2. **Orbital velocity reduction** (5% loss)
3. **Potential altitude decay**

### Recovery Steps
1. **Adjust filter** in Panel 2
   - Increase filter window size
   - Switch to Butterworth if needed
   
2. **Fire thrusters** in Panel 1
   - Restore lost orbital velocity
   - Monitor altitude recovery
   
3. **Manage power** in Panel 3
   - Disable non-essential subsystems
   - Monitor battery levels

### Tips
- Practice emergency recovery before competition
- Quick filter adjustment is critical
- Balance fuel cost with orbit recovery needs

---

## Data Export

### Export Options
Click "Export Telemetry" button to save mission data:

#### Exported Files
1. **telemetry_TIMESTAMP.csv**: Solar power and signal data
2. **orbital_TIMESTAMP.csv**: Position and velocity data
3. **power_TIMESTAMP.csv**: Battery and power consumption data
4. **finance_TIMESTAMP.csv**: Cost and budget data
5. **session_summary_TIMESTAMP.txt**: Overall mission summary

### Data Format
All CSV files use semicolon (;) delimiter with headers:
- First row: Column names
- Subsequent rows: Data points

### Using Exported Data
- Import into Excel/Google Sheets for analysis
- Use in Scilab/MATLAB for further processing
- Create custom plots and reports
- Document mission performance

---

## Tips for Competition Success

### 1. Demonstrate Interconnected Systems
- Show how altitude affects eclipse duration
- Demonstrate noise impact on power decisions
- Explain the feedback loops between panels

### 2. Use Mathematical Notation
- Reference the differential equations
- Explain filter mathematics
- Show cost-benefit calculations

### 3. Optimize Performance
- Achieve high SNR with appropriate filtering
- Maintain high cost efficiency
- Keep battery health above 90%

### 4. Handle Emergencies Gracefully
- Quick filter adjustment
- Efficient orbit recovery
- Minimal fuel usage

### 5. Document Your Approach
- Explain design decisions
- Highlight innovative features
- Show understanding of underlying physics

### Scoring Criteria
- **Code Structure**: Modular, well-documented code
- **GUI Design**: Professional layout with LaTeX formatting
- **Functionality**: All features working correctly
- **Innovation**: Creative use of Scilab features
- **Mathematical Accuracy**: Correct physics and calculations

---

## Troubleshooting

### Module Loading Errors
**Problem**: "Failed to load modules"
**Solution**: 
- Ensure all files are in correct directories
- Check that you're in the project directory
- Run test_modules.sce to identify specific issues

### GUI Not Displaying
**Problem**: GUI window doesn't appear
**Solution**:
- Check Scilab console for error messages
- Ensure GUI Builder toolbox is installed
- Try restarting Scilab

### Simulation Running Slowly
**Problem**: Laggy or unresponsive simulation
**Solution**:
- Reduce time step in gui_builder.sci
- Close other applications
- Check system resources

### Filter Not Working
**Problem**: Filtered signal looks same as noisy
**Solution**:
- Increase filter parameter (window size or cutoff)
- Check that filter type is correctly selected
- Verify noise level is appropriate

### Battery Draining Too Fast
**Problem**: Battery depletes quickly
**Solution**:
- Disable non-essential subsystems
- Increase solar panel efficiency (higher altitude)
- Reduce consumer load

### Orbit Decaying
**Problem**: Altitude decreasing continuously
**Solution**:
- Fire thrusters to increase velocity
- Raise altitude to reduce atmospheric drag
- Check for emergency mode activation

### Export Not Working
**Problem**: CSV files not created
**Solution**:
- Ensure data/ directory exists
- Check write permissions
- Verify logging is enabled

---

## Advanced Usage

### Custom Scenarios
Modify initial parameters in `gui_builder.sci`:
```scilab
init_orbit(altitude_km, velocity_ms)
init_power_grid(charge, capacity)
init_finance_tracker(budget, fuel)
```

### Adding Custom Filters
Extend `dsp_filter.sci` with new filter functions:
```scilab
function filtered = my_custom_filter(signal, params)
    // Your filter implementation
endfunction
```

### Modifying Physics
Adjust constants in `orbit_mechanics.sci`:
```scilab
G = 6.674e-11;  // Gravitational constant
M_earth = 5.972e24;  // Earth mass
```

---

## Contact & Support

For issues or questions:
- Check the README.md for basic information
- Review test_modules.sce for usage examples
- Examine individual module files for detailed documentation

---

## Version History

- **v1.0** (2026): Initial release for IIT Bombay FOSSEE competition
  - Complete orbital mechanics simulation
  - Digital signal processing filters
  - Power grid management
  - Financial tracking
  - Emergency mode
  - CSV data export
