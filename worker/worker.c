

#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <netdb.h>
#include <sys/types.h> 
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
  
#include <bcm2835.h>
#include <time.h>

#define PIN RPI_V2_GPIO_P1_22
#define PORT    18500 
#define BUFSIZE 1024

/*
 * error - wrapper for perror
 */
void error(char *msg) {
  perror(msg);
  exit(1);
}

int main(int argc, char **argv) {
  
  /* ** BCM library initialization ** */

	if (!bcm2835_init())
  {
    error("bcm2835_init failed. Are you running as root??\n");
  }
  if (!bcm2835_spi_begin())
  {
    error("bcm2835_spi_begin failed. Are you running as root??\n");
  }

  bcm2835_gpio_fsel(PIN, BCM2835_GPIO_FSEL_OUTP);
	bcm2835_gpio_write(PIN, LOW);
  
  bcm2835_spi_setBitOrder(BCM2835_SPI_BIT_ORDER_MSBFIRST);     
  bcm2835_spi_setDataMode(BCM2835_SPI_MODE0);                  
  bcm2835_spi_setClockDivider(BCM2835_SPI_CLOCK_DIVIDER_16);
  bcm2835_spi_chipSelect(BCM2835_SPI_CS0);                     
  bcm2835_spi_setChipSelectPolarity(BCM2835_SPI_CS0, LOW);     
	
	delay(10);
	bcm2835_gpio_write(PIN, HIGH);
	delay(10);
		

  /* ** ECHOSERVER.C (MODIFIED) ** */

  int listenfd; /* listening socket */
  int connfd; /* connection socket */
  int portno; /* port to listen on */
  int clientlen; /* byte size of client's address */
  struct sockaddr_in serveraddr; /* server's addr */
  struct sockaddr_in clientaddr; /* client addr */
  struct hostent *hostp; /* client host info */
  char buf[BUFSIZE]; /* message buffer */
  char *hostaddrp; /* dotted decimal host addr string */
  int optval; /* flag value for setsockopt */
  int n; /* message byte size */

  int loopback;

  /* check command line args */
  if (argc < 2) {
    portno = PORT;
  } else {
  	portno = atoi(argv[1]);
	}

	if (argc > 2) {
		loopback = (strcmp(argv[2], "--loopback") == 0);
	} else {
		loopback = 0;
	}


  /* socket: create a socket */
  listenfd = socket(AF_INET, SOCK_STREAM, 0);
  if (listenfd < 0) 
    error("ERROR opening socket\n");

  /* setsockopt: Handy debugging trick that lets 
   * us rerun the server immediately after we kill it; 
   * otherwise we have to wait about 20 secs. 
   * Eliminates "ERROR on binding: Address already in use" error. 
   */
  optval = 1;
  setsockopt(listenfd, SOL_SOCKET, SO_REUSEADDR, 
     (const void *)&optval , sizeof(int));

  /* build the server's internet address */
  bzero((char *) &serveraddr, sizeof(serveraddr));
  serveraddr.sin_family = AF_INET; /* we are using the Internet */
  serveraddr.sin_addr.s_addr = htonl(INADDR_ANY); /* accept reqs to any IP addr */
  serveraddr.sin_port = htons((unsigned short)portno); /* port to listen on */

  /* bind: associate the listening socket with a port */
  if (bind(listenfd, (struct sockaddr *) &serveraddr, 
   sizeof(serveraddr)) < 0) 
    error("ERROR on binding\n");

  /* listen: make it a listening socket ready to accept connection requests */
  if (listen(listenfd, 5) < 0) /* allow 5 requests to queue up */ 
    error("ERROR on listen\n");
  int once = 1; 

  clientlen = sizeof(clientaddr);
	printf("Opening connection on port %d\n", portno);
  while (1) {

    /* accept: wait for a connection request */
    connfd = accept(listenfd, (struct sockaddr *) &clientaddr, &clientlen);
    if (connfd < 0) { 
			if (once) {
				printf("Socket error");
				once = 0;
			}
      continue;
		}

    /* gethostbyaddr: determine who sent the message */
    /*
		hostp = gethostbyaddr((const char *)&clientaddr.sin_addr.s_addr, 
  sizeof(clientaddr.sin_addr.s_addr), AF_INET);
    if (hostp == NULL) {
			printf("Host error\n");
      close(connfd);
			continue;
		}
    hostaddrp = inet_ntoa(clientaddr.sin_addr);
    if (hostaddrp == NULL) {
			printf("Address resolution error\n");
      close(connfd);
			continue;
		}
    printf("server established connection with %s (%s)\n", 
    hostp->h_name, hostaddrp);
		*/
    
		printf("Connection established\n");
		while (1) {
    	bzero(buf, BUFSIZE);
    	n = read(connfd, buf, BUFSIZE-4);
    	if (n <= 0) 
				break; 
			printf("Received: %s (%i)\n", buf, n);
			
			// pad input
			while ((n & 0x3) != 0) {
				buf[n] = '\0';
				n++;
			}
			printf("After pad: %s (%i)\n", buf, n);
			uint32_t word_count = n / 4;
			buf[n] = '\0';
		  uint32_t verify = 0;
			uint32_t none = 0;
			char sink[4];
      
			if (loopback) {
				/* loopback mode */
				bcm2835_spi_transfernb(buf, sink, 2);
				if (n-2 > 0) {
				  bcm2835_spi_transfernb(&buf[2], buf, n-2);
    	  }
				bcm2835_spi_transfernb((char *)&none, &buf[n-2], 2);
				verify = n;
			} else {
				/* normal operation */
				// send enable byte
				bcm2835_spi_transfer(1);
        // send 4-byte word_count
	  		bcm2835_spi_transfernb((char *)&word_count, sink, 4);
				// send words
	  		bcm2835_spi_transfern(buf, word_count * 4);
       
			  // recv enable byte 
	  		while (!bcm2835_spi_transfer(0));
	  	  bzero(buf, 4);
				// recv 4-byte n
			  bcm2835_spi_transfernb(buf, (char *)&verify, 4);
    	  bzero(buf, BUFSIZE);
				// receive words
				bcm2835_spi_transfern(buf, verify * 4);
			}

			printf("Sending: %s (%i)\n", buf, verify * 4);
	
    	n = write(connfd, buf, verify * 4);
    	if (n < 0)
				break; 
		}
		printf("Connection closed\n");
		close(connfd);
  }
}
