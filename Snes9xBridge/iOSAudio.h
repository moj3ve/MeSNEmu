#ifndef MeSNEmu_iOSAudio_h
#define MeSNEmu_iOSAudio_h

#ifdef __cplusplus
extern "C" {
#endif
    
    int SIAudioOffset();
    void SIDemuteSound(int buffersize);
    void SIMuteSound(void);
    
#ifdef __cplusplus
}
#endif

#endif
