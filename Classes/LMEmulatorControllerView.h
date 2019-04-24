#import <UIKit/UIKit.h>

@class LMBTControllerView;

@class LMButtonView;
@class LMDPadView;
@class LMPixelView;

typedef enum _LMEmulatorControllerViewMode
{
  LMEmulatorControllerViewModeNormal,
  LMEmulatorControllerViewModeScreenOnly,
  LMEmulatorControllerViewModeControllerOnly
} LMEmulatorControllerViewMode;

@interface LMEmulatorControllerView : UIView
{
  unsigned int _bufferWidth;
  unsigned int _bufferHeight;
  unsigned int _bufferHeightExtended;
  unsigned char* _imageBuffer;
  unsigned char* _imageBufferAlt;
  unsigned char* _565ImageBuffer;
  
  LMPixelView* _screenView;
  
  LMButtonView* _startButton;
  LMButtonView* _selectButton;
    
  LMButtonView* _aButton;
  LMButtonView* _bButton;
  LMButtonView* _xButton;
  LMButtonView* _yButton;
  LMButtonView* _lButton;
  LMButtonView* _rButton;
    
  LMDPadView* _dPadView;
  
  LMBTControllerView* _iCadeControlView;
  
  UIButton* _optionsButton;
  
  BOOL _hideUI;
  
  LMEmulatorControllerViewMode _viewMode;
}

@property (readonly) UIButton* optionsButton;
@property (readonly) LMBTControllerView* iCadeControlView;
@property (nonatomic) LMEmulatorControllerViewMode viewMode;

- (void)setControlsHidden:(BOOL)value animated:(BOOL)animated;
- (void)setMinMagFilter:(NSString*)filter;

- (void)setPrimaryBuffer;
- (void)flipFrontBufferWidth:(int)width height:(int)height;

@end
