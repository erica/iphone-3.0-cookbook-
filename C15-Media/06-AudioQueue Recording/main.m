/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "Recorder.h"
#import "LibraryController.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]
#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
#define FILEPATH [DOCUMENTS_FOLDER stringByAppendingPathComponent:[self dateString]]

@interface TestBedViewController : UIViewController
{
	IBOutlet UIButton		*button;
	IBOutlet UIProgressView	*power;
	BOOL					isRecording;
	Recorder				*myRecorder;
	NSTimer					*timer;
}
@property (retain) Recorder *myRecorder;
@end

@implementation TestBedViewController
@synthesize myRecorder;
- (NSString *) dateString
{
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
	formatter.dateFormat = @"ddMMMYY_hhmmssa";
	return [[formatter stringFromDate:[NSDate date]] stringByAppendingString:@".aif"];
}

- (void) library: (UIBarButtonItem *) bbi
{
	// stop any current recording	
	if (isRecording) 
	{
		[button setImage:[UIImage imageNamed:@"green.png"] forState:UIControlStateNormal];
		[button setImage:[UIImage imageNamed:@"green2.png"] forState:UIControlStateHighlighted];
		self.navigationItem.leftBarButtonItem = nil;
		[self.myRecorder stopRecording];
		self.myRecorder = nil;
		self.title = nil;
		isRecording = NO;
	}
	
	// stop power monitoring
	[timer invalidate];
	timer = nil;
	
	// push the library controller
	[self.navigationController pushViewController:[[[LibraryController alloc] init] autorelease] animated:YES];
}

- (NSString *) formatTime: (int) num
{
	int secs = num % 60;
	int min = num / 60;
	
	if (num < 60) return [NSString stringWithFormat:@"0:%02d", num];
	
	return	[NSString stringWithFormat:@"%d:%02d", min, secs];
}

- (void) updateStatus
{
	power.progress = [self.myRecorder averagePower];
	self.title = [self formatTime:[self.myRecorder currentTime]];
}

- (void) resumeRecording
{
	if (self.myRecorder && [self.myRecorder isRecording])
	{
		[self.myRecorder resume];
		self.navigationItem.leftBarButtonItem = BARBUTTON(@"Pause", @selector(resumeRecording));
	}
}

- (void) pauseRecording
{
	if (self.myRecorder && [self.myRecorder isRecording])
	{
		[self.myRecorder pause];
		self.navigationItem.leftBarButtonItem = BARBUTTON(@"Resume", @selector(resumeRecording));
	}
}

- (void) buttonPushed
{
	// Establish recorder
	if (!self.myRecorder) self.myRecorder = [[[Recorder alloc] init] autorelease];
	if (!self.myRecorder)
	{
		NSLog(@"Error: Could not create recorder");
		return;
	}
	
	if (!isRecording)
	{
		BOOL success = [self.myRecorder startRecording:FILEPATH];
		if (!success)
		{
			printf("Error starting recording\n");
			[self.myRecorder stopRecording];
			self.myRecorder = nil;
			isRecording = NO;
			return;
		}
	}
	else
	{
		[self.myRecorder stopRecording];
		self.myRecorder = nil;
		self.title = nil;
	}
	
	isRecording = !isRecording;
		
	// Handle the GUI updates
	if (isRecording)
	{
		// start monitoring the power level
		timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(updateStatus) userInfo:nil repeats:YES];
		
		// Update the button art
		[button setImage:[UIImage imageNamed:@"red.png"] forState:UIControlStateNormal];
		[button setImage:[UIImage imageNamed:@"red2.png"] forState:UIControlStateHighlighted];
		
		self.navigationItem.leftBarButtonItem = BARBUTTON(@"Pause", @selector(pauseRecording));
	}
	else 
	{
		// Stop monitoring the power level
		power.progress = 0.0f;
		[timer invalidate];
		timer = nil;
		
		// Update the button art
		[button setImage:[UIImage imageNamed:@"green.png"] forState:UIControlStateNormal];
		[button setImage:[UIImage imageNamed:@"green2.png"] forState:UIControlStateHighlighted];
		
		self.navigationItem.leftBarButtonItem = nil;
	}
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Library", @selector(library:));
	[button addTarget:self action:@selector(buttonPushed) forControlEvents:UIControlEventTouchUpInside];
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
