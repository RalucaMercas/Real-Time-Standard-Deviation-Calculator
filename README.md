# 📊 Real-Time Standard Deviation Calculator

## 📌 Overview
This project implements a **hardware circuit** on an **FPGA board** using the **AXI Stream protocol** to process real-time sensor data from a **microcontroller**. The system calculates the **standard deviation** of incoming data.

## 🕹️ Features
- 🔹 **Real-Time Standard Deviation Calculation** – Computes standard deviation on-the-fly for incoming sensor data.
- 🔹 **Sensor Data Processing** – Reads real-world temperature and humidity data, from a **DHT11 sensor** using an Arduino.
- 🔹 **AXI Stream Protocol** – FPGA processes the sensor data in a **streaming pipeline** using dedicated hardware modules. AXI Stream ensures efficient and low-latency communication between modules.
- 🔹 **Data Output & Visualization** – Computed values are **sent back to the PC** and plotted using Python.


