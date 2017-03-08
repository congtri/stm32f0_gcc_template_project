CC=arm-none-eabi-gcc
AR=arm-none-eabi-ar

###########################################

vpath %.c STM32F0xx_StdPeriph_Driver/src

CFLAGS  = -g -O2 -Wall
CFLAGS += -mlittle-endian -mthumb -mcpu=cortex-m0 -march=armv6s-m
CFLAGS += -ffreestanding -nostdlib
CFLAGS += -includestm32f0xx_conf.h -ICMSIS/Include -ICMSIS/STM32F0xx -ISTM32F0xx_StdPeriph_Driver/inc


ST_DRV_SRCS =	stm32f0xx_adc.c          \
				stm32f0xx_cec.c          \
				stm32f0xx_comp.c         \
				stm32f0xx_crc.c          \
				stm32f0xx_dac.c          \
				stm32f0xx_dbgmcu.c       \
				stm32f0xx_dma.c          \
				stm32f0xx_exti.c         \
				stm32f0xx_flash.c        \
				stm32f0xx_gpio.c         \
				stm32f0xx_i2c.c          \
				stm32f0xx_iwdg.c         \
				stm32f0xx_misc.c         \
				stm32f0xx_pwr.c          \
				stm32f0xx_rcc.c          \
				stm32f0xx_rtc.c          \
				stm32f0xx_spi.c          \
				stm32f0xx_syscfg.c       \
				stm32f0xx_tim.c          \
				stm32f0xx_usart.c        \
				stm32f0xx_wwdg.c         \


OBJ_ST_DRV = $(ST_DRV_SRCS:%.c=../$(OBJ_BUILD_DIR)/%.o)
OBJS = $(ST_DRV_SRCS:.c=.o)

.PHONY: libstm32f0.a

#Building lib file with stm32f0xx_xxx.o drivers
all: libstm32f0.a

%.o : %.c
##	Build and print CFLAG to console
##	$(CC) $(CFLAGS) -c -o ../$(OBJ_BUILD_DIR)/$@ $^

##	Build without print CFLAG to console	
	@echo "BUILD: $^ \t\t-> $@"
	@$(CC) $(CFLAGS) -c -o ../$(OBJ_BUILD_DIR)/$@ $^

libstm32f0.a: $(OBJS)
	@echo "BUILD: $@"
	@$(AR) -r ../$(OBJ_BUILD_DIR)/$@ $(OBJ_ST_DRV)

clean:
#	rm -f libstm32f0.a
#	rm -f *.o
