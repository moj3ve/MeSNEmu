#import <UIKit/UIKit.h>

@class BTControllerView;

@class ButtonView;
@class DPadView;
@class PixelView;

typedef enum _EmulatorControllerViewMode
{
    EmulatorControllerViewModeNormal,
    EmulatorControllerViewModeScreenOnly,
    EmulatorControllerViewModeControllerOnly
} EmulatorControllerViewMode;

@interface EmulatorControllerView : UIView
{
    unsigned int _bufferWidth;
    unsigned int _bufferHeight;
    unsigned int _bufferHeightExtended;
    unsigned char* _imageBuffer;
    unsigned char* _imageBufferAlt;
    unsigned char* _565ImageBuffer;
    
    PixelView* _screenView;
    
    ButtonView* _startButton;
    ButtonView* _selectButton;
    
    ButtonView* _aButton;
    ButtonView* _bButton;
    ButtonView* _xButton;
    ButtonView* _yButton;
    ButtonView* _lButton;
    ButtonView* _rButton;
    
    DPadView* _dPadView;
    
    BTControllerView* _iCadeControlView;
    
    UIButton* _optionsButton;
    
    BOOL _hideUI;
    
    EmulatorControllerViewMode _viewMode;
}

@property (readonly) UIButton* optionsButton;
@property (readonly) BTControllerView* iCadeControlView;
@property (nonatomic) EmulatorControllerViewMode viewMode;
@property (readonly) PixelView* screenView;

- (void)setControlsHidden:(BOOL)value animated:(BOOL)animated;
- (void)setMinMagFilter:(NSString*)filter;

- (void)setPrimaryBuffer;
- (void)flipFrontBufferWidth:(int)width height:(int)height;

@end
