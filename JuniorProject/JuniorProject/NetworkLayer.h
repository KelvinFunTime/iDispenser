//
//  NetworkLayer.h
//  JuniorProject
//
//  Created by K Mac on 3/17/13.
//
//

#import <Foundation/Foundation.h>

typedef enum
{
	FULL = 0,
	HALF,
	QUARTER,
	DANGER
} WATER_LEVELS;

@protocol NetworkDelegate
-(void)messageFromServer:(NSString*)message;
@end

@interface NetworkLayer : NSObject <NSStreamDelegate>

@property (nonatomic, weak) id<NetworkDelegate> delegate;

+(NetworkLayer*)sharedSingleton;
- (void)initNetworkCommunication;

-(void)getTank1WaterLevel;
-(void)getTank2WaterLevel;

@end