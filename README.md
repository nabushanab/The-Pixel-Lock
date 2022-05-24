# Abstract
This is the source code for my final project for a class called embedded systems. The source code is written in AVR assembly and works with an Arduino Uno and additional hardware.


# Introduction
The Pixel Lock system is a general lock. In order to unlock this system, you have to
match a 5x5 pixel picture (made from LEDs) with the predetermined key. The system compares
the picture input with the key and will unlock it if they match. The display utilizes three colors
and makes sure the colors match the key as well. The system works with the microcontroller as
the brain of the circuit. The microcontroller sends data to the LED display through three separate
serial buses. The current LED format is saved and changed within the microcontroller’s registers.
The pixel key is saved within the code of the microcontroller. When the registers containing the
current LED format are equal to the key you can unlock the lock, where the microcontroller
powers the solenoid.

# Parts List
● Solenoid Lock Device (6V, 1.5A)
● 25 RGB LEDs (common anode)
● 10 74HC595 Shift Register
● N4001 Rectifier Diode
● TIP 120 Bipolar Transistor
● External Power Supply (6V, 2A)

