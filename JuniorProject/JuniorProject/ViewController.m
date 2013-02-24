//
//  ViewController.m
//  JuniorProject
//
//  Created by Kelvin McDonald on 2/17/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

#define VIEW_HEIGHT 300
#define VIEW_WIDTH 160

@implementation ViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self initNetworkCommunication];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	[self setTestSegment:nil];
	[self setLevelView:nil];
}

- (void)initNetworkCommunication
{
	CFReadStreamRef readStream;
	CFWriteStreamRef writeStream;
	CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"localhost", 8080, &readStream, &writeStream);
	
	self.inputStream = (__bridge NSInputStream *)readStream;
	self.outputStream = (__bridge NSOutputStream *)writeStream;
	[self.inputStream setDelegate:self];
	[self.outputStream setDelegate:self];
	[self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[self.inputStream open];
	[self.outputStream open];
	
	NSLog(@"Network init");
}

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent
{
	switch (streamEvent) {
			
		case NSStreamEventOpenCompleted:
			NSLog(@"Stream opened");
			break;
		case NSStreamEventHasBytesAvailable:
            
			if (theStream == self.inputStream) {
				
				uint8_t buffer[1024];
				int len;
				
				while ([self.inputStream hasBytesAvailable]) {
					len = [self.inputStream read:buffer maxLength:sizeof(buffer)];
					if (len > 0) {
						
						NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
						
						if (nil != output) {
                            
							NSLog(@"server said: %@", output);
							[self messageReceived:output];
							
						}
					}
				}
			}
			break;
            
			
		case NSStreamEventErrorOccurred:
			
			//NSLog(@"Can not connect to the host!");
			break;
			
		case NSStreamEventEndEncountered:
            
            [theStream close];
            [theStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            theStream = nil;
			
			break;
		default:
			NSLog(@"Unknown event");
	}
}

- (void)messageReceived:(NSString*)message
{
	BOOL changed = NO;
	int height = VIEW_HEIGHT;
	
	if([message isEqualToString:@"Full"])
	{
		height *= 0.95;
		changed = YES;
	}
	else if([message isEqualToString:@"Half"])
	{
		height *= 0.50;
		changed = YES;
	}
	else if([message isEqualToString:@"Quarter"])
	{
		height *= 0.25;
		changed = YES;
	}
	else if([message isEqualToString:@"Danger"])
	{
		height *= 0.05;
		changed = YES;
	}
	
	if(changed)
	{
		CGRect rect = CGRectMake(self.levelView.frame.origin.x, 369 - height, VIEW_WIDTH, height);
		
		self.levelView.frame = rect;
	}
}

-(IBAction)refreshLevel:(id)sender
{
	[self getWaterLevel];
}

- (void)sendMessage:(NSString*)message
{
	NSData *data = [[NSData alloc] initWithData:[message dataUsingEncoding:NSASCIIStringEncoding]];
	[self.outputStream write:[data bytes] maxLength:[data length]];
}

-(IBAction)segmentChanged:(id)sender
{
	UISegmentedControl* seg = (UISegmentedControl*)sender;
	
	switch (seg.selectedSegmentIndex)
	{
		case 0:
			[self sendMessage:@"SetWaterLevel:Full:"];
			break;

		case 1:
			[self sendMessage:@"SetWaterLevel:Half:"];
			break;
			
		case 2:
			[self sendMessage:@"SetWaterLevel:Quarter:"];
			break;
			
		case 3:
			[self sendMessage:@"SetWaterLevel:Danger:"];
			break;
			
		default:
			break;
	}
}

- (void)getWaterLevel
{
	[self sendMessage:@"GetWaterLevel:"];
}

@end
