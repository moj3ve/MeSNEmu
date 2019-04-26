#import "iCadeReaderView.h"


typedef enum _BTControllerType
{
  BTControllerType_Custom = 0,
  BTControllerType_iCade = 1,
  BTControllerType_iCade8Bitty = 2,
  BTControllerType_EXHybrid = 3,
  BTControllerType_SteelSeriesFree = 4,
  BTControllerType_8BitdoFC30 = 5,
  BTControllerType_iMpulse = 6,
  BTControllerType_8BitdoNES30 = 7,
  BTControllerType_IPEGAPG9025 = 8,
  BTControllerType_Snakebyteidroidcon = 9
} BTControllerType;

@interface BTControllerView : iCadeReaderView {
  BTControllerType _controllerType;
}

- (void)setOnStateString:(const char*)onState offStateString:(const char*)offState;

@property (nonatomic) BTControllerType controllerType;

+ (NSArray*)supportedControllers;

@end
