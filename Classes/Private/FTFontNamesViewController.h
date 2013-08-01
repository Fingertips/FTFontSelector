#import <UIKit/UIKit.h>

@interface FTFontNamesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong) NSArray *fontNames;
@property (strong) UITableView *tableView;
@property (assign) NSInteger currentSelectedFontIndex;
@property (weak) FTFontSelectorController *fontSelectorController;
@property (assign) BOOL dismissOnSelection;

@end
