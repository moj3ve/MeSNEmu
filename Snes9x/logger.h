#ifndef _LOGGER_H_
#define _LOGGER_H_

void S9xResetLogger(void);
void S9xCloseLogger(void);
void S9xVideoLogger(void *, int, int, int, int);
void S9xAudioLogger(void *, int);

#endif
