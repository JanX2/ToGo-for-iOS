/************************\
	Previous URLs List
\************************/

// Dependencies
#import "PreviousURLs_ViewController.h"

#pragma mark Macros
// Macros
#define TABLE_DATA(a, b) [[[tableData objectAtIndex: a] objectForKey: @"data"] objectAtIndex: b]

@implementation PreviousURLs_ViewController

#pragma mark Properties
// Properties
@synthesize tableData, searchData;
@synthesize searchMode, canSelect;
@synthesize urlTable;
@synthesize urlInfo;
@synthesize urlSearch;

#pragma mark Instance Management
// Instance Management
-(id) init 
{
	self = [self initWithNibName: @"OlderURL_ViewController" bundle: nil];
	
	return self;
}

-(void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	
	[tableData release];
	[searchData release];
	[urlTable release];
	[editButton release];
	[doneButton release];
	[urlSearch release];
	
	[super dealloc];
}

#pragma mark View Management
// View Management
-(void) viewDidLoad
{
	// Set the title.
	self.navigationItem.title = @"Past Websites";
	
//#ifndef IPAD
	// Set up the colors.
	//self.view.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed: @"Background_1.png"]];
	urlSearch.tintColor = self.navigationController.navigationBar.tintColor;
//#endif
	
	// And the buttons.
	editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemEdit 
																							target: self action: @selector(editAction:)];
	doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemDone 
															   target: self action: @selector(editAction:)];
	
	self.navigationItem.rightBarButtonItem = editButton;
	
	// Sign up for notifications.
	[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(updateInfo) 
												 name: FUURLManagerURLListDidChangeNotification object: [FUURLManager sharedManager]];
	
	self.searchData = [NSMutableArray array];
}

-(void) viewWillAppear: (BOOL) animated
{
	self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
	
	[self updateInfo];
	
	// Check for a selected row.
	if ( [urlTable indexPathForSelectedRow] != nil ) 
		[urlTable deselectRowAtIndexPath: [urlTable indexPathForSelectedRow] animated: YES];
	
	[super viewWillAppear: animated];
}

-(void) viewWillDisappear: (BOOL) animated
{
	[super viewWillDisappear: animated];
}

-(BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation
{
	if ( DEVICE_TYPE != kFUDeviceiPad )
		return ( toInterfaceOrientation == UIInterfaceOrientationPortrait 
				|| toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown );
	
	return YES;
}

#pragma mark User Interaction Management
// User Interaction Management
-(IBAction) editAction: (id) sender
{
	if ( urlTable.editing ) {
		
		[urlTable setEditing: NO animated: YES];
		
		[self.navigationItem setRightBarButtonItem: editButton animated: YES];
		
	} else {
		
		[urlTable setEditing: YES animated: YES];
		
		[self.navigationItem setRightBarButtonItem: doneButton animated: YES];
		
	}
}

#pragma mark Data Management
// Data Management
-(void) loadInfo
{
	self.tableData = [[NSMutableArray alloc] init];
	
	STANDARD_TABLE_DATA_ARRAY
	
	NEW_SECTION(@"");
	
	NSMutableArray *allURLs;
	
	if ( searchMode ) 
		allURLs = self.searchData;
	else 
		allURLs = [[FUURLManager sharedManager] urlList];
	
	for ( NSMutableDictionary *url in allURLs ) {
		
		UIImage *icon = [UIImage imageWithContentsOfFile: 
						 [DOCUMENTS_DIRECTORY stringByAppendingPathComponent: 
						  [url objectForKey: @"iconFileName"]]];
		
		[sectionData addObject: dictionaryForTableViewCellWithImage(UITableViewCellReuseIDSubtitle, 1, ( searchMode ) ? 0 : 1, 2, 
																   [url objectForKey: @"title"], 
																   [url objectForKey: @"url"], 
																	icon)];
		
	}
	
	[tableData addObject: eachSection];
	
	END_STANDARD_TABLE_DATA_ARRAY
}

-(void) updateInfo
{
	if ( BACKGROUND_MODE ) {
		
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(updateInfo) 
													 name: UIApplicationDidBecomeActiveNotification object: nil];
		
		return;
		
	}
	
	[[NSNotificationCenter defaultCenter] removeObserver: self name: UIApplicationDidBecomeActiveNotification object: nil];
	
	[self loadInfo];
	[urlTable reloadData];
}

#pragma mark -
#pragma mark Search Management
/* Search Management *\
\*********************/

#pragma mark Functionality
// Functionality
-(void) searchTable
{	
	// Get the text.
	NSString *searchText = urlSearch.text;
	
	// Set up the array.
	self.searchData = nil;
	self.searchData = [NSMutableArray array];
	
	NSMutableArray *urlList = [[FUURLManager sharedManager] urlList];
	
	// Enumerate through and search.
	for ( NSDictionary *eachURL in [[FUURLManager sharedManager] urlList] ) {
		
		// Go through each piece of the url data.
		for ( NSString *eachKey in eachURL ) {
			
			// We'll only compare strings for now.
			if ( ![[eachURL objectForKey: eachKey] isKindOfClass: [NSString class]] )
				continue;
			
			if ( [eachKey isEqualToString: @"iconFileName"] ) 
				continue;
			
			// Get the range.
			NSRange searchMatch = [[eachURL objectForKey: eachKey] rangeOfString: searchText options: NSCaseInsensitiveSearch];
			
			if ( searchMatch.location != NSNotFound ) {
				
				[searchData addObject: eachURL];
				
				break;
				
			}
		}
		
	}
}

-(IBAction) dismissSearch: (id) sender
{
	// Clear the data.
	self.searchData = nil;
	
	// Set the flags.
	self.searchMode = FALSE;
	self.canSelect = TRUE;
	
	// Resign the bar.
	[urlSearch resignFirstResponder];
	
	// Set the text.
	urlSearch.placeholder = urlSearch.text;
	urlSearch.text = nil;
	
	if ( urlSearch.placeholder == nil ) 
		urlSearch.placeholder = @"Search";
	
	// Get rid of the button.
	[self.navigationItem setLeftBarButtonItem: nil animated: YES];
	[self.navigationItem setRightBarButtonItem: editButton animated: YES];
	
	// Reload the table.
	[self updateInfo];
}

-(void) setCanSelect: (BOOL) yorn
{
	canSelect = yorn;
	
	urlTable.allowsSelection = canSelect;
	urlTable.scrollEnabled = canSelect;
}

#pragma mark Bar Delegation
// Bar Delegation
-(BOOL) searchBarShouldBeginEditing: (UISearchBar *) searchBar
{
	if ( urlTable.editing ) 
		return NO;
	
	return YES;
}

-(void) searchBarTextDidBeginEditing: (UISearchBar *) searchBar
{
	// Determine what to do.
	BOOL isNotNil = ( [searchBar.text length] > 0 );
	
	// Set the search flags.
	self.searchMode = isNotNil;
	self.canSelect = TRUE;
	
	// Add the Done button.
	UIBarButtonItem *searchDoneButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemDone target: self 
																		 action: @selector(dismissSearch:)] autorelease];
	
	[self.navigationItem setLeftBarButtonItem: searchDoneButton animated: YES];
	[self.navigationItem setRightBarButtonItem: nil animated: NO];
	
	// Set up the bar.
	if ( [urlSearch.placeholder isEqualToString: @"Search"] )
		urlSearch.placeholder = nil;
	
	urlSearch.text = urlSearch.placeholder;
	urlSearch.placeholder = nil;
	
	// Search if needed.
	if ( [urlSearch.text length] > 0 ) 
		[self searchTable];
	
	// Make the table fit, if needed.
	if ( DEVICE_TYPE != kFUDeviceiPad )
		urlTable.frame = CGRectMake(urlTable.frame.origin.x, urlTable.frame.origin.y, urlTable.frame.size.width, 156);
}

-(void) searchBar: (UISearchBar *) searchBar textDidChange: (NSString *) searchText
{
	// Determine what to do.
	BOOL isNotNil = ( [searchText length] > 0 ) ? TRUE : FALSE;
	
	// Update our flags.
	self.searchMode = isNotNil;
	self.canSelect = TRUE;
	
	if ( isNotNil ) 
		[self searchTable];
	
	[self updateInfo];
}

-(void) searchBarSearchButtonClicked: (UISearchBar *) searchBar
{
	[self searchTable];
	
	[urlSearch resignFirstResponder];
}

-(void) searchBarTextDidEndEditing: (UISearchBar *) searchBar
{
	// Make the table fit.
	if ( DEVICE_TYPE != kFUDeviceiPad )
		urlTable.frame = CGRectMake(urlTable.frame.origin.x, urlTable.frame.origin.y, urlTable.frame.size.width, 372);
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
	
	[cell setEditingAccessoryType: 0];
	
	[cellData release];
	
	return cell;
}

#pragma mark Edit Mode Setup
// Edit Mode Setup
-(UITableViewCellEditingStyle) tableView: (UITableView *) tableView editingStyleForRowAtIndexPath: (NSIndexPath *) indexPath
{
	return (UITableViewCellEditingStyle) INTVALUE([TABLE_DATA(IPSection, IPRow) objectForKey: @"editingStyle"]);
}

-(BOOL) tableView: (UITableView *) tableView shouldIndentWhileEditingRowAtIndexPath: (NSIndexPath *) indexPath
{
	if ( [TABLE_DATA(IPSection, IPRow) objectForKey: @"editingStyle"] != 0 )
		return YES;
	
	return NO;
}

#pragma mark User Interaction Management
// User Interaction Management
-(void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
	[urlSearch resignFirstResponder];
	
	// Get the data for the row.
	NSDictionary *currentURL;
	
	if ( searchMode ) 
		currentURL = [searchData objectAtIndex: IPRow];
	else 
		currentURL = [[FUURLManager sharedManager] URLAtIndex: IPRow];
	
	// Set up a URL view.
	URLInfo_ViewController *urlView = [[[URLInfo_ViewController alloc] init] autorelease];
	urlView.urlObj = currentURL;
	
#ifdef IPAD
	// Put it in a popover for iPad.
	UINavigationController *urlNav = [[[UINavigationController alloc] initWithRootViewController: urlView] autorelease];
	
	UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController: urlNav];
	popover.delegate = self;
	//popover.popoverContentSize = urlView.view.frame.size;
	
	CGRect cellRect = [tableView rectForRowAtIndexPath: indexPath];
	
	[popover presentPopoverFromRect: cellRect inView: tableView permittedArrowDirections: UIPopoverArrowDirectionAny animated: YES];
	
	return;
#endif
	
	// Push it.
	[self.navigationController pushViewController: urlView animated: YES];
	
	// Deprecated.
	/*NSString *openTitle = nil;
	
	if ( OS_VERSION >= kFUiOSVersion3_2 )
		openTitle = @"View Site";
	else 
		openTitle = @"Open in Safari";
	
	
	// Open an action sheet.
	UIActionSheet *urlSheet = [[[UIActionSheet alloc] initWithTitle: @"What would you like to do?" delegate: self 
												  cancelButtonTitle: @"Cancel" destructiveButtonTitle: nil 
												  otherButtonTitles: openTitle, @"Send This Site", nil] 
							   autorelease];
	
	// Set up the text for the scroll view.
	NSString *urlStr = [currentURL objectForKey: @"url"];
	NSString *senderName = [currentURL objectForKey: @"sendingDeviceName"];
	NSString *title = [currentURL objectForKey: @"title"];
	NSString *description = [currentURL objectForKey: @"description"];
	
	NSString *urlTextStr = [NSString stringWithFormat: @"Title: %@\nDescription: %@\nLink: %@\nFrom: %@", 
							title, description, urlStr, senderName];
	
	// Create a text popover.
	self.urlInfo = [[[UITextView alloc] initWithFrame: CGRectMake(5, -180, 310, 175)] autorelease];
	urlInfo.text = urlTextStr;
	urlInfo.textColor = [UIColor whiteColor];
	//urlInfo.font = [UIFont systemFontOfSize: 24.0];
	urlInfo.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent: .8];
	
	// Layering.
	CALayer *urlInfoLayer = [urlInfo layer];
	urlInfoLayer.masksToBounds = YES;
	urlInfoLayer.cornerRadius = 10.0;
	urlInfoLayer.borderColor = [UIColor whiteColor].CGColor;
	urlInfoLayer.borderWidth = 1;
	
	// Add it in. 
	if ( DEVICE_TYPE == kFUDeviceiPad ) {
		
		urlInfo.frame = CGRectMake(10, 10, 310, 175);
		[self.view addSubview: urlInfo];
		
	} else 
		[urlSheet addSubview: urlInfo];
	
	// Show the action sheet.
	[urlSheet showInView: self.view];*/
}

-(void) tableView: (UITableView *) tableView commitEditingStyle: (UITableViewCellEditingStyle) editingStyle 
forRowAtIndexPath: (NSIndexPath *) indexPath
{
	// Delete the URL.
	if ( searchMode ) 
		[[FUURLManager sharedManager] removeURL: [searchData objectAtIndex: IPRow]];
	else
		[[FUURLManager sharedManager] removeURLAtIndex: IPRow];
	
	// Reload the data.
	if ( searchMode ) 
		[self searchTable];
	
	[self loadInfo];
	
	// Remove the cell.
	if ( searchMode )
		[tableView reloadData];
	else 
		TABLE_UPDATE(tableView, [tableView deleteRowsAtIndexPaths: ARRAY(indexPath) withRowAnimation: UITableViewRowAnimationRight]);
}

#pragma mark -
#pragma mark Action Sheet Delegation
/* Action Sheet Delegation *\
\***************************/

-(void) actionSheet: (UIActionSheet *) actionSheet willDismissWithButtonIndex: (NSInteger) buttonIndex
{	
	[UIView beginAnimations: nil context: nil];
	[UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration: 0.15];
	
	urlInfo.alpha = 0.5;
	
	if ( DEVICE_TYPE == kFUDeviceiPad ) {
		
		urlInfo.alpha = 0.0;
		
		[urlInfo performSelector: @selector(removeFromSuperview) withObject: nil afterDelay: 0.15];
		[self performSelector: @selector(setUrlInfo:) withObject: nil afterDelay: 0.15];
		
	}
	
	urlInfo.frame = CGRectMake(5, 5, 310, 175);
	
	[UIView commitAnimations];
}

-(void) actionSheet: (UIActionSheet *) actionSheet didDismissWithButtonIndex: (NSInteger) buttonIndex
{
	FUURLManager *urlManager = [FUURLManager sharedManager];
	
	// Get the selected index.
	NSInteger index = [urlTable indexPathForSelectedRow].row;
	
	// Get the url.
	NSDictionary *selectedURL;
	
	if ( searchMode ) 
		selectedURL = [searchData objectAtIndex: index];
	else 
		selectedURL = [urlManager URLAtIndex: index];
	
	if ( buttonIndex == 0 ) {
		
		if ( OS_VERSION >= kFUiOSVersion3_2 ) {
			
			// Open the fullscreen browser.
			WebView_ViewController *webView = [[[WebView_ViewController alloc] init] autorelease];
			
			[webView loadViewWithURL: selectedURL];
			
			// Push it.
			[self.navigationController pushViewController: webView animated: YES];
			
		} else {
			
			// Open.
			[urlManager openURL: selectedURL];
			
		}
		
	} else if ( buttonIndex == 1 ) {
		
		// Set up a send view.
		SendURL_ViewController *sendView = [[[SendURL_ViewController alloc] init] autorelease];
		
		[sendView loadViewWithURL: selectedURL];
		
		// Push it.
		[self.navigationController pushViewController: sendView animated: YES];
		
	} else if ( buttonIndex == 2 ) {
		
		// Cancelled, do nothing.
		
	}
	
	[urlTable deselectRowAtIndexPath: [urlTable indexPathForSelectedRow] animated: YES];
}

@end

#pragma mark -
#pragma mark Popover Delegation
/* Popover Delegation *\
\**********************/

#ifdef IPAD
@implementation PreviousURLs_ViewController (PopoverDelegation)

-(void) popoverControllerDidDismissPopover: (UIPopoverController *) popover
{
	[urlTable deselectRowAtIndexPath: [urlTable indexPathForSelectedRow] animated: YES];
}

@end
#endif