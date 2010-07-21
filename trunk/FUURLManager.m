/*****************\
	URL Manager
\*****************/

// Dependencies
#import "FUURLManager.h"

#pragma mark Constants
// Constants
NSString * const FUURLManagerNewURLAddedNotification = @"_FUURLManagerNewURLAddedNotification";
NSString * const FUURLManagerCurrentURLDidChangeNotification = @"_FUURLManagerCurrentURLDidChangeNotification";
NSString * const FUURLManagerURLListDidChangeNotification = @"_FUURLManagerURLListDidChangeNotification";
NSString * const FUURLManagerWillOpenURLNotification = @"_FUURLManagerWillOpenURLNotification";

#pragma mark Globals
// Globals
static FUURLManager *kSharedManager;

@implementation FUURLManager

#pragma mark Properties
// Properties
@synthesize currentURL;
@synthesize urlList;

#pragma mark Instance Management
// Instance Management
+(id) allocWithZone: (NSZone *) zone
{
 	return [[self sharedManager] retain];
}

-(id) init
{
	self = [super init];
	
	if ( self ) {
		
		self.urlList = [NSMutableArray arrayWithContentsOfFile: [DOCUMENTS_DIRECTORY stringByAppendingPathComponent: @"urls.plist"]];
		
		if ( !urlList || [urlList count] == 0 )
			self.urlList = [NSMutableArray array];
		else 
			self.currentURL = [urlList objectAtIndex: 0];
		
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(updateCurrentURL) 
													 name: FUURLManagerCurrentURLDidChangeNotification object: self];
		
	}
	
	return self;
}

+(FUURLManager *) sharedManager
{
	if ( !kSharedManager )
		kSharedManager = [[super allocWithZone: NULL] init];
	
	return [kSharedManager autorelease];
}

-(id) retain
{
	return kSharedManager;
}

-(void) release
{
	return;
}

-(id) copyWithZone: (NSZone *) zone
{
	return kSharedManager;
}

-(void) dealloc
{
	[self performSelector: @selector(saveDown) onThread: [NSThread currentThread] withObject: nil waitUntilDone: YES];
	
	[currentURL release];
	[urlList release];
	
	[super dealloc];
}

#pragma mark Variable Management
// Variable Management
-(void) setCurrentURL: (NSMutableDictionary *) url
{
	[currentURL release];
	currentURL = nil;
	
	currentURL = [url retain];
	
	[[NSNotificationCenter defaultCenter] postNotificationName: FUURLManagerCurrentURLDidChangeNotification object: currentURL];
}

-(NSMutableDictionary *) currentURL
{
	[self updateCurrentURL];
	
	return currentURL;
}

#pragma mark Opening URLs
// Opening URLs
-(void) openURL: (NSDictionary *) url
{
	// Get the url string.
	NSString *urlStr = [url objectForKey: @"url"];
	
	// Put it together for use.
	NSURL *urlObj = [NSURL URLWithString: urlStr];
	
	// Make sure it's not broken. If we're good, tell everyone, if not, abort.
	if ( urlObj ) 
		[[NSNotificationCenter defaultCenter] postNotificationName: FUURLManagerWillOpenURLNotification object: urlObj];
	else
		return;

	// Do it.
	[[UIApplication sharedApplication] openURL: urlObj];
}

#pragma mark URL Queries
// URL Queries
-(NSDictionary *) URLAtIndex: (NSInteger) index
{
	if ( [urlList count] > index )
		return [urlList objectAtIndex: index];
	
	return nil;
}

#pragma mark Data Control
// Data Control
-(void) checkMetadataForAllURLs
{
	[NSThread detachNewThreadSelector: @selector(_checkMetadataForAllURLs) toTarget: self withObject: nil];
}

-(void) _checkMetadataForAllURLs
{
	NSAutoreleasePool *checkPool = [NSAutoreleasePool new];
	
	// Enumerate through.
	for ( int i = 0; i < [urlList count]; ++i ) {
		
		// Grab the current object.
		NSDictionary *aDict = [urlList objectAtIndex: i];
		
		// Check it.
		if ( [[aDict objectForKey: @"needsRefresh"] boolValue] ) {
			
			[aDict retain];
			
			// Remove it.
			[urlList removeObjectAtIndex: i];
			
			// Create a new dictionary.
			NSMutableDictionary *newDict = [self fetchMetadataForURL: [aDict objectForKey: @"url"]];
			
			// Add in the necessary data.
			[newDict setObject: [aDict objectForKey: @"url"] forKey: @"url"];
			[newDict setObject: [aDict objectForKey: @"sendingDeviceName"] forKey: @"sendingDeviceName"];
			
			// Now add it back into the list.
			[urlList insertObject: newDict atIndex: i];
			
		}
		
		aDict = nil;
		
	}
	
	[self saveDown];
	
	[[NSNotificationCenter defaultCenter] postNotificationName: FUURLManagerURLListDidChangeNotification object: self];
	
	[checkPool drain];
}

-(NSMutableDictionary *) fetchMetadataForURL: (NSString *) theURL
{
	[[UIApplication sharedApplication] performSelectorOnMainThread: @selector(showNetworkIndicator:) 
														withObject: BOOLOBJ(YES) waitUntilDone: YES];
	
	// Set up a URL request to the Fappulous app hub.
	NSURL *url = [NSURL URLWithString: STRING_WITH_FORMAT(@"http://fappulo.us/apps_backend/HopTo/websiteMeta.php?url=%@", theURL)];
	
	BOOL noInternet = FALSE;
	
	// First, test the internet connection.
	noInternet = ( [INTERNET_MONTITOR currentReachabilityStatus] == NotReachable );
	
	// Now get the metadata.
	NSMutableDictionary *metaData = nil;
	
	if ( noInternet ) 
		metaData = nil;
	else 
		metaData = [NSMutableDictionary dictionaryWithContentsOfURL: url];
	
	// Set up the base dictionary.
	NSMutableDictionary *urlDict = [NSMutableDictionary dictionary];
	
	// Let's try getting the favicon.
	NSURL *favURL;
	NSURL *favURLSrc = [NSURL URLWithString: theURL];
	NSData *iconData = nil;
	
	BOOL useGoogle = FALSE;
	
getIcon: ;
	
	if ( !useGoogle && !noInternet ) {
		
		favURL = [NSURL URLWithString: STRING_WITH_FORMAT(@"%@://%@/favicon.ico", [favURLSrc scheme], [favURLSrc host])];
		
		iconData = [NSData dataWithContentsOfURL: favURL];
		
	} else {
		
		iconData = [NSData dataWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"GoogleFavicon" ofType: @"png"]];
		
	}
	
makeDict: ;
	
	UIImage *favIconSrc = [UIImage imageWithData: iconData];
	NSData *favIconData = UIImagePNGRepresentation(favIconSrc);
	UIImage *favIcon = [UIImage imageWithData: favIconData];
	
	if ( favIcon == nil ) {
		
		useGoogle = TRUE;
		goto getIcon;
		
	}
	
	// Save it.
	if ( favIcon != nil ) {
		
		NSString *urlSha = STRING_WITH_FORMAT(@"Favicon%@.png", FUStringSha1(theURL));
		
		[favIconData writeToFile: [DOCUMENTS_DIRECTORY stringByAppendingPathComponent: urlSha] atomically: YES];
		
		[urlDict setObject: urlSha forKey: @"iconFileName"];
		
	} else {
		
		[urlDict setObject: NSNULL forKey: @"iconFileName"];
		
	}
	
	if ( [metaData objectForKey: @"title"] == nil ) 
		[urlDict setObject: @"No Title" forKey: @"title"];
	else 
		[urlDict setObject: [[metaData objectForKey: @"title"] stringByReplacingOccurrencesOfString: @"\\" withString: @""] forKey: @"title"];
	
	if ( [metaData objectForKey: @"description"] == nil )
		[urlDict setObject: @"No description found." forKey: @"description"];
	else 
		[urlDict setObject: [[metaData objectForKey: @"description"] stringByReplacingOccurrencesOfString: @"\\" withString: @""] 
						forKey: @"description"];
	
	// If no internet, set a flag for later so we'll know to get the metadata again.
	if ( noInternet ) {
		
		[urlDict setObject: BOOLOBJ(YES) forKey: @"needsRefresh"];
		
		[urlDict setObject: @"Couldn't connect to internet to download information. Will try again later." forKey: @"description"];
		
	}
	
	metaData = nil;
	
	[[UIApplication sharedApplication] performSelectorOnMainThread: @selector(showNetworkIndicator:) 
														withObject: BOOLOBJ(NO) waitUntilDone: YES];
	
	return urlDict;
}

-(void) updateCurrentURL
{
	// Make sure there's something there.
	if ( [urlList count] > 0 ) {
		
		if ( [urlList objectAtIndex: 0] != currentURL ) {
			
			self.currentURL = [urlList objectAtIndex: 0];
			
		}
		
	} else if ( currentURL != nil ) {
		
		// If there's nothing there, then the url should be empty.
		self.currentURL = nil;
		
	}
}

-(void) addURL: (NSString *) url from: (NSString *) nameOfDevice
{	
	[NSThread detachNewThreadSelector: @selector(_addURLInBackground:) toTarget: self 
						   withObject: DICTIONARY(url, @"URL", nameOfDevice, @"deviceName")];
}

-(void) _addURLInBackground: (NSDictionary *) urlSourceDict
{
	// Set up a pool.
	NSAutoreleasePool *addPool = [NSAutoreleasePool new];
	
	// Grab the info out of the dictionary.
	NSString *url = [urlSourceDict objectForKey: @"URL"];
	NSString *nameOfDevice = [urlSourceDict objectForKey: @"deviceName"];
	
	// Get the info set up in a dictionary.
	NSMutableDictionary *urlDict = [self fetchMetadataForURL: url];
	
	[urlDict setObject: url forKey: @"url"];
	[urlDict setObject: nameOfDevice forKey: @"sendingDeviceName"];
	
	// Add it at the beginning of the array.
	if ( [urlList count] > 0 ) 
		[urlList insertObject: urlDict atIndex: 0];
	else 
		[urlList addObject: urlDict];
	
	// We'll only hang on to the last 100.
	if ( [urlList count] > 100 ) 
		[urlList removeLastObject];
	
	[self saveDown];
	
	// Tell everyone what's just happened.
	[[NSNotificationCenter defaultCenter] postNotificationName: FUURLManagerNewURLAddedNotification object: self];
	[[NSNotificationCenter defaultCenter] postNotificationName: FUURLManagerCurrentURLDidChangeNotification object: self];
	[[NSNotificationCenter defaultCenter] postNotificationName: FUURLManagerURLListDidChangeNotification object: self];
	
	[addPool drain];
}

-(void) removeURLAtIndex: (NSInteger) index
{
	if ( [urlList count] > index ) {
		
		// Delete it.
		[urlList removeObjectAtIndex: index];
		
		// Save.
		[self saveDown];
		
		// Tell everyone what's just happened.
		[[NSNotificationCenter defaultCenter] postNotificationName: FUURLManagerURLListDidChangeNotification object: urlList];
		
	}
}

-(void) removeURL: (NSDictionary *) url
{
	if ( [urlList containsObject: url] ) {
		
		// Get rid of the cached icon if there is one.
		if ( [url objectForKey: @"iconFileName"] != NSNULL ) {
			
			NSFileManager *fm = [NSFileManager defaultManager];
			
			[fm removeItemAtPath: [DOCUMENTS_DIRECTORY stringByAppendingPathComponent: [url objectForKey: @"iconFileName"]] error: nil];
			
		}
		
		// Delete it.
		[urlList removeObject: url];
		
		// Save.
		[self saveDown];
		
		// Tell everyone what's just happened.
		[[NSNotificationCenter defaultCenter] postNotificationName: FUURLManagerURLListDidChangeNotification object: urlList];
		
	}
}

-(BOOL) saveDown
{
	// Write to file.
	return [urlList writeToFile: [DOCUMENTS_DIRECTORY stringByAppendingPathComponent: @"urls.plist"] atomically: YES];
}

@end