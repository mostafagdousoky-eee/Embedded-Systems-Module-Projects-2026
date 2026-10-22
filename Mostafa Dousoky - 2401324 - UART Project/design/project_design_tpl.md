# Detailed Design Document

| **Author**  | Mostafa G Dousoky          |
|:------------|:---------------------------|
| **Status**  | Final Submission           |
| **Version** | 1.0                        |
| **Date**    | 19/10/2026                 |
| **Project** | Arduino Uno UART Interface |

## 1. Introduction

This document describes an Embedded C application developed for the Arduino Uno using direct register access to the ATmega328P microcontroller.

The application monitors a push button connected to D2 and transmits state-change messages to a PC through UART. It also receives commands to control an LED connected to D8 and sends responses confirming recognized commands or reporting unknown commands.

The software consists of three modules: the application (`main.c`), the I/O module (`Io.c` and `Io.h`), and the UART driver (`Uart.c` and `Uart.h`).

### 1.1 Purpose and Scope

The application supports the following functions:

- Initialize UART communication at 9600 baud.
- Configure D2 as an input with an internal pull-up.
- Configure D8 as an LED output.
- Transmit `button_pressed` and `button_released` when the button state changes.
- Receive `led_on` and `led_off` commands.
- Control the LED and transmit confirmation messages.
- Report unsupported commands without changing the LED state.

The application uses polling, blocking UART operations, and direct register access without the Arduino software framework or UART interrupts.

## 2. Architectural Overview

The system consists of a PC serial terminal, the application module, the I/O module, the UART driver, and the ATmega328P hardware peripherals.

The application coordinates button monitoring and command processing. The I/O module provides GPIO functions, while the UART driver handles serial communication and string operations.

### 2.1 System Architecture Diagram

@startuml

title Arduino Uno UART Interface Architecture

rectangle "PC Serial Terminal" as PC

rectangle "Arduino Uno - ATmega328P" {
    rectangle "Application Module\nmain.c" as APP

    rectangle "I/O Module" as IO {
        rectangle "Io.c\nGPIO Operations" as IOC
        rectangle "Io.h\nDeclarations" as IOH
    }

    rectangle "UART Driver" as UART {
        rectangle "Uart.c\nCommunication" as UC
        rectangle "Uart.h\nDeclarations" as UH
    }

    rectangle "Hardware Registers\nGPIO and USART" as REG
}

PC <--> UC : UART communication
APP --> IOH : GPIO function calls
APP --> UH : UART function calls
IOC --> REG : GPIO access
UC --> REG : USART access

@enduml


### 2.2 Hardware Configuration

| Component   | Arduino Pin | ATmega328P Pin | Configuration       |
|:------------|:------------|:---------------|:--------------------|
| Push button | D2          | PD2            | Input with pull-up  |
| LED         | D8          | PB0            | Digital output      |
| UART RX     | D0          | PD0/RXD        | Serial reception    |
| UART TX     | D1          | PD1/TXD        | Serial transmission |

The button connects PD2 to GND when pressed. The internal pull-up keeps the pin HIGH when released. The I/O function `Io_Read()` inverts the physical input level, returning `1` for LOW (pressed) and `0` for HIGH (released).

The LED connects to PB0 and requires a suitable current-limiting resistor. UART communication uses the Arduino Uno's USB-to-serial interface.

### 2.3 Assumptions and Constraints

- CPU clock: 16 MHz.
- UART: 9600 baud, 8 data bits, no parity, one stop bit (8N1).
- Commands are case-sensitive and terminated by LF (`\n`).
- The command buffer has a fixed capacity of 10 bytes.
- Button debouncing and interrupt-driven processing are not implemented.

## 3. Functional Description

### 3.1 Initialization and Button Monitoring

The application initializes GPIO directly in `main()`:

1. Configure PD2 as an input and enable its internal pull-up.
2. Configure PB0 as an output and initialize the LED to LOW.
3. Initialize UART using `Uart_Init()`.
4. Read the initial button state to establish a baseline.

The main loop continuously reads the button using `Io_Read('D', PD2)` and compares its current state with the previous state.

| Logical state | Physical level | Transmitted message |
|:--------------|:---------------|:--------------------|
| `1`           | LOW            | `button_pressed\n`  |
| `0`           | HIGH           | `button_released\n` |

When the state changes, the corresponding message is transmitted and the previous state is updated. Messages end with LF rather than CRLF.

Mechanical contact bounce may generate multiple events because no software debounce mechanism is implemented.

### 3.2 UART Command Processing and LED Control

The application checks for received data using `Uart_IsDataAvailable()` and calls `Uart_ReceiveString()` to receive a command terminated by LF. It compares the received command using `Uart_CompareString()`.

| Command         | Action              | Response            |
|:----------------|:--------------------|:--------------------|
| `led_on`        | Set PB0 HIGH        | `LED ON\n`          |
| `led_off`       | Set PB0 LOW         | `LED OFF\n`         |
| Unknown command | Leave LED unchanged | `Unknown command\n` |

The command buffer is declared as `char command[10]`, allowing up to nine stored characters plus the null terminator. Characters exceeding this capacity are discarded until LF is received.

The receiver does not remove carriage returns. Therefore, CRLF-terminated commands will not match the supported strings. The PC terminal should be configured to send LF only.

### 3.3 I/O Module

The I/O module provides generic GPIO operations using the ATmega328P registers.

| Function                     | Responsibility                                             |
|:-----------------------------|:-----------------------------------------------------------|
| `Io_Mode(port, pin, mode)`   | Configure a pin as input (`0`) or output (`1`).            |
| `Io_Read(port, pin)`         | Return the physical pin level.                    |
| `Io_Write(port, pin, value)` | Set an output HIGH/LOW or enable/disable an input pull-up. |

The module supports ports B, C, and D. It manipulates `DDR` registers to configure pin direction, `PIN` registers to read input levels, and `PORT` registers to control outputs or internal pull-ups.

For example, `Io_Write('B', PB0, 1)` turns the LED on, while `Io_Write('B', PB0, 0)` turns it off.

`Io_Read()` returns `0` for unsupported ports. The current implementation does not report invalid pins or ports in the write and mode functions.

### 3.4 UART Driver

The UART driver provides the following functions:

| Function                 | Responsibility                                            |
|:-------------------------|:----------------------------------------------------------|
| `Uart_Init()`            | Initialize UART transmission and reception.               |
| `Uart_SetBaudRate()`     | Calculate and configure the baud rate registers.          |
| `Uart_SendChar()`        | Transmit one character.                                   |
| `Uart_ReadData()`        | Wait for and return a received character.                 |
| `Uart_SendString()`      | Transmit a null-terminated string.                        |
| `Uart_CompareString()`   | Compare two null-terminated strings.                      |
| `Check_Data_Avail()`     | Check the receive-complete flag.                          |
| `Uart_ReceiveString()`   | Receive characters until LF and append a null terminator. |

`Uart_Init()` sets the baud rate to 9600 and enables transmission and reception through `TXEN0` and `RXEN0`. It configures eight data bits, no parity, and one stop bit.

The baud rate register is calculated as:

`UBRR = (F_CPU / (16 × BaudRate)) - 1`

For a 16 MHz clock and 9600 baud, the register value is 103.

`Uart_SendChar()` waits for `UDRE0` before writing to `UDR0`. `Uart_ReadData()` waits for `RXC0` before returning the received character. Both operations use polling and blocking waits.

`Uart_SendString()` transmits characters until the null terminator. Although it accepts a `Size` parameter, that parameter is ignored. `Uart_CompareString()` performs an exact, case-sensitive comparison and returns `1` for a match or `0` otherwise.

## 4. Implementation

### 4.1 Main Loop

After initialization, the application repeats the following sequence:

1. Read the current button state.
2. Detect and report any state change.
3. Update the previous button state.
4. Check for received UART data.
5. Receive a complete command terminated by LF.
6. Execute the matching LED operation and send a response, or report an unknown command.

The application processes button monitoring and UART commands sequentially. Blocking reception and transmission may delay button monitoring, and intermediate button transitions may be missed during lengthy operations.

### 4.2 GPIO and Message Handling

The I/O module uses bitwise register operations to set and clear individual GPIO bits. The application accesses these operations through `Io_Mode()`, `Io_Read()`, and `Io_Write()` rather than manipulating registers directly.

The UART driver transmits the five application message types with explicit LF terminators:

- `button_pressed\n`
- `button_released\n`
- `LED ON\n`
- `LED OFF\n`
- `Unknown command\n`

The receive function stores no more than `Size - 1` characters and appends a null terminator. Oversized commands are silently truncated while remaining characters are discarded until LF arrives.

## 5. Integration and Configuration

### 5.1 Project Files

| File     | Responsibility                                                             |
|:---------|:---------------------------------------------------------------------------|
| `main.c` | GPIO initialization, button monitoring, command processing, and responses. |
| `Io.c`   | GPIO direction, input reading, and output/pull-up control.                 |
| `Io.h`   | I/O function declarations and header guard.                                |
| `Uart.c` | UART configuration, character and string communication, and comparison.    |
| `Uart.h` | UART function declarations and header guard.                               |

The three source files are compiled and linked into the firmware. The header files provide the declarations needed for communication between modules. The build environment must target the ATmega328P and use the correct 16 MHz clock definition.

### 5.2 Configuration Parameters

| Parameter                     | Value              |
|:------------------------------|:-------------------|
| `F_CPU`                       | `16000000UL`       |
| Baud rate                     | 9600               |
| UART frame                    | 8N1                |
| Baud rate register            | 103                |
| Button                        | PD2 / D2           |
| Button configuration          | Input with pull-up |
| LED                           | PB0 / D8           |
| Initial LED state             | LOW                |
| Command buffer                | 10 bytes           |
| Maximum stored command length | 9 characters       |
| Command terminator            | LF (`\n`)          |
| Communication method          | Polling            |

The PC terminal must use 9600 baud, 8N1, and LF line endings.

### 5.3 Error Handling and Limitations

The current implementation has the following limitations:

- No software debounce filtering.
- Blocking UART operations can delay button monitoring.
- CRLF commands are rejected because carriage returns are not removed.
- No command acknowledgment for button events.
- Oversized commands are not explicitly reported.
- No reception timeout for incomplete commands.
- UART framing, parity, and receive-buffer overrun errors are not explicitly handled.
- Command matching is case-sensitive.
- `Uart_SendString()` ignores its `Size` parameter.
- Invalid GPIO arguments are not consistently reported.

These limitations reflect the supplied implementation and are not features that have already been addressed.

## 6. Conclusion

The Arduino Uno UART Interface demonstrates bidirectional serial communication using Embedded C and direct register access to the ATmega328P.

The application monitors a button on D2, transmits state-change messages, receives LED control commands, controls an LED on D8, and returns command responses to the PC.

Its five-file structure separates application logic, GPIO operations, and UART communication into distinct modules. Although the implementation demonstrates modular embedded programming and register-level peripheral control, improvements to debounce filtering, command parsing, buffer error reporting, and UART error handling would improve reliability and robustness.