#import <UIKit/UIKit.h>

@class FileListItem;

@interface ROMBrowserController : UITableViewController
{
  FileListItem* _detailsItem;
  NSString* _romPath;
  NSString* _sramPath;
  
  NSArray* _romList;
  NSArray* _sectionTitles;
  NSArray* _sectionMarkers;
  
  NSArray* _filteredRomList;
  NSArray* _filteredSectionTitles;
  NSArray* _filteredSectionMarkers;
  
  NSTimer* _fsTimer;
}

@property (retain) FileListItem* detailsItem;

@end
