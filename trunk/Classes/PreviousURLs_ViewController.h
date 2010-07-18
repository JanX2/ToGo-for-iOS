/************************\
	Previous URLs List
\************************/

// Dependencies
#import <UIKit/UIKit.h>

// Forward Declarations
@class FUURLManager;
#ifdef IPAD
@class WebView_ViewController;
#endif

@interface PreviousURLs_ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate,
																	UISearchBarDelegate>
{
	// Data
	NSMutableArray *tableData, *searchData;
	
	// Flags
	BOOL searchMode, canSelect;
	
	// View
	UITableView *urlTable;
	UIBarButtonItem *editButton, *doneButton;
	UITextView *urlInfo;
	UISearchBar *urlSearch;
}

#pragma mark Properties
// Properties
@property (nonatomic, retain) NSMutableArray *tableData, *searchData;
@property (nonatomic) BOOL searchMode, canSelect;
@property (nonatomic, retain) IBOutlet UITableView *urlTable;
@property (nonatomic, assign) UITextView *urlInfo;
@property (nonatomic, retain) IBOutlet UISearchBar *urlSearch;

#pragma mark Instance Management
// Instance Management
-(id) init;
-(void) dealloc;

#pragma mark View Management
// View Management
-(void) viewDidLoad;
-(void) viewWillAppear: (BOOL) animated;
-(void) viewWillDisappear: (BOOL) animated;
-(BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation;

#pragma mark User Interaction Management
// User Interaction Management
-(IBAction) editAction: (id) sender;

#pragma mark Data Management
// Data Management
-(void) loadInfo;
-(void) updateInfo;

#pragma mark -
#pragma mark Search Management
/* Search Management *\
\*********************/

#pragma mark Functionality
// Functionality
-(void) searchTable;
-(IBAction) dismissSearch: (id) sender;
-(void) setCanSelect: (BOOL) yorn;

#pragma mark Bar Delegation
// Bar Delegation
-(BOOL) searchBarShouldBeginEditing: (UISearchBar *) searchBar;
-(void) searchBarTextDidBeginEditing: (UISearchBar *) searchBar;
-(void) searchBar: (UISearchBar *) searchBar textDidChange: (NSString *) searchText;
-(void) searchBarSearchButtonClicked: (UISearchBar *) searchBar;
-(void) searchBarTextDidEndEditing: (UISearchBar *) searchBar;

#pragma mark -
#pragma mark Table View Management
/* Table View Management *\
\*************************/

#pragma mark Setup
// Setup
-(NSInteger) numberOfSectionsInTableView: (UITableView *) tableView;
-(NSString *) tableView: (UITableView *) tableView titleForHeaderInSection: (NSInteger) section;
-(NSInteger) tableView: (UITableView *) table numberOfRowsInSection: (NSInteger) section;
-(CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath;
-(UITableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath;

#pragma mark Edit Mode Setup
// Edit Mode Setup
-(UITableViewCellEditingStyle) tableView: (UITableView *) tableView editingStyleForRowAtIndexPath: (NSIndexPath *) indexPath;
-(BOOL) tableView: (UITableView *) tableView shouldIndentWhileEditingRowAtIndexPath: (NSIndexPath *) indexPath;

#pragma mark User Interaction Management
// User Interaction Management
-(void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath;
-(void) tableView: (UITableView *) tableView commitEditingStyle: (UITableViewCellEditingStyle) editingStyle 
forRowAtIndexPath: (NSIndexPath *) indexPath;

#pragma mark -
#pragma mark Action Sheet Delegation
/* Action Sheet Delegation *\
\***************************/

-(void) actionSheet: (UIActionSheet *) actionSheet didDismissWithButtonIndex: (NSInteger) buttonIndex;

@end