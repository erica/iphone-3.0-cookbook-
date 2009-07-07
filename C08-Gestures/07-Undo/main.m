/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]

@interface DragView : UIImageView
{
	CGPoint startLocation;
	NSString *whichFlower;
	UIViewController *viewController;
}
@property (retain) NSString *whichFlower;
@property (assign) UIViewController *viewController;
@end

@implementation DragView
@synthesize whichFlower;
@synthesize viewController;

- (void) encodeWithCoder: (NSCoder *)coder
{
	[coder encodeCGRect:self.frame forKey:@"viewFrame"];
	[coder encodeObject:self.whichFlower forKey:@"flowerType"];
}

- (id) initWithCoder: (NSCoder *)coder
{
	[super initWithFrame:CGRectZero];
	self.frame = [coder decodeCGRectForKey:@"viewFrame"];
	self.whichFlower = [coder decodeObjectForKey:@"flowerType"];
	self.image = [UIImage imageNamed:self.whichFlower];
	self.userInteractionEnabled = YES;
	return self;
}

- (void) setPosition: (CGPoint) pos
{
	// Prepare undo-redo first
	[[self.undoManager prepareWithInvocationTarget:self] setPosition:self.center];
	[self.viewController performSelector:@selector(checkUndoAndUpdateNavBar) withObject:nil afterDelay:0.2f];

	// Make the change
	[UIView beginAnimations:@"" context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.1f];
	self.center = pos; // animate
	[UIView commitAnimations];
}

- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
	// Calling set position prepares for undo-redo
	[self setPosition:self.center];
	
	// Calculate and store offset, and pop view into front if needed
	CGPoint pt = [[touches anyObject] locationInView:self];
	startLocation = pt;
	[[self superview] bringSubviewToFront:self];
}

- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
	// Calculate offset
	CGPoint pt = [[touches anyObject] locationInView:self];
	float dx = pt.x - startLocation.x;
	float dy = pt.y - startLocation.y;
	CGPoint newcenter = CGPointMake(self.center.x + dx, self.center.y + dy);

	// Bound movement into parent bounds
	float halfx = CGRectGetMidX(self.bounds);
	newcenter.x = MAX(halfx, newcenter.x);
	newcenter.x = MIN(self.superview.bounds.size.width - halfx, newcenter.x);

	float halfy = CGRectGetMidY(self.bounds);
	newcenter.y = MAX(halfy, newcenter.y);
	newcenter.y = MIN(self.superview.bounds.size.height - halfy, newcenter.y);

	// Set new location
	self.center = newcenter;
}

- (void) touchesEnded:(NSSet *)touches withEvent: (UIEvent *) event
{
	[self.viewController performSelector:@selector(checkUndoAndUpdateNavBar)];
}

- (void) touchesCancelled:(NSSet *)touches withEvent: (UIEvent *) event
{
	[self touchesEnded:touches withEvent:event];
}

- (void) dealloc
{
	self.whichFlower = nil;
	[super dealloc];
}
@end


@interface TestBedViewController : UIViewController
{
	NSUndoManager *undoManager;
}
@property (retain) NSUndoManager *undoManager;
@end

@implementation TestBedViewController
@synthesize undoManager;

#define MAXFLOWERS 12
#define DATAPATH [NSString stringWithFormat:@"%@/Documents/flowers.archive", NSHomeDirectory()]

- (void) checkUndoAndUpdateNavBar
{
	while ([self.undoManager isUndoing]);
	
	// Don't show the undo button if the undo stack is empty
	if (!self.undoManager.canUndo) 
		self.navigationItem.leftBarButtonItem = nil;
	else
		self.navigationItem.leftBarButtonItem = BARBUTTON(@"Undo", @selector(undo));
}

- (void) undo
{
	// Perform the undo
	[self.undoManager undo];
}

- (void) archiveInterface
{
	NSArray *flowers = [[self.view viewWithTag:201] subviews];
	[NSKeyedArchiver archiveRootObject:flowers toFile:DATAPATH];
}

- (BOOL) unarchiveInterfaceInView: (UIView *) backdrop
{
	NSArray *flowers = [NSKeyedUnarchiver unarchiveObjectWithFile:DATAPATH];
	if (!flowers) return NO;

	for (UIView *aView in flowers)	
	{
		[backdrop addSubview:aView];
		[(DragView *)aView setViewController:self];
	}
	return YES;
}

CGPoint randomPoint() 
{
	int half = 32; // half of flower size
	int freesize = 240 - 2 * half; // inner area
	return CGPointMake(random() % freesize + half, random() % freesize + half);
}

- (void) loadFlowersInView: (UIView *) backdrop
{
	for (int i = 0; i < MAXFLOWERS; i++)
	{
		NSString *whichFlower = [[NSArray arrayWithObjects:@"blueFlower.png", @"pinkFlower.png", @"orangeFlower.png", nil] objectAtIndex:(random() % 3)];
		DragView *dragger = [[DragView alloc] initWithImage:[UIImage imageNamed:whichFlower]];
		dragger.center = randomPoint();
		dragger.userInteractionEnabled = YES;
		dragger.whichFlower = whichFlower;
		dragger.viewController = self;
		[backdrop addSubview:dragger];
		[dragger release];
	}
}

- (void) viewDidLoad
{
	// Initialize the undo manager for this application
	self.undoManager = [[NSUndoManager alloc] init];
	[self.undoManager setLevelsOfUndo:999];
	[self.undoManager release];
	
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	srandom(time(0));
	
	// Add backdrop which will bound the movement for the flowers
	UIView *backdrop = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 282.0f)];
	backdrop.backgroundColor = [UIColor blackColor];
	backdrop.center = CGPointMake(160.0f, 140.0f);
	backdrop.tag = 201;

	if (![self unarchiveInterfaceInView:backdrop])
		[self loadFlowersInView:backdrop]; 

	[self.view  addSubview:backdrop];
	[backdrop release];
}

- (void) dealloc
{
	self.undoManager = nil;
	[super dealloc];
}
@end

@interface TestBedAppDelegate : NSObject <UIApplicationDelegate>
{
	TestBedViewController *tbvc;
}
@property (retain) TestBedViewController *tbvc;
@end

@implementation TestBedAppDelegate
@synthesize tbvc;

- (void)applicationDidFinishLaunching:(UIApplication *)application {	
	UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.tbvc = [[[TestBedViewController alloc] init] autorelease];
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self.tbvc];
	[window addSubview:nav.view];
	[window makeKeyAndVisible];
}

- (void) applicationWillTerminate: (UIApplication *) application
{
	[self.tbvc archiveInterface]; // update the defaults on quit
}
@end

int main(int argc, char *argv[])
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	int retVal = UIApplicationMain(argc, argv, nil, @"TestBedAppDelegate");
	[pool release];
	return retVal;
}
