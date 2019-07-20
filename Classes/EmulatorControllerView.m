#import "EmulatorControllerView.h"

#import "../iCade/BTControllerView.h"
#import "../Snes9xBridge/Snes9xMain.h"

#import "ButtonView.h"
#import "DPadView.h"
#import "PixelView.h"
#import "PixelLayer.h"
#import "SettingsController.h"

@interface EmulatorControllerView(Privates)

@end

#pragma mark -

@implementation EmulatorControllerView(Privates)

#pragma mark UI Creation Shortcuts

- (ButtonView*)smallButtonWithButton:(int)buttonMap
{
    int width = 44;
    int height = 24;
    ButtonView* button = [[ButtonView alloc] initWithFrame:(CGRect){0,0, width,height}];
    button.image = [UIImage imageNamed:@"ButtonWide.png"];
    button.label.textColor = [UIColor colorWithWhite:1 alpha:0.75];
    button.label.shadowColor = [UIColor colorWithWhite:0 alpha:0.35];
    button.label.shadowOffset = CGSizeMake(0, -1);
    button.label.font = [UIFont systemFontOfSize:10];
    button.button = buttonMap;
    if(buttonMap == SI_BUTTON_START) {
        button.label.text = NSLocalizedString(@"START", nil);
    }
    else if(buttonMap == SI_BUTTON_SELECT) {
        button.label.text = NSLocalizedString(@"SELECT", nil);
    }
    return [button autorelease];
}

- (ButtonView*)buttonWithButton:(int)buttonMap
{
    BOOL rygbButtons = [[NSUserDefaults standardUserDefaults] boolForKey:kSettingsRYGBButtons];
    int side = 60;
    side = 70;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        side = 70;
    }
    ButtonView* button = [[ButtonView alloc] initWithFrame:(CGRect){0,0, side,side}];
    button.button = buttonMap;
    button.label.font = [UIFont boldSystemFontOfSize:27.0];
    if(buttonMap == SI_BUTTON_A) {
        if (rygbButtons == YES) {
            button.label.textColor = [UIColor colorWithRed:136/255.0 green:140/255.0 blue:148/255.0 alpha:0.75];
        }
        else {
            button.label.textColor = [UIColor colorWithRed:63/255.0 green:32/255.0 blue:127/255.0 alpha:0.75];
        }
        button.label.shadowColor = [UIColor colorWithWhite:1 alpha:0.25];
        button.label.shadowOffset = CGSizeMake(0, 1);
        button.label.text = NSLocalizedString(@"A", nil);
        if (rygbButtons == YES) {
            button.image = [UIImage imageNamed:@"RedButton.png"];
        }
        else {
            button.image = [UIImage imageNamed:@"PurpleButton.png"];
        }
    }
    else if(buttonMap == SI_BUTTON_B) {
        if (rygbButtons == YES) {
            button.label.textColor = [UIColor colorWithRed:136/255.0 green:140/255.0 blue:148/255.0 alpha:0.75];
        }
        else {
            button.label.textColor = [UIColor colorWithRed:63/255.0 green:32/255.0 blue:127/255.0 alpha:0.75];
        }
        button.label.shadowColor = [UIColor colorWithWhite:1 alpha:0.25];
        button.label.shadowOffset = CGSizeMake(0, 1);
        button.label.text = NSLocalizedString(@"B", nil);
        if (rygbButtons == YES) {
            button.image = [UIImage imageNamed:@"YellowButton.png"];
        }
        else {
            button.image = [UIImage imageNamed:@"PurpleButton.png"];
        }
    }
    else if(buttonMap == SI_BUTTON_X) {
        if (rygbButtons == YES) {
            button.label.textColor = [UIColor colorWithRed:136/255.0 green:140/255.0 blue:148/255.0 alpha:0.75];
        }
        else {
            button.label.textColor = [UIColor colorWithRed:122/255.0 green:101/255.0 blue:208/255.0 alpha:0.75];
        }
        button.label.shadowColor = [UIColor colorWithWhite:1 alpha:0.25];
        button.label.shadowOffset = CGSizeMake(0, 1);
        button.label.text = NSLocalizedString(@"X", nil);
        if (rygbButtons == YES) {
            button.image = [UIImage imageNamed:@"BlueButton.png"];
        }
        else {
            button.image = [UIImage imageNamed:@"LightPurpleButton.png"];
        }
    }
    else if(buttonMap == SI_BUTTON_Y) {
        if (rygbButtons == YES) {
            button.label.textColor = [UIColor colorWithRed:136/255.0 green:140/255.0 blue:148/255.0 alpha:0.75];
        }
        else {
            button.label.textColor = [UIColor colorWithRed:122/255.0 green:101/255.0 blue:208/255.0 alpha:0.75];
        }
        button.label.shadowColor = [UIColor colorWithWhite:1 alpha:0.25];
        button.label.shadowOffset = CGSizeMake(0, 1);
        button.label.text = NSLocalizedString(@"Y", nil);
        if (rygbButtons == YES) {
            button.image = [UIImage imageNamed:@"GreenButton.png"];
        }
        else {
            button.image = [UIImage imageNamed:@"LightPurpleButton.png"];
        }
    }
    else if(buttonMap == SI_BUTTON_L || buttonMap == SI_BUTTON_R) {
        button.image = [UIImage imageNamed:@"LRButton.png"];
        button.label.textColor = [UIColor colorWithRed:136/255.0 green:140/255.0 blue:148/255.0 alpha:0.75];
        button.label.shadowColor = [UIColor colorWithWhite:1 alpha:0.25];
        button.label.shadowOffset = CGSizeMake(0, 1);
        if(buttonMap == SI_BUTTON_L) {
            button.label.text = NSLocalizedString(@"L", nil);
        }
        else if(buttonMap == SI_BUTTON_R) {
            button.label.text = NSLocalizedString(@"R", nil);
        }
    }
    return [button autorelease];
}

@end

#pragma mark -

@implementation EmulatorControllerView

@synthesize optionsButton = _optionsButton;
@synthesize iCadeControlView = _iCadeControlView;
@synthesize viewMode = _viewMode;
- (void)setViewMode:(EmulatorControllerViewMode)viewMode
{
    if(_viewMode != viewMode)
    {
        _viewMode = viewMode;
        [self setNeedsLayout];
    }
}

- (void)setControlsHidden:(BOOL)value animated:(BOOL)animated
{
    if(_hideUI != value)
    {
        _hideUI = value;
        [self setNeedsLayout];
        if(animated == YES)
            [UIView animateWithDuration:0.3 animations:^{
                [self layoutIfNeeded];
            }];
        else
            [self layoutIfNeeded];
    }
}

- (void)setMinMagFilter:(NSString*)filter
{
    _screenView.layer.minificationFilter = filter;
    _screenView.layer.magnificationFilter = filter;
}

- (void)setPrimaryBuffer
{
    SISetScreen(_imageBuffer);
}

- (void)flipFrontBufferWidth:(int)width height:(int)height
{
    if(_imageBuffer == nil || _565ImageBuffer == nil)
        return;
    
    [_screenView updateBufferCropResWidth:width height:height];
    
    if(((PixelLayer*)_screenView.layer).displayMainBuffer == YES)
    {
        SISetScreen(_imageBufferAlt);
        
        [_screenView setNeedsDisplay];
        
        ((PixelLayer*)_screenView.layer).displayMainBuffer = NO;
    }
    else
    {
        SISetScreen(_imageBuffer);
        
        [_screenView setNeedsDisplay];
        
        ((PixelLayer*)_screenView.layer).displayMainBuffer = YES;
    }
}

@end

#pragma mark -

@implementation EmulatorControllerView(UIView)

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.multipleTouchEnabled = YES;
        _viewMode = EmulatorControllerViewModeNormal;
        
        // screen
        _screenView = [[PixelView alloc] initWithFrame:(CGRect){0,0,10,10}];
        _screenView.userInteractionEnabled = NO;
        [self addSubview:_screenView];
        
        // start / select buttons
        _startButton = [[self smallButtonWithButton:SI_BUTTON_START] retain];
        [self addSubview:_startButton];
        
        _selectButton = [[self smallButtonWithButton:SI_BUTTON_SELECT] retain];
        [self addSubview:_selectButton];
        
        // menu button
        _optionsButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [_optionsButton setBackgroundImage:[UIImage imageNamed:@"ButtonWide.png"] forState:UIControlStateNormal];
        [_optionsButton setTitle:NSLocalizedString(@"MENU", nil) forState:UIControlStateNormal];
        [_optionsButton setTitleColor:[UIColor colorWithWhite:1 alpha:0.75] forState:UIControlStateNormal];
        [_optionsButton setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.35] forState:UIControlStateNormal];
        _optionsButton.titleLabel.shadowOffset = CGSizeMake(0, -1);
        _optionsButton.titleLabel.font = [UIFont systemFontOfSize:10];
        [self addSubview:_optionsButton];
        
        // ABXY buttons
        _aButton = [[self buttonWithButton:SI_BUTTON_A] retain];
        [self addSubview:_aButton];
        
        _bButton = [[self buttonWithButton:SI_BUTTON_B] retain];
        [self addSubview:_bButton];
        
        _xButton = [[self buttonWithButton:SI_BUTTON_X] retain];
        [self addSubview:_xButton];
        
        _yButton = [[self buttonWithButton:SI_BUTTON_Y] retain];
        [self addSubview:_yButton];
        
        // L/R buttons
        _lButton = [[self buttonWithButton:SI_BUTTON_L] retain];
        [self addSubview:_lButton];
        
        _rButton = [[self buttonWithButton:SI_BUTTON_R] retain];
        [self addSubview:_rButton];
        
        // d-pad
        _dPadView = [[DPadView alloc] initWithFrame:(CGRect){0,0,10,10}];
        [self addSubview:_dPadView];
        
        // iCade support
        _iCadeControlView = [[BTControllerView alloc] initWithFrame:CGRectZero];
        [self addSubview:_iCadeControlView];
        _iCadeControlView.active = YES;
        
        // creating our buffers
        _bufferWidth = 512;
        _bufferHeight = 480;
        _bufferHeightExtended = 480;
        
        // RGBA888 format
        unsigned short defaultComponentCount = 4;
        unsigned short bufferBitsPerComponent = 8;
        unsigned int pixelSizeBytes = (_bufferWidth*bufferBitsPerComponent*defaultComponentCount)/8/_bufferWidth;
        if(pixelSizeBytes == 0)
            pixelSizeBytes = defaultComponentCount;
        unsigned int bufferBytesPerRow = _bufferWidth*pixelSizeBytes;
        CGBitmapInfo bufferBitmapInfo = kCGImageAlphaNoneSkipLast;
        
        // BGR 555 format (something weird)
        defaultComponentCount = 3;
        bufferBitsPerComponent = 5;
        pixelSizeBytes = 2;
        bufferBytesPerRow = _bufferWidth*pixelSizeBytes;
        bufferBitmapInfo = kCGImageAlphaNoneSkipFirst|kCGBitmapByteOrder16Little;
        
        if(_imageBuffer == nil)
        {
            _imageBuffer = (unsigned char*)calloc(_bufferWidth*_bufferHeightExtended, pixelSizeBytes);
        }
        if(_imageBufferAlt == nil)
        {
            _imageBufferAlt = (unsigned char*)calloc(_bufferWidth*_bufferHeightExtended, pixelSizeBytes);
        }
        if(_565ImageBuffer == nil)
            _565ImageBuffer = (unsigned char*)calloc(_bufferWidth*_bufferHeightExtended, 2);
        
        [(PixelLayer*)_screenView.layer setImageBuffer:_imageBuffer
                                                 width:_bufferWidth
                                                height:_bufferHeight
                                      bitsPerComponent:bufferBitsPerComponent
                                           bytesPerRow:bufferBytesPerRow
                                            bitmapInfo:bufferBitmapInfo];
        [(PixelLayer*)_screenView.layer addAltImageBuffer:_imageBufferAlt];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    BOOL fullScreen = [[NSUserDefaults standardUserDefaults] boolForKey:kSettingsFullScreen];
    BOOL darkMode = [[NSUserDefaults standardUserDefaults] boolForKey:kSettingsDarkMode];
    UIColor* plasticColor = [UIColor colorWithRed:195/255.0 green:198/255.0 blue:205/255.0 alpha:1];
    UIColor* blackColor = [UIColor blackColor];
    if(_viewMode == EmulatorControllerViewModeScreenOnly)
        plasticColor = [UIColor blackColor];
    else if(_viewMode == EmulatorControllerViewModeControllerOnly)
        blackColor = plasticColor;
    int originalWidth = 256;
    int originalHeight = 224;
    int width = originalWidth;
    int height = originalHeight;
    int screenOffsetY = 0;
    CGSize size = self.bounds.size;
    int screenBorderX = 5;
    int screenBorderY = 30;
    int buttonSpacing = 7;
    int smallButtonsOriginX = 0;
    int smallButtonsOriginY = 0;
    int smallButtonsSpacing = 5;
    BOOL smallButtonsVertical = YES;
    float controlsAlpha = 1;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        screenBorderX = 90;
        screenBorderY = 90;
    }
    
    if(size.height > size.width)
    {
        // portrait
        if (darkMode == YES) {
            self.backgroundColor = [UIColor colorWithRed:0.07 green:0.07 blue:0.08 alpha:1.0];
        }
        else {
            self.backgroundColor = plasticColor;
        }
        
        if(_viewMode == EmulatorControllerViewModeControllerOnly)
        {
            // portrait - controller mode
            width = height = 0;
            int dpadHeight = _dPadView.image.size.height;
            screenBorderY = size.height*0.5-dpadHeight*0.5;
            smallButtonsVertical = NO;
            smallButtonsOriginY = size.height-smallButtonsSpacing-_startButton.image.size.height;
            smallButtonsOriginX = size.width*0.5-_startButton.image.size.width*1.5-smallButtonsSpacing;
        }
        else
        {
            // portrait - screen or screen+controller mode
            if(fullScreen == YES)
            {
                // portrait - full screen
                width = size.width;
                height = (int)(width/(double)originalWidth*originalHeight);
                
                if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
                {
                    smallButtonsVertical = NO;
                    smallButtonsOriginX = smallButtonsSpacing;
                    smallButtonsOriginY = height+smallButtonsSpacing;
                }
                else
                {
                    smallButtonsVertical = YES;
                    smallButtonsOriginX = (size.width-_startButton.frame.size.width)/2;
                    smallButtonsOriginY = size.height-_dPadView.image.size.height;
                }
            }
            else
            {
                // portrait - 1:1
                if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
                {
                    screenOffsetY = (int)((size.width-width)/4);
                    smallButtonsVertical = NO;
                    smallButtonsOriginX = (size.width-(_startButton.frame.size.width*3+smallButtonsSpacing*2))/2;
                    smallButtonsOriginY = screenOffsetY+height+smallButtonsSpacing;
                }
                else
                {
                    screenOffsetY = -2;
                    smallButtonsVertical = YES;
                    smallButtonsOriginX = (size.width-_startButton.frame.size.width)/2;
                    smallButtonsOriginY = size.height-_dPadView.image.size.height;
                }
            }
        }
    }
    else
    {
        // landscape
        if(_viewMode == EmulatorControllerViewModeControllerOnly)
        {
            // landscape - controller mode
            self.backgroundColor = plasticColor;
            width = height = 0;
            int dpadHeight = _dPadView.image.size.height;
            screenBorderY = size.height*0.5-dpadHeight*0.5;
            smallButtonsVertical = NO;
            smallButtonsOriginY = size.height-smallButtonsSpacing-_startButton.image.size.height;
            smallButtonsOriginX = size.width*0.5-_startButton.image.size.width*1.5-smallButtonsSpacing;
            if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
                screenBorderX = 30;
        }
        else
        {
            // landscape - screen only or screen+controller mode
            if(fullScreen == YES)
            {
                // landscape - full screen
                self.backgroundColor = blackColor;
                
                height = size.height;
                width = (int)(height/(double)originalHeight*originalWidth);
                
                smallButtonsVertical = YES;
                smallButtonsOriginX = ((size.width-width)/2-_startButton.frame.size.width)/2;
                smallButtonsOriginY = smallButtonsOriginX;
                
                if(_hideUI == NO)
                    controlsAlpha = 0.5;
                else
                    controlsAlpha = 0;
            }
            else
            {
                // landscape - 1:1
                if (darkMode == YES) {
                    self.backgroundColor = [UIColor colorWithRed:0.07 green:0.07 blue:0.08 alpha:1.0];
                }
                else {
                    self.backgroundColor = plasticColor;
                }
                
                if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
                {
                    smallButtonsVertical = YES;
                    smallButtonsOriginX = ((size.width-width)/2-_startButton.frame.size.width)/2;
                    smallButtonsOriginY = smallButtonsOriginX;
                }
                else
                {
                    screenOffsetY = -2;
                    smallButtonsVertical = YES;
                    smallButtonsOriginX = (size.width-_startButton.frame.size.width)/2;
                    smallButtonsOriginY = size.height-_dPadView.image.size.height;
                }
            }
        }
    }
    
    if(_viewMode == EmulatorControllerViewModeScreenOnly)
        controlsAlpha = 0;
    else if(_viewMode == EmulatorControllerViewModeControllerOnly)
    {
        controlsAlpha = 1;
        
        
    }
    
    // layout screen
    int screenOffsetX = (size.width-width)/2;
    if(screenOffsetY == -1)
        screenOffsetY = screenOffsetX;
    else if(screenOffsetY == -2)
        screenOffsetY = (size.height-screenBorderY-_dPadView.image.size.height-height)/2;
    if(_viewMode == EmulatorControllerViewModeScreenOnly)
        // we're showing only the screen. center it
        _screenView.frame = (CGRect){(int)((size.width-width)*0.5), (int)((size.height-height)*0.5), width,height};
    else
        // we're showing the controls + screen
        _screenView.frame = (CGRect){screenOffsetX,screenOffsetY, width,height};
    
    if(_viewMode == EmulatorControllerViewModeControllerOnly)
        _screenView.alpha = 0;
    else
        _screenView.alpha = 1;
    
    // start, select, menu buttons
    int xOffset = 0;
    int yOffset = 0;
    if(smallButtonsVertical == YES)
        yOffset = _startButton.frame.size.height+smallButtonsSpacing;
    else
        xOffset = _startButton.frame.size.width+smallButtonsSpacing;
    
    if(_viewMode == EmulatorControllerViewModeScreenOnly)
    {
        _startButton.alpha = 0;
        _selectButton.alpha = 0;
        _optionsButton.alpha = 0;
    }
    else
    {
        _startButton.alpha = 1;
        _selectButton.alpha = 1;
        _optionsButton.alpha = 1;
    }
    
    // layout buttons
    if(size.height > size.width)
    {
        // portrait
        // portrait - screen or screen+controller mode
        // portrait - full screen
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            int buttonSize = _aButton.frame.size.width;
            _aButton.frame = (CGRect){size.width-buttonSize*1-screenBorderX, size.height-buttonSize*2.3-screenBorderY, _aButton.frame.size};
            _aButton.alpha = controlsAlpha;
            _bButton.frame = (CGRect){size.width-buttonSize*1.73-screenBorderX, size.height-buttonSize*1.5-screenBorderY, _bButton.frame.size};
            _bButton.alpha = controlsAlpha;
            _xButton.frame = (CGRect){size.width-buttonSize*1.73-screenBorderX, size.height-buttonSize*3.1-screenBorderY, _xButton.frame.size};
            _xButton.alpha = controlsAlpha;
            _yButton.frame = (CGRect){size.width-buttonSize*2.5-screenBorderX, size.height-buttonSize*2.3-screenBorderY, _yButton.frame.size};
            _yButton.alpha = controlsAlpha;
            
            _lButton.alpha = controlsAlpha;
            _lButton.frame = (CGRect){size.width-buttonSize*2.3-screenBorderX-buttonSpacing, size.height-buttonSize*4.3-screenBorderY-buttonSpacing, _yButton.frame.size};
            _rButton.alpha = controlsAlpha;
            _rButton.frame = (CGRect){size.width-buttonSize*1.1-screenBorderX, size.height-buttonSize*4.3-screenBorderY-buttonSpacing, _xButton.frame.size};
            
            _startButton.frame = (CGRect){size.width-buttonSize*2.6-screenBorderX-buttonSpacing, size.height-47, _startButton.frame.size};
            _selectButton.frame = (CGRect){size.width-buttonSize*3.45-screenBorderX, size.height-47, _selectButton.frame.size};
            _optionsButton.frame = (CGRect){smallButtonsOriginX,smallButtonsOriginY, _selectButton.frame.size};
        }
        else
        {
            int buttonSize = _aButton.frame.size.width;
            _aButton.frame = (CGRect){size.width-buttonSize*1-screenBorderX, size.height-buttonSize*2.3-screenBorderY, _aButton.frame.size};
            _aButton.alpha = controlsAlpha;
            _bButton.frame = (CGRect){size.width-buttonSize*1.73-screenBorderX, size.height-buttonSize*1.5-screenBorderY, _bButton.frame.size};
            _bButton.alpha = controlsAlpha;
            _xButton.frame = (CGRect){size.width-buttonSize*1.73-screenBorderX, size.height-buttonSize*3.1-screenBorderY, _xButton.frame.size};
            _xButton.alpha = controlsAlpha;
            _yButton.frame = (CGRect){size.width-buttonSize*2.5-screenBorderX, size.height-buttonSize*2.3-screenBorderY, _yButton.frame.size};
            _yButton.alpha = controlsAlpha;
            
            _lButton.alpha = controlsAlpha;
            _lButton.frame = (CGRect){size.width-buttonSize*2.3-screenBorderX-buttonSpacing, size.height-buttonSize*4.3-screenBorderY-buttonSpacing, _yButton.frame.size};
            _rButton.alpha = controlsAlpha;
            _rButton.frame = (CGRect){size.width-buttonSize*1.1-screenBorderX, size.height-buttonSize*4.3-screenBorderY-buttonSpacing, _xButton.frame.size};
            
            _startButton.frame = (CGRect){size.width-buttonSize*2.6-screenBorderX-buttonSpacing, size.height-47, _startButton.frame.size};
            _selectButton.frame = (CGRect){size.width-buttonSize*3.45-screenBorderX, size.height-47, _selectButton.frame.size};
            _optionsButton.frame = (CGRect){smallButtonsOriginX,smallButtonsOriginY, _selectButton.frame.size};
        }
    }
    else
    {
        int buttonSize = _aButton.frame.size.width;
        _aButton.frame = (CGRect){size.width-buttonSize*1-screenBorderX, size.height-buttonSize*1.8-screenBorderY, _aButton.frame.size};
        _aButton.alpha = controlsAlpha;
        _bButton.frame = (CGRect){size.width-buttonSize*1.73-screenBorderX, size.height-buttonSize*1-screenBorderY, _bButton.frame.size};
        _bButton.alpha = controlsAlpha;
        _xButton.frame = (CGRect){size.width-buttonSize*1.73-screenBorderX, size.height-buttonSize*2.6-screenBorderY, _xButton.frame.size};
        _xButton.alpha = controlsAlpha;
        _yButton.frame = (CGRect){size.width-buttonSize*2.5-screenBorderX, size.height-buttonSize*1.8-screenBorderY, _yButton.frame.size};
        _yButton.alpha = controlsAlpha;
        
        _lButton.alpha = controlsAlpha;
        _lButton.frame = (CGRect){size.width-buttonSize*2.3-screenBorderX-buttonSpacing, size.height-buttonSize*3.8-screenBorderY-buttonSpacing, _yButton.frame.size};
        _rButton.alpha = controlsAlpha;
        _rButton.frame = (CGRect){size.width-buttonSize*1.1-screenBorderX, size.height-buttonSize*3.8-screenBorderY-buttonSpacing, _xButton.frame.size};
        
        _startButton.frame = (CGRect){smallButtonsOriginX,smallButtonsOriginY, _startButton.frame.size};
        _selectButton.frame = (CGRect){smallButtonsOriginX+xOffset,smallButtonsOriginY+yOffset, _selectButton.frame.size};
        _optionsButton.frame = (CGRect){smallButtonsOriginX+2*xOffset,smallButtonsOriginY+2*yOffset, _selectButton.frame.size};
    }
    
    // layout d-pad
    // dPadView.frame = (CGRect){screenBorderX,size.height-_dPadView.image.size.height-screenBorderY, _dPadView.image.size};
    // _dPadView.alpha = controlsAlpha;
    if(size.height > size.width)
    {
        // portrait
        // portrait - screen or screen+controller mode
        // portrait - full screen
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            _dPadView.frame = (CGRect){screenBorderX,size.height-210-screenBorderY, _dPadView.image.size};
            _dPadView.alpha = controlsAlpha;
        }
        else
        {
            _dPadView.frame = (CGRect){screenBorderX,size.height-210-screenBorderY, _dPadView.image.size};
            _dPadView.alpha = controlsAlpha;
        }
    }
    else
    {
        // landscape
        _dPadView.frame = (CGRect){screenBorderX,size.height-_dPadView.image.size.height-screenBorderY, _dPadView.image.size};
        _dPadView.alpha = controlsAlpha;
    }
}

@end

#pragma mark -

@implementation EmulatorControllerView(NSObject)

- (void)dealloc
{
    if(_imageBuffer != nil)
        free(_imageBuffer);
    _imageBuffer = nil;
    
    if(_imageBufferAlt != nil)
        free(_imageBufferAlt);
    _imageBufferAlt = nil;
    
    if(_565ImageBuffer != nil)
        free(_565ImageBuffer);
    _565ImageBuffer = nil;
    
    [_screenView release];
    _screenView = nil;
    
    [_startButton release];
    _startButton = nil;
    [_selectButton release];
    _selectButton = nil;
    [_aButton release];
    _aButton = nil;
    [_bButton release];
    _bButton = nil;
    [_yButton release];
    _yButton = nil;
    [_xButton release];
    _xButton = nil;
    [_lButton release];
    _lButton = nil;
    [_rButton release];
    _rButton = nil;
    [_dPadView release];
    _dPadView = nil;
    
    [_iCadeControlView release];
    _iCadeControlView = nil;
    
    [_optionsButton release];
    _optionsButton = nil;
    
    [super dealloc];
}

@end
