#include "stm32f0xx_conf.h"
#include "stm32f0xx.h"

#if 0
void SysTick_Handler(void)
{
	static uint16_t tick = 0;

	switch(tick++)
	{
		case 100:
			tick = 0;
			GPIOC->ODR ^= (1 << 8);
			break;
	}
}

int main(void)
{

	RCC->AHBENR |= RCC_AHBENR_GPIOCEN;     // enable the clock to GPIOC
	//(RM0091 lists this as IOPCEN, not GPIOCEN)

	GPIOC->MODER = (1 << 16);

	SysTick_Config(SystemCoreClock / 100);

	while(1);
}
#else

void delay(void)
{
	int time;
	for (time = 0; time < 4000000; time++)
	{
		;
	}
}

void gpio_setup(void)
{
	GPIO_InitTypeDef GPIO_InitStructure;
	RCC_AHBPeriphClockCmd(RCC_AHBPeriph_GPIOC, ENABLE);

	GPIO_InitStructure.GPIO_Pin = GPIO_Pin_9 | GPIO_Pin_8;
	GPIO_InitStructure.GPIO_Mode = GPIO_Mode_OUT;
	GPIO_InitStructure.GPIO_OType = GPIO_OType_PP;
	GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
	GPIO_InitStructure.GPIO_PuPd = GPIO_PuPd_NOPULL;
	GPIO_Init(GPIOC, &GPIO_InitStructure);
}

int main(void)
{
	gpio_setup();
	while (1)
	{
		GPIOC->ODR = 0x0100;
		delay();
		GPIOC->ODR = 0x0200;
		delay();
	}
}
#endif
