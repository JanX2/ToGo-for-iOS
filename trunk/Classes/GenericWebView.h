//
//  GenericWebView.h
//  ProveIt
//
//  Created by Drew R. Hood on 20.3.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GenericWebView : UIViewController <UIWebViewDelegate>
{
	NSString *viewTitle, *viewURL;
	
	UIWebView *myWebView;
}

@property (nonatomic, copy) NSString *viewTitle, *viewURL;
@property (nonatomic, retain) IBOutlet UIWebView *myWebView;

+(GenericWebView *) viewWithTitle: (NSString *) theTitle andURL: (NSString *) theURL;
-(GenericWebView *) initWithTitle: (NSString *) theTitle andURL: (NSString *) theURL;

-(IBAction) safariAction: (id) sender;

@end