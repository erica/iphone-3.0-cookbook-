/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]

@interface TestBedViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, UIActionSheetDelegate>
@end

@implementation TestBedViewController
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return 1000000;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
	return 120.0f;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
	UIImageView *imageView;
	imageView = view ? (UIImageView *) view : [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 60.0f, 60.0f)];
	NSArray *names = [NSArray arrayWithObjects:@"club.png", @"diamond.png", @"heart.png", @"spade.png", nil];
	imageView.image = [UIImage imageNamed:[names objectAtIndex:(row % 4)]];	
	CFShow(imageView.image);
	return imageView;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	UIPickerView *pickerView = (UIPickerView *)[actionSheet viewWithTag:101];
	NSArray *names = [NSArray arrayWithObjects:@"C", @"D", @"H", @"S", nil];
	self.title = [NSString stringWithFormat:@"%@•%@•%@", 
				  [names objectAtIndex:([pickerView selectedRowInComponent:0] % 4)], 
				  [names objectAtIndex:([pickerView selectedRowInComponent:1] % 4)], 
				  [names objectAtIndex:([pickerView selectedRowInComponent:2] % 4)]];
	[actionSheet release];
}

- (void) action: (id) sender
{
	NSString *title = UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation) ? @"\n\n\n\n\n\n\n\n\n" : @"\n\n\n\n\n\n\n\n\n\n\n\n" ;

	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Set Combo", nil];
	[actionSheet showInView:self.view];

	UIPickerView *pickerView = [[[UIPickerView alloc] init] autorelease];
	pickerView.tag = 101;
	pickerView.delegate = self;
	pickerView.dataSource = self;
	pickerView.showsSelectionIndicator = YES;

	[actionSheet addSubview:pickerView];
	
	// Pick a random item in the middle of the table
	[pickerView selectRow:50000 + (random() % 4) inComponent:0 animated:YES];
	[pickerView selectRow:50000 + (random() % 4) inComponent:1 animated:YES];
	[pickerView selectRow:50000 + (random() % 4) inComponent:2 animated:YES];
	
	// Peek at dimensions
	// CFShow(NSStringFromCGRect(pickerView.frame));
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void) viewDidLoad
{
	srandom([NSDate timeIntervalSinceReferenceDate]);
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
