#import "SaveManager.h"

#import "../Snes9x/port.h"
#import "../Snes9x/snes9x.h"
#import "../Snes9x/snapshot.h"

#import "../Snes9xBridge/iOSAudio.h"


@implementation SaveManager(Privates)

+ (NSString*)pathForRunningStates
{
  static NSString* path = nil;
  @synchronized(self)
  {
    if(path == nil)
    {
      NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
      path = [[paths objectAtIndex:0] copy];
    }
  }
  return path;
}

+ (NSString*)pathForSaveStates
{
  static NSString* path = nil;
  @synchronized(self)
  {
    if(path == nil)
    {
      NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
      path = [[paths objectAtIndex:0] copy];
    }
  }
  return path;
}

extern "C" volatile int SI_EmulationDidPause;
extern "C" volatile int SI_AudioIsOnHold;

+ (void)saveStateForROMName:(NSString*)romFileName inSlot:(int)slot
{
  NSLog(@"EmulationDidPause %i", SI_EmulationDidPause);
  NSLog(@"AudioIsOnHold %i", SI_AudioIsOnHold);
  
  NSString* savePath = [SaveManager pathForSaveOfROMName:romFileName slot:slot];
  
  if(S9xFreezeGame([savePath UTF8String]))
    NSLog(@"Saved to %@", savePath);
  else
    NSLog(@"Failed to save to %@", savePath);
}

+ (void)loadStateForROMName:(NSString*)romFileName inSlot:(int)slot
{
  NSLog(@"EmulationDidPause %i", SI_EmulationDidPause);
  NSLog(@"AudioIsOnHold %i", SI_AudioIsOnHold);
  
  NSString* savePath = [SaveManager pathForSaveOfROMName:romFileName slot:slot];
  
  if([[NSFileManager defaultManager] fileExistsAtPath:savePath] == NO)
  {
    NSLog(@"Save file doesn't exist at: %@", savePath);
    return;
  }
  
  if(S9xUnfreezeGame([savePath UTF8String]))
    NSLog(@"Loaded from %@", savePath);
  else
    NSLog(@"Failed to load from %@", savePath);
}

@end

@implementation SaveManager

+ (NSString*)legacy_pathForRunningStates
{
  NSArray* paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
  return [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Saves"];
}

+ (NSString*)legacy_pathForSaveStates
{
  NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  return [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Saves"];
}

+ (NSString*)pathForSaveOfROMName:(NSString*)romFileName slot:(int)slot
{  
  NSString* saveFolderPath = nil;
  if(slot <= 0)
    saveFolderPath = [SaveManager pathForRunningStates];
  else
    saveFolderPath = [SaveManager pathForSaveStates];
  
  if([[NSFileManager defaultManager] fileExistsAtPath:saveFolderPath isDirectory:nil] == NO)
    [[NSFileManager defaultManager] createDirectoryAtPath:saveFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
  
  NSString* romFileNameWithoutExtension = [romFileName stringByDeletingPathExtension];
  NSString* saveFileName = [[romFileNameWithoutExtension stringByAppendingPathExtension:[NSString stringWithFormat:@"%03d", slot]] stringByAppendingPathExtension:@"frz"];
  return [saveFolderPath stringByAppendingPathComponent:saveFileName];
}

+ (BOOL)hasStateForROMNamed:(NSString*)romFileName slot:(int)slot
{
  NSString* path = [SaveManager pathForSaveOfROMName:romFileName slot:slot];
  return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

+ (void)saveRunningStateForROMNamed:(NSString*)romFileName
{
  [SaveManager saveStateForROMName:romFileName inSlot:0];
}
+ (void)loadRunningStateForROMNamed:(NSString*)romFileName
{
  [SaveManager loadStateForROMName:romFileName inSlot:0];
}

+ (void)saveStateForROMNamed:(NSString*)romFileName slot:(int)slot
{
  if(slot <= 0)
    return;
  
  [SaveManager saveStateForROMName:romFileName inSlot:slot];
}
+ (void)loadStateForROMNamed:(NSString*)romFileName slot:(int)slot
{
  if(slot <= 0)
    return;
  
  [SaveManager loadStateForROMName:romFileName inSlot:slot];
}

@end
