//
//  ViewController.h
//  Pedometer
//
//  Created by Chad Nachiappan on 9/14/14.
//  Copyright (c) 2014 Chad Nachiappan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController {

float px;
float py;
float pz;

int numSteps;
BOOL isChange;
BOOL isSleeping;
    
}

@property (retain, nonatomic) IBOutlet UILabel *headingLabel;

@end
