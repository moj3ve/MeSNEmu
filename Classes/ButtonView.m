#import "ButtonView.h"

#import "../Snes9xBridge/Snes9xMain.h"

@implementation ButtonView(Privates)

- (void)handleTouches:(NSSet*)touches
{
    UITouch* touch = [touches anyObject];
    if(touch.phase == UITouchPhaseCancelled || touch.phase == UITouchPhaseEnded || touch == nil)
        SISetControllerReleaseButton(_button);
    else
        SISetControllerPushButton(_button);
}

@end

@implementation ButtonView

@synthesize button = _button;
@synthesize label = _label;

@end

#pragma mark -

@implementation ButtonView(UIView)

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.userInteractionEnabled = YES;
        //self.backgroundColor = [UIColor whiteColor];
        self.contentMode = UIViewContentModeCenter;
        
        _label = [[UILabel alloc] initWithFrame:(CGRect){0,0, frame.size}];
        _label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _label.backgroundColor = nil;
        _label.opaque = NO;
        _label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_label];
    }
    return self;
}

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    [self handleTouches:touches];
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
    [self handleTouches:touches];
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
    [self handleTouches:touches];
}

- (void)touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event
{
    [self handleTouches:touches];
}

@end

#pragma mark -

@implementation ButtonView(NSObject)

- (void)dealloc
{
    [_label release];
    _label = nil;
    
    [super dealloc];
}

@end
