#import "iCadeReaderView.h"


typedef enum _BTControllerType
{
    BTControllerType_Custom = 0,
    BTControllerType_iCade = 1,
    BTControllerType_iCade8Bitty = 2,
    BTControllerType_nControl = 3,
    BTControllerType_8BitdoFC30 = 4,
    BTControllerType_8BitdoNES30 = 5,
    BTControllerType_IPEGAPG9025 = 6
}   BTControllerType;

@interface BTControllerView : iCadeReaderView {
    BTControllerType _controllerType;
}

- (void)setOnStateString:(const char*)onState offStateString:(const char*)offState;

@property (nonatomic) BTControllerType controllerType;

+ (NSArray*)supportedControllers;

@end
