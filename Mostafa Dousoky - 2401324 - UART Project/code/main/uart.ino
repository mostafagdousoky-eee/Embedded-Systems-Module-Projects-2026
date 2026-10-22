
#if !defined(__AVR_ATmega328P__)                // Check if the ATmega328P microcontroller is not defined
#include <avr/iom328p.h>                        // Include the ATmega328P register definitions
#endif                                          // End of the conditional compilation block

#include "Uart.h"                               // Include UART function declarations


void Uart_Init(void) {                          // Initialize UART communication

    Uart_SetBaudRate(9600);                     // Set the communication speed to 9600 baud

    UCSR0B = (1 << TXEN0) | (1 << RXEN0);       // Enable UART transmission and reception

    UCSR0C = (1 << UCSZ01) | (1 << UCSZ00);     // Configure UART for 8 data bits and 1 stop bit
}                                               // End of UART initialization


void Uart_SetBaudRate(unsigned short BuadRate)  // Set the UART communication speed
{
    unsigned short UBBR = ((F_CPU / 16) / BuadRate) - 1; // Calculate the baud rate register value

    UBRR0L = (UBBR & 0xFF);                     // Store the lower 8 bits of the calculated value
    UBRR0H = ((UBBR >> 8) & 0xFF);             // Store the upper bits in the baud rate register
}                                               // End of baud rate configuration


void Uart_SendChar(unsigned char DataByte)      // Send one character through UART
{
    while (!(UCSR0A & (1 << UDRE0)));           // Wait until the UART transmit buffer is empty

    UDR0 = DataByte;                            // Write the character to the UART data register
}                                               // End of character transmission


unsigned char Uart_ReadData(void) {             // Receive one character through UART

    while (!(UCSR0A & (1 << RXC0)));            // Wait until a character has been received

    return UDR0;                                // Return the received character
}                                               // End of character reception


void Uart_SendString(char DataString[], unsigned char Size) // Send a string through UART
{
    int i;                                      // Declare a variable to track the character position

    for (i = 0; DataString[i]; i++)             // Loop through the string until the null terminator
    {
        Uart_SendChar(DataString[i]);           // Send the current character
    }
}                                               // End of string transmission


unsigned char Uart_CompareString(char S1[], char S2[])
{
    int i = 0;                                        // Start at the first character

    while (S1[i] != '\0' || S2[i] != '\0') // Continue until both strings end
    {
        if (S1[i] != S2[i])                 // Check if the characters are different
        {
            return 0;                                 // Return 0 if the strings do not match
        }

        i++;                                          // Move to the next character
    }

    return 1;                                         // Return 1 if the strings match
}


unsigned char Check_Data_Avail(void)              // Check if UART data has arrived
{
    return (UCSR0A & (1 << RXC0)) != 0;              // Return 1 if data is available, otherwise 0
}


void Uart_ReceiveString(char DataString[], unsigned char Size) // Receive a string through UART
{
    unsigned char i = 0;                      // Initialize the index of the received string
    unsigned char DataByte;                   // Store the received character

    while (1)                                 // Repeat until the end of the string is received
    {
        DataByte = Uart_ReadData();            // Read a character from UART

        if (DataByte == '\n')                 // Check if the end of the string has been received
            break;                            // Exit the loop

        if (i < Size - 1)                     // Check if there is space for the character and null terminator
        {
            DataString[i] = DataByte;         // Store the received character in the string
            i++;                              // Move to the next position in the string
        }
    }

    DataString[i] = '\0';                     // Add the null terminator to mark the end of the string
}
