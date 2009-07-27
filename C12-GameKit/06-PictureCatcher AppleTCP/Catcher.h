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
	NSNetService *service;
	
	BOOL success;
}

@property (retain) NSImageView *imageView;
@property (retain) NSTextField *textField;
@property (retain) NSTextField *statusText;
@property (retain) NSButton *button;
@property (retain) NSProgressIndicator *progress;
@property (retain) NSMenuItem *saveItem;
@property (retain) NSData *imageData;
@property (retain) NSNetServiceBrowser *browser;
@property (retain) NSNetService *service;

- (IBAction) catchPlease: (id) sender;
- (IBAction) savePlease: (id) sender;
@end
