#import <UIKit/UIKit.h>

#import "LMMultipleChoicePickerDelegate.h"

@interface LMMultipleChoicePicker : UITableViewController
{
  NSArray* _optionNames;
  NSArray* _optionValues;
  int _pickedIndex;
  
  id<LMMultipleChoicePickerDelegate> _delegate;
}

@property (copy) NSArray* optionNames;
@property (copy) NSArray* optionValues;
@property int pickedIndex;

@property (assign) id<LMMultipleChoicePickerDelegate> delegate;

@end
