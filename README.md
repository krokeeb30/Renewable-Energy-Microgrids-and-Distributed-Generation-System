# Renewable Energy Microgrids and Distributed Generation System

A comprehensive blockchain-based system for managing renewable energy microgrids, enabling peer-to-peer energy trading, grid monitoring, and distributed generation coordination using Clarity smart contracts.

## System Overview

This system provides a decentralized platform for renewable energy management that addresses the key challenges of modern distributed energy systems:

- **Energy Production & Consumption Balancing**: Real-time monitoring and balancing of energy supply and demand across the microgrid
- **Grid Interconnection & Power Quality**: Continuous monitoring of power quality metrics and grid stability
- **Transparent Pricing & Energy Trading**: Market-driven pricing mechanisms with transparent energy trading
- **Peer-to-Peer Energy Sharing**: Direct energy transactions between prosumers (producer-consumers)
- **Community Ownership**: Shared ownership models for renewable energy assets
- **Regulatory Compliance**: Built-in compliance tracking and reporting for utility integration

## Architecture

The system consists of five interconnected smart contracts:

### 1. Energy Management Contract (`energy-management.clar`)
- Tracks energy production and consumption for all participants
- Manages energy balancing algorithms
- Handles energy storage coordination
- Maintains real-time energy flow data

### 2. Grid Monitoring Contract (`grid-monitoring.clar`)
- Monitors power quality metrics (voltage, frequency, harmonics)
- Tracks grid stability and interconnection status
- Manages fault detection and isolation
- Provides grid health reporting

### 3. Energy Trading Contract (`energy-trading.clar`)
- Facilitates energy trading between participants
- Implements dynamic pricing mechanisms
- Manages order matching and settlement
- Tracks trading history and market data

### 4. Peer-to-Peer Sharing Contract (`p2p-sharing.clar`)
- Enables direct energy sharing between neighbors
- Manages sharing agreements and contracts
- Handles micro-transactions for energy exchange
- Supports community energy pools

### 5. Regulatory Compliance Contract (`regulatory-compliance.clar`)
- Tracks regulatory requirements and compliance status
- Manages utility integration and reporting
- Handles certification and audit trails
- Ensures grid code compliance

## Key Features

### Energy Participants
- **Producers**: Solar panels, wind turbines, other renewable sources
- **Consumers**: Residential, commercial, and industrial energy users
- **Prosumers**: Participants who both produce and consume energy
- **Storage Systems**: Battery systems, pumped hydro, other storage technologies

### Trading Mechanisms
- **Real-time Spot Trading**: Immediate energy transactions at current market prices
- **Forward Contracts**: Pre-arranged energy delivery agreements
- **Peer-to-Peer Direct Sales**: Direct energy sales between neighbors
- **Community Energy Pools**: Shared energy resources for community members

### Monitoring & Quality Assurance
- **Power Quality Metrics**: Voltage stability, frequency regulation, harmonic distortion
- **Grid Stability Monitoring**: Real-time assessment of grid health and stability
- **Fault Detection**: Automated detection and isolation of grid faults
- **Performance Analytics**: Comprehensive reporting on system performance

## Data Structures

### Energy Participant
```clarity
{
  participant-id: uint,
  participant-type: (string-ascii 20),  ; "producer", "consumer", "prosumer", "storage"
  capacity: uint,                       ; Maximum capacity in kWh
  current-production: uint,             ; Current production in kWh
  current-consumption: uint,            ; Current consumption in kWh
  grid-connected: bool,                 ; Grid connection status
  certified: bool,                      ; Regulatory certification status
  registration-block: uint              ; Block height of registration
}
