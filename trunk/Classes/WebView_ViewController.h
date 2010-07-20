/******************************\
	Web View View Controller
\******************************/

// Dependencies
#import <UIKit/UIKit.h>

// Forward Declarations
@class FUURLManager;

@interface WebView_ViewController : UIViewController <UIWebViewDelegate, UIActionSheetDelegate>
{
	// Data
	NSDictionary *urlObj;
	
	// Flags
	BOOL navUp;
	
	// User Interaction
	UITapGestureRecognizer *tapGesture;
	
	// View
	UILabel *instructionsLabel;
	UIActivityIndicatorView *pinWheel;
	UIWebView *urlView;
	UIToolbar *controlBar;
	UIBarButtonItem *backButton, *forwardButton, *stopButton;
}

#pragma mark Properties
// Properties
@property (nonatomic, retain) NSDictionary *urlObj;
@property (nonatomic, retain) UITapGestureRecognizer *tapGesture;
@property (nonatomic, retain) IBOutlet UILabel *instructionsLabel;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *pinWheel;
@property (nonatomic, retain) IBOutlet UIWebView *urlView;
@property (nonatomic, retain) IBOutlet UIToolbar *controlBar;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *backButton, *forwardButton, *stopButton;

#pragma mark Instance Management
// Instance Management
-(void) loadViewWithURL: (NSDictionary *) theURL;
-(void) dealloc;

#pragma mark View Management
// View Management
-(void) viewDidLoad;
-(void) viewWillAppear: (BOOL) animated;
-(void) viewDidAppear: (BOOL) animated;
-(void) viewWillDisappear: (BOOL) animated;
-(BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation;
-(void) willRotateToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation duration: (NSTimeInterval) duration;
-(void) didRotateFromInterfaceOrientation: (UIInterfaceOrientation) fromInterfaceOrientation;
-(void) showNav;
-(void) hideNav;
-(void) checkButtons;

#pragma mark User Interaction Management
// User Interaction Management
-(IBAction) touchAction: (id) sender;
-(IBAction) navigationAction: (id) sender;
-(IBAction) safariAction: (id) sender;

#pragma mark -
#pragma mark Web View Management
/* Web View Management *\
\***********************/

#pragma mark Setup
// Setup
-(void) loadHome;

#pragma mark Delegation
// Delegation
-(void) webViewDidStartLoad: (UIWebView *) webView;
-(void) webViewDidFinishLoad: (UIWebView *) webView;
-(BOOL) webView: (UIWebView *) webView shouldStartLoadWithRequest: (NSURLRequest *) request 
 navigationType: (UIWebViewNavigationType) navigationType;
-(void) webView: (UIWebView *) webView didFailLoadWithError: (NSError *) error;

#pragma mark -
#pragma mark Action Sheet Delegation
/* Action Sheet Delegation *\
\***************************/

-(void) actionSheet: (UIActionSheet *) actionSheet didDismissWithButtonIndex: (NSInteger) buttonIndex;

@end