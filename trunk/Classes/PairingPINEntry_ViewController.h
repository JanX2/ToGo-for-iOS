/***********************\
	Pairing PIN Entry
\***********************/

// Dependencies
#import <UIKit/UIKit.h>

// Forward Declarations
@class PairingService;
@class Connection;
@protocol ConnectionDelegate;
@protocol PairingServiceDelegate;

@interface PairingPINEntry_ViewController : UIViewController <ConnectionDelegate, PairingServiceDelegate>
{
	// Backend
	PairingService *pairingService;
	NSNetService *pairingNetService;
	Connection *pairingConnection;
	
	// View
	UILabel *pairingInstructions;
	UITextField *pairingCode;
}

#pragma mark Properties
// Properties
@property (nonatomic, retain) PairingService *pairingService;
@property (nonatomic, retain) NSNetService *pairingNetService;
@property (nonatomic, retain) Connection *pairingConnection;
@property (nonatomic, retain) IBOutlet UILabel *pairingInstructions;
@property (nonatomic, retain) IBOutlet UITextField *pairingCode;

#pragma mark Instance Management
// Instance Management
-(void) loadPINWithNetService: (NSNetService *) netService andPairingService: (PairingService *) pairing;
-(void) dealloc;

#pragma mark View Management
// View Management
-(void) viewDidLoad;
-(void) viewWillAppear: (BOOL) animated;
-(void) viewWillDisappear: (BOOL) animated;

#pragma mark User Interaction Management
// User Interaction Management
-(IBAction) cancelAction: (id) sender;
-(IBAction) pairAction: (id) sender;
-(void) textChanged;

#pragma mark Data Management
// Data Management
-(BOOL) canPair;

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
#pragma mark Pairing Service Delegation
/* Pairing Service Delegation *\
\******************************/

-(void) pairingServiceDidPair: (PairingService *) thePairingService;
-(void) pairingServiceDidFailToPair: (PairingService *) thePairingService;

@end