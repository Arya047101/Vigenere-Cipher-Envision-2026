# Vigenere-Cipher-Envision-2026
This project explores the hardware-level implementation of the Vigenère Cipher, a polyalphabetic substitution algorithm, using Verilog. This project focuses on modeling and verifying the algorithm at the Register Transfer Level (RTL) using Verilog. The system performs encryption and decryption using a repeating keyword and modulo-26 arithmetic. A Finite State Machine (FSM) is designed to control data flow, and comprehensive testbenches are developed to validate correctness through simulation. The final objective is to demonstrate a fully functional and verified cryptographic core through RTL simulation. 

## Literature Survey and Technologies Used:

HDL: Verilog

FSM: Finite State Machine

Modulo 26-Arithmetic units
Methodology:

The hardware implementation of the Vigenère Cipher is divided into the basic mathematical math used and the specific Verilog modules that make up the system.

Core Mathematical Logic

    Character Mapping: Every letter from A to Z is converted into a number from 0 to 25 (A=0, B=1, ..., Z=25). Since 25 is the highest number, a 5-bit wire width is used to carry the data without losing bits.
    Encryption: The 5-bit plaintext number is added to the 5-bit key number. A modulo-26 operation is applied to keep the final result within the 0–25 alphabet range:
    {EncryptedText} = ({PlainText} + {Key}) mod 26
    Decryption: The key value is subtracted from the encrypted text value. To prevent errors or negative numbers in hardware, 26 is added before taking the modulo:
    {DecryptedText} = ({EncryptedText} - {Key}) mod 26
    

## Vigenère Cipher
<img width="938" height="938" alt="image" src="https://github.com/user-attachments/assets/dea57a28-3014-4407-8a73-fb442bf00595" />


## Hardware Module Description

The system is split into four distinct blocks connected under a single top-level module:

**A. Vigenère Core (vigenere_core)**

This block takes one plaintext character, one key character, and a mode selection signal. To avoid underflow errors during subtraction, it temporarily extends the characters to 6 bits. It then gives the output as either the encrypted or decrypted character based on the chosen mode.

**B. Input Controller (input_controller)**

This block takes user inputs from physical hardware switches and stores them. When the store pulse signal is high, it checks the input_mode_switch to save the incoming character as either plaintext or key data while incrementing the respective string length tracker.

**C. Cipher Engine (cipher_engine)**

This is the main control unit that handles the sequencing loop. When the start signal is pulsed, it runs character-by-character through the stored text flat array. If the plaintext is longer than the key, it cycles the key index back to 0 so the keyword repeats over and over until processing is finished and the done flag goes high.

**D. Output Controller (output_controller)**

This block manages how the final result is read out. When the cipher finishes (done == 1), the first encrypted/decrypted character is immediately displayed. Each subsequent press of the next button advances the index and displays the next character from the flat result array. Once the index reaches text_len (i.e. past the last character), the sentinel 5'b11111 is output to signal end-of-string, and then it is warped back.
