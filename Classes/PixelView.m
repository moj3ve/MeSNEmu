#import "PixelView.h"

#import "PixelLayer.h"

@implementation PixelView

- (void)updateBufferCropResWidth:(unsigned int)width height:(unsigned int)height
{
    [(PixelLayer*)self.layer updateBufferCropWidth:width height:height];
}

@end

#pragma mark -

@implementation PixelView(UIView)

- (void)drawRect:(CGRect)rect
{
    // override this to allow the CALayer to be invalidated and thus displaying the actual layer contents
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        // Initialization code
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

+ (Class)layerClass
{
    return [PixelLayer class];
}

@end
