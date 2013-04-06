//
//  ViewController.h
//  JuniorProject
//
//  Created by Kelvin McDonald on 2/17/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetworkLayer.h"

@interface ViewController : UIViewController <NetworkDelegate>

@property (weak, nonatomic) IBOutlet UIView* levelView;

-(IBAction)refreshLevel:(id)sender;

@end
