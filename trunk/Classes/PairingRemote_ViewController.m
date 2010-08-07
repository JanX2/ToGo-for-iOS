/************************************\
	Pairing Remote View Controller
\************************************/

// Dependencies
#import "PairingRemote_ViewController.h"

// Macros
#define TABLE_DATA(a, b) [[[tableData objectAtIndex: a] objectForKey: @"data"] objectAtIndex: b]

@implementation PairingRemote_ViewController

#pragma mark Properties
// Properties
@synthesize finder;
@synthesize server;
@synthesize clients;
@synthesize tableData;
@synthesize pairingTable;
@synthesize pairingInstructions;
@synthesize pairingCode;
@synthesize pairingRemoteLabel;

#pragma mark Instance Management
// Instance Management
-(void) dealloc
{
	[finder release];
	[server release];
	[clients release];
	[tableData release];
	[pairingTable release];
	[pairingInstructions release];
	[pairingCode release];
	[pairingRemoteLabel release];
	
	[super dealloc];
}

#pragma mark View Management
// View Management
-(void) viewDidLoad
{
	self.navigationItem.title = @"Pairing";
	
	// Button.
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemDone 
																							target: self action: @selector(doneAction:)] autorelease];
	
	// Set the device name.
	pairingInstructions.text = STRING_WITH_FORMAT(@"Open HopTo on the device you'd like to pair, select %@, and enter the code below:", 
												  [[UIDevice currentDevice] name]);
}

-(void) viewWillAppear: (BOOL) animated
{
	[self startServer];
	[self startFinder];
	
	[self loadInfo];
	[pairingTable reloadData];
	
	[super viewWillAppear: animated];
}

-(void) viewWillDisappear: (BOOL) animated
{
	[self stopServer];
	[finder stop];
	
	[super viewWillDisappear: animated];
}

-(void) dismissView
{
	[self.parentViewController dismissModalViewControllerAnimated: YES];
}

#pragma mark User Interaction Management
// User Interaction Management
-(IBAction) doneAction: (id) sender
{
	[self dismissView];
}

#pragma mark Data Management
// Data Management
-(void) loadInfo
{
	self.tableData = nil;
	self.tableData = [[NSMutableArray alloc] init];
	
	STANDARD_TABLE_DATA_ARRAY
	
	NEW_SECTION(@"");
	
	for ( NSNetService *eachService in finder.servers ) {
		
		[sectionData addObject: dictionaryForTableViewCellWithData(UITableViewCellReuseIDDefault, 1, 0, 2, [eachService name], nil, eachService)];
		
	}
	
	[tableData addObject: eachSection];
	
	END_SECTION;
}

#pragma mark -
#pragma mark Server Browser Management
/* Server Browser Management *\
\*****************************/

#pragma mark Setup
// Setup
-(BOOL) startFinder
{
	self.finder = [[ServerBrowser alloc] init];
	finder.delegate = self;
	
	if ( ![finder startWithServiceType: FUServerBonjourTypePairing] ) {
		
		self.finder = nil;
		
		return NO;
		
	}
	
	return YES;
}

#pragma mark Delegation
// Delegation
-(void) updateServerList
{
	[self loadInfo];
	[pairingTable reloadData];
}

#pragma mark -
#pragma mark Server Management
/* Server Management *\
\*********************/

#pragma mark Setup
// Setup
-(BOOL) startServer
{
	self.navigationItem.prompt = @"Starting pairing service...";
	
	if ( self.server == nil ) 
		self.server = [[PairingService alloc] init];
	
	// Set the delegate.
	server.delegate = self;
	
	// Try to start.
	if ( ![server start] ) {
		
		self.navigationItem.prompt = @"Couldn't start pairing service.";
		
		self.server = nil;
		
		return NO;
		
	}
	
	pairingCode.text = STRING_WITH_FORMAT(@"%d", server.pairingPIN);
	
	self.clients = [NSMutableSet set];
	
	self.navigationItem.prompt = @"Pairing service started!";
	
	return YES;
}

-(void) stopServer
{
	[server stop];
	
	self.clients = nil;
}

#pragma mark Delegation
// Delegation
-(void) serverFailed: (Server *) theServer reason: (NSString *) reason
{
	NSLog(@"Server failed: %@", reason);
	
	self.navigationItem.prompt = @"Server failed.";
}

-(void) handleNewConnection: (Connection *) connection
{
	self.navigationItem.prompt = @"Incoming connection...";
	
	connection.delegate = self;
	
	[clients addObject: connection];
}

#pragma mark -
#pragma mark Connection Delegation
/* Connection Delegation *\
\*************************/

#pragma mark Setup
// Setup
-(void) connectionSucceeded: (Connection *) connection
{
	NSLog(@"Connection succeeded!");
}

-(void) connectionAttemptFailed: (Connection *) connection
{
	self.navigationItem.prompt = @"Couldn't connect...";
}

-(void) connectionTerminated: (Connection *) connection
{
	[clients removeObject: connection];
	
	self.navigationItem.prompt = @"Connection closed!";
}

#pragma mark Data Flow
// Data Flow
-(void) receivedNetworkPacket: (NSDictionary *) message viaConnection: (Connection *) connection
{
	self.navigationItem.prompt = @"Receiving data, verifying PIN...";
}

#pragma mark -
#pragma mark Table View Management
/* Table View Management *\
\*************************/

#pragma mark Setup
// Setup
-(NSInteger) numberOfSectionsInTableView: (UITableView *) tableView
{
	return [tableData count];
}

-(NSString *) tableView: (UITableView *) tableView titleForHeaderInSection: (NSInteger) section
{
	return [[tableData objectAtIndex: section] objectForKey: @"header"];
}

-(NSInteger) tableView: (UITableView *) table numberOfRowsInSection: (NSInteger) section
{
	return [[[tableData objectAtIndex: section] objectForKey: @"data"] count];
}

-(CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath
{
	return 44.0;
}

-(UITableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
	NSMutableDictionary *cellData = [TABLE_DATA(IPSection, IPRow) retain];
	
	id cell = generateTableViewCell(tableView, cellData, [cellData objectForKey: @"reuseID"]);
	
	[cellData release];
	
	return cell;
}

#pragma mark User Interaction Management
// User Interaction Management
-(void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
	[tableView deselectRowAtIndexPath: indexPath animated: YES];
	
	NSMutableDictionary *cellData = [TABLE_DATA(IPSection, IPRow) retain];
	
	// Set up a PIN entry view.
	PairingPINEntry_ViewController *pinView = [[[PairingPINEntry_ViewController alloc] init] autorelease];
	
	// Load in the service.
	[pinView loadPINWithNetService: [cellData objectForKey: @"data"] andPairingService: server];
	
	// Push it.
	[self.navigationController pushViewController: pinView animated: YES];
}

@end