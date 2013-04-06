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

static int lastContainer = 1;

#pragma mark - View lifecycle

- (void)viewDidUnload
{
	[super viewDidUnload];
	[self setTestSegment:nil];
	[self setLevelView:nil];
	[[NetworkLayer sharedSingleton] setDelegate:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[[NetworkLayer sharedSingleton] setDelegate:self];
}

-(IBAction)refreshLevel:(id)sender
{
	[self getWaterLevel];
}

-(IBAction)segmentChanged:(id)sender
{
	UISegmentedControl* seg = (UISegmentedControl*)sender;
	
	switch (seg.selectedSegmentIndex)
	{
		case 0:
			if(self.view.tag == 1)
				[[NetworkLayer sharedSingleton] setTank1WaterLevel:FULL];
			else if(self.view.tag == 2)
				[[NetworkLayer sharedSingleton] setTank2WaterLevel:FULL];
			break;

		case 1:
			if(self.view.tag == 1)
				[[NetworkLayer sharedSingleton] setTank1WaterLevel:HALF];
			else if(self.view.tag == 2)
				[[NetworkLayer sharedSingleton] setTank2WaterLevel:HALF];
			break;
			
		case 2:
			if(self.view.tag == 1)
				[[NetworkLayer sharedSingleton] setTank1WaterLevel:QUARTER];
			else if(self.view.tag == 2)
				[[NetworkLayer sharedSingleton] setTank2WaterLevel:QUARTER];
			break;
			
		case 3:
			if(self.view.tag == 1)
				[[NetworkLayer sharedSingleton] setTank1WaterLevel:DANGER];
			else if(self.view.tag == 2)
				[[NetworkLayer sharedSingleton] setTank2WaterLevel:DANGER];
			break;
			
		default:
			if(self.view.tag == 1)
				[[NetworkLayer sharedSingleton] setTank1WaterLevel:FULL];
			else if(self.view.tag == 2)
				[[NetworkLayer sharedSingleton] setTank2WaterLevel:FULL];
			break;
	}
}

- (void)getWaterLevel
{
	if(self.view.tag == 1)
	{
		lastContainer = 1;
		[[NetworkLayer sharedSingleton] getTank1WaterLevel];
	}
	else if(self.view.tag == 2)
	{
		lastContainer = 2;
		[[NetworkLayer sharedSingleton] getTank2WaterLevel];
	}
}

-(void)messageFromServer:(NSString *)message
{
	NSLog(@"To container %d", self.view.tag);
	
	if(self.view.tag == lastContainer)
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
			CGRect rect = CGRectMake(self.levelView.frame.origin.x, VIEW_HEIGHT - height, VIEW_WIDTH, height);
			
			self.levelView.frame = rect;
		}
	}
}

@end
