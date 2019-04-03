#ifndef _hq2x_h_
#define _hq2x_h_

bool8 S9xBlitHQ2xFilterInit (void);
void S9xBlitHQ2xFilterDeinit (void);
void HQ2X_16 (uint8 *, uint32, uint8 *, uint32, int, int);
void HQ3X_16 (uint8 *, uint32, uint8 *, uint32, int, int);
void HQ4X_16 (uint8 *, uint32, uint8 *, uint32, int, int);

#endif
