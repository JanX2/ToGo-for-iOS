/*******************************\
	Main View View Controller
\*******************************/

// Dependencies
#import "MainView_ViewController.h"

#pragma mark Globals
// Globals
static MainView_ViewController *kSharedController;

enum _kTableSections {
	kTableSectionOpenURL,
	kTableSectionSendURL,
	kTableSectionOlderURLs
} kTableSection;

#pragma mark Macros
// Macros
#define TABLE_DATA(a, b) [[[tableData objectAtIndex: a] objectForKey: @"data"] objectAtIndex: b]

@implementation MainView_ViewController

#pragma mark Properties 
// Properties
@synthesize currentURL;
@synthesize tableData;
@synthesize urlTextStr;
@synthesize urlText;
@synthesize noURLsLabel, detailsLabel, previewLabel;
@synthesize urlTable;
@synthesize urlView;
@synthesize fullscreenButton;
@synthesize webViewContainer;
@synthesize activityIndicator;

#pragma mark Instance Management
// Instance Management
+(MainView_ViewController *) sharedController
{
	return kSharedController;
}

-(void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	
	[currentURL release];
	[tableData release];
	[urlTextStr release];
	[urlText release];
	[noURLsLabel release];
	[detailsLabel release];
	[previewLabel release];
	[urlTable release];
	[urlView release];
	[fullscreenButton release];
	[webViewContainer release];
	[activityIndicator release];
	
	[super dealloc];
}

#pragma mark View Management
// View Management
-(void) viewDidLoad
{
	kSharedController = self;
	
	// Set the title.
	self.navigationItem.title = LOCAL(@"Current Site");
	
	// Set the labels.
	detailsLabel.text = LOCAL(@"Details");
	previewLabel.text = LOCAL(@"Preview");
	noURLsLabel.text = LOCAL(@"No URLs");
	fullscreenButton.title = LOCAL(@"View in Fullscreen");
	
	// The settings button.
	/*self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed: @"20-gear2.png"] 
																			   style: UIBarButtonItemStyleBordered target: self 
																			  action: @selector(settingsAction:)] 
											  autorelease];*/
	
#ifndef IPAD
	self.view.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed: @"Background_iPhone.png"]];
	urlTable.backgroundColor = [UIColor clearColor];
#endif
	
	// The buttons.
	/*self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemEdit 
																							target: self 
																							action: @selector(settingsAction:)] 
											  autorelease];*/
	
	// Layering for the web view and toolbar.
	CALayer *webContainerLayer = [webViewContainer layer];
	webContainerLayer.masksToBounds = YES;
	webContainerLayer.cornerRadius = 10.0;
	webContainerLayer.borderColor = [[[UIColor blackColor] colorWithAlphaComponent: 1.0] CGColor];
	webContainerLayer.borderWidth = 1;
	
#ifdef IPAD
	// Set up the table view right.
	urlTable.backgroundView = nil;
	urlTable.opaque = NO;
	
	// Sign up for reachability notifications.
	[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(loadInfo) 
												 name: kReachabilityChangedNotification object: nil];
#endif
	
	// Now the corner radius for the text view.
	CALayer *textViewLayer = [urlText layer];
	textViewLayer.masksToBounds = YES;
	textViewLayer.cornerRadius = 10.0;
	textViewLayer.borderColor = [[UIColor grayColor] CGColor];
	textViewLayer.borderWidth = 1.0;
	
	// Sign up for notifications of changes to the current URL.
	[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(loadInfo) 
												 name: FUURLManagerCurrentURLDidChangeNotification object: [FUURLManager sharedManager]];
}

-(void) viewWillAppear: (BOOL) animated
{
	[self loadInfo];
	[urlTable reloadData];
	
	self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
	
	[self shouldAutorotateToInterfaceOrientation: self.interfaceOrientation];
	
	static BOOL didShowAlert;
	
	// First launch check.
	if ( FIRST_LAUNCH_MODE && !didShowAlert ) {
		
		UIAlertView *welcomeAlert = [[[UIAlertView alloc] initWithTitle: @"Get It ToGo!" 
																message: @"Welcome to ToGo! Before you get started, maybe you'd like to \
check out the Get It ToGo bookmarklet for your browser! It makes things much easier, and is required \
for sending from your iPhone OS device. You can choose to check it out now, or add it to your list of \
saved sites for later. Thank you and enjoy ToGo!" 
															   delegate: self 
													  cancelButtonTitle: @"Save for Later" otherButtonTitles: @"Check It Out!", nil] autorelease];
		
		[welcomeAlert show];
		
		didShowAlert = TRUE;
		
	}
	
	[super viewWillAppear: animated];
}

-(void) viewWillDisappear: (BOOL) animated
{
	[urlView stopLoading];
	
	HIDE_NETWORK_INDICATOR;
	
	[super viewWillDisappear: animated];
}

-(BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation
{
#ifndef IPAD
	return ( toInterfaceOrientation == UIInterfaceOrientationPortrait 
			|| toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown );
#endif
	
	/*if ( [[[UIDevice currentDevice] model] isEqualToString: @"iPhone"] 
		|| [[[UIDevice currentDevice] model] isEqualToString: @"iPhone Simulator"] ) 
	{
		
		if ( toInterfaceOrientation == UIInterfaceOrientationPortrait 
				|| toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown ) 
			urlTable.scrollEnabled = NO;
		else 
			urlTable.scrollEnabled = YES;
		
		return YES;
		
	}*/
	
#ifdef IPAD
	if ( toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown ) {
		
		// Set the proper frames.
		webViewContainer.frame = CGRectMake(20, 49, 728, 672);
		detailsLabel.frame = CGRectMake(20, 740, 280, 21);
		urlText.frame = CGRectMake(20, 769, 383, 181);
		urlTable.frame = CGRectMake(421, 740, 327, 210);
		
		// Set the background image.
		self.view.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed: @"Background_iPad_Portrait.png"]];
		
		/*if ( self.interfaceOrientation == UIInterfaceOrientationPortrait 
			|| self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown )
			[[UIApplication sharedApplication] setStatusBarHidden: YES withAnimation: UIStatusBarAnimationSlide];*/
		
	} else if ( toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft 
			   || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight ) {
		
		webViewContainer.frame = CGRectMake(16, 49, 700, 625);
		detailsLabel.frame = CGRectMake(729, 49, 275, 21);
		urlText.frame = CGRectMake(729, 78, 275, 384);
		urlTable.frame = CGRectMake(729, 470, 275, 210);
		
		// Set the background image.
		self.view.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed: @"Background_iPad_Landscape.png"]];
		
		/*if ( self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft 
			|| self.interfaceOrientation == UIInterfaceOrientationLandscapeRight )
			[[UIApplication sharedApplication] setStatusBarHidden: YES withAnimation: UIStatusBarAnimationSlide];*/
		
	}
	
	noURLsLabel.center = urlText.center;
	//[urlView reload];
	[urlText loadHTMLString: urlTextStr baseURL: nil];
	
	return YES;
#endif
}

-(void) willAnimateSecondHalfOfRotationFromInterfaceOrientation: (UIInterfaceOrientation) fromInterfaceOrientation 
													   duration: (NSTimeInterval) duration
{
	if ( DEVICE_TYPE == kFUDeviceiPad ) {
		
		if ( [UIApplication sharedApplication].statusBarHidden )
			[[UIApplication sharedApplication] setStatusBarHidden: NO withAnimation: UIStatusBarAnimationSlide];
		
	}
}

#pragma mark User Interaction Management
// User Interaction Management
/*-(IBAction) settingsAction: (id) sender
{
	// Set up a pairing view.
	PairingRemote_ViewController *pairingView = [[[PairingRemote_ViewController alloc] init] autorelease];
	
	// Give it a nav. controller.
	UINavigationController *pairingNav = [[[UINavigationController alloc] initWithRootViewController: pairingView] autorelease];
	
	// Present it.
	[self.navigationController presentModalViewController: pairingNav animated: YES];
}*/

-(IBAction) safariAction: (id) sender
{
	[[FUURLManager sharedManager] openURL: [FUURLManager sharedManager].currentURL];
}

-(IBAction) browseAction: (id) sender
{
	// Set up a web view.
	WebView_ViewController *webView = [[[WebView_ViewController alloc] init] autorelease];
	
	// Load the url.
	[webView loadViewWithURL: [[FUURLManager sharedManager] currentURL]];
	
	// Push it.
	[self.navigationController pushViewController: webView animated: YES];
}

#pragma mark Data Management
// Data Management
-(void) loadInfo
{
	if ( BACKGROUND_MODE ) {
		
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(loadInfo) 
													 name: UIApplicationDidBecomeActiveNotification object: nil];
		
		return;
		
	}
	
	[[NSNotificationCenter defaultCenter] removeObserver: self name: UIApplicationDidBecomeActiveNotification object: nil];
	
	// Set up the URL text view.
	self.currentURL = nil;
	self.currentURL = [[FUURLManager sharedManager] currentURL];
	
	if ( currentURL == nil ) {
		
		noURLsLabel.hidden = FALSE;
		[urlView loadHTMLString: nil baseURL: nil];
		[urlText loadHTMLString: nil baseURL: nil];
		
		goto makeTable;
		
	}
	
	NSString *urlStr = [currentURL objectForKey: @"url"];
	NSString *senderName = [currentURL objectForKey: @"sendingDeviceName"];
	NSString *title = ( [currentURL objectForKey: @"title"] == nil ) ? @"No Title" : [currentURL objectForKey: @"title"];
	NSString *description = ( [currentURL objectForKey: @"description"] == nil ) ? urlStr : [currentURL objectForKey: @"description"];
	
	NSString *urlStyleStr = [NSString stringWithString: @"<html><head>\
							 <style> body{width:95%;} \
							 p{margin:.6em 0 .3em;line-height:150%;} \
							 img{border:0;} \
							 h2{font-weight:normal;font-size:175%;letter-spacing:-.04em;line-height:110%;\
							 margin:.7em 0 .2em;letter-spacing:-0.03em;}\
							 *{margin:0 10 0 10;padding:0;font-family:\"Segoe UI\",Calibri,\"Myriad Pro\",Myriad,\"Trebuchet MS\", \
							 Helvetica,Arial,sans-serif;}\
							 </style></head>"];
	self.urlTextStr = [NSString stringWithFormat: @"%@<body><h2 style=\"text-align: center;\"><img title=\"Promo_Teaser_1\" \
							src=\"file://%@\" alt=\"\" \
							width=\"16\" height=\"16\" />%@</h2> \
							<p>%@</p> \
							<p>%@ %@.</p></body></html>", urlStyleStr, 
							[DOCUMENTS_DIRECTORY stringByAppendingPathComponent: [currentURL objectForKey: @"iconFileName"]], 
							LOCAL(title), LOCAL(description), LOCAL(@"Sent from"), senderName];
	
	[urlText loadHTMLString: urlTextStr baseURL: nil];
	noURLsLabel.hidden = TRUE;
	
	if ( DEVICE_TYPE == kFUDeviceiPad ) {
		
		[urlView stopLoading];
		[urlView loadHTMLString: nil baseURL: nil];
		
		// Start loading the web view.
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString: urlStr]];
		[request setCachePolicy: NSURLRequestReloadIgnoringCacheData];
		
		if ( [INTERNET_MONTITOR currentReachabilityStatus] != NotReachable )
			[urlView loadRequest: request];
		else 
			[urlView loadHTMLString: @"Err." baseURL: nil];
		
	}
	
makeTable: ;
	
	// And now the table.
	self.tableData = nil;
	
	tableData = [[NSMutableArray alloc] init];
	
	STANDARD_TABLE_DATA_ARRAY
	
	NEW_SECTION(@"");
	
	// Determine what to say.
	NSString *safariTitle = nil;
	
#ifdef IPAD
	safariTitle = LOCAL(@"Open in Safari");
#else
	if ( OS_VERSION >= kFUiOSVersion3_2 )
		safariTitle = LOCAL(@"View Site");
	else 
		safariTitle = LOCAL(@"Open in Safari");
#endif
		
	[sectionData addObject: dictionaryForTableViewCell(UITableViewCellReuseIDDefault, 1, 0, 2, safariTitle, nil)];
	
	[tableData addObject: eachSection];
	
	NEW_SECTION(@"");
	
	[sectionData addObject: dictionaryForTableViewCell(UITableViewCellReuseIDDefault, 1, 0, 2, LOCAL(@"Send this Website"), nil)];
	
	[tableData addObject: eachSection];
	
	NEW_SECTION(@"");
	
	[sectionData addObject: dictionaryForTableViewCell(UITableViewCellReuseIDDefault, 1, 0, 2, LOCAL(@"Past Websites"), nil)];
	
	[tableData addObject: eachSection];
	
/*#ifdef IPAD
	NEW_SECTION(@"");
	
	[sectionData addObject: dictionaryForTableViewCell(UITableViewCellReuseIDDefault, 1, 0, 2, @"Open in Safari", nil)];
	
	[tableData addObject: eachSection];
#endif*/
	
	END_STANDARD_TABLE_DATA_ARRAY
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
	
	if ( IPSection == kTableSectionOpenURL ) {
		
#ifndef IPAD
		if ( OS_VERSION >= kFUiOSVersion3_2 ) {
			
			// Set up a web view.
			WebView_ViewController *webView = [[[WebView_ViewController alloc] init] autorelease];
			
			// Load the url.
			[webView loadViewWithURL: [[FUURLManager sharedManager] currentURL]];
			
			// Push it.
			[self.navigationController pushViewController: webView animated: YES];
			
		} else {
			
			[[FUURLManager sharedManager] openURL: [FUURLManager sharedManager].currentURL];
			
		}
#else
		[[FUURLManager sharedManager] openURL: [FUURLManager sharedManager].currentURL];
#endif
		
	} else if ( IPSection == kTableSectionOlderURLs ) {
		
		// Set up the previous list.
		PreviousURLs_ViewController *prevView = [[[PreviousURLs_ViewController alloc] init] autorelease];
		
		// Push it.
		[self.navigationController pushViewController: prevView animated: YES];
		
	} else if ( IPSection == kTableSectionSendURL ) {
		
		// Set up a send view.
		SendURL_ViewController *sendView = [[[SendURL_ViewController alloc] init] autorelease];
		sendView.delegate = self;
		
		[sendView loadViewWithURL: [FUURLManager sharedManager].currentURL];
		
#ifdef IPAD
		// Put it in a popover for iPad.
		UINavigationController *sendNav = [[[UINavigationController alloc] initWithRootViewController: sendView] autorelease];
		
		UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController: sendNav];
		popover.popoverContentSize = CGSizeMake(320, 450);
		
		CGRect cellRect = [tableView rectForRowAtIndexPath: indexPath];
		
		[popover presentPopoverFromRect: cellRect inView: tableView permittedArrowDirections: UIPopoverArrowDirectionAny animated: YES];
		
		sendView.popoverController = popover;
		
		return;
#endif
		
		// Otherwise, push it.
		[self.navigationController pushViewController: sendView animated: YES];
		
//#endif
		
	}
}

#pragma mark -
#pragma mark Web View Delegation
/* Web View Delegation *\
\***********************/

-(void) webViewDidStartLoad: (UIWebView *) webView
{
	// Show the activity indicators.
	SHOW_NETWORK_INDICATOR;
	
	[activityIndicator startAnimating];
}

-(void) webViewDidFinishLoad: (UIWebView *) webView
{
	// Hide the activity indicators.
	HIDE_NETWORK_INDICATOR;
	
	[activityIndicator stopAnimating];
}

-(BOOL) webView: (UIWebView *) webView shouldStartLoadWithRequest: (NSURLRequest *) request 
 navigationType: (UIWebViewNavigationType) navigationType
{
	return YES;
}

-(void) webView: (UIWebView *) webView didFailLoadWithError: (NSError *) error
{
	if ( [error code] == -1009 ) {
		
		// No internet.
		HIDE_NETWORK_INDICATOR;
		
		NSString *errorString = STRING(@"<html><center><p><font size=+5 color='red'>Please connect to the internet.\
												   </font></p></center></html>");
		
		[self.urlView loadHTMLString: errorString baseURL: nil];
		
	} else if ([error code] != -999) {
		//show error alert, etc.
		
		// load error, hide the activity indicator in the status bar
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		
		// report the error inside the webview
		NSString* errorString = [NSString stringWithFormat:
								 @"<html><center><font size=+5 color='red'>An error occurred:<br>(%i) %@</font></center></html>",
								 [error code], error.localizedDescription];
		[self.urlView loadHTMLString:errorString baseURL:nil];
		
	}
}

#pragma mark -
#pragma mark Alert View Delegation
/* Alert View Delegation *\
\*************************/

-(void) alertView: (UIAlertView *) alertView didDismissWithButtonIndex: (NSInteger) buttonIndex
{
	// Save it for later.
	[[FUURLManager sharedManager] addURL: @"http://fappulo.us/ToGo/GetItToGo" from: @"Fappulous HQ"];
	
	// Open it if wanted.
	if ( buttonIndex == 1 ) {
		
		if ( OS_VERSION >= kFUiOSVersion3_2 ) {
			
			// Set up a web view.
			WebView_ViewController *webView = [[[WebView_ViewController alloc] init] autorelease];
			
			// Load the url.
			[webView loadViewWithURL: [[FUURLManager sharedManager] currentURL]];
			
			// Push it.
			[self.navigationController pushViewController: webView animated: YES];
			
		} else {
			
			[[FUURLManager sharedManager] openURL: [FUURLManager sharedManager].currentURL];
			
		}
		
	}
}

#pragma mark -
#pragma mark Send View Delegation
/* Send View Delegation *\
\************************/

-(void) sendView: (SendURL_ViewController *) sendView didSendURL: (NSDictionary *) sentURL
{
	[sendView.popoverController dismissPopoverAnimated: YES];
}

@end