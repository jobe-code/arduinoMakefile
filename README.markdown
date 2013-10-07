arduinoMakefile
===============

This project is just a simple Makefile for Arduino. There are some Makefiles in
the Web but all of them are complicated and some does not work properly for
newer versions of Arduino. This Makefile is simple and just works!

It does:

- Compiles your sketch, including the standard Arduino library required
- Merge all files into a .elf and them translate it to a .hex file
- Upload the .hex to Arduino's flash memory


**WARNING[0]:** it was tested only in Fedora with Arduino Duemilanove. Probably
  it'll work well in any GNU/Linux distribution or Mac OS with Arduino
  Duemilanove. Windows users: sorry, please use a better OS.

**WARNING[1]:** by now the feature of compiling external libraries (even
  standard libraries and third-party libraries) is not implemented. So, if you
  have some `#include` in your project, probably it won't work


Why another Makefile?
---------------------

Quote from original author, Álvaro Justen:

> The question was answered in the section above -- but I'm studying all the
> Makefiles for Arduino that I found in the Web and trying to implement the
> simplest way of doing it right. I've created a [**comprehensive list of
> Makefiles**](https://github.com/turicas/arduinoMakefile/blob/master/resources.markdown)
> and I'm categorizing them.


Dependencies
------------

You need to have installed:

- Arduino IDE unpacked -- we just use the libraries' source code
- `gcc-avr`, `avr-libc` and `binutils-avr` -- for compilation
- `avrdude` -- for upload
- `make` -- to interpret the Makefile


If you run Fedora, just execute this recipe:

   sudo yum install arduino


Usage
-----

The head of Makefile is self-explanatory, please read the comments and change these variables:


    # Sketch filename without .pde (should be in the same directory of Makefile)
    SKETCH_NAME=Blink
    # The port Arduino is connected
    #  Uno, in GNU/linux: generally /dev/ttyACM0
    #  Duemilanove, in GNU/linux: generally /dev/ttyUSB0
    PORT=/dev/ttyACM0
    # The path of Arduino IDE
    ARDUINO_DIR=/usr/share/arduino
    # Boardy type: use "arduino" for Uno or "skt500v1" for Duemilanove
    BOARD_TYPE=arduino
    # Baud-rate: use "115200" for Uno or "57600" for Duemilanove
    BAUD_RATE=115200
