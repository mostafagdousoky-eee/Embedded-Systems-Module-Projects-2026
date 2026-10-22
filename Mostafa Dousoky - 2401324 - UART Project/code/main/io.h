#ifndef IO_H
#define IO_H

void Io_Mode(unsigned char port, unsigned char pin, unsigned char mode);  // Set the pin mode

unsigned char Io_Read(unsigned char port, unsigned char pin);             // Read the pin value

void Io_Write(unsigned char port, unsigned char pin, unsigned char value); // Write the pin value

#endif