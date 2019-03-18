#import <Foundation/Foundation.h>

@protocol LMTableViewCellDelegate <NSObject>

- (void)LM_cellValueChanged:(UITableViewCell*)cell;

@end
