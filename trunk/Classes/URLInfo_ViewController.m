/**************\
	URL Info
\**************/

// Dependencies
#import "URLInfo_ViewController.h"

#import "Functions.h"

// Typedefs
typedef enum {
	kTableSectionOpenURL,
	kTableSectionSendURL,
	kTableSectionDelete
} TableSection;

#pragma mark Macros
// Macros
#define TABLE_DATA(a, b) [[[tableData objectAtIndex: a] objectForKey: @"data"] objectAtIndex: b]

@implementation URLInfo_ViewController

#pragma mark Properties
// Properties
@synthesize delegate;
@synthesize urlObj;
@synthesize tableData;
@synthesize urlTextStr;
@synthesize detailsLabel;
@synthesize urlText;
@synthesize urlTable;

#pragma mark Instance Management
// Instance Management
-(void) loadViewWithURL: (NSMutableDictionary *) url
{
	self.urlObj = url;
}

-(void) dealloc
{
	[urlObj release];
	[tableData release];
	[urlTextStr release];
	[detailsLabel release];
	[urlText release];
	[urlTable release];
	
	[super dealloc];
}

#pragma mark View Management
// View Management
-(void) viewDidLoad
{
	// Set the title.
	self.navigationItem.title = LOCAL(@"Site Info");
	
	// Set local text.
	detailsLabel.text = LOCAL(@"Details");
	
	self.view.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed: @"Background_iPhone.png"]];
	urlTable.backgroundColor = [UIColor clearColor];
#ifdef IPAD
	urlTable.backgroundView = nil;
#endif
	
	// Now the corner radius for the text view.
	CALayer *textViewLayer = [urlText layer];
	textViewLayer.masksToBounds = YES;
	textViewLayer.cornerRadius = 10.0;
	textViewLayer.borderColor = [[UIColor grayColor] CGColor];
	textViewLayer.borderWidth = 1.0;
}

-(void) viewWillAppear: (BOOL) animated
{
	[self loadInfo];
	[urlTable reloadData];
	
	[super viewWillAppear: animated];
}

-(void) viewWillDisappear: (BOOL) animated
{
	[super viewWillDisappear: animated];
}

#pragma mark Data Management
// Data Management
-(void) loadInfo
{
	// Set up the URL text view.
	NSString *urlStr = [urlObj objectForKey: @"url"];
	NSString *senderName = [urlObj objectForKey: @"sendingDeviceName"];
	NSString *title = ( [urlObj objectForKey: @"title"] == nil ) ? @"No Title" : [urlObj objectForKey: @"title"];
	NSString *description = ( [urlObj objectForKey: @"description"] == nil ) ? urlStr : [urlObj objectForKey: @"description"];
	
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
					   [DOCUMENTS_DIRECTORY stringByAppendingPathComponent: [urlObj objectForKey: @"iconFileName"]], 
					   LOCAL(title), LOCAL(description), LOCAL(@"Sent from"), senderName];
	
	[urlText loadHTMLString: urlTextStr baseURL: nil];
	
	// The table.
	self.tableData = [[NSMutableArray alloc] init];
	
	STANDARD_TABLE_DATA_ARRAY
	
	NEW_SECTION(@"");
	
	// Determine what to say.
	NSString *safariTitle = nil;
	
	if ( OS_VERSION >= kFUiOSVersion3_2 )
		safariTitle = LOCAL(@"View Site");
	else 
		safariTitle = LOCAL(@"Open in Safari");
	
	[sectionData addObject: dictionaryForTableViewCell(UITableViewCellReuseIDDefault, 1, 0, 2, safariTitle, nil)];
	
	[tableData addObject: eachSection];
	END_SECTION;
	
	NEW_SECTION(@"");
	
	[sectionData addObject: dictionaryForTableViewCell(UITableViewCellReuseIDDefault, 1, 0, 2, LOCAL(@"Send this Website"), nil)];
	
	[tableData addObject: eachSection];
	END_SECTION;
	
	NEW_SECTION(@"");
	
	[sectionData addObject: dictionaryForTableViewCell(UITableViewCellReuseIDDefault, 1, 0, 2, LOCAL(@"Delete this Website"), nil)];
	
	[tableData addObject: eachSection];
	END_SECTION;
	
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
	
#ifdef IPAD
	if ( delegate != nil ) {
			
		if ( IPSection == 2 ) {
			
			UIActionSheet *deleteConfirm = [[[UIActionSheet alloc] initWithTitle: nil delegate: self cancelButtonTitle: LOCAL(@"Cancel") 
														  destructiveButtonTitle: LOCAL(@"Delete") otherButtonTitles: nil] autorelease];
			
			[deleteConfirm showInView: self.view];
			
			return;
			
		}
		
		[delegate urlInfoView: self didRequestAction: IPSection];
		
		return;
		
	}
#endif
	
	if ( IPSection == kTableSectionOpenURL ) {
		
		if ( OS_VERSION >= kFUiOSVersion3_2 ) {
			
			// Set up a web view.
			WebView_ViewController *webView = [[[WebView_ViewController alloc] init] autorelease];
			
			// Load the url.
			[webView loadViewWithURL: urlObj];
			
			// Push it.
			[self.navigationController pushViewController: webView animated: YES];
			
		} else {
			
			[[FUURLManager sharedManager] openURL: urlObj];
			
		}
		
	} else if ( IPSection == kTableSectionDelete ) {
		
		UIActionSheet *deleteConfirm = [[[UIActionSheet alloc] initWithTitle: nil delegate: self cancelButtonTitle: LOCAL(@"Cancel") 
													  destructiveButtonTitle: LOCAL(@"Delete") otherButtonTitles: nil] autorelease];
		
		[deleteConfirm showInView: self.view];
		
	} else if ( IPSection == kTableSectionSendURL ) {
		
		// Set up a send view.
		SendURL_ViewController *sendView = [[[SendURL_ViewController alloc] init] autorelease];
		
		[sendView loadViewWithURL: urlObj];
		
		[self.navigationController pushViewController: sendView animated: YES];
		
	}
}

#pragma mark -
#pragma mark Action Sheet Delegation
/* Action Sheet Delegation *\
\***************************/

-(void) actionSheet: (UIActionSheet *) actionSheet didDismissWithButtonIndex: (NSInteger) buttonIndex
{
	if ( buttonIndex == 0 ) {
		
		// Do it.
		[[FUURLManager sharedManager] removeURL: urlObj];
		
		// Get out.
		[self.navigationController popViewControllerAnimated: YES];
		
#ifdef IPAD
		// If we're on an iPad, notify the delegate.
		if ( delegate != nil ) {
			
			if ( [delegate respondsToSelector: @selector(urlInfoView:didRequestAction:)] ) {
				
				[delegate urlInfoView: self didRequestAction: kURLInfoActionDelete];
				
				return;
				
			}
			
		}
#endif
		
	}
}

@end