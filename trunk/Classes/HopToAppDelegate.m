/********************************\
	HopTo Application Delegate
\********************************/

// Dependencies
#import "HopToAppDelegate.h"

#pragma mark Globals
// Globals
static id kSharedDelegate;

@implementation HopToAppDelegate

#pragma mark Properties
// Properties
@synthesize urlServer;
@synthesize urlClients;
@synthesize wifiMonitor;
@synthesize internetMonitor;
@synthesize osVersion;
@synthesize deviceType;
@synthesize backgroundMode, firstLaunchMode, wifi;
@synthesize appBundle, documentsDirectory;
@synthesize deviceToken, deviceAlias;
@synthesize incomingMessage;
@synthesize window;
@synthesize navigationController;

#pragma mark Instance Management
// Instance Management
+(id) sharedDelegate
{
	return kSharedDelegate;
}

-(void) dealloc 
{
	[urlServer release];
	[urlClients release];
	[wifiMonitor release];
	[internetMonitor release];
	[appBundle release];
	[documentsDirectory release];
	[deviceAlias release];
	[deviceToken release];
	[incomingMessage release];
	[navigationController release];
	[window release];
	
	[super dealloc];
}

#pragma mark Setters & Getters
// Setters & Getters
-(BOOL) wifi
{
	return wifi;
	
	return [self checkReachablility];
}

#pragma mark Application Lifecycle Management
// Application Lifecycle Management
-(BOOL) application: (UIApplication *) application didFinishLaunchingWithOptions: (NSDictionary *) launchOptions
{
	NSLog(@"Welcome to HopTo! Launch options = %@ %@", launchOptions, [[UIDevice currentDevice] model]);
	
	kSharedDelegate = self;
	
	application.statusBarStyle = UIStatusBarStyleDefault;
	
	// Set the OS Version.
	osVersion = [[[[UIDevice currentDevice] systemVersion] stringByReplacingOccurrencesOfString: @"." withString: @""] doubleValue] * 100;
	
	// Determine the device.
	if ( osVersion >= kFUiOSVersion3_2 )
		deviceType = (int) ( [[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPhone );
	else 
		deviceType = 0;
	
	self.wifi = YES;
	
	[self startURLServer];
	
	// Set up Reachability.
	self.wifiMonitor = [Reachability reachabilityForLocalWiFi];
	[wifiMonitor startNotifer];
	
	self.internetMonitor = [Reachability reachabilityForInternetConnection];
	[internetMonitor startNotifer];
	
	[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(checkReachablility:) 
												 name: kReachabilityChangedNotification object: wifiMonitor];
	
	[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(internetReachabilityDidChange:) 
												 name: kReachabilityChangedNotification object: internetMonitor];
	
	// Determine if this is first launch mode.
	self.firstLaunchMode = [self determineFirstLaunchMode];
	
	[[NSUserDefaults standardUserDefaults] setBool: YES forKey: FUHTLaunchedUserDefaultsKey];
	
	// Set up the directories.
	self.appBundle = [[NSBundle mainBundle] bundlePath];
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *basePath = ( [paths count] > 0 ) ? [paths objectAtIndex: 0] : nil;
	
	self.documentsDirectory = basePath;
	
	[self checkReachablility: nil];
	[self internetReachabilityDidChange: nil];
	
	// Defaults Override
	[[NSUserDefaults standardUserDefaults] setBool: TRUE forKey: @"FU_Debug_Mode"];
	[[NSUserDefaults standardUserDefaults] setBool: TRUE forKey: @"FU_Memory_Mode"];
	[[NSUserDefaults standardUserDefaults] setBool: TRUE forKey: @"FU_Core_Data_Logging"];
	
	/*if ( launchOptions && [launchOptions objectForKey: UIApplicationLaunchOptionsRemoteNotificationKey] != nil ) {
		
		NSDictionary *notification = [launchOptions objectForKey: UIApplicationLaunchOptionsRemoteNotificationKey];
		
		FUURLManager *urlManager = [FUURLManager sharedManager];
		
		[urlManager addURL: [notification objectForKey: @"url"] from: [notification objectForKey: @"sender"]];
		
		[urlManager openURL: urlManager.currentURL];
		
		return YES;
		
	}*/
	
	navigationController.navigationBar.tintColor = [UIColor colorWithRed: 0.28627451 green: 0.58039216 blue: 0.79607843 alpha: 1.0];
	
	[window addSubview: [navigationController view]];
	[window makeKeyAndVisible];
	
	/*// Handle a URL launch.
	if ( launchOptions != nil && [launchOptions objectForKey: UIApplicationLaunchOptionsURLKey] != nil ) {
		
		// Get the url.
		NSString *urlStr = [[[launchOptions objectForKey: UIApplicationLaunchOptionsURLKey] absoluteString] 
							stringByReplacingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
		
		NSLog(@"urlStr = %@", urlStr);
		
		NSString *urlSource = [urlStr stringByReplacingOccurrencesOfString: @"togo://send/?url=" withString: @""];
		
		NSLog(@"URL source = %@", urlSource);
		
		//NSMutableDictionary *url = [[urlObj query] explodeToDictionaryInnerGlue: @"=" outterGlue: @"&"];
		
		//[[FUURLManager sharedManager] addURL: urlSource from: DEVICE_NAME];
		
	}*/
	
continueLaunch: ;
	
	return YES;
}

-(void) application: (UIApplication *) application handleOpenURL: (NSURL *) url
{
	NSString *urlStr = [[url absoluteString] stringByReplacingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
	
	//NSURL *urlObj = [NSURL URLWithString: urlStr];
	
	NSString *urlSource = [urlStr stringByReplacingOccurrencesOfString: @"togo://send/?url=" withString: @""];
	
	[[FUURLManager sharedManager] addURL: urlSource from: DEVICE_NAME];
}

-(void) applicationWillResignActive: (UIApplication *) application
{
	[[FUURLManager sharedManager] saveDown];
	
	self.backgroundMode = TRUE;
}

-(void) applicationDidBecomeActive: (UIApplication *) application
{
	self.backgroundMode = FALSE;
}

-(void) applicationDidEnterBackground: (UIApplication *) application
{
	NSLog(@"Entering background.");
	
	[self stopURLServer];
	
	self.backgroundMode = TRUE;
	
	/*UIBackgroundTaskIdentifier bgTask;
	
	NSAssert(bgTask == UIBackgroundTaskInvalid, nil);
	
	bgTask = [application beginBackgroundTaskWithExpirationHandler: ^{
	
		NSLog(@"Entering background.");
		
		[urlServer stop];
		self.urlServer = nil;
		
		self.backgroundMode = TRUE;
		
		dispatch_async(dispatch_get_main_queue(), ^{
			
			if ( bgTask != UIBackgroundTaskInvalid ) {
				
				[application endBackgroundTask: bgTask];
				
			}
			
		});
		
	}];
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		
		[[NSRunLoop currentRunLoop] run];
		
		NSLog(@"Entering background.");
		
		[urlServer stop];
		self.urlServer = nil;
		
		self.backgroundMode = TRUE;
		
		dispatch_async(dispatch_get_main_queue(), ^{
			
			if ( bgTask != UIBackgroundTaskInvalid ) {
				
				[application endBackgroundTask: bgTask];
				
			}
			
		});
		
	});*/
}

-(void) applicationWillEnterForeground: (UIApplication *) application
{
	NSLog(@"Entering foreground.");
	
	[self startURLServer];
	
	self.backgroundMode = FALSE;
}

-(void) applicationWillTerminate: (UIApplication *) application
{
	[[NSUserDefaults standardUserDefaults] setBool: YES forKey: FUHTLaunchedUserDefaultsKey];
	
	[self performSelectorOnMainThread: @selector(stopURLServer) withObject: nil waitUntilDone: YES];
	
	while ( urlServer != nil )
		;
	
	// Save data if appropriate
	[[FUURLManager sharedManager] saveDown];
	
	NSLog(@"ThankoooComAgayynnn");
}

-(BOOL) determineFirstLaunchMode
{
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	
	if ( ![defs boolForKey: FUHTLaunchedUserDefaultsKey] )
		return YES;
	
	return NO;
}

-(void) showNewURLAlert
{
	[[NSNotificationCenter defaultCenter] removeObserver: self name: FUURLManagerNewURLAddedNotification object: nil];
	
	// Grab the new URL.
	NSDictionary *theURL = [FUURLManager sharedManager].currentURL;
	
	// Create the alert view.
	UIAlertView *urlAlert = [[[UIAlertView alloc] initWithTitle: LOCAL(@"New Site") 
														message:  STRING_WITH_FORMAT(@"%@ %@ %@. %@",
																					 [theURL objectForKey: @"title"], 
																					 LOCAL(@"New URL Part 1"),
																					 [theURL objectForKey: @"sendingDeviceName"],
																					 LOCAL(@"New URL Part 2"))
													   delegate: self cancelButtonTitle: LOCAL(@"Not Now") 
											  otherButtonTitles: LOCAL(@"View"), nil] autorelease];
	
	if ( deviceType == kFUDeviceiPad ) {
		
		
		if ( [navigationController visibleViewController] != [MainView_ViewController sharedController] ) 
			[urlAlert show];
		
	} else 
		[urlAlert show];
}

/*
#pragma mark -
#pragma mark Push Notification Registration
// Push Notification Registration
-(void) application: (UIApplication *) application didRegisterForRemoteNotificationsWithDeviceToken: (NSData *) theDeviceToken
{
	
#if !TARGET_IPHONE_SIMULATOR
	
	// Prepare the Device Token for Registration (remove spaces and < >)
	self.deviceToken = [[[[theDeviceToken description] 
						  stringByReplacingOccurrencesOfString:@"<"withString:@""] 
						 stringByReplacingOccurrencesOfString:@">" withString:@""] 
						stringByReplacingOccurrencesOfString: @" " withString: @""];
	
	// Build URL String for Registration
	// !!! CHANGE "www.mywebsite.com" TO YOUR WEBSITE. Leave out the http://
	// !!! SAMPLE: "secure.awesomeapp.com"
	//NSString *host = @"https://go.urbanairship.com/";
	
	//NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
    self.deviceAlias = [[UIDevice currentDevice] uniqueIdentifier];
	
	// Display the network activity indicator
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	// We like to use ASIHttpRequest classes, but you can make this register call how ever you like
	// just notice that it's an http PUT
	NSOperationQueue *queue = [[[NSOperationQueue alloc] init] autorelease];
	NSString *UAServer = @"https://go.urbanairship.com";
	NSString *urlString = [NSString stringWithFormat:@"%@%@%@/", UAServer, @"/api/device_tokens/", self.deviceToken];
	NSURL *url = [NSURL URLWithString:  urlString];
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
	request.requestMethod = @"PUT";
	
	// Send along our device alias as the JSON encoded request body
	if(self.deviceAlias != nil && [self.deviceAlias length] > 0) {
		[request addRequestHeader: @"Content-Type" value: @"application/json"];
		[request appendPostData:[[NSString stringWithFormat: @"{\"alias\": \"%@\"}", self.deviceAlias]
								 dataUsingEncoding:NSUTF8StringEncoding]];
	}
	
	// Authenticate to the server
	request.username = FUUAAppKey;
	request.password = FUUAAppSecret;
	
	[request setDelegate:self];
	[request setDidFinishSelector: @selector(successMethod:)];
	[request setDidFailSelector: @selector(requestWentWrong:)];
	[queue addOperation:request];
	
#endif
}

-(void) application: (UIApplication *) application didFailToRegisterForRemoteNotificationsWithError: (NSError *) error
{
	NSLog(@"Error: %@", [error userInfo]);
}

-(void) successMethod: (ASIHTTPRequest *) request 
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
	[userDefaults setValue: self.deviceToken forKey: @"_UALastDeviceToken"];
	[userDefaults setValue: self.deviceAlias forKey: @"_UALastAlias"];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	[[NSUserDefaults standardUserDefaults] setBool: YES forKey: @"FU_Push_Capable"];
}

-(void) requestWentWrong: (ASIHTTPRequest *) request 
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	NSError *error = [request error];
	
	UIAlertView *someError = [[UIAlertView alloc] initWithTitle: @"Network error" 
																 message: @"Error registering with server"
													   delegate: self
											  cancelButtonTitle: @"Ok"
											  otherButtonTitles: nil];
	
	[someError show];
	[someError release];
	
	NSLog(@"ERROR: NSError query result: %@", error);
	
	[[NSUserDefaults standardUserDefaults] setBool: NO forKey: @"FU_Push_Capable"];
}

-(void) application: (UIApplication *) application didReceiveRemoteNotification: (NSDictionary *) userInfo
{
	NSLog(@"Received notification: %@", userInfo);
	
	NSDictionary *notification = userInfo;
	
	//NSDictionary *aps = [userInfo objectForKey: @"aps"];
	
	//UIAlertView *pushAlert = [[UIAlertView alloc] initWithTitle: @"HopTo" message: [aps objectForKey: @"alert"] 
		//											   delegate: self cancelButtonTitle: @"Never View" 
			//								  otherButtonTitles: @"View Later", @"View Now", nil];
	
	//[pushAlert show];
	
	FUURLManager *urlManager = [FUURLManager sharedManager];
	
	[urlManager addURL: [notification objectForKey: @"url"] from: [notification objectForKey: @"sender"]];
	
	[urlManager openURL: urlManager.currentURL];
}

*/

#pragma mark -
#pragma mark URL Server Management
/* URL Server Management *\
\*************************/

-(BOOL) startURLServer
{
	if ( urlServer != nil )
		return YES;
	
	self.urlServer = [[Server alloc] init];
	urlServer.serviceType = FUServerBonjourTypeURL;
	urlServer.delegate = self;
	
	if ( ![urlServer start] ) {
		
		self.urlServer = nil;
		
		NSLog(@"URL Server did not start!");
		
		return NO;
		
	}
	
	return YES;
}

-(void) stopURLServer
{
	if ( self.urlServer == nil )
		return;
	
	[urlServer stop];
	
	self.urlServer = nil;
}

#pragma mark Delegation
// Delegation
-(void) serverDidStart: (Server *) server
{
	self.urlClients = [NSMutableSet set];
	
	NSLog(@"Server started!");
}

-(void) serverFailed: (Server *) server reason: (NSString *) reason
{
	self.urlClients = nil;
	
	NSLog(@"Server failed: %@", reason);	
}

-(void) serverDidStop: (Server *) server
{
	self.urlClients = nil;
	
	NSLog(@"Server stopped!");
}

-(void) handleNewConnection: (Connection *) connection
{
	SHOW_NETWORK_INDICATOR;
	
	NSLog(@"Incoming Connection!");
	
	connection.delegate = self;
	
	[urlClients addObject: connection];
}

#pragma mark Network Control
// Network Control
-(BOOL) checkReachablility: (NSNotification *) notification
{
	Reachability *reacher = [notification object];
	
	if ( notification == nil ) 
		reacher = [Reachability reachabilityForLocalWiFi];
	
	// Check for anything other than wifi.
	if ( [reacher currentReachabilityStatus] != ReachableViaWiFi || [reacher connectionRequired] ) {
		
		if ( !wifi )
			return NO;
		
		self.wifi = NO;
		
		[self showWifiWarning];
		
		[self stopURLServer];
		
	} else {
		
		self.wifi = TRUE;
		
		[self startURLServer];
		
	}
	
	return wifi;
}

-(void) internetReachabilityDidChange: (NSNotification *) notification
{
	if ( [[Reachability reachabilityWithHostName: @"www.google.com"] currentReachabilityStatus] != NotReachable )
		[[FUURLManager sharedManager] checkMetadataForAllURLs];
}

-(void) showWifiWarning
{
	UIAlertView *wifiAlert = [[[UIAlertView alloc] initWithTitle: LOCAL(@"No WiFi") 
														 message: LOCAL(@"Wifi Alert")
														delegate: self cancelButtonTitle: LOCAL(@"OK") otherButtonTitles: nil] autorelease];
	
	wifiAlert.tag = 1;
	
	[wifiAlert show];
}

#pragma mark -
#pragma mark URL Connections Delegation
/* URL Connections Delegation *\
\******************************/

#pragma mark Setup
// Setup
-(void) connectionSucceeded: (Connection *) connection
{
	HIDE_NETWORK_INDICATOR;
	
	NSLog(@"Connection established!");
}

-(void) connectionAttemptFailed: (Connection *) connection
{
	HIDE_NETWORK_INDICATOR;
	
	[urlClients removeObject: connection];
	
	NSLog(@"Connection attempt failed! Shiggety-whaaaaaat?????");
}

-(void) connectionTerminated: (Connection *) connection
{
	HIDE_NETWORK_INDICATOR;
	
	[urlClients removeObject: connection];
	
	// Handle the message if needed.
	if ( self.incomingMessage != nil ) 
		[self handleIncomingMessage];
	
	NSLog(@"Connection terminated!");
}

#pragma mark Data Flow
// Data Flow
-(void) receivedNetworkPacket: (NSDictionary *) message viaConnection: (Connection *) connection
{
	NSLog(@"Received Packet: %@", message);
	
	// First thing we'll do is create a URL object with the string. This will tell us
	// if it's usable or not.
	NSURL *url = [NSURL URLWithString: [message objectForKey: @"url"]];
	
	// If it's messed up, we'll simply return to sender.
	if ( url == nil ) {
		
		[connection sendNetworkPacket: DICTIONARY(BOOLOBJ(NO), @"didReceiveURL", DEVICE_NAME, @"sendingDeviceName")];
		
		return;
		
	} else {
		
		[connection sendNetworkPacket: DICTIONARY(BOOLOBJ(YES), @"didReceiveURL", DEVICE_NAME, @"sendingDeviceName")];
		
		self.incomingMessage = message;
		
	}
}

-(void) handleIncomingMessage
{
	SHOW_NETWORK_INDICATOR;
	
	// Grab the message.
	NSDictionary *message = self.incomingMessage;
	
	// Get the strings.
	NSString *urlStr = [message objectForKey: @"url"];
	NSString *from = [message objectForKey: @"sendingDeviceName"];
	
	// Send it off to the URL manager.
	[[FUURLManager sharedManager] addURL: urlStr from: from];
	
	if ( backgroundMode ) {
		
		SystemSoundID sound;
		
		NSURL *soundURL = [NSURL URLWithString: [[NSBundle mainBundle] pathForResource: @"swoosh" ofType: @"wav"]];
		
		AudioServicesCreateSystemSoundID((CFURLRef) soundURL, &sound);
		
		AudioServicesPlayAlertSound(sound);
		
		return;
		
	}
	
	// Sign up for the notification when it's added.
	[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(showNewURLAlert) 
												 name: FUURLManagerNewURLAddedNotification object: [FUURLManager sharedManager]];
	
	// Get rid of the incoming message now.
	self.incomingMessage = nil;
	
	HIDE_NETWORK_INDICATOR;
}

#pragma mark -
#pragma mark Alert View Delegation
/* Alert View Delegation *\
\*************************/

-(void) alertView: (UIAlertView *) alertView didDismissWithButtonIndex: (NSInteger) buttonIndex
{
	if ( buttonIndex == 0 ) {
		
		// Not now.
		return;
		
	} else if ( buttonIndex == 1 ) {
		
		if ( osVersion >= kFUiOSVersion3_2 ) {
			
			// Open a web view.
			WebView_ViewController *webView = [[[WebView_ViewController alloc] init] autorelease];
			
			// Load it in. 
			[webView loadViewWithURL: [FUURLManager sharedManager].currentURL];
			
			// Push it.
			[navigationController pushViewController: webView animated: YES];
			
		} else {
			
			// Open it.
			[[FUURLManager sharedManager] openURL: [FUURLManager sharedManager].currentURL];
			
		}
		
	}
}

@end