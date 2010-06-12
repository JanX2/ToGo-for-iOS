/***********************\
	Pairing PIN Entry
\***********************/

// Dependencies
#import "PairingPINEntry_ViewController.h"

@implementation PairingPINEntry_ViewController

#pragma mark Properties
// Properties
@synthesize pairingService;
@synthesize pairingNetService;
@synthesize pairingConnection;
@synthesize pairingInstructions;
@synthesize pairingCode;

#pragma mark Instance Management
// Instance Management
-(void) loadPINWithNetService: (NSNetService *) netService andPairingService: (PairingService *) pairing
{
	self.pairingConnection = [[Connection alloc] initWithNetService: netService];
	pairingConnection.delegate = self;
	self.pairingService = pairing;
	pairingService.pairingConnection = self.pairingConnection;
	pairingService.pairingDelegate = self;
	pairingService.delegate = self;
}

-(void) dealloc
{
	[pairingService release];
	[pairingNetService release];
	[pairingConnection release];
	[pairingInstructions release];
	[pairingCode release];
	
	[super dealloc];
}

#pragma mark View Management
// View Management
-(void) viewDidLoad
{
	self.navigationItem.title = STRING_WITH_FORMAT(@"Pair With %@", [pairingNetService name]);
	
	// Buttons.
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCancel 
																						   target: self action: @selector(cancelAction:)] autorelease];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle: @"Pair" style: UIBarButtonItemStyleDone 
																			  target: self action: @selector(pairAction:)] autorelease];
	
	// Set up the text field notification.
	[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(textChanged) 
												 name: UITextFieldTextDidChangeNotification object: pairingCode];
	
	pairingCode.text = nil;
}

-(void) viewWillAppear: (BOOL) animated
{
	self.navigationItem.prompt = STRING_WITH_FORMAT(@"Opening connection to %@...", [pairingNetService name]);
	
	[pairingConnection connect];
	
	[pairingCode becomeFirstResponder];
	
	[self canPair];
}

-(void) viewWillDisappear: (BOOL) animated
{
	self.navigationItem.prompt = @"Closing connection...";
	
	[pairingConnection close];
	
	[pairingCode resignFirstResponder];
}

#pragma mark User Interaction Management
// User Interaction Management
-(IBAction) cancelAction: (id) sender
{
	[self.navigationController popViewControllerAnimated: YES];
}

-(IBAction) pairAction: (id) sender
{
	if ( ![self canPair] )
		return;
	
	// Set up the network packet.
	NSDictionary *packet = DICTIONARY(FUPairingServerAuthPIN, @"header", 
									  INTOBJ([pairingCode.text intValue]), @"message", 
									  [[UIDevice currentDevice] name], @"from");
	
	// Send it.
	[pairingConnection sendNetworkPacket: packet];
}

-(void) textChanged
{
	[self canPair];
}

#pragma mark Data Management
// Data Management
-(BOOL) canPair
{
	BOOL canPair = TRUE;
	
	if ( [pairingCode.text length] != 4 )
		canPair = FALSE;
	
	self.navigationItem.rightBarButtonItem.enabled = canPair;
	
	return canPair;
}

#pragma mark -
#pragma mark Connection Delegation
/* Connection Delegation *\
\*************************/

#pragma mark Setup
// Setup
-(void) connectionSucceeded: (Connection *) connection
{
	NSLog(@"Connected to %@", [connection->netService name]);
	
	self.navigationItem.prompt = @"Connected! Ready to pair...";
}

-(void) connectionAttemptFailed: (Connection *) connection
{
	self.navigationItem.prompt = @"Couldn't connect! Will retry in a moment...";
	
	NSDate *tenSecs = [NSDate dateWithTimeIntervalSinceNow: 10];
	
	NSTimer *retryTimer = [[NSTimer alloc] initWithFireDate: tenSecs interval: 0 target: pairingConnection 
												   selector: @selector(connect) userInfo: nil repeats: NO];
	
	[[NSRunLoop currentRunLoop] addTimer: retryTimer forMode: NSDefaultRunLoopMode];
	
	[retryTimer release];
}

-(void) connectionTerminated: (Connection *) connection
{
	self.navigationItem.prompt = @"Connection closed.";
	
	[self.navigationController popViewControllerAnimated: YES];
}

#pragma mark Data Flow
// Data Flow
-(void) receivedNetworkPacket: (NSDictionary *) message viaConnection: (Connection *) connection
{
	NSLog(@"Message received: %@", message);
	
	[pairingService handlePairingMessage: message];
}

#pragma mark -
#pragma mark Pairing Service Delegation
/* Pairing Service Delegation *\
\******************************/

-(void) pairingServiceDidPair: (PairingService *) thePairingService
{
	NSLog(@"Pair successful!");
}

-(void) pairingServiceDidFailToPair: (PairingService *) thePairingService
{
	NSLog(@"Pair failed!");
}

@end