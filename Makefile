###############################################################################
#                     Makefile for Arduino Duemilanove/Uno                    #
# Copyright (C) 2011 Álvaro Justen <alvaro@justen.eng.br>                     #
# Copyright (C) 2013 Stéphane Raimbault <stephane.raimbault@gmail.com>        #
#                                                                             #
# This project is hosted at GitHub: http://github.com/turicas/arduinoMakefile #
#                                                                             #
# This program is free software; you can redistribute it and/or               #
#  modify it under the terms of the GNU General Public License                #
#  as published by the Free Software Foundation; either version 2             #
#  of the License, or (at your option) any later version.                     #
#                                                                             #
# This program is distributed in the hope that it will be useful,             #
#  but WITHOUT ANY WARRANTY; without even the implied warranty of             #
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              #
#  GNU General Public License for more details.                               #
#                                                                             #
# You should have received a copy of the GNU General Public License           #
#  along with this program; if not, please read the license at:               #
#  http://www.gnu.org/licenses/gpl-2.0.html                                   #
###############################################################################

#Sketch, board and IDE path configuration (in general change only this section)
# Sketch filename (should be in the same directory of Makefile)
SKETCH_NAME=Blink.ino
# The port Arduino is connected
#  Uno, in GNU/linux: generally /dev/ttyACM0
#  Duemilanove, in GNU/linux: generally /dev/ttyUSB0
PORT=/dev/ttyUSB0
# The path of Arduino IDE
ARDUINO_DIR=/usr/share/arduino
# hardware/arduino
# Boardy type: use "arduino" for Uno or "stk500v1" for Duemilanove
BOARD_TYPE=arduino
# Baud-rate: use "115200" for Uno or "57600" for Duemilanove
BAUD_RATE=57600

#Compiler and uploader configuration
MCU=atmega328p
DF_CPU=16000000L
ARDUINO_CORES=$(ARDUINO_DIR)/hardware/arduino/cores/arduino
ARDUINO_VARIANTS=$(ARDUINO_DIR)/hardware/arduino/variants/standard
ARDUINO_VERSION=101
INCLUDES=-I. -I$(ARDUINO_CORES) -I$(ARDUINO_VARIANTS)
TMP_DIR=/tmp/build_arduino

CC=/usr/bin/avr-gcc
CPP=/usr/bin/avr-g++
AVR_OBJCOPY=/usr/bin/avr-objcopy
AVRDUDE=/usr/bin/avrdude
COMMON_FLAGS=-mmcu=$(MCU) -DF_CPU=$(DF_CPU) -MMD -DUSB_VID=null -DUSB_PID=null \
	-DARDUINO=$(ARDUINO_VERSION)
CC_FLAGS=-g -Os -Wall -ffunction-sections -fdata-sections
CPP_FLAGS=-g -Os -Wall -fno-exceptions -ffunction-sections -fdata-sections
CORE_C_FILES=wiring_pulse WInterrupts wiring wiring_digital wiring_analog
CORE_CPP_FILES=HardwareSerial new USBCore CDC main HID WMath Stream IPAddress \
	WString Print Tone


all:	clean compile upload

clean:
	@echo '# *** Cleaning...'
	rm -rf "$(TMP_DIR)"


compile:
	@echo '# *** Compiling...'

	mkdir $(TMP_DIR)
	echo '#include "Arduino.h"' > "$(TMP_DIR)/$(SKETCH_NAME).cpp"
	cat $(SKETCH_NAME) >> "$(TMP_DIR)/$(SKETCH_NAME).cpp"

	@#Compiling the sketch file:
	$(CPP) -c $(CPP_FLAGS) $(COMMON_FLAGS) $(INCLUDES) \
	       "$(TMP_DIR)/$(SKETCH_NAME).cpp" \
	       -o "$(TMP_DIR)/$(SKETCH_NAME).o"

	@#Compiling Arduino core .c dependecies:
	for core_c_file in ${CORE_C_FILES}; do \
	    $(CC) -c $(CC_FLAGS) $(COMMON_FLAGS) $(INCLUDES) \
	         $(ARDUINO_CORES)/$$core_c_file.c \
		  -o $(TMP_DIR)/$$core_c_file.o; \
	done

	@#Compiling Arduino core .cpp dependecies:
	for core_cpp_file in ${CORE_CPP_FILES}; do \
	    $(CPP) -c $(CPP_FLAGS) $(COMMON_FLAGS) $(INCLUDES) \
	           $(ARDUINO_CORES)/$$core_cpp_file.cpp \
		   -o $(TMP_DIR)/$$core_cpp_file.o; \
	done

	@#TODO: compile external libraries here
	@#TODO: use .d files to track dependencies and compile them
	@#      change .c by -MM and use -MF to generate .d

	$(CC) -mmcu=$(MCU) -lm -Wl,--gc-sections -Os \
	      -o $(TMP_DIR)/$(SKETCH_NAME).elf $(TMP_DIR)/*.o
	$(AVR_OBJCOPY) -O ihex -j .eeprom --set-section-flags=.eeprom=alloc,load \
		--no-change-warnings --change-section-lma .eeprom=0 \
	               $(TMP_DIR)/$(SKETCH_NAME).elf \
		       $(TMP_DIR)/$(SKETCH_NAME).eep
	$(AVR_OBJCOPY) -O ihex -R .eeprom \
	               $(TMP_DIR)/$(SKETCH_NAME).elf \
		       $(TMP_DIR)/$(SKETCH_NAME).hex
	@echo '# *** Compiled successfully! \o/'

reset:
	@echo '# *** Resetting...'
	stty --file $(PORT) hupcl
	sleep 0.1
	stty --file $(PORT) -hupcl

upload:
	@echo '# *** Uploading...'
	$(AVRDUDE) -V -p$(MCU) -c$(BOARD_TYPE) \
	           -b$(BAUD_RATE) -P$(PORT) -D \
		   -Uflash:w:$(TMP_DIR)/$(SKETCH_NAME).hex:i
	@echo '# *** Done - enjoy your sketch!'
