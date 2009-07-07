/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]

@interface TestBedViewController : UIViewController
{
	int count;
}
@end

@implementation TestBedViewController

- (void) basicStringManipulation
{
	// Create strings
	NSString *myString = @"A string constant";
	myString = [NSString stringWithFormat:@"The number is %d", 5]; 
	
	// Append strings
	NSLog(@"%@", [myString stringByAppendingString:@"22"]);
	NSLog(@"%@", [myString stringByAppendingFormat:@"%d", 22]);
	
	// Access length and characters
	NSLog(@"%d", myString.length);
	printf("%c\n", [myString characterAtIndex:2]);
	
	// Convert to C-string
	printf("%s\n", [myString UTF8String]);
	printf("%s\n", [myString cStringUsingEncoding: NSUTF8StringEncoding]);
	
	// Convert from C-string
	NSLog(@"%@", [NSString stringWithCString:"Hello World" encoding: NSUTF8StringEncoding]);
}

- (void) readAndWriteFiles
{
	NSString *myString = @"Hello World";
	NSError *error;
	NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/file.txt"];
	if (![myString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error])
	{
		NSLog(@"Error writing to file: %@", [error localizedDescription]);
		return;
	}
	NSLog(@"File successfully written to file");
	
	NSString *inString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
	if (!inString)
	{
		NSLog(@"Error reading from file %@: %@", [path lastPathComponent], [error localizedDescription]);
		return;
	}
	NSLog(@"File successfully read from file");
	NSLog(@"%@", inString);
	
	// This produces a non-existent file error
	path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/foobar.txt"];
	inString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
	if (!inString)
	{
		NSLog(@"Error reading from file %@: %@", [path lastPathComponent], [error localizedDescription]);
		return;
	}
}

- (void) showcaseSubstrings
{
	NSString *myString = @"One Two Three Four Five Six Seven";
	NSArray *wordArray = [myString componentsSeparatedByString:@" "];
	NSLog(@"%@", wordArray);
	
	NSString *sub1 = [myString substringToIndex:7];
	NSLog(@"%@", sub1);
	
	NSString *sub2 = [myString substringFromIndex:4];
	NSLog(@"%@", sub2);
	
	NSRange r;
	r.location = 4;
	r.length = 2;
	NSString *sub3 = [myString substringWithRange:r];
	NSLog(@"%@", sub3);
	
	NSRange searchRange = [myString rangeOfString:@"Five"];
	if (searchRange.location != NSNotFound)
	{
		NSLog(@"Range location: %d, length: %d", searchRange.location, searchRange.length);
		NSLog(@"%@", [myString stringByReplacingCharactersInRange:searchRange withString:@"New String"]);
	}
	
	
	NSString *replaced = [myString stringByReplacingOccurrencesOfString:@" " withString:@" * "];
	NSLog(@"%@", replaced);
}

- (void) caseChanges
{
	NSString *myString = @"Hello world. How do you do?";
	NSLog(@"%@", [myString uppercaseString]);
	NSLog(@"%@", [myString lowercaseString]);
	NSLog(@"%@", [myString capitalizedString]);
}

- (void) compareAndTest
{
	NSString *s1 = @"Hello World";
	NSString *s2 = @"Hello Mom";
	NSLog(@"%@ %@ %@", s1, [s1 isEqualToString:s2] ? @"equals" : @"differs from", s2);
	NSLog(@"%@ %@ %@", s1, [s1 hasPrefix:@"Hello"] ? @"starts with" : @"does not start with", @"Hello");
	NSLog(@"%@ %@ %@", s1, [s1 hasSuffix:@"Hello"] ? @"ends with" : @"does not end with", @"Hello");
}

- (void) convertToNumbers
{
	NSString *s1 = @"3.141592";
	NSLog(@"%d", [s1 intValue]);
	NSLog(@"%d", [s1 boolValue]);
	NSLog(@"%f", [s1 floatValue]);
	NSLog(@"%f", [s1 doubleValue]);
}

- (void) mutableStrings;
{
	NSMutableString *myString = [NSMutableString stringWithString:@"Hello World. "];
	[myString appendFormat:@"The results are %@ now.", @"in"];
	NSLog(@"%@", myString);
}

- (void) basicNumbers
{
	NSNumber *number = [NSNumber numberWithFloat:3.141592];
	NSLog(@"%d", [number intValue]);
	NSLog(@"%@", [number stringValue]);
}

- (void) basicDates
{
	// current time
	NSDate *date = [NSDate date];
	
	// time 10 seconds from now
	date = [NSDate dateWithTimeIntervalSinceNow:10.0f];
	
	// Show the date
	NSLog(@"%@", [date description]);

	// Sleep 5 seconds and check the time interval. Uncomment to run
	/*
	NSLog(@"About to sleep for 5 seconds");
	[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:5.0f]];
	NSLog(@"Slept %f seconds", [[NSDate date] timeIntervalSinceDate:date]);
	 */
	
	// Produce a formatted string representing the current date
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
	formatter.dateFormat = @"MM/dd/YY HH:mm:ss";
	NSString *timestamp = [formatter stringFromDate:[NSDate date]];
	NSLog(@"%@", timestamp);
}

- (void) handleTimer: (NSTimer *) timer
{
	printf("Timer count: %d\n", count++);
	if (count > 3) 
	{
		[timer invalidate];
		printf("Timer disabled\n");
	}
}

- (void) startTimer
{
	count = 1;
	[NSTimer scheduledTimerWithTimeInterval: 1.0f target: self selector: @selector(handleTimer:) userInfo: nil repeats: YES];
}

- (void) collectionsOverview
{
	NSArray *array = [NSArray arrayWithObjects:@"One", @"Two", @"Three", nil];
	NSLog(@"%d", array.count);
	
	// Indices start with 0
	NSLog(@"%@", [array objectAtIndex:0]);
	
	// This causes a crash. The last object is at count - 1
	// NSLog(@"%@", [array objectAtIndex:array.count]);
	
	// Mutable arrays can be edited
	NSMutableArray *marray = [NSMutableArray arrayWithArray:array];
	[marray addObject:@"Four"];
	[marray removeObjectAtIndex:2];
	NSLog(@"%@", marray);
	
	// Combining arrays
	NSLog(@"%@", [array arrayByAddingObjectsFromArray:marray]);
	
	// Checking arrays
	if ([marray containsObject:@"Four"])
		NSLog(@"The index is %d", [marray indexOfObject:@"Four"]);
	
	
	// Joining Components
	NSLog(@"%@", [array componentsJoinedByString:@" "]);
	
	// Create and populate a dictionary
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	[dict setObject:@"1" forKey:@"A"];
	[dict setObject:@"2" forKey:@"B"];
	[dict setObject:@"3" forKey:@"C"];
	NSLog(@"%@", [dict description]);
	
	// Query
	NSLog(@"%@", [dict objectForKey:@"A"]);
	NSLog(@"%@", [dict objectForKey:@"F"]);
	

	// Replacing an object
	[dict setObject:@"foo" forKey:@"C"];
	NSLog(@"%@", [dict objectForKey:@"C"]);
	
	// Removing an object
	[dict removeObjectForKey:@"B"];
	
	// Count and allKeys
	NSLog(@"The dictionary has %d objects", [dict count]);
	NSLog(@"%@", [dict allKeys]);
	
	// Write to file and read back in
	NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/ArraySample.txt"];
	if ([array writeToFile:path atomically:YES])
		NSLog(@"File was written successfully");
	
	NSArray *newArray = [NSArray arrayWithContentsOfFile:path];
	NSLog(@"%@", newArray);
}

- (void) basicURLsAndNSData
{
	NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/foo.txt"];
	NSURL *url1 = [NSURL fileURLWithPath:path];
	NSLog(@"%@", url1);
		
	NSString *urlpath = @"http://ericasadun.com";
	NSURL *url2 = [NSURL URLWithString:urlpath];
	NSLog(@"%d characters read", [[NSString stringWithContentsOfURL:url2] length]);
	
	NSData *data = [NSData dataWithContentsOfURL:url2];
	NSLog(@"%d", [data length]);
}

- (void) showFileManager
{
	NSFileManager *fm = [NSFileManager defaultManager];
	
	// List the files in the sandbox Documents folder
	NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
	NSLog(@"%@",[fm directoryContentsAtPath:path]);
	
	// List the files in the application bundle
	path = [[NSBundle mainBundle] bundlePath];	
	NSLog(@"%@",[fm directoryContentsAtPath:path]);
	
	// Retrieve a path from the bundle
	NSBundle *mb = [NSBundle mainBundle];
	NSLog(@"%@", [mb pathForResource:@"Default" ofType:@"png"]);
	
	// Show move, copy, and remove
	NSError *error;
	
	// Create a file
	NSString *docspath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
	NSString *filepath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/testfile"];
	NSArray *array = [@"One Two Three" componentsSeparatedByString:@" "];
	[array writeToFile:filepath atomically:YES];
	NSLog(@"%@", [fm directoryContentsAtPath:docspath]);
	
	
	// Copy the file
	NSString *copypath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/copied"];
	if (![fm copyItemAtPath:filepath toPath:copypath error:&error])
	{
		NSLog(@"Copy Error: %@", [error localizedDescription]);
		return;
	}
	NSLog(@"%@", [fm directoryContentsAtPath:docspath]);
	
	// Move the file
	NSString *newpath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/renamed"];
	if (![fm moveItemAtPath:filepath toPath:newpath error:&error])
	{
		NSLog(@"Move Error: %@", [error localizedDescription]);
		return;
	}
	NSLog(@"%@", [fm directoryContentsAtPath:docspath]);
	
	// Remove a file
	if (![fm removeItemAtPath:copypath error:&error])
	{
		NSLog(@"Remove Error: %@", [error localizedDescription]);
		return;
	}
	NSLog(@"%@", [fm directoryContentsAtPath:docspath]);
	
}

- (void) action: (id) sender
{
	// STRINGS
	[self basicStringManipulation];
	[self readAndWriteFiles];
	[self showcaseSubstrings];
	[self caseChanges];
	[self compareAndTest];
	[self convertToNumbers];
	[self mutableStrings];
	
	// NUMBERS AND DATES
	[self basicNumbers];
	[self basicDates];
	// [self startTimer]; // Uncomment to run the timer
	
	// COLLECTIONS
	[self collectionsOverview];
	
	// URLs
	[self basicURLsAndNSData];
	
	// File Manager
	[self showFileManager];
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Action", @selector(action:));
}
@end

@interface TestBedAppDelegate : NSObject <UIApplicationDelegate>
@end

@implementation TestBedAppDelegate
- (void)applicationDidFinishLaunching:(UIApplication *)application {	
	UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[[TestBedViewController alloc] init]];
	[window addSubview:nav.view];
	[window makeKeyAndVisible];
}
@end

int main(int argc, char *argv[])
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	int retVal = UIApplicationMain(argc, argv, nil, @"TestBedAppDelegate");
	[pool release];
	return retVal;
}
