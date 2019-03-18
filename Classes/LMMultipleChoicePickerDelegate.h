#import <Foundation/Foundation.h>

@class LMMultipleChoicePicker;

@protocol LMMultipleChoicePickerDelegate <NSObject>

- (void)multipleChoice:(LMMultipleChoicePicker*)picker changedIndex:(int)index;

@end
