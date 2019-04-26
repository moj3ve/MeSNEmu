#import <Foundation/Foundation.h>

@protocol TableViewCellDelegate <NSObject>

- (void)cellValueChanged:(UITableViewCell*)cell;

@end
