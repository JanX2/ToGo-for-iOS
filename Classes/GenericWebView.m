//
//  GenericWebView.m
//  ProveIt
//
//  Created by Drew R. Hood on 20.3.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GenericWebView.h"


@implementation GenericWebView

@synthesize viewTitle, viewURL;
@synthesize myWebView;

+(GenericWebView *) viewWithTitle: (NSString *) theTitle andURL: (NSString *) theURL
{
	return [[[[self class] alloc] initWithTitle: theTitle andURL: theURL] autorelease];
}

-(GenericWebView *) initWithTitle: (NSString *) theTitle andURL: (NSString *) theURL
{
	self = [self initWithNibName: @"GenericWebView" bundle: nil];
	
	if ( self ) {
		
		self.hidesBottomBarWhenPushed = TRUE;
		
		viewTitle = theTitle;
		viewURL = theURL;
		
	}
	
	return self;
}

- (void)dealloc
{
	[myWebView release];
	[viewTitle release];
	[viewURL release];
	
	[super dealloc];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.title = LOCAL(viewTitle);
	
	[self.myWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString: viewURL]]];
}

-(IBAction) safariAction: (id) sender
{
	[[UIApplication sharedApplication] openURL: [NSURL URLWithString: viewURL]];
}

// called after the view controller's view is released and set to nil.
// For example, a memory warning which causes the view to be purged. Not invoked as a result of -dealloc.
// So release any properties that are loaded in viewDidLoad or can be recreated lazily.
//
- (void)viewDidUnload
{
	[super viewDidUnload];
	
	// release and set to nil
	self.myWebView = nil;
}


#pragma mark -
#pragma mark UIViewController delegate methods

- (void)viewWillAppear:(BOOL)animated
{
	self.myWebView.delegate = self;	// setup the delegate as the web view is shown
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.myWebView stopLoading];	// in case the web view is still loading its content
	self.myWebView.delegate = nil;	// disconnect the delegate as the webview is hidden
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// we support rotation in this view controller
	return YES;
}

// this helps dismiss the keyboard when the "Done" button is clicked
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	[self.myWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[textField text]]]];
	
	return YES;
}


#pragma mark -
#pragma mark UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	// starting the load, show the activity indicator in the status bar
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	// finished loading, hide the activity indicator in the status bar
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	if ([error code] != -999) {
		//show error alert, etc.
		
		// load error, hide the activity indicator in the status bar
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		
		// report the error inside the webview
		NSString* errorString = [NSString stringWithFormat:
								 @"<html><center><font size=+5 color='red'>An error occurred:<br>%@</font></center></html>",
								 error.localizedDescription];
		[self.myWebView loadHTMLString:errorString baseURL:nil];
		
	}
}

@end