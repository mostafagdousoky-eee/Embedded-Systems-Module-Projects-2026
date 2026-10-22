## Embedded Systems Project Report: Arduino Uno UART Interface

## 1. Introduction

This project implements a UART-based communication interface between a personal computer (PC) and an Arduino Uno using Embedded C.

The system consists of two main use cases:

Button Monitoring: The Arduino Uno monitors an input button connected to digital pin D2. When the button is pressed or released, the system transmits the corresponding message (button_pressed or button_released) to the PC through UART.

LED Control: The system receives commands from the PC through UART and controls a digital LED connected to pin D8. The supported commands are led_on and led_off.

The application uses direct register access on the ATmega328P microcontroller and a separate UART driver for serial communication. The UART interface is configured for 9600 baud, 8 data bits, no parity, and 1 stop bit.

The project demonstrates GPIO configuration, UART communication, button state monitoring, command processing, and digital output control.

## 2. Project Code

**GitHub Repository:**
[submission_repo](https://github.com/mostafagdousoky-eee/Embedded-Systems-Module-Projects-2026.git)

**Local Root Directory**
[link_to_local_root_directory](./code/main/)

## 3. Test Cases
[robot_tests](./test/assignment_test_cases.robot)

## 4. Bill of Materials (BOM)

**BOM**
[bom_file](./bom/bom.csv)

**Optimized BOM**
[optimized_bom_file](./bom/optimized_bom.csv)

## 5. Video Demonstration
[recorded_video](./video/sample_video.mp4)


## 6. Design
[design_document](./design/project_design_tpl.md)