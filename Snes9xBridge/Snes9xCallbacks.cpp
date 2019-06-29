#include "Snes9xCallbacks.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/time.h>
#include <libgen.h>

#include "../Snes9x/snes9x.h"
#include "../Snes9x/memmap.h"
#include "../Snes9x/apu/apu.h"
#include "../Snes9x/conffile.h"
#include "../Snes9x/controls.h"
#include "../Snes9x/display.h"

#include "Snes9xMain.h"
#include "iOSAudio.h"

#define MAX_MESSAGE_LEN (36 * 3)

#pragma mark Defines

#undef TIMER_DIFF
#define TIMER_DIFF(a, b) ((((a).tv_sec - (b).tv_sec) * 1000000) + (a).tv_usec - (b).tv_usec)

#pragma mark - External Forward Declarations

extern void SIFlipFramebuffer(int width, int height);

extern int SI_SoundOn;

#pragma mark - Global Variables

struct timeval SI_NextFrameTime = { 0, 0 };
int SI_FrameTimeDebt = 0;
int SI_SleptLastFrame = 0;

#pragma mark - SNES9X Callbacks

void S9xExit()
{
}

void S9xParsePortConfig(ConfigFile &a, int pass)
{
    
}

void S9xExtraUsage (void)
{
    
}

void S9xParseArg (char** a, int &b, int c)
{
    
}

void S9xMessage(int /*type */, int /*number */, const char *message)
{
    printf("%s", message);
}

void S9xAutoSaveSRAM()
{
    SISaveSRAM();
}

void S9xToggleSoundChannel(int c)
{
    static int sound_switch = 255;
    
    if (c == 8)
        sound_switch = 255;
    else
        sound_switch ^= 1 << c;
    
    S9xSetSoundControl (sound_switch);
}

bool8 S9xOpenSoundDevice(void)
{
    if(SI_SoundOn)
        return TRUE;
    else
        return FALSE;
}

void S9xInitSync()
{
    
}

void S9xSyncSpeed() {
    struct timeval now;
    
    // calculate lag
    gettimeofday (&now, NULL);
    
    if (SI_NextFrameTime.tv_sec == 0)
    {
        SI_NextFrameTime = now;
        ++SI_NextFrameTime.tv_usec;
    }
    int lag = TIMER_DIFF (now, SI_NextFrameTime);
    SI_FrameTimeDebt += lag-(int)Settings.FrameTime;
    //printf("Frame Time: %i. Should be less than %i\n", lag, (int)Settings.FrameTime);
    
    // if we're  going too fast
    bool sleptThis = 0;
    if(SI_FrameTimeDebt < 0 && IPPU.SkippedFrames == 0)
        //if(debt+(int)Settings.FrameTime < 0 && IPPU.SkippedFrames == 0)
    {
        int audioOffset = SIAudioOffset();
        if(-SI_FrameTimeDebt+audioOffset > 0)
            usleep(-SI_FrameTimeDebt+audioOffset);
        //usleep(-(debt+(int)Settings.FrameTime));
        SI_FrameTimeDebt = 0;
        sleptThis = 1;
    }
    
    // if we're going too slow or fixed frameskip
    if (Settings.SkipFrames == AUTO_FRAMERATE && !Settings.SoundSync)
    {
        // auto frameskip
        if(SI_FrameTimeDebt > (int)Settings.FrameTime*10 || IPPU.SkippedFrames >= 2)
            SI_FrameTimeDebt = 0;
        
        if(SI_FrameTimeDebt > 0 && SI_SleptLastFrame == 0)
        {
            IPPU.RenderThisFrame = 0;
            IPPU.SkippedFrames++;
        }
        else
        {
            IPPU.RenderThisFrame = 1;
            IPPU.SkippedFrames = 0;
        }
    }
    else
    {
        // frameskip a set number of frames
        if(IPPU.SkippedFrames < Settings.SkipFrames)
        {
            IPPU.RenderThisFrame = 0;
            IPPU.SkippedFrames++;
        }
        else
        {
            IPPU.RenderThisFrame = 1;
            IPPU.SkippedFrames = 0;
        }
    }
    
    if(sleptThis == 1)
        SI_SleptLastFrame = 1;
    else
        SI_SleptLastFrame = 0;
    
    //next_frame_time = now;
    gettimeofday (&SI_NextFrameTime, NULL);
}

bool8 S9xInitUpdate()
{
    return (TRUE);
}

bool8 S9xDoScreenshot (int Width, int Height)
{
    return true;
}

bool8 S9xOpenSnapshotFile (const char* fname, bool8 read_only, STREAM* file)
{
    if (read_only)
    {
        if (0 != (*file = OPEN_STREAM(fname, "rb")))
            return (true);
    }
    else
    {
        if (0 != (*file = OPEN_STREAM(fname, "wb")))
            return (true);
    }
    
    return (false);
}

void S9xCloseSnapshotFile (STREAM file)
{
    CLOSE_STREAM(file);
}

bool8 S9xDeinitUpdate(int Width, int Height)
{
    SIFlipFramebuffer(Width, Height);
    return (TRUE);
}

bool8 S9xContinueUpdate(int Width, int Height)
{
    return (TRUE);
}

void S9xSetPalette()
{
    return;
}

void S9xHandlePortCommand(s9xcommand_t cmd, int16 data1, int16 data2)
{
    return;
}

bool S9xPollButton(uint32 id, bool * pressed)
{
    return 0;
}

bool S9xPollAxis(uint32 id, int16 * value)
{
    return 0;
}

bool S9xPollPointer(uint32 id, int16 * x, int16 * y)
{
    return 0;
}

const char *S9xChooseFilename(bool8 read_only)
{
    return NULL;
}

const char * S9xChooseMovieFilename(bool8 read_only)
{
    return NULL;
}

const char * S9xGetDirectory(enum s9x_getdirtype dirtype)
{
    static int index = 0;
    static char path[4][PATH_MAX + 1];
    
    char    inExt[16];
    char    drive[_MAX_DRIVE + 1], dir[_MAX_DIR + 1], fname[_MAX_FNAME + 1], ext[_MAX_EXT + 1];
    
    index++;
    if (index > 3)
        index = 0;
    
    switch (dirtype)
    {
        case SNAPSHOT_DIR:        strcpy(inExt, ".frz");    break;
        case SRAM_DIR:            strcpy(inExt, ".srm");    break;
        case SCREENSHOT_DIR:    strcpy(inExt, ".png");    break;
        case SPC_DIR:            strcpy(inExt, ".spc");    break;
        case CHEAT_DIR:            strcpy(inExt, ".cht");    break;
        case BIOS_DIR:            strcpy(inExt, ".bio");    break;
        case LOG_DIR:            strcpy(inExt, ".log");    break;
        default:                strcpy(inExt, ".xxx");    break;
    }
    
    _splitpath(S9xGetFilename(inExt, dirtype), drive, dir, fname, ext);
    _makepath(path[index], drive, dir, "", "");
    
    int    l = strlen(path[index]);
    if (l > 1)
        path[index][l - 1] = 0;
    
    return (path[index]);
}

const char * S9xGetFilename(const char *ex, enum s9x_getdirtype dirtype)
{
    static char filename [PATH_MAX + 1];
    char drive [_MAX_DRIVE + 1];
    char dir [_MAX_DIR + 1];
    char fname [_MAX_FNAME + 1];
    char ext [_MAX_EXT + 1];
    
    _splitpath (Memory.ROMFilename, drive, dir, fname, ext);
    strcpy (filename, "");
    strcat (filename, SLASH_STR);
    strcat (filename, fname);
    strcat (filename, ex);
    return (filename);
}

const char * S9xGetFilenameInc(const char *e, enum s9x_getdirtype dirtype)
{
    S9xMessage (0,0,"get filename inc");
    return e;
}

const char * S9xBasename(const char *name)
{
    static char    s[PATH_MAX + 1];
    
    strncpy(s, name, PATH_MAX + 1);
    s[PATH_MAX] = 0;
    
    size_t    l = strlen(s);
    
    for (unsigned int i = 0; i < l; i++)
    {
        if (s[i] < 32 || s[i] >= 127)
            s[i] = '_';
    }
    
    return (basename(s));
}

const char * S9xStringInput (const char * s)
{
    return s;
}

void _splitpath(char const *buf, char *drive, char *dir, char *fname, char *ext)
{
    *drive = 0;
    
    char const * slash = strrchr (buf, '/');
    if (!slash)
        slash = strrchr (buf, '\\');
    
    char const * dot = strrchr (buf, '.');
    
    if (dot && slash && dot < slash)
        dot = NULL;
    
    if (!slash)
    {
        strcpy (dir, "");
        strcpy (fname, buf);
        if (dot)
        {
            *(fname + (dot - buf)) = 0;
            strcpy (ext, dot + 1);
        }
        else
            strcpy (ext, "");
    }
    else
    {
        strcpy (dir, buf);
        *(dir + (slash - buf)) = 0;
        strcpy (fname, slash + 1);
        if (dot)
        {
            *(fname + (dot - slash) - 1) = 0;
            strcpy (ext, dot + 1);
        }
        else
            strcpy (ext, "");
    }
}

void _makepath(char *filename, const char *drive, const char *dir, const char *fname, const char *ext)
{
    if (dir && *dir)
    {
        strcpy (filename, dir);
        strcat (filename, "/");
    }
    else
        *filename = 0;
    strcat (filename, fname);
    if (ext && *ext)
    {
        strcat (filename, ".");
        strcat (filename, ext);
    }
}

int access(const char *pathname, int mode)
{
    return 1;
}
