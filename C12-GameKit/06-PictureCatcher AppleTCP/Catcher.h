#import <Cocoa/Cocoa.h>
#import "TCPConnection.h"

@interface Catcher : NSObject <TCPConnectionDelegate>
{
	IBOutlet NSImageView *imageView;
	IBOutlet NSTextField *textField;
	IBOutlet NSTextField *statusText;
	IBOutlet NSButton *button;
	IBOutlet NSMenuItem *saveItem;
	IBOutlet NSProgressIndicator *progress;
	
	NSData *imageData;
	NSNetServiceBrowser *browser;
	
	BOOL success;
}

@property (retain) NSData *imageData;
@property (retain) NSNetServiceBrowser *browser;

- (IBAction) catchPlease: (id) sender;
- (IBAction) savePlease: (id) sender;
@end
