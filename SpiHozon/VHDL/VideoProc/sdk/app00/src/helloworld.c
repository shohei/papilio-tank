#include <stdio.h>
#include "platform.h"
#include "xbasic_types.h"
#include "XIOModule.h"

#define SDA_O 0x80000010
#define SCL_O 0x80000014
#define GPO3_BASE 0x80000018
#define GPO4_BASE 0x8000001C
#define SDA_I 0x80000020
#define SCL_I 0x80000024
#define GPI3_BASE 0x80000028
#define GPI4_BASE 0x8000002C

int SDA_OENB = 0;
int SDA_BIT = 1;
int SCL_OENB = 0;
int SCL_BIT = 1;
int viewmode = 0;
int dispoff = 0;
int pixstb = 0;
int pixrd = 0;
int pixwr = 0;
int pix2logic = 0;
int pix2nios = 0;
int lbrdy = 0;
int CARD_CMD = 0;
int CARD_CLK = 0;
int CARD_DAT3 = 1;
int CARD_DAT0 = 0;
int VMOTOR_L = 0;
int VMOTOR_R = 0;
int frame2Spi = 0;
int frame2Logic = 0;
int MAXFRAME = 1;
unsigned char verify;
int offset = 1;
int sw2pushed = 0;
int sw3pushed = 0;

/************************************************************************
*  Commands
************************************************************************/
    #define CMD_READ  (unsigned)0x03
    #define CMD_WRITE (unsigned)0x02
    #define CMD_WREN  (unsigned)0x06
    #define CMD_RDSR  (unsigned)0x05
    #define CMD_ERASE (unsigned)0x60
    #define CMD_EWSR  (unsigned)0x50
    #define CMD_WRSR  (unsigned)0x01
    #define CMD_SER   (unsigned)0x20

unsigned char pix_Rg[704];
unsigned char pix_gB[704];

void SetGpo3() {
	*(volatile unsigned long *)(GPO3_BASE)
			= (VMOTOR_R << 25) + (VMOTOR_L << 24) + (pix2logic << 8) + (pixwr << 7) + (pixrd << 6) + (pixstb << 5)
			+ (dispoff << 4) + viewmode;
}

void SetGpo4() {
	*(volatile unsigned long *)(GPO4_BASE)
			= (CARD_DAT3 << 2) + (CARD_CLK << 1) + (CARD_CMD << 0);
}

void card_dout(int d) {
	CARD_CMD = d;
	SetGpo4();
}

void card_clk(int d) {
	CARD_CLK = d;
	SetGpo4();
}

unsigned char card_din() {
	unsigned char res;
	res = *(volatile unsigned long *)GPI4_BASE & 0x1;
	return res;
}

void card_cson() {
	CARD_DAT3 = 0;
	SetGpo4();
}

void card_csoff() {
	CARD_DAT3 = 1;
	SetGpo4();
}

// send & get SPI data
unsigned char spi_tx( unsigned char c )
{
	unsigned char    ret;

	ret = 0;
    if( c & 0x80 ) card_dout(1); else card_dout(0);
    card_clk(1);
    if ( card_din() ) ret |= 0x80;
    card_clk(0);

    if( c & 0x40 ) card_dout(1); else card_dout(0);
    card_clk(1);
    if ( card_din() ) ret |= 0x40;
    card_clk(0);

    if( c & 0x20 ) card_dout(1); else card_dout(0);
    card_clk(1);
    if ( card_din() ) ret |= 0x20;
    card_clk(0);

    if( c & 0x10 ) card_dout(1); else card_dout(0);
    card_clk(1);
    if ( card_din() ) ret |= 0x10;
    card_clk(0);

    if( c & 0x08 ) card_dout(1); else card_dout(0);
    card_clk(1);
    if ( card_din() ) ret |= 0x08;
    card_clk(0);

    if( c & 0x04 ) card_dout(1); else card_dout(0);
    card_clk(1);
    if ( card_din() ) ret |= 0x04;
    card_clk(0);

    if( c & 0x02 ) card_dout(1); else card_dout(0);
    card_clk(1);
    if ( card_din() ) ret |= 0x02;
    card_clk(0);

    if( c & 0x01 ) card_dout(1); else card_dout(0);
    card_clk(1);
    if ( card_din() ) ret |= 0x01;
    card_clk(0);

    return ret;
}

// get responce
unsigned char spi_getresponce(int n, unsigned char nexp)
{
	unsigned char    ret, loops;

    for ( loops = 0; loops < n; loops++ ) {
        ret = spi_tx( 0xff );
        if ( ret != nexp )
            break;
    }
    return ret;
}

//	wait routine. loop_count 2k is wait for 1ms
void _wait(loop_count)
int loop_count;
{
	volatile int sum, data;
	sum	= 0;
	for (data = 0; data < loop_count; data++) {
		sum = (data << 8);
	}
  return;
}

void WriteEnable(void)
{
	card_cson();
    spi_tx(CMD_WREN);
    card_csoff();
}

unsigned char IsWriteBusy(void)
{
    unsigned char    temp;

    card_cson();
    spi_tx(CMD_RDSR);

    temp = spi_tx(0);
    card_csoff();

    return (temp & 0x01);
}

void SectorErase(unsigned long address)
{
    WriteEnable();
    card_cson();

    spi_tx(CMD_SER);

    spi_tx((0xFF0000 & address) >> 16);

    spi_tx((0xFF00 & address) >> 8);

    spi_tx((0xFF & address) >> 0);

    card_csoff();

    // Wait for write end
    _wait(70000);
    while(IsWriteBusy());
}

void WriteByte(unsigned char data, unsigned long address)
{
    WriteEnable();
    card_cson();

    spi_tx(CMD_WRITE);

    spi_tx((0xFF0000 & address) >> 16);

    spi_tx((0xFF00 & address) >> 8);

    spi_tx((0xFF & address) >> 0);

    spi_tx(data);

    card_csoff();

    // Wait for write end
    while(IsWriteBusy());
}

void WriteByteNx(unsigned char *dataArray, unsigned long address, int n)
{
	int i;
    WriteEnable();
    card_cson();

    spi_tx(CMD_WRITE);

    spi_tx((0xFF0000 & address) >> 16);

    spi_tx((0xFF00 & address) >> 8);

    spi_tx((0xFF & address) >> 0);

    for(i = 0; i < n; i++) spi_tx(dataArray[i]);

    card_csoff();

    // Wait for write end
    while(IsWriteBusy());
}

unsigned char ReadByte(unsigned long address)
{
    unsigned char    temp;
    card_cson();

    spi_tx(CMD_READ);

    spi_tx((0xFF0000 & address) >> 16);

    spi_tx((0xFF00 & address) >> 8);

    spi_tx((0xFF & address) >> 0);

    temp = spi_tx(0);

    card_csoff();
    return (temp);
}

unsigned char WriteArray(unsigned long address, unsigned char *pData, unsigned short nCount)
{
	unsigned long   addr;
    unsigned char    *pD;
    unsigned short    counter;

    addr = address;
    pD = pData;

    for(counter = 0; counter < nCount; counter+=64)
    {
        WriteByteNx(pD, addr, 64);
        pD+=64;
        addr+=64;
    }

    return (1);
}

void ReadArray(unsigned long address, unsigned char *pData, unsigned short nCount)
{
    card_cson();

    spi_tx(CMD_READ);

    spi_tx((0xFF0000 & address) >> 16);

    spi_tx((0xFF00 & address) >> 8);

    spi_tx((0xFF & address) >> 0);

    while(nCount--)
    {
        *pData++ = spi_tx(0);
    }

    card_csoff();
}

unsigned char  LineToSPI(int page, int lineno, int offset) {
	int linerdy;
	int i;
	unsigned long regval;
	unsigned char ret1, ret2, ret;

	// wait untill the line buffer becomes full
	linerdy = 0;
	while(linerdy == 0) {
		linerdy = (*(volatile unsigned long *)GPI3_BASE >> 2);
	}

	_wait(300);

	pixrd = 1;
	SetGpo3();

			// get 704 pixels from SDRAM // 有効画素数は640だが余裕を持って704画素読み書きする
			for(i = 0; i < 704; i++) {
				pixstb = 0;
				SetGpo3();
				pixstb = 1;
				SetGpo3();
				regval = (*(volatile unsigned long *)GPI3_BASE) >> 3;
				pix_gB[i] = 0x00ff & regval;
				pix_Rg[i] = regval >> 8;
			}
	pixrd = 0;
	SetGpo3();

	ret1 = WriteArray((512*(page+offset) + lineno)<<10, pix_gB, 704);
	_wait(900);

	ret2 = WriteArray((512*(page+offset)+256 + lineno)<<10, pix_Rg, 704);
	_wait(900);

	if(ret1 == 1 && ret2 == 1) ret = 1;
	else ret = 0;
	return ret;
}

void LineFromSPI(int page, int lineno, int offset) {
	int linerdy;
	int i;
	unsigned long regval;
	unsigned char ret;

	ReadArray((512*(page+offset) + lineno)<<10, pix_gB, 704);

	_wait(900);
	ReadArray((512*(page+offset)+256 + lineno)<<10, pix_Rg, 704);

	_wait(900);

	pixwr = 1;
	SetGpo3();

	// send 704 pixels to SDRAM // 有効画素数は640だが余裕を持って704画素読み書きする
	for(i = 0; i < 704; i++) {
		pix2logic =  (pix_Rg[i] << 8) + pix_gB[i];
		SetGpo3();
		pixstb = 1;
		SetGpo3();
		pixstb = 0;
		SetGpo3();
	}

	pixwr = 0;
	SetGpo3();

	_wait(300);
	// wait untill line buffer empty
	linerdy = 0;
	while(linerdy == 0) {
		linerdy = (*(volatile unsigned long *)GPI3_BASE >> 2) ;
	}
	_wait(9000);
}

void SetClockDir(int oenb) {
	SCL_OENB = oenb;
	*(volatile unsigned long *)(SCL_O) = (SCL_OENB << 1) + SCL_BIT;
}

void SetClockBit(int bit) {
	SCL_BIT = bit;
	*(volatile unsigned long *)(SCL_O) = (SCL_OENB << 1) + SCL_BIT;
}

void SetDataDir(int oenb) {
	SDA_OENB = oenb;
	*(volatile unsigned long *)(SDA_O) = (SDA_OENB << 1) + SDA_BIT;
}

void SetDataBit(int bit) {
	SDA_BIT = bit;
	*(volatile unsigned long *)(SDA_O) = (SDA_OENB << 1) + SDA_BIT;
}

int GetDataBit() {
	int res;
	res = *(volatile unsigned long *)(SDA_I);
	res &= 1;
	return res;
}

void SCCBSendBit(int data) {
	SetClockDir(1);
	SetClockBit(0);
	SetDataDir(1);
	SetDataBit(0);
	_wait(10);
	if(data == 0) {
		SetDataBit(0);
	} else {
		SetDataBit(1);
	}
	SetClockBit(1);
	_wait(10);
	SetClockBit(0);
}

int SCCBReceiveBit() {
	unsigned long res;
	SetClockDir(1);
	SetClockBit(0);
	_wait(10);
	SetClockBit(1);
	SetDataDir(0);
	_wait(10);
	res = GetDataBit();
	SetClockBit(0);
	return res;
}

int SCCBSendByte(int data) {
	unsigned long mask = 1<<7;
	int i;

	for(i = 0; i < 8; i++) {
		SCCBSendBit(data & mask);
		mask = mask >> 1;
	}
	return SCCBReceiveBit();
}

unsigned short SCCBReceiveByte() {
	unsigned short res = 0;
	int i;
	for(i = 0; i < 8; i++) {
		res = res << 1;
		if(SCCBReceiveBit()) {
			res |= 0x01;
		}
	}
	SCCBSendBit(1);
	return res;
}

void SCCBStart() {
	_wait(10);
	SetDataDir(1);
	SetDataBit(1);
	SetClockDir(1);
	SetClockBit(1);
	_wait(10);
	SetDataBit(0);
	_wait(10);
	SetClockBit(0);
}

void SCCBStop() {
	_wait(10);
	SetDataDir(1);
	SetDataBit(0);
	SetClockDir(1);
	SetClockBit(1);
	_wait(10);
	SetDataBit(1);
	_wait(10);
	SetDataDir(0);
	SetClockDir(0);
	_wait(10000);
}

void SCCBWrite(int addr, int data) {
	int devID = 0x42;

	SCCBStart();
	SCCBSendByte(devID);
	SCCBSendByte(addr);
	SCCBSendByte(data);
	SCCBStop();
}

unsigned short SCCBRead(int addr) {
	unsigned short res;
	int devID = 0x42;

	SCCBStart();
	SCCBSendByte(devID);
	SCCBSendByte(addr);

	SCCBStart();
	SCCBSendByte(devID|0x01);
	res = SCCBReceiveByte();
	SCCBStop();
	return res;
}

void FrameToSPI() {
	int i;
	if(frame2Spi < MAXFRAME) {//3) {
	///////////////////////////////////////////////////////////
	// MAXFRAME枚書くまでは動き検出
    		_wait(1500000);
			viewmode = 5;
			SetGpo3();
			_wait(3000);
			for(i = 0; i < 240; i++) {
				verify = LineToSPI(frame2Spi, i, offset);
				if(verify == 0) break;
			}
			frame2Spi++;
			viewmode = 0;
			SetGpo3();
    		_wait(1500000);
			viewmode = 4;
			SetGpo3();
    		_wait(1500000);
	}
}

void FrameFromSPI() {
	int i;
//////////////////////////////////////////////////////////
// MAXFRAME枚描いた後はプッシュボタンの処理
		if(frame2Logic < MAXFRAME) {
			viewmode = 6;
			SetGpo3();
			_wait(3000);
			for(i = 0; i < 240; i++) {
				LineFromSPI(frame2Logic, i, offset);
			}
			frame2Logic++;
			viewmode = 1;
			SetGpo3();
		}
}

void SeeButtons() {
	unsigned long reg1, reg1old, reg1tmp, reg2tmp, reg3tmp;
	reg1old = reg1;
  	reg1tmp = *(volatile unsigned long *)GPI3_BASE & 0x03;
	_wait(10000);
  	reg2tmp = *(volatile unsigned long *)GPI3_BASE & 0x03;
	_wait(10000);
 	reg3tmp = *(volatile unsigned long *)GPI3_BASE & 0x03;
	_wait(10000);
	reg1 = *(volatile unsigned long *)GPI3_BASE & 0x03;
	if(reg1 == reg1tmp && reg1 == reg2tmp && reg1 == reg3tmp) {
	} else {
		reg1 = reg1old;
	}

	if(reg1 != reg1old) {
		_wait(300000);
	}
	if((reg1 & 0x03) == 0x02) { // SW2が押された
		sw2pushed = 1;
	} else if((reg1 & 0x03) == 0x01) { // SW3が押された
		sw3pushed = 1;
	} else {
		sw2pushed = 0;
		sw3pushed = 0;
	}
}

int main()
{
	unsigned long regmdet, regbtn;
	int i, k, res;
	int tmpint = 0;
	int loop = 0;
	int motionfound = 0;
	int angle = 0;
	int toright = 1;

	viewmode = 0;
	dispoff = 0;
	pixstb = 0;
	pixrd = 0;
	pixwr = 0;
	SetGpo3();

	SCCBWrite(0x12, 0x80); // reset

	SCCBWrite(0x01, 0x40);
	SCCBWrite(0x02, 0x60);
	SCCBWrite(0x03, 0x0a);
	SCCBWrite(0x0c, 0x00);
	SCCBWrite(0x0e, 0x61);
	SCCBWrite(0x0f, 0x4b);
	SCCBWrite(0x15, 0x00);
	SCCBWrite(0x16, 0x02);
	SCCBWrite(0x17, 0x13);
	SCCBWrite(0x18, 0x01);
	SCCBWrite(0x19, 0x02);
	SCCBWrite(0x1a, 0x7a);
	SCCBWrite(0x1e, 0x37); // from 07 to 37 2012/11/6
	SCCBWrite(0x21, 0x02);
	SCCBWrite(0x22, 0x91);
	SCCBWrite(0x29, 0x07);
	SCCBWrite(0x32, 0xb6);
	SCCBWrite(0x33, 0x0b);
	SCCBWrite(0x34, 0x11);
	SCCBWrite(0x35, 0x0b);
	SCCBWrite(0x37, 0x1d);
	SCCBWrite(0x38, 0x71);
	SCCBWrite(0x39, 0x2a);
	SCCBWrite(0x3b, 0x12);
	SCCBWrite(0x3c, 0x78);
	SCCBWrite(0x3d, 0xc3);
	SCCBWrite(0x3e, 0x00);
	SCCBWrite(0x3f, 0x00);
	SCCBWrite(0x41, 0x08);
	SCCBWrite(0x41, 0x38);
	SCCBWrite(0x43, 0x0a);
	SCCBWrite(0x44, 0xf0);
	SCCBWrite(0x45, 0x34);
	SCCBWrite(0x46, 0x58);
	SCCBWrite(0x47, 0x28);
	SCCBWrite(0x48, 0x3a);
	SCCBWrite(0x4b, 0x09);
	SCCBWrite(0x4c, 0x00);
	SCCBWrite(0x4d, 0x40);
	SCCBWrite(0x4e, 0x20);
	SCCBWrite(0x4f, 0x80);
	SCCBWrite(0x50, 0x80);
	SCCBWrite(0x51, 0x00);
	SCCBWrite(0x52, 0x22);
	SCCBWrite(0x53, 0x5e);
	SCCBWrite(0x54, 0x80);
	SCCBWrite(0x56, 0x40);
	SCCBWrite(0x58, 0x9e);
	SCCBWrite(0x59, 0x88);
	SCCBWrite(0x5a, 0x88);
	SCCBWrite(0x5b, 0x44);
	SCCBWrite(0x5c, 0x67);
	SCCBWrite(0x5d, 0x49);
	SCCBWrite(0x5e, 0x0e);
	SCCBWrite(0x69, 0x00);
	SCCBWrite(0x6a, 0x40);
	SCCBWrite(0x6b, 0x0a);
	SCCBWrite(0x6c, 0x0a);
	SCCBWrite(0x6d, 0x55);
	SCCBWrite(0x6e, 0x11);
	SCCBWrite(0x6f, 0x9f);
	SCCBWrite(0x70, 0x3a);
	SCCBWrite(0x71, 0x35);
	SCCBWrite(0x72, 0x11);
	SCCBWrite(0x73, 0xf0);
	SCCBWrite(0x74, 0x10);
	SCCBWrite(0x75, 0x05);
	SCCBWrite(0x76, 0xe1);
	SCCBWrite(0x77, 0x01);
	SCCBWrite(0x78, 0x04);
	SCCBWrite(0x79, 0x01);
	SCCBWrite(0x8d, 0x4f);
	SCCBWrite(0x8e, 0x00);
	SCCBWrite(0x8f, 0x00);
	SCCBWrite(0x90, 0x00);
	SCCBWrite(0x91, 0x00);
	SCCBWrite(0x96, 0x00);
	SCCBWrite(0x97, 0x30); // from 00 to 30 2012/11/9
	SCCBWrite(0x98, 0x20);
	SCCBWrite(0x99, 0x30);
	SCCBWrite(0x9a, 0x00);
	SCCBWrite(0x9a, 0x84);
	SCCBWrite(0x9b, 0x29);
	SCCBWrite(0x9c, 0x03);
	SCCBWrite(0x9d, 0x4c);
	SCCBWrite(0x9e, 0x3f);
	SCCBWrite(0xa2, 0x02);
	SCCBWrite(0xa4, 0x88);
	SCCBWrite(0xb0, 0x84);
	SCCBWrite(0xb1, 0x0c);
	SCCBWrite(0xb2, 0x0e);
	SCCBWrite(0xb3, 0x82);
	SCCBWrite(0xb8, 0x0a);
	SCCBWrite(0xc8, 0xf0);
	SCCBWrite(0xc9, 0x60);

	SCCBWrite(0x12, 0x04); // RGB
	SCCBWrite(0x8c, 0x00); // RGB444 disable
	SCCBWrite(0x40, 0x10); // RGB565

	_wait(500000);

	viewmode = 4;

	regbtn = *(volatile unsigned long *)GPI3_BASE;
	if((regbtn & 0x03) == 0x02) { // SW2が押された
		frame2Spi = MAXFRAME;
	} else if((regbtn & 0x03) == 0x01) { // SW3が押された
		viewmode = 3;
	}

	SetGpo3();
	_wait(500000);

	dispoff = 1;
	SetGpo3();

	for(k = frame2Spi; k < MAXFRAME; k++) {
		for(i = 0; i < 240; i+=4) { // Eraseはセクタ単位(4096)なので4ラインおきで十分
			SectorErase((512*(k+offset) + i)<<10);
			_wait(900);
			SectorErase((512*(k+offset)+256 + i)<<10);
			_wait(900);
		}
	}
	dispoff = 0;
	SetGpo3();
	while(1) {
    	if(frame2Spi < MAXFRAME) {//3) {
        	///////////////////////////////////////////////////////////
        	// MAXFRAME枚書くまでは動き検出
    		regmdet = (*(volatile unsigned long *)GPI3_BASE >> 19) & 0x3;
    		if(regmdet != 0) {
    			motionfound = 1;
    			FrameToSPI();
    		}
    		if(loop == 999999) {
    			if(motionfound == 0) {
    				if(toright == 0) VMOTOR_L = 1;
    				else VMOTOR_R = 1;
    				SetGpo3();
    				_wait(300000); // 2k is 1ms, 2M is 1s
    				VMOTOR_L = 0;
    				VMOTOR_R = 0;
    				SetGpo3();
    				if(toright == 0) {
    					if(angle < 2) angle++;
    					else toright = 1;
    				} else {
    					if(angle > -2) angle--;
    					else toright = 0;
    				}
    				_wait(4000000); // 2k is 1ms, 2M is 1s
    			}
    			motionfound = 0;
    			loop = 0;
    		}
    		else {
    			loop++;
    		}
    	}
    	else {
    		SeeButtons();
    		//////////////////////////////////////////////////////////
    		// MAXFRAME枚描いた後はプッシュボタンの処理
    		if(sw2pushed == 1) {
    			FrameFromSPI();
    		}
    	}
	}
	return 0;
}

