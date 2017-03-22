################################################################################
#
#
#
#
################################################################################

PRJ_DIR        = $(PWD)
TARGET_OUT_DIR = Output
OBJ_OUT_DIR    = $(TARGET_OUT_DIR)/obj
LST_OUT_DIR    = $(TARGET_OUT_DIR)/lst
LIB_OUT_DIR    = $(TARGET_OUT_DIR)/lib

##Create Output folder
$(shell mkdir -p ${TARGET_OUT_DIR} 2>/dev/null)
$(shell mkdir -p ${OBJ_OUT_DIR} 2>/dev/null)
$(shell mkdir -p ${LST_OUT_DIR} 2>/dev/null)
$(shell mkdir -p ${LIB_OUT_DIR} 2>/dev/null)

# add startup file to build
STARTUP_DIR  = Device/startup
STARTUP_FILE = Device/startup/startup_stm32f0xx.s

# all the files will be generated with this name (main.elf, main.bin, main.hex, etc)
PROJ_NAME=stm32f0_project

# Location of the Libraries folder from the STM32F0xx Standard Peripheral Library
STD_PERIPH_LIB=Libraries/STM32F0xx_StdPeriph_Driver

# Location of the linker scripts
LDSCRIPT_INC=Device/ldscripts
LDSCRIPT=stm32f0.ld

# Configuration (cfg) file containing programming directives for OpenOCD
OPENOCD_PROC_FILE=Device/openocd_scripts/stm32f0-openocd.cfg

# Inc folder
INC_DIR  = -ICodes/inc
INC_DIR += -ILibraries
INC_DIR += -ILibraries/CMSIS/Include
INC_DIR += -ILibraries/CMSIS/STM32F0xx
INC_DIR += -ILibraries/STM32F0xx_StdPeriph_Driver/inc

# INC_DIR += -I$(STARTUP_DIR)

INC_DIR += -includeLibraries/stm32f0xx_conf.h

# Src folder
SRC_DIR  = Codes/src
SRC_DIR += Libraries/STM32F0xx_StdPeriph_Driver/src
SRC_DIR += $(STARTUP_DIR)

################################################################################
CC=arm-none-eabi-gcc
AR=arm-none-eabi-ar
OBJCOPY=arm-none-eabi-objcopy
OBJDUMP=arm-none-eabi-objdump
SIZE=arm-none-eabi-size


#
# Compiler Flags
#
CFLAGS  = -Wall -g -std=c99 -O0
CFLAGS += -mlittle-endian -mcpu=cortex-m0 -march=armv6-m -mthumb
CFLAGS += -ffunction-sections -fdata-sections
CFLAGS += $(INC_DIR)


#
# Linker Flags
#
LDFLAGS = -Wl,--gc-sections -Wl,-Map=$(TARGET_OUT_DIR)/$(PROJ_NAME).map -L$(LDSCRIPT_INC) -T$(LDSCRIPT)


vpath %.c $(SRC_DIR)
vpath %.s $(SRC_DIR)
vpath %.a $(LIB_OUT_DIR)

################################################################################

#
# Stm32f0xx standard library sources
#
SRC_FILE += $(STD_PERIPH_LIB)/src/stm32f0xx_adc.c
SRC_FILE += $(STD_PERIPH_LIB)/src/stm32f0xx_cec.c
SRC_FILE += $(STD_PERIPH_LIB)/src/stm32f0xx_comp.c
SRC_FILE += $(STD_PERIPH_LIB)/src/stm32f0xx_crc.c
SRC_FILE += $(STD_PERIPH_LIB)/src/stm32f0xx_dac.c 
SRC_FILE += $(STD_PERIPH_LIB)/src/stm32f0xx_dbgmcu.c
SRC_FILE += $(STD_PERIPH_LIB)/src/stm32f0xx_dma.c
SRC_FILE += $(STD_PERIPH_LIB)/src/stm32f0xx_exti.c
SRC_FILE += $(STD_PERIPH_LIB)/src/stm32f0xx_flash.c
SRC_FILE += $(STD_PERIPH_LIB)/src/stm32f0xx_gpio.c
SRC_FILE += $(STD_PERIPH_LIB)/src/stm32f0xx_i2c.c
SRC_FILE += $(STD_PERIPH_LIB)/src/stm32f0xx_iwdg.c
SRC_FILE += $(STD_PERIPH_LIB)/src/stm32f0xx_misc.c
SRC_FILE += $(STD_PERIPH_LIB)/src/stm32f0xx_pwr.c
SRC_FILE += $(STD_PERIPH_LIB)/src/stm32f0xx_rcc.c
SRC_FILE += $(STD_PERIPH_LIB)/src/stm32f0xx_rtc.c
SRC_FILE += $(STD_PERIPH_LIB)/src/stm32f0xx_spi.c
SRC_FILE += $(STD_PERIPH_LIB)/src/stm32f0xx_syscfg.c
SRC_FILE += $(STD_PERIPH_LIB)/src/stm32f0xx_tim.c
SRC_FILE += $(STD_PERIPH_LIB)/src/stm32f0xx_usart.c
SRC_FILE += $(STD_PERIPH_LIB)/src/stm32f0xx_wwdg.c

#
# User sources
#
SRC_FILE += Codes/src/main.c
SRC_FILE += Codes/src/system_stm32f0xx.c

#
# Asembly source
#
ASRC_FILE += $(STARTUP_DIR)/startup_stm32f0xx.s


# Convert all source files to object file with path
OBJS       = $(SRC_FILE:%.c=%.o)
OBJS      += $(ASRC_FILE:%.s=%.o)

# Filltering object file names
OBJS_FILE  = $(notdir $(OBJS))

# Adding object file names with Output directory
OBJS_OUT_BUILD   = $(OBJS_FILE:%.o=$(OBJ_OUT_DIR)/%.o)

.PHONY: clean elf debug


all: debug elf
	@echo
	@echo "BUILD DONE"

debug:
#	@echo "===================== PRINT ALL VALUES OR FLAGS TO DEBUG ====================="
#	@echo "*"
#	@echo "*" OBJS_FILE: $(OBJS_FILE)
#	@echo "*" OBJS     : $(OBJS)
#	@echo "*" OBJ_OUT  : $(OBJS_OUT_BUILD)
#	@echo "=============================================================================="
#	@echo 


# Assemble: create object files from assembler source files
%.o : %.s
	@echo
	@echo ASM: $(STARTUP_FILE)
	@$(CC) $(CFLAGS) -c -o $(OBJ_OUT_DIR)/$@ $^

# Compile: create object files from C source files
%.o : %.c
	@echo "CC: $^    \t\t-> $(OBJ_OUT_DIR)/$@"
	@$(CC) $(CFLAGS) -c -o $(OBJ_OUT_DIR)/$@ $^


elf: $(PROJ_NAME).elf
$(PROJ_NAME).elf : $(OBJS_FILE)
	@echo
	@echo "Build elf file: $@"
	@$(CC) $(CFLAGS) -o $(TARGET_OUT_DIR)/$(PROJ_NAME).elf $(OBJS_OUT_BUILD) $(LDFLAGS)
	@echo
	
	@echo "Build hex file: $(TARGET_OUT_DIR)/$(PROJ_NAME).hex"
	$(OBJCOPY) -O ihex $(TARGET_OUT_DIR)/$(PROJ_NAME).elf $(TARGET_OUT_DIR)/$(PROJ_NAME).hex
	@echo
	
	@echo "Build binary file: $(TARGET_OUT_DIR)/$(PROJ_NAME).bin"
	$(OBJCOPY) -O binary $(TARGET_OUT_DIR)/$(PROJ_NAME).elf $(TARGET_OUT_DIR)/$(PROJ_NAME).bin
	@echo
	
	@echo "Dump asm file: $(TARGET_OUT_DIR)/$(PROJ_NAME).lst"
	$(OBJDUMP) -St $(TARGET_OUT_DIR)/$(PROJ_NAME).elf > $(TARGET_OUT_DIR)/$(PROJ_NAME).lst
	@echo
	
	@echo "Dump code size"
	$(SIZE) -A $(TARGET_OUT_DIR)/$(PROJ_NAME).elf


clean:
	@echo "Clean project"
	@rm -rf $(TARGET_OUT_DIR)
	@rm -f *.o
	