#include <bcm2835.h>
#include <stdio.h>
#include <stdint.h>
#include <string.h>

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
			uint32_t mid, n, word_count, verify;
			char sink[4];
			
			uint32_t i = 0;
			printf("Val: ");
			scanf("%x", &i);

			word_count = 1;
			/* normal operation */
			// send enable byte
			bcm2835_spi_transfer(1);
      // send 4-byte word_count
	  	bcm2835_spi_transfernb((char *)&word_count, sink, 4);
			// send words
	  	bcm2835_spi_transfern((char *)&i, word_count * 4);
     
		  // recv enable byte 
	  	while (!bcm2835_spi_transfer(0));
			memset(&i, 0, 4);
			// recv 4-byte n
		  bcm2835_spi_transfernb((char *)&i, (char *)&verify, 4);
			printf("(%d)\n", verify);
			memset(&i, 0, 4);
			// receive words
			bcm2835_spi_transfern((char *)&i, verify * 4);

			printf("Recv: %x\n", i);	
		}

    bcm2835_spi_end();
    bcm2835_close();
    return 0;
}
