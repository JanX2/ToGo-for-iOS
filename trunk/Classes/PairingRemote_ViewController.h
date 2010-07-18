/************************************\
	Pairing Remote View Controller
\************************************/

// Dependencies
#import <UIKit/UIKit.h>

// Forward Declarations
@class PairingService;
@class Server;
@class ServerBrowser;
@class Connection;
@class PairingPINEntry_ViewController;
@protocol ServerDelegate;
@protocol ServerBrowserDelegate;
@protocol ConnectionDelegate;

@interface PairingRemote_ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, 
																	ServerDelegate, ServerBrowserDelegate, ConnectionDelegate>
{
	// Backend
	ServerBrowser *finder;
	PairingService *server;
	NSMutableSet *clients;
	
	// Data
	NSMutableArray *tableData;
	
	// View
	UITableView *pairingTable;
	UITextView *pairingInstructions;
	UITextField *pairingCode;
	UILabel *pairingRemoteLabel;
}

#pragma mark Properties
// Properties
@property (nonatomic, retain) ServerBrowser *finder;
@property (nonatomic, retain) PairingService *server;
@property (nonatomic, retain) NSMutableSet *clients;
@property (nonatomic, retain) NSMutableArray *tableData;
@property (nonatomic, retain) IBOutlet UITableView *pairingTable;
@property (nonatomic, retain) IBOutlet UITextView *pairingInstructions;
@property (nonatomic, retain) IBOutlet UITextField *pairingCode;
@property (nonatomic, retain) IBOutlet UILabel *pairingRemoteLabel;

#pragma mark Instance Management
// Instance Management
-(void) dealloc;

#pragma mark View Management
// View Management
-(void) viewDidLoad;
-(void) viewWillAppear: (BOOL) animated;
-(void) viewWillDisappear: (BOOL) animated;
-(void) dismissView;

#pragma mark User Interaction Management
// User Interaction Management
-(IBAction) doneAction: (id) sender;

#pragma mark Data Management
// Data Management
-(void) loadInfo;

#pragma mark -
#pragma mark Server Browser Management
/* Server Browser Management *\
\*****************************/

#pragma mark Setup
// Setup
-(BOOL) startFinder;

#pragma mark Delegation
// Delegation
-(void) updateServerList;

#pragma mark -
#pragma mark Server Management
/* Server Management *\
\*********************/

#pragma mark Setup
// Setup
-(BOOL) startServer;
-(void) stopServer;

#pragma mark Delegation
// Delegation
-(void) serverFailed: (Server *) theServer reason: (NSString *) reason;
-(void) handleNewConnection: (Connection *) connection;

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

@end