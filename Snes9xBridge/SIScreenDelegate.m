#import "SIScreenDelegate.h"

static NSObject<SIScreenDelegate>* delegate = nil;

void SISetScreenDelegate(NSObject<SIScreenDelegate>* value)
{
  delegate = value;
}

#pragma mark - Internal Flip Callback

void SIFlipFramebufferClient(int width, int height)
{
  [delegate performSelectorOnMainThread:@selector(flipFrontbuffer:) withObject:@[[NSNumber numberWithInt:width], [NSNumber numberWithInt:height]] waitUntilDone:NO];
}
