/*******************************\
	Main View View Controller
\*******************************/

// Dependencies
#import <UIKit/UIKit.h>

// Forward Declarations
@class FUURLManager;
@class PreviousURLs_ViewController;
//@class PairingRemote_ViewController;
@class SendURL_ViewController;
#ifdef IPAD
@class WebView_ViewController;
#endif

@interface MainView_ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIWebViewDelegate>
{
	// Data
	NSMutableDictionary *currentURL;
	NSMutableArray *tableData;
	NSString *urlTextStr;
	
	// View
	UIWebView *urlText;
	UILabel *noURLsLabel, *detailsLabel;
	UITableView *urlTable;
	UIWebView *urlView;
	UIBarButtonItem *openInSafariButton;
	UIView *webViewContainer;
	UIActivityIndicatorView *activityIndicator;
}

#pragma mark Properties 
// Properties
@property (nonatomic, retain) NSMutableDictionary *currentURL;
@property (nonatomic, retain) NSMutableArray *tableData;
@property (nonatomic, retain) NSString *urlTextStr;
@property (nonatomic, retain) IBOutlet UIWebView *urlText;
@property (nonatomic, retain) IBOutlet UILabel *noURLsLabel, *detailsLabel;
@property (nonatomic, retain) IBOutlet UITableView *urlTable;
@property (nonatomic, retain) IBOutlet UIWebView *urlView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *openInSafariButton;
@property (nonatomic, retain) IBOutlet UIView *webViewContainer;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;

#pragma mark Instance Management
// Instance Management
+(MainView_ViewController *) sharedController;
-(void) dealloc;

#pragma mark View Management
// View Management
-(void) viewDidLoad;
-(void) viewWillAppear: (BOOL) animated;
-(void) viewWillDisappear: (BOOL) animated;
-(BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation;
-(void) willAnimateSecondHalfOfRotationFromInterfaceOrientation: (UIInterfaceOrientation) fromInterfaceOrientation 
													   duration: (NSTimeInterval) duration;
#pragma mark User Interaction Management
// User Interaction Management
//-(IBAction) settingsAction: (id) sender;
-(IBAction) safariAction: (id) sender;
-(IBAction) browseAction: (id) sender;

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
#pragma mark Web View Delegation
/* Web View Delegation *\
\***********************/

-(void) webViewDidStartLoad: (UIWebView *) webView;
-(void) webViewDidFinishLoad: (UIWebView *) webView;
-(BOOL) webView: (UIWebView *) webView shouldStartLoadWithRequest: (NSURLRequest *) request 
 navigationType: (UIWebViewNavigationType) navigationType;
-(void) webView: (UIWebView *) webView didFailLoadWithError: (NSError *) error;

#pragma mark -
#pragma mark Alert View Delegation
/* Alert View Delegation *\
\*************************/

-(void) alertView: (UIAlertView *) alertView didDismissWithButtonIndex: (NSInteger) buttonIndex;

@end