#import "ScrollWheel.h"

#pragma mark Math
// Return a point with respect to a given origin
CGPoint centeredPoint(CGPoint pt, CGPoint origin)
{
	return CGPointMake(pt.x - origin.x, pt.y - origin.y);
}

// Return the angle of a point with respect to a given origin
float getangle (CGPoint p1, CGPoint c1)
{
	// SOH CAH TOA 
	CGPoint p = centeredPoint(p1, c1);
	float h = ABS(sqrt(p.x * p.x + p.y * p.y));
	float a = p.x;
	float baseAngle = acos(a/h) * 180.0f / M_PI;
	
	// Above 180
	if (p1.y > c1.y) baseAngle = 360.0f - baseAngle;
	
	return baseAngle;
}

// Return whether a point falls within the radius from a given origin
BOOL pointInsideRadius(CGPoint p1, float r, CGPoint c1)
{
	CGPoint pt = centeredPoint(p1, c1);
	float xsquared = pt.x * pt.x;
	float ysquared = pt.y * pt.y;
	float h = ABS(sqrt(xsquared + ysquared));
	if (((xsquared + ysquared) / h) < r) return YES;
	return NO;
}

@implementation ScrollWheel
@synthesize value;
@synthesize theta;

#pragma mark Object initialization
- (id) initWithFrame: (CGRect) aFrame
{
	if (self = [super initWithFrame:aFrame])
	{
		// This control uses a fixed 200x200 sized frame
		self.frame = CGRectMake(0.0f, 0.0f, 200.0f, 200.0f); 
		self.center = CGPointMake(CGRectGetMidX(aFrame), CGRectGetMidY(aFrame));
		
		// Add the touchwheel art
		UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wheel.png"]];
		[self  addSubview:iv];
		[iv release];
	}
	
	return self;
}

- (id) init
{
	return [self initWithFrame:CGRectZero];
}

+ (id) scrollWheel
{
	return [[[self alloc] init] autorelease];
}

#pragma mark Touch tracking

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint p = [touch locationInView:self];
	CGPoint cp = CGPointMake(self.bounds.size.width / 2.0f, self.bounds.size.height / 2.0f);
	// self.value = 0.0f; // Uncomment to set each touch to a separate value calculation

	// First touch must touch the gray part of the wheel
	if (!pointInsideRadius(p, cp.x, cp)) return NO;
	if (pointInsideRadius(p, 30.0f, cp)) return NO;

	// Set the initial angle
	self.theta = getangle([touch locationInView:self], cp);
	return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	
	CGPoint p = [touch locationInView:self];
	CGPoint cp = CGPointMake(self.bounds.size.width / 2.0f, self.bounds.size.height / 2.0f);

	// falls outside too far, with boundary of 50 pixels. Inside strokes treated as touched
	if (!pointInsideRadius(p, cp.x + 50.0f, cp)) return NO;
	
	float newtheta = getangle([touch locationInView:self], cp);
	float dtheta = newtheta - self.theta;

	// correct for edge conditions
	int ntimes = 0;
	while ((ABS(dtheta) > 300.0f)  && (ntimes++ < 4))
		if (dtheta > 0.0f) dtheta -= 360.0f; else dtheta += 360.0f;

	// Update current values
	self.value -= dtheta / 360.0f;
	self.theta = newtheta;

	// Send value changed alert
	[self sendActionsForControlEvents:UIControlEventValueChanged];

	return YES;
}
@end
