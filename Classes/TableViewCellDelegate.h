#import <Foundation/Foundation.h>

@protocol TableViewCellDelegate <NSObject>

- (void)LM_cellValueChanged:(UITableViewCell*)cell;

@end
