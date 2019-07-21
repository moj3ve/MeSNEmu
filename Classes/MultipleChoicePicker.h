#import <UIKit/UIKit.h>

#import "MultipleChoicePickerDelegate.h"

@interface MultipleChoicePicker : UITableViewController
{
    NSArray* _optionNames;
    NSArray* _optionValues;
    int _pickedIndex;
    
    id<MultipleChoicePickerDelegate> _delegate;
}

@property (copy) NSArray* optionNames;
@property (copy) NSArray* optionValues;
@property int pickedIndex;

@property (assign) id<MultipleChoicePickerDelegate> delegate;

@end
