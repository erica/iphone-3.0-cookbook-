#import <UIKit/UIKit.h>

@protocol AccelerometerHelperDelegate <NSObject>
@optional
- (void) shake; // shake event
- (void) ping; // accelerometer event
@end

@interface AccelerometerHelper : NSObject <UIAccelerometerDelegate>
{
	float	cx, cy, cz; // current
	float	lx, ly, lz; // last
	float	px, py, pz; // previous
	
	float	sensitivity;
	
	NSDate	*triggerTime;
	NSTimeInterval lockout;
	
	id <AccelerometerHelperDelegate> delegate;	
}

+ (AccelerometerHelper *) sharedInstance;

- (BOOL) checkTrigger;
- (float) dAngle;

@property (retain)	NSDate *triggerTime;
@property (assign)	float sensitivity;
@property (assign)	NSTimeInterval lockout;
@property (retain)	id delegate;
@end
