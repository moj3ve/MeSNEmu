#import <UIKit/UIKit.h>

@class FileListItem;

@interface RomBrowserController : UIViewController <UITableViewDelegate,UITableViewDataSource,UISearchDisplayDelegate>
{
    UITableViewStyle tableViewStyle;
    UITableView* _tableView;
    
    FileListItem* _detailsItem;
    NSString* _romPath;
    NSString* _sramPath;
    
    NSArray* _romList;
    NSArray* _sectionTitles;
    NSArray* _sectionMarkers;
    
    NSArray* _filteredRomList;
    NSArray* _filteredSectionTitles;
    NSArray* _filteredSectionMarkers;
}

@property (nonatomic, retain) UITableView *tableView;
@property (retain) FileListItem* detailsItem;

- (id)initWithStyle:(UITableViewStyle)theStyle;

@end
