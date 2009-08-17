/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioQueue.h>
#import <AudioToolbox/AudioFile.h>

#define NUM_BUFFERS 3
#define kAudioConverterPropertyMaximumOutputPacketSize		'xops'
#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

typedef struct
	{
		AudioFileID                 audioFile;
		AudioStreamBasicDescription dataFormat;
		AudioQueueRef               queue;
		AudioQueueBufferRef         buffers[NUM_BUFFERS];
		UInt32                      bufferByteSize; 
		SInt64                      currentPacket;
		BOOL                        recording;
	} RecordState;

@interface Recorder : NSObject {
	RecordState recordState;
}

- (BOOL)	isRecording;
- (float)	averagePower;
- (float)	peakPower;
- (float)	currentTime;
- (BOOL)	startRecording: (NSString *) filePath;
- (void)	stopRecording;
- (void)	pause;
- (BOOL)	resume;
@end
