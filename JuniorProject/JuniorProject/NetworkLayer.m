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

-(void)setTank1WaterLevel:(WATER_LEVELS)level
{
	[self sendTank:1 WaterLevel:level];
}

-(void)setTank2WaterLevel:(WATER_LEVELS)level
{
	[self sendTank:2 WaterLevel:level];
}

-(void)sendTank:(int)tank WaterLevel:(WATER_LEVELS)level
{
	NSString* message;
	
	switch (level)
	{
		case 0:
			message = [NSString stringWithFormat:@"SetWaterLevel%d:Full:", tank];
			break;
			
		case 1:
			message = [NSString stringWithFormat:@"SetWaterLevel%d:Half:", tank];
			break;
			
		case 2:
			message = [NSString stringWithFormat:@"SetWaterLevel%d:Quarter:", tank];
			break;
			
		case 3:
			message = [NSString stringWithFormat:@"SetWaterLevel%d:Danger:", tank];
			break;
			
		default:
			message = @"Error";
			break;
	}
	
	[self sendMessage:message];
}

@end
