#include <bcm2835.h>
#include <stdio.h>
#include <stdint.h>

#define PIN RPI_V2_GPIO_P1_22

int main(int argc, char **argv)
{
    if (!bcm2835_init())
    {
      printf("bcm2835_init failed. Are you running as root??\n");
      return 1;
    }
    if (!bcm2835_spi_begin())
    {
      printf("bcm2835_spi_begin failed. Are you running as root??\n");
      return 1;
    }

    bcm2835_gpio_fsel(PIN, BCM2835_GPIO_FSEL_OUTP);
	  bcm2835_gpio_write(PIN, LOW);

    bcm2835_spi_setBitOrder(BCM2835_SPI_BIT_ORDER_MSBFIRST);     
    bcm2835_spi_setDataMode(BCM2835_SPI_MODE0);                  
    bcm2835_spi_setClockDivider(BCM2835_SPI_CLOCK_DIVIDER_16);
    bcm2835_spi_chipSelect(BCM2835_SPI_CS0);                     
    bcm2835_spi_setChipSelectPolarity(BCM2835_SPI_CS0, LOW);     
		
		delay(500);
	  bcm2835_gpio_write(PIN, HIGH);
		delay(500);
		   
		while (1) {
			int i = 0;
			printf("Val: ");
			scanf("%x", &i);
			uint8_t val = bcm2835_spi_transfer((uint8_t)(i & 0xFF));
			printf("Recv: %x\n", val);	
		}

    bcm2835_spi_end();
    bcm2835_close();
    return 0;
}
