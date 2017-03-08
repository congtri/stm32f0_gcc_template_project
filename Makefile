export PROJECT_ROOT			?=$(PWD)
export OUTPUT_DIR			?=$(PROJECT_ROOT)/Output
export OBJ_BUILD_DIR		?=$(OUTPUT_DIR)/build

# Directory contens project code folder
CODE_DIR=Codes
CODE_DIR_INC=$(CODE_DIR)/inc
CODE_DIR_SRC=$(CODE_DIR)/src

# put your *.o targets here, make should handle the rest!
CODE_SRCS =		$(CODE_DIR_SRC)/main.c                    \
				$(CODE_DIR_SRC)/system_stm32f0xx.c        \

# all the files will be generated with this name (main.elf, main.bin, main.hex, etc)
PROJ_NAME=stm32f0_project

# Location of the Libraries folder from the STM32F0xx Standard Peripheral Library
STD_PERIPH_LIB=Libraries

# Location of the linker scripts
LDSCRIPT_INC=Device/ldscripts

# location of OpenOCD Board .cfg files (only used with 'make program')
OPENOCD_BOARD_DIR=/usr/share/openocd/scripts/board

# Configuration (cfg) file containing programming directives for OpenOCD
OPENOCD_PROC_FILE=Device/openocd_scripts/stm32f0-openocd.cfg

# that's it, no need to change anything below this line!

###################################################

CC=arm-none-eabi-gcc
OBJCOPY=arm-none-eabi-objcopy
OBJDUMP=arm-none-eabi-objdump
SIZE=arm-none-eabi-size

CFLAGS  = -Wall -g -std=c99 -Os  
#CFLAGS += -mlittle-endian -mthumb -mcpu=cortex-m0 -march=armv6s-m
CFLAGS += -mlittle-endian -mcpu=cortex-m0  -march=armv6-m -mthumb
CFLAGS += -ffunction-sections -fdata-sections
CFLAGS += -Wl,--gc-sections -Wl,-Map=$(OUTPUT_DIR)/$(PROJ_NAME).map

###################################################

vpath %.c src
vpath %.a $(OBJ_BUILD_DIR)

##Create Output folder
$(shell mkdir -p ${OUTPUT_DIR} 2>/dev/null)
$(shell mkdir -p ${OBJ_BUILD_DIR} 2>/dev/null)

CFLAGS += -I inc -I $(STD_PERIPH_LIB) -I $(STD_PERIPH_LIB)/CMSIS/STM32F0xx/Include
CFLAGS += -I $(STD_PERIPH_LIB)/CMSIS/Include -I $(STD_PERIPH_LIB)/STM32F0xx_StdPeriph_Driver/inc
CFLAGS += -include $(STD_PERIPH_LIB)/stm32f0xx_conf.h

CODE_SRCS += Device/startup_stm32f0xx.s # add startup file to build

# need if you want to build with -DUSE_CMSIS 
#CODE_SRCS += stm32f0_discovery.c
#CODE_SRCS += stm32f0_discovery.c stm32f0xx_it.c

#OBJS = $(CODE_SRCS:.c=.o)

###################################################

.PHONY: lib proj

all: lib proj

lib:
	$(MAKE) -C $(STD_PERIPH_LIB)

proj: 	$(PROJ_NAME).elf

$(PROJ_NAME).elf: $(CODE_SRCS)
	#Build object file
	$(CC) $(CFLAGS) $^ -o $(OUTPUT_DIR)/$@ -L$(OBJ_BUILD_DIR) -lstm32f0 -L$(LDSCRIPT_INC) -Tstm32f0.ld
	#Build hex file
	$(OBJCOPY) -O ihex $(OUTPUT_DIR)/$(PROJ_NAME).elf $(OUTPUT_DIR)/$(PROJ_NAME).hex
	#Build binary file
	$(OBJCOPY) -O binary $(OUTPUT_DIR)/$(PROJ_NAME).elf $(OUTPUT_DIR)/$(PROJ_NAME).bin
	#Dump asm file
	$(OBJDUMP) -St $(OUTPUT_DIR)/$(PROJ_NAME).elf > $(OUTPUT_DIR)/$(PROJ_NAME).lst
	#Dump code size
	$(SIZE) $(OUTPUT_DIR)/$(PROJ_NAME).elf
	
program: $(PROJ_NAME).bin
	openocd -f $(OPENOCD_BOARD_DIR)/stm32f0discovery.cfg -f $(OPENOCD_PROC_FILE) -c "stm_flash $(OUTPUT_DIR)/$(PROJ_NAME).bin" -c shutdown

clean:
	rm -rf $(OUTPUT_DIR)
	find ./ -name '*~' | xargs rm -f
	rm -f *.o
	rm -f $(STD_PERIPH_LIB)/*.o
	rm -f $(STD_PERIPH_LIB)/*.a

reallyclean: clean
	$(MAKE) -C $(STD_PERIPH_LIB) clean
