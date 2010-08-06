/**************\
	URL Info
\**************/

// Dependencies
#import <UIKit/UIKit.h>

// Forward Declarations
@class FUURLManager;
@class SendURL_ViewController;
@class WebView_ViewController;
@class URLInfo_ViewController;

// Typedefs
typedef enum _kURLInfoActions {
	kURLInfoActionView,
	kURLInfoActionSend,
	kURLInfoActionDelete
} URLInfoAction;

#pragma mark -
#pragma mark Delegate Protocol
#pragma mark -
/* Delegate Protocol *\
\*********************/

@protocol URLInfoDelegate

@required
-(void) urlInfoView: (URLInfo_ViewController *) infoView didRequestAction: (URLInfoAction) action;

@end

#pragma mark -
#pragma mark Header Declaration
#pragma mark -
/* Header Declaration *\
\**********************/

@interface URLInfo_ViewController : UIViewController <UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource>
{
	// Backend
	id <URLInfoDelegate, NSObject> delegate;
	
	// Data
	NSMutableDictionary *urlObj;
	NSMutableArray *tableData;
	NSString *urlTextStr;
	
	// View
	UILabel *detailsLabel;
	UIWebView *urlText;
	UITableView *urlTable;
}

#pragma mark Properties
// Properties
@property (nonatomic, assign) id <URLInfoDelegate, NSObject> delegate;
@property (nonatomic, retain) NSMutableDictionary *urlObj;
@property (nonatomic, retain) NSMutableArray *tableData;
@property (nonatomic, retain) NSString *urlTextStr;
@property (nonatomic, retain) IBOutlet UILabel *detailsLabel;
@property (nonatomic, retain) IBOutlet UIWebView *urlText;
@property (nonatomic, retain) IBOutlet UITableView *urlTable;

#pragma mark Instance Management
// Instance Management
-(void) loadViewWithURL: (NSMutableDictionary *) url;
-(void) dealloc;

#pragma mark View Management
// View Management
-(void) viewDidLoad;
-(void) viewWillAppear: (BOOL) animated;
-(void) viewWillDisappear: (BOOL) animated;

#pragma mark Data Management
// Data Management
-(void) loadInfo;

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

#pragma mark User Interaction Management
// User Interaction Management
-(void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath;

#pragma mark -
#pragma mark Action Sheet Delegation
/* Action Sheet Delegation *\
\***************************/

-(void) actionSheet: (UIActionSheet *) actionSheet didDismissWithButtonIndex: (NSInteger) buttonIndex;

@end