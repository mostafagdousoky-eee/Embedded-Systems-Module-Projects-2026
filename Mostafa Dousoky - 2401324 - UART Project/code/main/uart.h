#ifndef __UART__                                      // Check if __UART__ has not been defined yet
#define __UART__                                      // Define __UART__ to prevent multiple inclusions

void Uart_Init(void);                                // Declare the function that initializes UART

void Uart_SetBaudRate(unsigned short BuadRate);       // Declare the function that sets the UART baud rate

void Uart_SendChar(unsigned char DataByte);           // Declare the function that transmits one character

unsigned char Check_Data_Avail(void);             // Declare the function that checks if received data is available

unsigned char Uart_ReadData();                        // Declare the function that reads one received character

void Uart_SendString(char DataString[], unsigned char Size); // Declare the function that transmits a string

void Uart_ReceiveString(char DataString[], unsigned char Size); // Receive a string until Enter

unsigned char Uart_CompareString(char S1[], char S2[]); // Compare two strings and return 1 if they match

#endif                                               // End of the header guard