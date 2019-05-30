#import "iCadeReaderView.h"


typedef enum _BTControllerType
{
  BTControllerType_Custom = 0,
  BTControllerType_iCade = 1,
  BTControllerType_iCade8Bitty = 2,
  BTControllerType_NControl = 3,
  BTControllerType_EXHybrid = 4,
  BTControllerType_SteelSeriesFree = 5,
  BTControllerType_8BitdoFC30 = 6,
  BTControllerType_iMpulse = 7,
  BTControllerType_8BitdoNES30 = 8,
  BTControllerType_IPEGAPG9025 = 9,
  BTControllerType_Snakebyteidroidcon = 10
} BTControllerType;

@interface BTControllerView : iCadeReaderView {
  BTControllerType _controllerType;
}

- (void)setOnStateString:(const char*)onState offStateString:(const char*)offState;

@property (nonatomic) BTControllerType controllerType;

+ (NSArray*)supportedControllers;

@end
