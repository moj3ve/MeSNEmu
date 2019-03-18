#import <UIKit/UIKit.h>

@interface LMButtonView : UIImageView
{
  uint32_t _button;
  UILabel* _label;
}

@property uint32_t button;
@property (readonly) UILabel* label;

@end
