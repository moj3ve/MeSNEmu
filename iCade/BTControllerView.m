#import "BTControllerView.h"

NSArray* BTSupportedControllers = nil;

@implementation BTControllerView(Privates)

- (void)BT_setOnStateString:(const char*)onState offStateString:(const char*)offState
{
  int mapSize = 12*sizeof(char);
  memcpy(_on_states,  onState, mapSize);
  memcpy(_off_states, offState, mapSize);
}

@end

#pragma mark -

@implementation BTControllerView

- (void)setOnStateString:(const char*)onState offStateString:(const char*)offState
{
  @synchronized(self)
  {
    self.controllerType = BTControllerType_Custom;
    [self BT_setOnStateString:onState offStateString:offState];
  }
}

@synthesize controllerType = _controllerType;
- (void)setControllerType:(BTControllerType)controllerType
{
  if(_controllerType != controllerType)
  {
    _controllerType = controllerType;
    
    for(NSArray* controller in [BTControllerView supportedControllers])
    {
      if([[controller objectAtIndex:1] intValue] == _controllerType)
      {
        char onString[13];
        char offString[13];
        memset(onString, '.', 12*sizeof(char));
        memset(offString, '.', 12*sizeof(char));
        onString[12] = '\0';
        offString[12] = '\0';
        
        NSString* controllerString = [controller objectAtIndex:2];
        for(NSUInteger i=0; i<[controllerString length]; i++)
        {
          if(i%2==0)
            onString[i/2] = [controllerString characterAtIndex:i];
          else
            offString[i/2] = [controllerString characterAtIndex:i];
        }
        
        /*NSLog(@"on:  %s", onString);
        NSLog(@"off: %s", offString);
        NSLog(@"Original: %@", controllerString);*/
        
        /*char* customOnString = "wdxa..lkoyhj";
        char* customOffString = "eczq..vpgtrn";
        NSMutableString* rebuilt = [NSMutableString string];
        for(NSUInteger i=0; i<24; i++)
        {
          unichar character;
          if(i%2==0)
            character = customOnString[i/2];
          else
            character = customOffString[i/2];
          [rebuilt appendString:[NSString stringWithCharacters:&character length:1]];
        }
        NSLog(@"rebuilt:  %@", rebuilt);*/
        
        [self BT_setOnStateString:onString
                     offStateString:offString];
        break;
      }
    }
  }
}

+ (NSArray*)supportedControllers
{
  @synchronized(self)
  {
    if(BTSupportedControllers == nil)
    {
      // original SNES layout
      // L             R
      //               X
      //     SE ST   Y   A
      //               B
      
      // map order: UP RT DN LT SE ST  Y  B  X  A  L  R
      
      BTSupportedControllers = [[@[                                     
                                    // iCade
                                    @[@"iCade",
                                      [NSNumber numberWithInt:BTControllerType_iCade],
                                      @"wedcxzaqythrufjnimkpoglv"],
                                    
                                    // iCade 8-Bitty
                                    @[@"iCade 8-Bitty",
                                      [NSNumber numberWithInt:BTControllerType_iCade8Bitty],
                                      @"wedcxzaqytufimkpoglvhrjn"],
                                    
                                    // nControl
                                    @[@"nControl",
                                      [NSNumber numberWithInt:BTControllerType_nControl],
                                      @""],
                                    
                                    // 8Bitdo FC30
                                    @[@"8Bitdo FC30",
                                      [NSNumber numberWithInt:BTControllerType_8BitdoFC30],
                                      @"wedcxzaqytufimkpoglvhrjn"],
                                    
                                    // 8Bitdo NES30
                                    @[@"8Bitdo NES30",
                                      [NSNumber numberWithInt:BTControllerType_8BitdoNES30],
                                      @"wedcxzaqlvogythrjnufkpim"],
                                    
                                    // IPEGA PG-9025
                                    @[@"IPEGA PG-9025",
                                      [NSNumber numberWithInt:BTControllerType_IPEGAPG9025],
                                      @"wedcxzaqoglvjnufythrimkp"]
                                    
                                   ] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                                     return [[obj1 firstObject] compare:[obj2 firstObject]];
                                   }] copy];
    }
  }
  return BTSupportedControllers;
}

@end

#pragma mark -

@implementation BTControllerView(UIView)

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if(self)
  {
    // Initialization code
  }
  return self;
}

@end
