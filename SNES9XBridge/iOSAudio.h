#ifndef MeSNEmu_iOSAudio_h
#define MeSNEmu_iOSAudio_h

#ifdef __cplusplus
extern "C" {
#endif
  
// audio synchronization stuff
int SIAudioOffset();

// starts up the AudioQueue system
void SIDemuteSound(int buffersize);
// stops the AudioQueue system
void SIMuteSound(void);

#ifdef __cplusplus
}
#endif

#endif

