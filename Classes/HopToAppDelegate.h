/********************************\
	HopTo Application Delegate
\********************************/

// Dependencies
#import <UIKit/UIKit.h>

// Forward Declarations
//@class ASIHTTPRequest;
@class Reachability;
@class Server;
@class Connection;
@class WebView_ViewController;
@protocol ServerDelegate;
@protocol ConnectionDelegate;

// Typedefs
typedef enum {
	kFUiOSVersion3 = 300,
	kFUiOSVersion3_1 = 310,
	kFUiOSVersion3_2 = 320,
	kFUiOSVersion4 = 400
} FUiOSVersion;

typedef enum {
	kFUDeviceiPhone,
	kFUDeviceiPad
} FUDevice;

@interface HopToAppDelegate : NSObject <UIApplicationDelegate, UIAlertViewDelegate, ServerDelegate, ConnectionDelegate> 
{
	// Backend
	Server *urlServer;
	NSMutableSet *urlClients;
	Reachability *wifiMonitor;
	
	// Flags
	FUiOSVersion osVersion;
	FUDevice deviceType;
	BOOL backgroundMode;
	BOOL firstLaunchMode;
	BOOL wifi;
	
    // Data
	NSString *appBundle, *documentsDirectory;
	NSString *deviceToken, *deviceAlias;
	
	// View
    UIWindow *window;
    UINavigationController *navigationController;
}

#pragma mark Properties
// Properties
@property (nonatomic, retain) Server *urlServer;
@property (nonatomic, retain) NSMutableSet *urlClients;
@property (nonatomic, retain) Reachability *wifiMonitor;
@property (nonatomic, assign, readonly) FUiOSVersion osVersion;
@property (nonatomic, assign, readonly) FUDevice deviceType;
@property (nonatomic) BOOL backgroundMode, firstLaunchMode, wifi;
@property (nonatomic, copy) NSString *appBundle, *documentsDirectory;
@property (nonatomic, copy) NSString *deviceToken, *deviceAlias;
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

#pragma mark Instance Management
// Instance Management
+(id) sharedDelegate;
-(void) dealloc;

#pragma mark Setters & Getters
// Setters & Getters
-(BOOL) wifi;

#pragma mark Application Lifecycle Management
// Application Lifecycle Management
-(BOOL) application: (UIApplication *) application didFinishLaunchingWithOptions: (NSDictionary *) launchOptions;
-(void) application: (UIApplication *) application handleOpenURL: (NSURL *) url;
-(void) applicationWillResignActive: (UIApplication *) application;
-(void) applicationDidBecomeActive: (UIApplication *) application;
#ifdef OS4
-(void) applicationDidEnterBackground: (UIApplication *) application;
-(void) applicationWillEnterForeground: (UIApplication *) application;
#endif
-(void) applicationWillTerminate: (UIApplication *) application;
-(BOOL) determineFirstLaunchMode;

/*
#pragma mark -
#pragma mark Push Notification Registration
// Push Notification Registration
-(void) application: (UIApplication *) application didRegisterForRemoteNotificationsWithDeviceToken: (NSData *) theDeviceToken;
-(void) application: (UIApplication *) application didFailToRegisterForRemoteNotificationsWithError: (NSError *) error;
-(void) successMethod: (ASIHTTPRequest *) request;
-(void) requestWentWrong: (ASIHTTPRequest *) request;
-(void) application: (UIApplication *) application didReceiveRemoteNotification: (NSDictionary *) userInfo;
*/

#pragma mark -
#pragma mark URL Server Management
/* URL Server Management *\
\*************************/

-(BOOL) startURLServer;
-(void) stopURLServer;

#pragma mark Delegation
// Delegation
-(void) serverDidStart: (Server *) server;
-(void) serverFailed: (Server *) server reason: (NSString *) reason;
-(void) serverDidStop: (Server *) server;
-(void) handleNewConnection: (Connection *) connection;

#pragma mark Network Control
// Network Control
-(BOOL) checkReachablility;
-(void) showWifiWarning;

#pragma mark -
#pragma mark URL Connections Delegation
/* URL Connections Delegation *\
\******************************/

#pragma mark Setup
// Setup
-(void) connectionSucceeded: (Connection *) connection;
-(void) connectionAttemptFailed: (Connection *) connection;
-(void) connectionTerminated: (Connection *) connection;

#pragma mark Data Flow
// Data Flow
-(void) receivedNetworkPacket: (NSDictionary *) message viaConnection: (Connection *) connection;

#pragma mark -
#pragma mark Alert View Delegation
/* Alert View Delegation *\
\*************************/

-(void) alertView: (UIAlertView *) alertView didDismissWithButtonIndex: (NSInteger) buttonIndex;

@end