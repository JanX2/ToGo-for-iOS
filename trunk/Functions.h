/***********************\
	General Functions
\***********************/

#import <Foundation/Foundation.h>

// Object Allocation Management
void destroy(id object);

// Time Calculations
NSTimeInterval intervalSinceMidnightForDate(NSDate *date);
NSDate * convertDateToMidnight(NSDate *date);

// Table View Shortcuts
extern id generateTableViewCell(UITableView *tableView, NSDictionary *cellData, NSString *reuseID);

// Math
CGFloat radians(CGFloat degrees);
NSString * FUStringSha1(NSString *input);

// Localization
NSString * FULocalizedString(NSString *source, NSString *flags);