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

void SetGpo3() {
	*(volatile unsigned long *)(GPO3_BASE)
			= (VMOTOR_R << 25) + (VMOTOR_L << 24) + (pix2logic << 8) + (pixwr << 7) + (pixrd << 6) + (pixstb << 5)
			+ (dispoff << 4) + viewmode;
}

void SetGpo4() {
	*(volatile unsigned long *)(GPO4_BASE)
			= (CARD_DAT3 << 2) + (CARD_CLK << 1) + (CARD_CMD << 0);
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
 // clock dir is output
	SetClockDir(1);
	SetClockBit(0);
// data dir is output
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
// clock dir is output
	SetClockDir(1);
	SetClockBit(0);
	_wait(10);
	SetClockBit(1);
// data dir is input
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
// data dir is output
	SetDataDir(1);
	SetDataBit(1);
// clock dir is output
	SetClockDir(1);
	SetClockBit(1);
	_wait(10);
	SetDataBit(0);
	_wait(10);
	SetClockBit(0);
}

void SCCBStop() {
	_wait(10);
// data dir is output
	SetDataDir(1);
	SetDataBit(0);
// clock dir is output
	SetClockDir(1);
	SetClockBit(1);
	_wait(10);
	SetDataBit(1);
	_wait(10);
// data dir is input
	SetDataDir(0);
// clock dir is input
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

int main()
{
	unsigned long reg1;

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

	reg1 = *(volatile unsigned long *)GPI3_BASE;
	if((reg1 & 0x03) == 0x02) { // SW2が押された
	} else if((reg1 & 0x03) == 0x01) { // リセット時にSW3が押されたら動き成分表示モード
		viewmode = 3;
	}

	SetGpo3();
	_wait(500000);

	while(1) {
    	if(((*(volatile unsigned long *)GPI3_BASE >> 19) & 0x3) == 0x1) { // only mdet_l is 1
    			VMOTOR_R = 1;
    	} else if(((*(volatile unsigned long *)GPI3_BASE >> 19) & 0x3) == 0x2) { // only mdet_r is 1
    			VMOTOR_L = 1;
    	} else {
				VMOTOR_L = 0;
				VMOTOR_R = 0;
		}
    	if(VMOTOR_L == 1 || VMOTOR_R == 1) {
    			SetGpo3();
    			_wait(300000); // 2k is 1ms, 2M is 1s
				VMOTOR_L = 0;
				VMOTOR_R = 0;
    			SetGpo3();
    			_wait(4000000); // 2k is 1ms, 2M is 1s
   		}

	}
	return 0;
}
