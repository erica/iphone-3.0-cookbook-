/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import "Recorder.h"

#define SAMPLES_PER_SECOND	8000.0f

// Derive the Buffer Size. I punt with the max buffer size.
void DeriveBufferSize (AudioQueueRef audioQueue, AudioStreamBasicDescription ASBDescription, Float64 seconds, UInt32 *outBufferSize)
{
    static const int maxBufferSize = 0x50000; // punting with 50k
    int maxPacketSize = ASBDescription.mBytesPerPacket; 
    if (maxPacketSize == 0) 
	{                           
        UInt32 maxVBRPacketSize = sizeof(maxPacketSize);
        AudioQueueGetProperty(audioQueue, kAudioConverterPropertyMaximumOutputPacketSize, &maxPacketSize, &maxVBRPacketSize);
    }
    
    Float64 numBytesForTime = ASBDescription.mSampleRate * maxPacketSize * seconds;
    *outBufferSize =  (UInt32)((numBytesForTime < maxBufferSize) ? numBytesForTime : maxBufferSize);
}

// Handle new input
static void HandleInputBuffer (void *aqData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer, const AudioTimeStamp *inStartTime,
							   UInt32 inNumPackets, const AudioStreamPacketDescription *inPacketDesc)
{
    RecordState *pAqData = (RecordState *) aqData;
    
    if (inNumPackets == 0 && pAqData->dataFormat.mBytesPerPacket != 0)
        inNumPackets = inBuffer->mAudioDataByteSize / pAqData->dataFormat.mBytesPerPacket;
    
    if (AudioFileWritePackets(pAqData->audioFile, NO, inBuffer->mAudioDataByteSize, inPacketDesc, pAqData->currentPacket, &inNumPackets, inBuffer->mAudioData) == noErr) 
    {
        pAqData->currentPacket += inNumPackets;   
        if (pAqData->recording == 0) return;
        AudioQueueEnqueueBuffer (pAqData->queue, inBuffer, 0, NULL);
    }
}

@implementation Recorder

// Initialize the recorder
- (id) init
{
    if (self = [super init]) recordState.recording = NO;    
    return self;
}

// Set up the recording format as low quality mono AIFF
- (void)setupAudioFormat:(AudioStreamBasicDescription*)format
{
    format->mSampleRate = SAMPLES_PER_SECOND;
    format->mFormatID = kAudioFormatLinearPCM;
    format->mFormatFlags = kLinearPCMFormatFlagIsBigEndian |  kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked; 
    format->mChannelsPerFrame = 1; // mono
    format->mBitsPerChannel = 16; 
    format->mFramesPerPacket = 1;
    format->mBytesPerPacket = 2; 
    format->mBytesPerFrame = 2;
    format->mReserved = 0; 
}

// Begin recording
- (BOOL) startRecording: (NSString *) filePath
{
	// file url
    [self setupAudioFormat:&recordState.dataFormat];
    CFURLRef fileURL =  CFURLCreateFromFileSystemRepresentation(NULL, (const UInt8 *) [filePath UTF8String], [filePath length], NO);
    // recordState.currentPacket = 0;
    
	// new input queue
    OSStatus status;
    status = AudioQueueNewInput(&recordState.dataFormat, HandleInputBuffer, &recordState, CFRunLoopGetCurrent(),kCFRunLoopCommonModes, 0, &recordState.queue);
    if (status) {CFRelease(fileURL); printf("Could not establish new queue\n"); return NO;}
  
	// create new audio file
    status = AudioFileCreateWithURL(fileURL, kAudioFileAIFFType, &recordState.dataFormat, kAudioFileFlags_EraseFile, &recordState.audioFile);
	CFRelease(fileURL); // thanks august joki
    if (status) {printf("Could not create file to record audio\n"); return NO;}
    
	// figure out the buffer size
    DeriveBufferSize(recordState.queue, recordState.dataFormat, 0.5, &recordState.bufferByteSize);
	
	// allocate those buffers and enqueue them
    for(int i = 0; i < NUM_BUFFERS; i++)
    {
        status = AudioQueueAllocateBuffer(recordState.queue, recordState.bufferByteSize, &recordState.buffers[i]);
        if (status) {printf("Error allocating buffer %d\n", i); return NO;}

        status = AudioQueueEnqueueBuffer(recordState.queue, recordState.buffers[i], 0, NULL);
        if (status) {printf("Error enqueuing buffer %d\n", i); return NO;}
    }
	
	// enable metering
    UInt32 enableMetering = YES;
    status = AudioQueueSetProperty(recordState.queue, kAudioQueueProperty_EnableLevelMetering, &enableMetering,sizeof(enableMetering));
    if (status) {printf("Could not enable metering\n"); return NO;}
    
	// start recording
    status = AudioQueueStart(recordState.queue, NULL);
    if (status) {printf("Could not start Audio Queue\n"); return NO;}
    recordState.currentPacket = 0;
    recordState.recording = YES;
    return YES;
}

- (float) averagePower
{
    AudioQueueLevelMeterState state[1];
    UInt32  statesize = sizeof(state);
    OSStatus status;
    status = AudioQueueGetProperty(recordState.queue, kAudioQueueProperty_CurrentLevelMeter, &state, &statesize);
    if (status) {printf("Error retrieving meter data\n"); return 0.0f;}
    return state[0].mAveragePower;
}

- (float) peakPower
{
    AudioQueueLevelMeterState state[1];
    UInt32  statesize = sizeof(state);
    OSStatus status;
    status = AudioQueueGetProperty(recordState.queue, kAudioQueueProperty_CurrentLevelMeter, &state, &statesize);
    if (status) {printf("Error retrieving meter data\n"); return 0.0f;}
    return state[0].mPeakPower;
}

// There's generally about a one-second delay before the buffers fully empty
- (void) reallyStopRecording
{
    AudioQueueFlush(recordState.queue);
    AudioQueueStop(recordState.queue, NO);
    recordState.recording = NO;
    
    for(int i = 0; i < NUM_BUFFERS; i++)
		AudioQueueFreeBuffer(recordState.queue, recordState.buffers[i]);
 
    AudioQueueDispose(recordState.queue, YES);
    AudioFileClose(recordState.audioFile);
}

// Stop the recording after waiting just a second
- (void) stopRecording
{
    [self performSelector:@selector(reallyStopRecording) withObject:NULL afterDelay:1.0f];
}

- (void) reallyPauseRecording
{
	if (!recordState.queue) {printf("Nothing to pause\n"); return;}
    OSStatus status = AudioQueuePause(recordState.queue);
    if (status) {printf("Error pausing audio queue\n"); return;}
}

- (void) pause
{
	[self performSelector:@selector(reallyPauseRecording) withObject:NULL afterDelay:0.5f];
}

- (BOOL) resume
{
    if (!recordState.queue){printf("Nothing to resume\n"); return NO;}
    OSStatus status = AudioQueueStart(recordState.queue, NULL);
    if (status) {printf("Error restarting audio queue\n"); return NO;}
    return YES;
}

// Return the current time
- (float) currentTime
{
    AudioTimeStamp outTimeStamp;
    OSStatus status = AudioQueueGetCurrentTime (recordState.queue, NULL, &outTimeStamp, NULL);
    if (status) {printf("Error: Could not retrieve current time\n"); return 0.0f;}
    return outTimeStamp.mSampleTime / SAMPLES_PER_SECOND;
}

// Return whether the recording is active
- (BOOL) isRecording
{
    return recordState.recording;
}

@end
