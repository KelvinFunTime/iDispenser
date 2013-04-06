//
//  NetworkLayer.m
//  JuniorProject
//
//  Created by K Mac on 3/17/13.
//
//

#import "NetworkLayer.h"

@interface NetworkLayer()
@property (nonatomic, strong) NSInputStream *inputStream;
@property (nonatomic, strong) NSOutputStream *outputStream;
@end

@implementation NetworkLayer

+(NetworkLayer*)sharedSingleton
{
	static NetworkLayer *sharedSingleton;
	
	@synchronized(self)
	{
		if (!sharedSingleton)
		{
			sharedSingleton = [[NetworkLayer alloc] init];
			[sharedSingleton initNetworkCommunication];
		}
		
		return sharedSingleton;
	}
}
//97.94.241.232
- (void)initNetworkCommunication
{
	CFReadStreamRef readStream;
	CFWriteStreamRef writeStream;
	CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"minecraft365.chickenkiller.com", 4321, &readStream, &writeStream);
	
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
			NSLog(@"Can not connect to the host!");
			break;
			
		case NSStreamEventEndEncountered:
            [theStream close];
            [theStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            theStream = nil;
			NSLog(@"Stream closed");
			
			break;
		default:
			//NSLog(@"Unknown event");
			break;
	}
}

- (void)messageReceived:(NSString*)message
{
	[self.delegate messageFromServer:message];
}

- (void)sendMessage:(NSString*)message
{
	NSData *data = [[NSData alloc] initWithData:[message dataUsingEncoding:NSASCIIStringEncoding]];
	[self.outputStream write:[data bytes] maxLength:[data length]];
}

-(void)getTank1WaterLevel
{
	[self sendMessage:@"GetWaterLevel1:"];
}
-(void)getTank2WaterLevel
{
	[self sendMessage:@"GetWaterLevel2:"];
}

@end
