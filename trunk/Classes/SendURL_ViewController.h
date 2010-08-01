/******************************\
	Send URL View Controller
\******************************/

// Dependencies
#import <UIKit/UIKit.h>

// Forward Declarations
@class ServerBrowser;
@class Connection;
@class Server;
@protocol ServerBrowserDelegate;
@protocol ConnectionDelegate;

#pragma mark -
#pragma mark Delegate Protocol
#pragma mark -
/* Delegate Protocol *\
\*********************/

@class SendURL_ViewController;

@protocol SendURL_ViewControllerDelegate

@optional
-(void) sendView: (SendURL_ViewController *) sendView didSendURL: (NSDictionary *) sentURL;

@end

#pragma mark -
#pragma mark Main Interface Declaration
#pragma mark -
/* Main Interface Declaration *\
\******************************/

@interface SendURL_ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, ServerBrowserDelegate, ConnectionDelegate>
{
	// Backend
	id <SendURL_ViewControllerDelegate, NSObject> delegate;
	ServerBrowser *finder;
	Connection *deviceConnection;
	
	// Data
	NSDictionary *preloadedURL;
	NSMutableArray *tableData;
	
	// View
	UITableView *serverList;
	UIToolbar *toolbar;
	UIBarButtonItem *sendButton;
	UIPopoverController *popoverController;
}

#pragma mark Properties
// Properties
@property (nonatomic, assign) id <SendURL_ViewControllerDelegate, NSObject> delegate;
@property (nonatomic, retain) ServerBrowser *finder;
@property (nonatomic, retain) Connection *deviceConnection;
@property (nonatomic, copy) NSDictionary *preloadedURL;
@property (nonatomic, retain) NSMutableArray *tableData;
@property (nonatomic, retain) IBOutlet UITableView *serverList;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *sendButton;
@property (nonatomic, assign) UIPopoverController *popoverController;

#pragma mark Instance Management
// Instance Management
-(void) loadViewWithURL: (NSDictionary *) url;
-(void) dealloc;

#pragma mark View Management
// View Management
-(void) viewDidLoad;
-(void) viewWillAppear: (BOOL) animated;
-(void) viewDidAppear: (BOOL) animated;
-(void) viewWillDisappear: (BOOL) animated;
-(BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation;

#pragma mark User Interaction Management
// User Interaction Mangement
-(IBAction) sendAction: (id) sender;

#pragma mark Data Management
// Data Management
-(void) loadInfo;

#pragma mark Reachability Management
// Reachability Management
-(void) networkChanged;

#pragma mark -
#pragma mark Server Browser Delegation
/* Server Browser Delegation *\
\*****************************/

-(void) updateServerList;

#pragma mark -
#pragma mark Connection Delegation
/* Connection Delegation *\
\*************************/

#pragma mark Setup
// Setup
-(void) connectionSucceeded: (Connection *) connection;
-(void) connectionAttemptFailed: (Connection *) connection;
-(void) connectionTerminated: (Connection *) connection;

#pragma mark Data Flow
// Data Flow
-(void) receivedNetworkPacket: (NSDictionary *) message viaConnection: (Connection *) connection;

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
#pragma mark Alert View Delegation
/* Alert View Delegation *\
\*************************/

-(void) alertView: (UIAlertView *) alertView didDismissWithButtonIndex: (NSInteger) buttonIndex;

@end