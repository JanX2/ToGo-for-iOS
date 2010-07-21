/***************************\
	Foundation Extensions
\***************************/

//#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIApplication (Extended)

-(void) showNetworkIndicator: (NSNumber *) show;

@end

@interface NSDictionary (MoreStuff)

// Functions
id dictionaryForTableViewCell(NSString *reuseID, int accessoryType, 
							  int editingStyle, int selectionStyle, 
							  NSString *textLabel, NSString *detailTextLabel);
id dictionaryForTableViewCellWithData(NSString *reuseID, int accessoryType, 
									  int editingStyle, int selectionStyle, 
									  NSString *textLabel, NSString *detailTextLabel,
									  id data);
id dictionaryForTableViewCellWithImage(NSString *reuseID, int accessoryType, 
									   int editingStyle, int selectionStyle, 
									   NSString *textLabel, NSString *detailTextLabel, 
									   UIImage *image);
id dictionaryForTableViewCellWithImageAndData(NSString *reuseID, int accessoryType, 
											  int editingStyle, int selectionStyle, 
											  NSString *textLabel, NSString *detailTextLabel, 
											  UIImage *image, id data);

// Instance Management
+(id) dictionaryByAddingObjectsAndKeys: (id) object, ... NS_REQUIRES_NIL_TERMINATION;

@end

@interface UIColor (FUE)

+(id) flatBlueColor;

@end

@interface NSString (ParseCategory)
- (NSMutableDictionary *)explodeToDictionaryInnerGlue:(NSString *)innerGlue outterGlue:(NSString *)outterGlue;
@end