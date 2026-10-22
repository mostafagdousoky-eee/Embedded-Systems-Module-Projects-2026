*** Settings ***
Documentation    Embedded Systems Project Test Cases - Arduino Uno UART Interface

*** Test Cases ***

Test Case 1: UART Initialization
    [Documentation]    Verify UART communication at 9600 baud, 8 data bits, no parity, and one stop bit.
    # Arrange
    Connect Arduino Uno to PC through USB.
    Configure the serial terminal to 9600 baud, 8-N-1, with LF line endings.
    Reset the Arduino.

    # Act
    Allow main() to initialize the UART through Uart_Init().
    Send led_on followed by LF.

    # Assert
    Verify that the LED turns ON.
    Verify that LED ON followed by LF is received by the PC.
    Verify that UART transmission and reception operate correctly.
    If register-level debugging is available, verify that TXEN0 and RXEN0 are enabled.


Test Case 2: Button Press Detection
    [Documentation]    Verify that pressing the button generates a button_pressed message.
    # Arrange
    Connect the button between D2 and GND.
    Ensure the button is initially released.

    # Act
    Press the button and keep it pressed.

    # Assert
    Verify that button_pressed followed by LF is transmitted.
    Verify that the message is transmitted once under stable input conditions.
    Record any additional events caused by contact bounce.


Test Case 3: Button Release Detection
    [Documentation]    Verify that releasing the button generates a button_released message.
    # Arrange
    Press the button and verify that button_pressed was transmitted.

    # Act
    Release the button.

    # Assert
    Verify that button_released followed by LF is transmitted.
    Verify that no additional release messages occur without another detected state change.


Test Case 4: Repeated Button Presses
    [Documentation]    Verify button event reporting over repeated press and release cycles.
    # Arrange
    Connect the button and open the serial terminal.

    # Act
    Press and release the button ten times.

    # Assert
    Verify that detected presses generate button_pressed messages.
    Verify that detected releases generate button_released messages.
    Compare the message count with the detected state transitions.
    Record any duplicate or missing events caused by contact bounce or blocking operations.


Test Case 5: LED ON Command
    [Documentation]    Verify that led_on turns the LED ON and returns a confirmation.
    # Arrange
    Connect an LED with a current-limiting resistor to D8, or use an equivalent output indicator.
    Ensure the LED is OFF.
    Configure the serial terminal to 9600 baud, 8-N-1, with LF line endings.

    # Act
    Send led_on followed by LF.

    # Assert
    Verify that PB0 (D8) becomes HIGH.
    Verify that the LED turns ON.
    Verify that LED ON followed by LF is received by the PC.


Test Case 6: LED OFF Command
    [Documentation]    Verify that led_off turns the LED OFF and returns a confirmation.
    # Arrange
    Turn the LED ON using the led_on command.

    # Act
    Send led_off followed by LF.

    # Assert
    Verify that PB0 (D8) becomes LOW.
    Verify that the LED turns OFF.
    Verify that LED OFF followed by LF is received by the PC.


Test Case 7: Repeated LED Commands
    [Documentation]    Verify that repeated LED commands produce the expected output and responses.
    # Arrange
    Reset the Arduino and verify that the LED is initially OFF.

    # Act
    Send led_on several times, terminating each command with LF.
    Send led_off several times, terminating each command with LF.

    # Assert
    Verify that the LED remains ON after each led_on command.
    Verify that the LED remains OFF after each led_off command.
    Verify that each processed command produces its corresponding confirmation.
    Verify that button monitoring continues between command-processing operations.


Test Case 8: Invalid UART Command
    [Documentation]    Verify that unknown commands produce an error response without changing the LED state.
    # Arrange
    Ensure the LED is OFF.

    # Act
    Send invalid_command followed by LF.

    # Assert
    Verify that the LED remains OFF.
    Verify that Unknown command followed by LF is received.
    Verify that the program continues running.
    Verify that a subsequent valid command is processed correctly.


Test Case 9: Empty UART Command
    [Documentation]    Verify that an empty LF-terminated command is rejected without changing the LED state.
    # Arrange
    Turn the LED ON.

    # Act
    Send LF without sending any command characters.

    # Assert
    Verify that the LED remains ON.
    Verify that Unknown command followed by LF is received.
    Verify that the program continues running.
    Verify that the next valid command is accepted.


Test Case 10: Partial UART Command
    [Documentation]    Verify that command execution waits for LF and assess blocking reception.
    # Arrange
    Ensure the LED is OFF.

    # Act
    Send led_on one character at a time without sending LF.
    Observe the LED before sending the terminator.
    Attempt a button state change while the command is incomplete.
    Send LF.

    # Assert
    Verify that the LED remains OFF until the complete command is received.
    Verify that the LED turns ON after LF terminates the valid command.
    Verify that button monitoring resumes after command reception.
    Record whether button transitions during blocking reception are missed.


Test Case 11: Command Termination Using CR and LF
    [Documentation]    Verify the actual LF-only command termination behavior.
    # Arrange
    Reset the Arduino before each independent line-ending test.
    Ensure the LED is OFF.

    # Act
    Send led_on followed by LF and verify the result.
    Reset the Arduino and send led_on followed by CR only.
    Observe the behavior before sending any further characters.
    Send LF to complete the pending command.
    Reset the Arduino and send led_on followed by CRLF.

    # Assert
    Verify that LF alone executes led_on successfully.
    Verify that CR alone does not terminate the command.
    Verify that CRLF causes the command to be rejected because CR remains in the received string.
    Verify that an additional LF is consumed as an empty command and produces Unknown command.
    Verify that the LED state changes only when a valid command is recognized.


Test Case 12: Incorrect Command Spelling
    [Documentation]    Verify that misspelled and uppercase commands are rejected.
    # Arrange
    Ensure the LED is OFF.

    # Act
    Send led_onn followed by LF.
    Send led_of followed by LF.
    Send LED_ON followed by LF.

    # Assert
    Verify that the LED remains OFF.
    Verify that each invalid command produces Unknown command followed by LF.
    Verify that a subsequent valid command works correctly.


Test Case 13: Command Buffer Boundary
    [Documentation]    Verify command storage limits and oversized-command handling.
    # Arrange
    Ensure the LED is OFF.
    Use the 10-byte command buffer, which stores at most nine characters plus the null terminator.

    # Act
    Send an eight-character command followed by LF.
    Send a nine-character command followed by LF.
    Send a command longer than nine characters followed by LF.

    # Assert
    Verify that no more than nine characters are stored.
    Verify that excess characters are discarded until LF.
    Verify that oversized commands are not explicitly reported as buffer errors.
    Verify that a subsequent valid command can be processed after the terminating LF.


Test Case 14: Command Recovery After Invalid Input
    [Documentation]    Verify recovery after invalid and oversized commands.
    # Arrange
    Ensure the LED is OFF.

    # Act
    Send an invalid command followed by LF.
    Send an oversized command followed by LF.
    Send led_on followed by LF.

    # Assert
    Verify that invalid commands produce Unknown command responses.
    Verify that the LED turns ON after the valid command.
    Verify that excess characters from the oversized command do not remain pending after its LF.
    Verify that the program continues operating normally.


Test Case 15: UART Input While Button Is Pressed
    [Documentation]    Verify command processing and button monitoring during normal operation.
    # Arrange
    Ensure the button is released and the LED is OFF.

    # Act
    Press the button.
    Send led_on followed by LF.
    Release the button.

    # Assert
    Verify that the LED turns ON and LED ON is transmitted.
    Verify that button_pressed and button_released are transmitted if both transitions are detected.
    Record any delayed or missing button events.


Test Case 16: Continuous Button Activity During UART Commands
    [Documentation]    Evaluate button monitoring while alternating LED commands.
    # Arrange
    Connect the button and LED.
    Open the serial terminal with LF line endings.

    # Act
    Repeatedly press and release the button while alternating led_on and led_off commands.

    # Assert
    Verify that recognized LED commands produce the expected output and responses.
    Verify that detected button transitions generate the corresponding messages.
    Record delayed or missing events caused by blocking UART operations.


Test Case 17: Rapid UART Command Transmission
    [Documentation]    Evaluate command reception when commands arrive with minimal spacing.
    # Arrange
    Ensure the LED is OFF.
    Prepare a PC script capable of transmitting commands at controlled intervals.

    # Act
    Send led_on and led_off commands repeatedly with LF terminators and progressively shorter intervals.

    # Assert
    Verify that commands are processed under the tested transmission conditions.
    Record lost, merged, delayed, or incorrectly processed commands.
    Record the minimum reliable interval between commands.
    Do not assume that every command is guaranteed to be processed under continuous high-rate input.


Test Case 18: UART Disconnection and Reconnection
    [Documentation]    Verify communication after the serial connection is restored.
    # Arrange
    Connect the Arduino to the PC and verify normal operation.

    # Act
    Close the serial terminal.
    Reopen the terminal and test communication.
    If physically disconnecting USB, reconnect the device and reset it if necessary.

    # Assert
    Verify that communication works when the serial terminal is reopened.
    Verify that button events and LED commands work after any required reset.
    Record whether reconnection causes the board to reset.


Test Case 19: Power-On Default State
    [Documentation]    Verify the LED output state after startup or reset.
    # Arrange
    Ensure the Arduino is powered off.

    # Act
    Power on or reset the Arduino.

    # Assert
    Verify that the program configures PB0 (D8) as an output.
    Verify that Io_Write('B', PB0, 0) sets the output LOW.
    Verify that the LED is OFF after initialization completes.


Test Case 20: Long-Duration Operation
    [Documentation]    Verify continuous operation under normal button and UART activity.
    # Arrange
    Connect the button, LED, and PC serial terminal.

    # Act
    Run the system for at least 30 minutes.
    Periodically send valid LED commands and operate the button.

    # Assert
    Verify that UART communication remains operational.
    Verify that button events continue to be detected.
    Verify that LED commands and confirmation messages work.
    Record any unexpected resets, missed events, or permanent lockups.


Test Case 21: Repeated Reset During Operation
    [Documentation]    Verify that the application returns to its configured state after resets.
    # Arrange
    Connect the Arduino and open the serial terminal.

    # Act
    Send LED commands and operate the button.
    Reset the Arduino several times during operation.

    # Assert
    Verify that the program restarts without becoming unresponsive.
    Verify that the LED is initialized to LOW after each startup.
    Verify that valid UART commands work after each reset.


Test Case 22: Button Held During Reset
    [Documentation]    Verify button event behavior when the button is held during startup.
    # Arrange
    Hold the button down.

    # Act
    Reset the Arduino while continuing to hold the button.
    Release the button after initialization.

    # Assert
    Verify that the initial pressed state becomes the baseline and does not generate a press event.
    Verify that button_released followed by LF is transmitted when the button is released.
    Verify that subsequent presses and releases are detected normally.


Test Case 23: Unsupported Command Case and Whitespace
    [Documentation]    Verify that commands with leading spaces, trailing spaces, or different letter cases are rejected.
    # Arrange
    Ensure the LED is OFF.

    # Act
    Send " led_on" followed by LF.
    Send "led_on " followed by LF.
    Send "Led_on" followed by LF.

    # Assert
    Verify that each unsupported command produces Unknown command followed by LF.
    Verify that the LED remains OFF.
    Verify that the exact valid command led_on works afterward.
