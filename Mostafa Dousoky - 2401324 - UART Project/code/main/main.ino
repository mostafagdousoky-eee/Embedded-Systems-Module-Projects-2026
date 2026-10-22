
#define F_CPU 16000000UL                       // Set CPU frequency to 16 MHz

#include "Uart.h"                              // Include UART communication functions
#include "Io.h"                                // Include input/output control functions


int main(void)                                 // Main function where program execution begins
{
    unsigned char prevButton;                  // Store the previous state of the button
    unsigned char currentButton;               // Store the current state of the button

    char request[10];                          // Store the command received from the PC

    Io_Mode('D', PD2, 0);                      // Configure PD2 (D2) as an input
    Io_Write('D', PD2, 1);                     // Enable the internal pull-up resistor for the button

    Io_Mode('B', PB0, 1);                      // Configure PB0 (D8) as an output
    Io_Write('B', PB0, 0);                     // Turn the LED OFF initially

    Uart_Init();                               // Initialize UART communication

    // Read the initial button state to establish a baseline
    prevButton = !(Io_Read('D', PD2));            // Store the initial state of the button

    while (1)                                  // Repeat continuously
    {
        currentButton = !(Io_Read('D', PD2));     // Read the current state of the button

        if (currentButton != prevButton)       // Check if the button state has changed
        {
            if (currentButton)                 // Check if the button is pressed
            {
                Uart_SendString("button_pressed\n", 15); // Send the pressed message
            }
            else                               // The button has been released
            {
                Uart_SendString("button_released\n", 16); // Send the released message
            }

            prevButton = currentButton;        // Save the new state of the button
        }

        if (Check_Data_Avail())             // Check if data has been received from the PC
        {
            Uart_ReceiveString(request, sizeof(request)); // Receive the command from the PC

            if (Uart_CompareString(request, "led_on")) // Check if the command is to turn the LED ON
            {
                Io_Write('B', PB0, 1);         // Turn the LED ON
                Uart_SendString("LED ON\n", 7); // Send confirmation that the LED is ON
            }
            else if (Uart_CompareString(request, "led_off")) // Check if the command is to turn the LED OFF
            {
                Io_Write('B', PB0, 0);         // Turn the LED OFF
                Uart_SendString("LED OFF\n", 8); // Send confirmation that the LED is OFF
            }
            else                               // The received command is not recognized
            {
                Uart_SendString("Unknown command\n", 16); // Send an error message to the PC
            }
        }
    }

    return 0;                                  // End the program (normally unreachable)
}