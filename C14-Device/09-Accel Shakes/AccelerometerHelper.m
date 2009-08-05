#import "AccelerometerHelper.h"

#define UNDEFINED_VALUE		999.99f
#define SIGN(x)	((x < 0.0f) ? -1.0f : 1.0f)

@implementation AccelerometerHelper
@synthesize sensitivity;
@synthesize lockout;
@synthesize triggerTime;
@synthesize delegate;

static AccelerometerHelper *sharedInstance = nil;

+(AccelerometerHelper *) sharedInstance {
    if(!sharedInstance) sharedInstance = [[self alloc] init];
    return sharedInstance;
}

- (id) init
{
	if (!(self = [super init])) return self;
	
	self.triggerTime = [NSDate date];
	
	cx = UNDEFINED_VALUE;
	cy = UNDEFINED_VALUE;
	cz = UNDEFINED_VALUE;
	
	lx = UNDEFINED_VALUE;
	ly = UNDEFINED_VALUE;
	lz = UNDEFINED_VALUE;

	px = UNDEFINED_VALUE;
	py = UNDEFINED_VALUE;
	pz = UNDEFINED_VALUE;
	
	self.sensitivity = 0.5f;
	self.lockout = 0.5f;
	
	// Start the accelerometer going
	[[UIAccelerometer sharedAccelerometer] setDelegate:self];
	
	return self;
}

- (void) setX: (float) aValue
{
	px = lx;
	lx = cx;
	cx = aValue;
}

- (void) setY: (float) aValue
{
	py = ly;
	ly = cy;
	cy = aValue;
}

- (void) setZ: (float) aValue
{
	pz = lz;
	lz = cz;
	cz = aValue;
}

- (float) dAngle
{
	if (cx == UNDEFINED_VALUE) return UNDEFINED_VALUE;
	if (lx == UNDEFINED_VALUE) return UNDEFINED_VALUE;
	if (px == UNDEFINED_VALUE) return UNDEFINED_VALUE;
	
	// Calculate the dot product of the first pair
	float dot1 = cx * lx + cy * ly + cz * lz;
	float a = ABS(sqrt(cx * cx + cy * cy + cz * cz));
	float b = ABS(sqrt(lx * lx + ly * ly + lz * lz));
	dot1 /= (a * b);
	
	// Calculate the dot product of the second pair
	float dot2 = lx * px + ly * py + lz * pz;
	a = ABS(sqrt(px * px + py * py + pz * pz));
	dot2 /= a * b;
	
	// Return the difference between the vector angles
	return acos(dot2) - acos(dot1);
}

- (BOOL) checkTrigger
{
	if (lx == UNDEFINED_VALUE) return NO;
	
	// Check to see if the new data can be triggered
	if ([[NSDate date] timeIntervalSinceDate:self.triggerTime] < self.lockout) return NO;
	
	// Get the current angular change
	float change = [self dAngle];
	
	// If we have not yet gathered two samples, return NO
	if (change == UNDEFINED_VALUE) return NO;
	
	// Check to see if the dot product falls below the trigger sensitivity
	if (change > self.sensitivity)
	{
		self.triggerTime = [NSDate date];
		return YES;
	}
	else return NO;
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
	[self setX:-[acceleration x]];
	[self setY:[acceleration y]];
	[self setZ:[acceleration z]];
	
	// All accelerometer events
	if (self.delegate && [self.delegate respondsToSelector:@selector(ping)])
		[self.delegate performSelector:@selector(ping)];
	
	// All shake events
	if ([self checkTrigger] && self.delegate && [self.delegate respondsToSelector:@selector(shake)])
	{
		[self.delegate performSelector:@selector(shake)];
	}
}


@end
