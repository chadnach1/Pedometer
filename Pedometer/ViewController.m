//
//  ViewController.m
//  Pedometer
//
//  Created by Chad Nachiappan on 9/14/14.
//  Copyright (c) 2014 Chad Nachiappan. All rights reserved.
//

#import "ViewController.h"
#import "UIColor+HexString.h"

#import "BitcoinRewarding.h"

@interface ViewController ()
@property UIButton *rightButton;
@property NSMutableArray *transactions;
@property BRAccount *account;
@end

@implementation ViewController

@synthesize headingLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getAuthCode:) name:BR_AUTHCODE_NOTIFICATION_TYPE object:nil];
    
    [self auth];

    
    self.view.backgroundColor = [UIColor colorWithHexString:@"#4CD964"];
    
   headingLabel = [[UILabel alloc] initWithFrame:CGRectMake(-100, 30, 500, 500)];
    
    headingLabel.text = @"0";
    headingLabel.textColor = [UIColor orangeColor];
    
    headingLabel.textAlignment = NSTextAlignmentCenter;
    headingLabel.backgroundColor = [UIColor clearColor];
    headingLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Thin" size:100.0];
    headingLabel.hidden = NO;
    headingLabel.highlighted = YES;
    headingLabel.highlightedTextColor = [UIColor whiteColor];
    headingLabel.lineBreakMode = YES;
    headingLabel.numberOfLines = 0;
    
    [self.view addSubview:headingLabel];
    
    [[UIAccelerometer sharedAccelerometer] setUpdateInterval:1.0 / 60.0];
    [[UIAccelerometer sharedAccelerometer] setDelegate:self];
    
    px = py = pz = 0;
    numSteps = 0;
    
    headingLabel.text = [NSString stringWithFormat:@"%d", numSteps];
    
    if (headingLabel.text == @"20") {
        
        [BitcoinRewarding sendO2];
        
        NSString *message = [NSString stringWithFormat:@"You get %@ bitcoin", [BitcoinRewarding getBitcoinUnit]];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Congratulations" message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];

    }
	// Do any additional setup after loading the view, typically from a nib.
}

// UIAccelerometerDelegate method, called when the device accelerates.
-(void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
    
    float xx = acceleration.x;
    float yy = acceleration.y;
    float zz = acceleration.z;
    
    float dot = (px * xx) + (py * yy) + (pz * zz);
    float a = ABS(sqrt(px * px + py * py + pz * pz));
    float b = ABS(sqrt(xx * xx + yy * yy + zz * zz));
    
    dot /= (a * b);
    
    if (dot <= 0.82) {
        if (!isSleeping) {
            isSleeping = YES;
            [self performSelector:@selector(wakeUp) withObject:nil afterDelay:0.3];
            numSteps += 1;
            if (numSteps == 10) {
                
                [BitcoinRewarding sendO2];
                
                NSString *message = [NSString stringWithFormat:@"You get %@ bitcoin", [BitcoinRewarding getBitcoinUnit]];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Congratulations" message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alert show];
            }

            headingLabel.text = [NSString stringWithFormat:@"%d", numSteps];
                

        }
    }
    
    
    px = xx; py = yy; pz = zz;
    
}

- (void)wakeUp {
    isSleeping = NO;
}


- (IBAction)reset:(id)sender {
    numSteps = 0;
    self.headingLabel.text = [NSString stringWithFormat:@"%d", numSteps];
}

- (void)getAuthCode:(NSNotification *)notification
{
    NSLog(@"%@",[[notification userInfo] objectForKey:BR_AUTHCODE_URL_KEY]);
    
    // We need this url link when we login at the first time.
    [[UIApplication sharedApplication] openURL:[[notification userInfo] objectForKey:BR_AUTHCODE_URL_KEY]];
}


// Get uers data. That's necessary to setup.
- (void)auth
{
    NSLog([BRCoinbase isAuthenticated] ? @"Yes" : @"No");
    
    if (![BRCoinbase isAuthenticated]) {
        [BRCoinbase login:^(NSError *error) {
            if (error) {
                NSLog(@"%@", error);
            } else {
                [BRCoinbase getAccount:^(BRAccount *account, NSError *error) {
                    self.account = account;
                    [BRExchange getExchangeRates:^(NSDictionary *entries, NSError *error) {
                        
                    }];
                    
                    [self.account getTransactions:^(NSArray *transactions, NSError *error) {
                        self.transactions = [transactions mutableCopy];
                        
                    }];
                }];
            }
        }];
    } else {
        self.account = nil;
        [self.transactions removeAllObjects];
    }
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
