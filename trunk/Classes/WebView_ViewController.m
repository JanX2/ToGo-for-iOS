/******************************\
	Web View View Controller
\******************************/

// Dependencies
#import "WebView_ViewController.h"

@implementation WebView_ViewController

#pragma mark Properties
// Properties
@synthesize urlObj;
@synthesize tapGesture;
@synthesize instructionsLabel;
@synthesize pinWheel;
@synthesize urlView;
@synthesize controlBar;
@synthesize backButton, forwardButton, stopButton;

#pragma mark Instance Management
// Instance Management
-(void) loadViewWithURL: (NSDictionary *) theURL
{
	self.urlObj = theURL;
}

-(void) dealloc
{
	[urlObj release];
	[tapGesture release];
	[instructionsLabel release];
	[urlView release];
	[controlBar release];
	[backButton release];
	[forwardButton release];
	[stopButton release];
	
	[super dealloc];
}

#pragma mark View Management
// View Management
-(void) viewDidLoad
{
	// Set the title.
	self.navigationItem.title = ( [urlObj objectForKey: @"title"] == nil ) ? @"Browser" : [urlObj objectForKey: @"title"];
	
#ifndef IPAD
	// Add the button.
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemAction 
																							target: self action: @selector(safariAction:)] autorelease];
#endif
	
	// Start off without navigation.
	self.navigationController.navigationBar.alpha = 0.0;
	controlBar.alpha = 0.0;
	navUp = FALSE;
	
	// Set up the tap gesture.
	self.tapGesture = [[[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(touchAction:)] autorelease];
	tapGesture.numberOfTouchesRequired = 2;
	tapGesture.numberOfTapsRequired = 1;
	[urlView addGestureRecognizer: tapGesture];
	
	// The swipes.
	/*UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget: urlView action: @selector(goBack)];
	swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
	swipeLeft.numberOfTouchesRequired = 2;
	swipeLeft.cancelsTouchesInView = TRUE;
	swipeLeft.delaysTouchesBegan = TRUE;
	
	UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget: urlView action: @selector(goForward)];
	swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
	swipeRight.numberOfTouchesRequired = 2;
	swipeLeft.cancelsTouchesInView = TRUE;
	swipeLeft.delaysTouchesBegan = TRUE;
	
	[urlView addGestureRecognizer: swipeLeft];
	[urlView addGestureRecognizer: swipeRight];*/
	
	// Load the page.
	[self loadHome];
	
	// Handle the instructions.
	CALayer *instructionsLayer = [instructionsLabel layer];
	instructionsLayer.masksToBounds = YES;
	instructionsLayer.cornerRadius = 23.0;
	
	[UIView beginAnimations: nil context: nil];
	[UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration: 0.5];
	[UIView setAnimationDelay: 1.5];
	
	instructionsLabel.alpha = 0.0;
	
	[UIView commitAnimations];
}

-(void) viewWillAppear: (BOOL) animated
{	
	// Set up the navigation bar.
	self.navigationController.navigationBar.tintColor = nil;
	self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
#ifdef IPAD
	[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackOpaque;
#else
	[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackTranslucent;
#endif
	//[UIApplication sharedApplication].statusBarHidden = TRUE;
	
	[super viewWillAppear: animated];
}

-(void) viewDidAppear: (BOOL) animated
{
	if ( [INTERNET_MONTITOR currentReachabilityStatus] == NotReachable )
		[self.navigationController popViewControllerAnimated: YES];
}

-(void) viewWillDisappear: (BOOL) animated
{
	// Set up the navigation bar.
	self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
	[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
	[[UIApplication sharedApplication] setStatusBarHidden: NO];
	//[UIApplication sharedApplication].statusBarHidden = FALSE;
	
	[urlView stopLoading];
	
	HIDE_NETWORK_INDICATOR;
	
	[super viewWillDisappear: animated];
}

-(BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation
{
	instructionsLabel.center = urlView.center;
	
#ifndef IPAD
	return ( toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown );
#endif
	
	return YES;
}

-(void) willRotateToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation duration: (NSTimeInterval) duration
{
	if ( controlBar.alpha == 0.0 )
		navUp = FALSE;
	else 
		navUp = TRUE;
	
	[self showNav];
}

-(void) didRotateFromInterfaceOrientation: (UIInterfaceOrientation) fromInterfaceOrientation
{
	if ( !navUp )
		[self performSelector: @selector(hideNav) withObject: nil afterDelay: 1.5];
}

-(void) showNav
{
	//self.navigationController.navigationBar.alpha = 0.0;
	//controlBar.alpha = 0.0;
	
#ifdef IPAD
	[[UIApplication sharedApplication] setStatusBarHidden: FALSE withAnimation: UIStatusBarAnimationFade];
#endif
	
	[UIView beginAnimations: nil context: nil];
	[UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration: 0.5];
	
	self.navigationController.navigationBar.alpha = 1.0;
	controlBar.alpha = 1.0;
	
	[UIView commitAnimations];
}

-(void) hideNav
{
	//self.navigationController.navigationBar.alpha = 1.0;
	//controlBar.alpha = 1.0;
	
#ifdef IPAD
	[[UIApplication sharedApplication] setStatusBarHidden: TRUE withAnimation: UIStatusBarAnimationFade];
#endif
	
	[UIView beginAnimations: nil context: nil];
	[UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration: 0.5];
	
	self.navigationController.navigationBar.alpha = 0.0;
	controlBar.alpha = 0.0;
	
	[UIView commitAnimations];
}

-(void) checkButtons
{
	backButton.enabled = urlView.canGoBack;
	forwardButton.enabled = urlView.canGoForward;
	stopButton.enabled = urlView.loading;
}

#pragma mark User Interaction Management
// User Interaction Management
-(IBAction) touchAction: (id) sender
{
	if ( controlBar.alpha == 0 ) 
		[self showNav];
	else 
		[self hideNav];
}

-(IBAction) navigationAction: (id) sender
{
	int tag = [sender tag];
	
	switch ( tag ) {
		case 0:
			[self loadHome];
			break;
		case 1:
			[urlView goBack];
			break;
		case 2:
			[urlView goForward];
			break;
		case 3:
			[urlView stopLoading];
			HIDE_NETWORK_INDICATOR;
			[pinWheel stopAnimating];
			[self performSelector: @selector(hideNav) withObject: nil afterDelay: 3.0];
			[self checkButtons];
			break;
		case 4:
			[urlView reload];
			break;
	}
}

-(IBAction) safariAction: (id) sender
{
#ifndef IPAD
	// Confirm.
	UIActionSheet *safariConfirm = [[[UIActionSheet alloc] initWithTitle: nil delegate: self cancelButtonTitle: @"Cancel" 
												  destructiveButtonTitle: nil otherButtonTitles: @"Open in Safari", nil] autorelease];
	
	[safariConfirm showInView: self.view];
	
	return;
#endif
	
	[[FUURLManager sharedManager] openURL: urlObj];
}

#pragma mark -
#pragma mark Web View Management
/* Web View Management *\
\***********************/

#pragma mark Setup
// Setup
-(void) loadHome
{
	// Stop loading.
	[urlView stopLoading];
	
	// Set up the url.
	NSURL *url = [NSURL URLWithString: [urlObj objectForKey: @"url"]];
	NSURLRequest *request = [NSURLRequest requestWithURL: url];
	
	// Load it.
	[urlView loadRequest: request];
}

#pragma mark Delegation
-(void) webViewDidStartLoad: (UIWebView *) webView
{
	SHOW_NETWORK_INDICATOR;
	
	if ( controlBar.alpha == 0.0 ) 
		navUp = FALSE;
	else 
		navUp = TRUE;
	
	[self showNav];
	
	[pinWheel startAnimating];
	
	[self checkButtons];
}

-(void) webViewDidFinishLoad: (UIWebView *) webView
{
	HIDE_NETWORK_INDICATOR;
	
	if ( !navUp )
		[self performSelector: @selector(hideNav) withObject: nil afterDelay: 3.0];
	
	[pinWheel stopAnimating];
	
	[self checkButtons];
}

-(BOOL) webView: (UIWebView *) webView shouldStartLoadWithRequest: (NSURLRequest *) request 
 navigationType: (UIWebViewNavigationType) navigationType
{
	return YES;
}

-(void) webView: (UIWebView *) webView didFailLoadWithError: (NSError *) error
{
	if ([error code] != -999) {
		//show error alert, etc.
		
		// load error, hide the activity indicator in the status bar
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		
		// report the error inside the webview
		NSString* errorString = [NSString stringWithFormat:
								 @"<html><center><font size=+5 color='red'>An error occurred:<br>%@</font></center></html>",
								 error.localizedDescription];
		[self.urlView loadHTMLString:errorString baseURL:nil];
		
		[self checkButtons];
		
	} /* else {
		
		// report the error inside the webview
		NSString* errorString = [NSString stringWithFormat:
								 @"<html><center><font size=100 color='red'>O_O Something died.</font></center></html>",
								 error.localizedDescription];
		[self.urlView loadHTMLString:errorString baseURL:nil];
		
		[urlView reload];
		
	}*/
}

#pragma mark -
#pragma mark Action Sheet Delegation
/* Action Sheet Delegation *\
\***************************/

-(void) actionSheet: (UIActionSheet *) actionSheet didDismissWithButtonIndex: (NSInteger) buttonIndex
{
	if ( buttonIndex == 0 ) {
		
		// Do. 
		[[FUURLManager sharedManager] openURL: urlObj];
		
	} else {
		
		// Don't do.
		
	}
}

@end