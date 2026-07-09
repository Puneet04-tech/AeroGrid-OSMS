# AeroGrid-OSMS (Orbital Space Station Mission Control & Energy Grid Simulator)

## 🚀 Project Overview

A comprehensive multi-variable simulation system for IIT Bombay FOSSEE competition that integrates orbital mechanics, digital signal processing, and power grid management with financial optimization.

### Core Interconnected Feedback Loop

1. **Orbit affects Solar Power**: Orbital altitude changes eclipse duration and solar energy generation
2. **Noise affects Grid Decisions**: Cosmic radiation creates telemetry static that impacts power management decisions

### Advanced Features

- **Space Debris Emergency Mode**: Anomaly injector for collision/solar flare simulation
- **Financial Cost per Burn Optimization**: Tracks propellant consumption and mission efficiency
- **CSV Data Logging**: Exports telemetry data for analysis

## 🛠️ Tech Stack

- **GUI Layer**: `uicontrol` API + GUI Builder (Scilab Toolbox)
- **Mathematical Core**: `ode()` for orbital differential equations
- **Signal Processing**: `ffilt()` and `iir()` for digital filters
- **Data Layer**: `csvRead` and `csvWrite` for data management

## 📁 Project Structure

```
AeroGrid-OSMS/
├── main.sce                          # Main execution file
├── test_modules.sce                  # Module validation test script
├── modules/
│   ├── orbit_mechanics.sci          # Orbital mechanics calculations
│   ├── dsp_filter.sci               # Digital signal processing filters
│   ├── power_grid.sci               # Power grid management
│   ├── finance_tracker.sci          # Financial tracking system
│   └── data_logger.sci              # CSV data logging
├── gui/
│   ├── gui_builder.sci              # GUI layout management
│   ├── panel_flight_dynamics.sci    # Panel 1: Flight Dynamics
│   ├── panel_telemetry.sci          # Panel 2: Telemetry DSP
│   └── panel_power_grid.sci         # Panel 3: Power Grid & Finance
├── data/
│   └── baseline_solar.csv           # Baseline solar radiation data
├── README.md
├── USER_GUIDE.md                     # Comprehensive user documentation
└── LICENSE
```

## 🚀 Installation

### Prerequisites
- Scilab 6.0 or higher
- GUI Builder Toolbox: `atomsInstall('guibuilder')`

### Setup Instructions

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd AeroGrid-OSMS
   ```

2. Install required Scilab toolboxes:
   ```scilab
   atomsInstall('guibuilder')
   atomsInstall('signal')
   ```

3. Run the application:
   ```scilab
   exec('main.sce', -1)
   ```

4. (Optional) Test modules:
   ```scilab
   exec('test_modules.sce', -1)
   ```

5. For detailed usage instructions, see [USER_GUIDE.md](USER_GUIDE.md)

## 📖 Usage Guide

### Panel 1: Flight Dynamics Simulator
- Adjust orbital altitude using the slider
- Fire thrusters to maintain orbit
- Monitor orbital decay and critical attrition warnings

### Panel 2: Deep-Space Telemetry DSP Filter
- Toggle between Moving Average and Butterworth filters
- Adjust filter parameters using sliders
- Compare noisy input vs filtered output signals

### Panel 3: Power Grid & Financial Calculator
- Enable/disable station subsystems
- Monitor energy costs and fuel reserves
- Track mission financial efficiency

### Emergency Mode
- Click "Space Debris Emergency" to simulate anomalies
- Adjust filters and fire thrusters to recover

### Data Export
- Click "Export Telemetry" to save session data as CSV

## 🎯 Key Features for Competition

1. **Modular Code Structure**: Separate .sci files for each component
2. **LaTeX Integration**: Mathematical equations displayed in GUI
3. **Real-time Simulation**: Dynamic orbital calculations using ODE solver
4. **Signal Processing**: Digital filters for noise reduction
5. **Financial Optimization**: Cost tracking for mission management
6. **Data Export**: CSV logging for analysis

## 📝 Mathematical Models

### Orbital Mechanics
```
d²r/dt² = -GM/r² * r̂
```

### Signal Processing
- Moving Average Filter
- Butterworth Low-pass Filter

### Power Management
```
∫(Solar Power - Consumer Load) dt
```

## 🏆 Competition Criteria Addressed

- **Code Readability**: Modular structure with clear documentation
- **Innovation**: Multi-variable simulation with interconnected feedback loops
- **GUI Design**: Professional layout with LaTeX formatting
- **Functionality**: Complete simulation of orbital, power, and financial systems

## 👥 Authors

Developed for IIT Bombay FOSSEE Competition

## 📄 License

This project is open source and available for educational purposes.

## 🙏 Acknowledgments

- IIT Bombay FOSSEE
- Scilab Development Team
- GUI Builder Toolbox Contributors
