/******************************\
	Send URL View Controller
\******************************/

// Dependencies
#import "SendURL_ViewController.h"

#import "Functions.h"

#pragma mark Globals
// Globals
enum _kTableSections {
	kTableSectionServers
} kTableSection;

#pragma mark Constants
// Constants
NSString * const FUSendURL_ViewControllerDidSendURLNotification = @"_FUSendURL_ViewControllerDidSendURLNotification";

#pragma mark Macros
// Macros
#define TABLE_DATA(a, b) [[[tableData objectAtIndex: a] objectForKey: @"data"] objectAtIndex: b]

@implementation SendURL_ViewController

#pragma mark Properties
// Properties
@synthesize delegate;
@synthesize finder;
@synthesize deviceConnection;
@synthesize preloadedURL;
@synthesize tableData;
@synthesize serverList;
@synthesize toolbar;
@synthesize sendButton;
@synthesize popoverController;

#pragma mark Instance Management
// Instance Management
-(void) loadViewWithURL: (NSDictionary *) url
{
	self.preloadedURL = url;
}

-(void) dealloc
{
	[finder release];
	[deviceConnection release];
	[preloadedURL release];
	[tableData release];
	[serverList release];
	[toolbar release];
	[sendButton release];
	
	[super dealloc];
}

#pragma mark View Management
// View Management
-(void) viewDidLoad
{
	// Set the title.
	self.navigationItem.title = LOCAL(@"Send a Site");
	
	// Set local text.
	sendButton.title = LOCAL(@"Send");
	
	if ( DEVICE_TYPE == kFUDeviceiPad )
		serverList.backgroundView = nil;
	
	self.view.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed: @"Background_iPhone.png"]];
	serverList.backgroundColor = [UIColor clearColor];
#ifdef IPAD
	serverList.backgroundView = nil;
#endif
	toolbar.tintColor = self.navigationController.navigationBar.tintColor;
	
	// Set up the Finder.
	self.finder = [[ServerBrowser alloc] init];
	finder.delegate = self;
	
	[finder startWithServiceType: FUServerBonjourTypeURL];
	
	// The Send button starts off disabled.
	sendButton.enabled = NO;
}

-(void) viewWillAppear: (BOOL) animated
{
	self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
	
	// Make sure we have a URL.
	if ( self.preloadedURL == nil ) {
		
		UIAlertView *failAlert = [[[UIAlertView alloc] initWithTitle: LOCAL(@"No Site") message: LOCAL(@"No website selected!")
															delegate: self cancelButtonTitle: LOCAL(@"OK") otherButtonTitles: nil] autorelease];
		
		[failAlert show];
		
	}
	
	[self updateServerList];
}

-(void) viewDidAppear: (BOOL) animated
{
	// Make sure we have wifi.
	if ( !WIFI ) {
		
		[APP_DELEGATE showWifiWarning];
		
		[self.navigationController popViewControllerAnimated: YES];
		
	} else {
		
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(networkChanged) 
													 name: kReachabilityChangedNotification object: nil];
		
	}
	
	[super viewDidAppear: animated];
}

-(void) viewWillDisappear: (BOOL) animated
{
	[finder stop];
	
	[[NSNotificationCenter defaultCenter] removeObserver: self name: kReachabilityChangedNotification object: nil];
	
	[super viewWillDisappear: animated];
}

-(BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation
{
#ifndef IPAD
	return ( toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown );
#endif
	
	return YES;
}

#pragma mark User Interaction Management
// User Interaction Mangement
-(IBAction) sendAction: (id) sender
{
	// Set the prompt.
	self.navigationItem.prompt = LOCAL(@"Checking things out...");
	
	// First, figure out which row is selected.
	NSInteger selectedIndex = [serverList indexPathForSelectedRow].row;
	
	// Now get the Net Service.
	NSNetService *selectedDevice = [finder.servers objectAtIndex: selectedIndex];
	
	// Create a Connection.
	self.deviceConnection = [[Connection alloc] initWithNetService: selectedDevice];
	deviceConnection.delegate = self;
	
	// Progress report.
	self.navigationItem.prompt = LOCAL(@"Establishing a connection...");
	
	// Connect.
	[deviceConnection connect];
	
	// Now disable the button.
	sendButton.enabled = FALSE;
}

#pragma mark Data Management
// Data Management
-(void) loadInfo
{
	self.tableData = [[NSMutableArray alloc] init];
	
	STANDARD_TABLE_DATA_ARRAY
	
	NEW_SECTION(@"");
	
	for ( NSNetService *eachServer in finder.servers ) {
		
		[sectionData addObject: dictionaryForTableViewCell(UITableViewCellReuseIDDefault, 0, 0, 2, [eachServer name], nil	)];
		
	}
	
	if ( [finder.servers count] == 0 ) 
		self.navigationItem.prompt = LOCAL(@"Start ToGo on another device...");
	else 
		self.navigationItem.prompt = LOCAL(@"Choose a device...");
	
	[tableData addObject: eachSection];
	END_SECTION;
}

#pragma mark Reachability Management
// Reachability Management
-(void) networkChanged
{
	if ( [[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] != ReachableViaWiFi ) 
		[self.navigationController popViewControllerAnimated: YES];
}

#pragma mark -
#pragma mark Server Browser Delegation
/* Server Browser Delegation *\
\*****************************/

-(void) updateServerList
{
	if ( BACKGROUND_MODE ) {
		
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(updateServerList)
													 name: UIApplicationDidBecomeActiveNotification object: [UIApplication sharedApplication]];
		
	}
	
	[[NSNotificationCenter defaultCenter] removeObserver: self name: UIApplicationDidBecomeActiveNotification 
												  object: [UIApplication sharedApplication]];
	
	[self loadInfo];
	[serverList reloadData];
}

#pragma mark -
#pragma mark Connection Delegation
/* Connection Delegation *\
\*************************/

#pragma mark Setup
// Setup
-(void) connectionSucceeded: (Connection *) connection
{
	if ( connection == deviceConnection ) {
		
		// Report progress.
		self.navigationItem.prompt = LOCAL(@"Sending site...");
		
		NSDictionary *packet = DICTIONARY([preloadedURL objectForKey: @"url"], @"url", DEVICE_NAME, @"sendingDeviceName");
		
		[connection sendNetworkPacket: packet];
		
	}
}

-(void) connectionAttemptFailed: (Connection *) connection
{
	if ( connection == deviceConnection ) {
		
		self.navigationItem.prompt = LOCAL(@"Could not connect.");
		
	}
}

-(void) connectionTerminated: (Connection *) connection
{
	// This is a successful connection, we'll assume.
	self.navigationItem.prompt = LOCAL(@"Success!");
	
	self.deviceConnection = nil;
	
	// Notify the delegate if there is one.
	if ( delegate != nil ) {
		
		if ( [delegate respondsToSelector: @selector(sendView:didSendURL:)] ) 
			[delegate sendView: self didSendURL: preloadedURL];
		
	}
	
	// Everything went well, so pop the view.
	[self.navigationController popViewControllerAnimated: YES];
}

#pragma mark Data Flow
// Data Flow
-(void) receivedNetworkPacket: (NSDictionary *) message viaConnection: (Connection *) connection
{
	NSLog(@"Received Packet: %@", message);
	
	if ( BOOLVALUE([message objectForKey: @"didReceiveURL"]) )
		[deviceConnection close];
	else {
		
		NSDictionary *packet = DICTIONARY([preloadedURL objectForKey: @"url"], @"url", DEVICE_NAME, @"sendingDeviceName");
		
		[connection sendNetworkPacket: packet];
		
	}
	
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
	sendButton.enabled = YES;
	self.navigationItem.prompt = LOCAL(@"Now hit Send...");
}

-(void) tableView: (UITableView *) tableView didDeselectRowAtIndexPath: (NSIndexPath *) indexPath
{
	if ( [tableView indexPathForSelectedRow] == nil ) {
		
		sendButton.enabled = NO;
		self.navigationItem.prompt = LOCAL(@"Choose a device...");
		
	}
}

#pragma mark -
#pragma mark Alert View Delegation
/* Alert View Delegation *\
\*************************/

-(void) alertView: (UIAlertView *) alertView didDismissWithButtonIndex: (NSInteger) buttonIndex
{
	[self.navigationController popViewControllerAnimated: YES];
}

@end