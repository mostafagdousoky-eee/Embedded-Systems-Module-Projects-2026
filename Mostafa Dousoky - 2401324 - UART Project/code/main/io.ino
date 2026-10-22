#include <avr/io.h>                           // Access AVR microcontroller registers
#include "Io.h"                               // Include input/output function declarations


void Io_Mode(unsigned char port, unsigned char pin, unsigned char mode)  // Configure the pin as input or output
{
    if (port == 'B')                          // Check if the selected port is B
    {
        if (mode == 1)                         // Configure the pin as output
            DDRB = DDRB | (1 << pin);          // Set the corresponding DDRB bit to 1
        else                                   // Otherwise, configure the pin as input
            DDRB = DDRB & ~(1 << pin);         // Set the corresponding DDRB bit to 0
    }
    else if (port == 'C')                     // Check if the selected port is C
    {
        if (mode == 1)                         // Configure the pin as output
            DDRC = DDRC | (1 << pin);          // Set the corresponding DDRC bit to 1
        else                                   // Otherwise, configure the pin as input
            DDRC = DDRC & ~(1 << pin);         // Set the corresponding DDRC bit to 0
    }
    else if (port == 'D')                     // Check if the selected port is D
    {
        if (mode == 1)                         // Configure the pin as output
            DDRD = DDRD | (1 << pin);          // Set the corresponding DDRD bit to 1
        else                                   // Otherwise, configure the pin as input
            DDRD = DDRD & ~(1 << pin);         // Set the corresponding DDRD bit to 0
    }
}


unsigned char Io_Read(unsigned char port, unsigned char pin)  // Read the current state of a pin
{
    if (port == 'B')                          // Check if the selected port is B
        return (PINB & (1 << pin));          // Return 0 if the pin is LOW, otherwise return 1

    else if (port == 'C')                     // Check if the selected port is C
        return (PINC & (1 << pin));          // Return 0 if the pin is LOW, otherwise return 1

    else if (port == 'D')                     // Check if the selected port is D
        return (PIND & (1 << pin));          // Return 0 if the pin is LOW, otherwise return 1

    return 0;                                 // Return 0 if the selected port is invalid
}


void Io_Write(unsigned char port, unsigned char pin, unsigned char value)  // Set the output pin value
{
    if (port == 'B')                          // Check if the selected port is B
    {
        if (value == 1)                       // Check if the value should be HIGH
            PORTB = PORTB | (1 << pin);       // Set the corresponding PORTB bit to 1
        else                                   // Otherwise, set the pin LOW
            PORTB = PORTB & ~(1 << pin);      // Set the corresponding PORTB bit to 0
    }
    else if (port == 'C')                     // Check if the selected port is C
    {
        if (value == 1)                       // Check if the value should be HIGH
            PORTC = PORTC | (1 << pin);       // Set the corresponding PORTC bit to 1
        else                                   // Otherwise, set the pin LOW
            PORTC = PORTC & ~(1 << pin);      // Set the corresponding PORTC bit to 0
    }
    else if (port == 'D')                     // Check if the selected port is D
    {
        if (value == 1)                       // Check if the value should be HIGH
            PORTD = PORTD | (1 << pin);       // Set the corresponding PORTD bit to 1
        else                                   // Otherwise, set the pin LOW
            PORTD = PORTD & ~(1 << pin);      // Set the corresponding PORTD bit to 0
    }
}
