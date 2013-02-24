//
//  ViewController.h
//  JuniorProject
//
//  Created by Kelvin McDonald on 2/17/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <NSStreamDelegate>

@property (nonatomic, strong) NSInputStream *inputStream;
@property (nonatomic, strong) NSOutputStream *outputStream;

@property (weak, nonatomic) IBOutlet UISegmentedControl *testSegment;
@property (weak, nonatomic) IBOutlet UIView* levelView;

-(IBAction)segmentChanged:(id)sender;
-(IBAction)refreshLevel:(id)sender;

@end
