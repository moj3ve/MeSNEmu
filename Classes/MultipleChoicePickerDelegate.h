#import <Foundation/Foundation.h>

@class MultipleChoicePicker;

@protocol MultipleChoicePickerDelegate <NSObject>

- (void)multipleChoice:(MultipleChoicePicker*)picker changedIndex:(int)index;

@end
