//
//  ViewController.m
//  SXJOrientationLockDetector
//
//  Created by Xinjiang Shao on 11/30/15.
//  Copyright © 2015 Xinjiang Shao. All rights reserved.
//
//  Refer to http://codrspace.com/yuvirajsinh/device-orientation-detection-using-coremotion/

#import "ViewController.h"
#import <CoreMotion/CoreMotion.h>
#import <ImageIO/ImageIO.h>

@interface ViewController () {
    UIInterfaceOrientation orientationLast, orientationAfterProcess;
    CMMotionManager *motionManager;
}

@property (nonatomic, weak) IBOutlet UIButton *lockStatusButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [self initializeMotionManager];
   
    [_lockStatusButton addTarget:self action:@selector(checkOrientationLock:) forControlEvents:UIControlEventTouchUpInside];
    
    
}

- (IBAction)checkOrientationLock:(id)sender {
    BOOL isLocked = [self isOrientationLocked];
    if (isLocked) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Orientation Locked"
                                                                       message:@"You need to unlock orientation to use this feature!"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  [alert dismissViewControllerAnimated:YES completion:nil];
                                                              }];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
    }
    
}

- (BOOL) isOrientationLocked {
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    if (
        (UIDeviceOrientationIsPortrait(deviceOrientation) && !UIInterfaceOrientationIsPortrait(orientationLast)) ||
        (UIDeviceOrientationIsLandscape(deviceOrientation) && !UIInterfaceOrientationIsLandscape(orientationLast))
        )
    {
        NSLog(@"Locked %ld %ld", deviceOrientation, orientationLast);
        return YES;
    } else {
        NSLog(@"Unlocked %ld %ld", deviceOrientation, orientationLast);
        return NO;
    }
}


- (void)initializeMotionManager {
    motionManager = [[CMMotionManager alloc] init];
    motionManager.accelerometerUpdateInterval = .2;
    motionManager.gyroUpdateInterval = .2;
    
    [motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                        withHandler:^(CMAccelerometerData  *accelerometerData, NSError *error) {
                                            if (!error) {
                                                [self outputAccelertionData:accelerometerData.acceleration];
                                                //NSLog(@"update acceleration: %f %f %f",accelerometerData.acceleration.x, accelerometerData.acceleration.y, accelerometerData.acceleration.z);
                                            }
                                            else{
                                                NSLog(@"%@", error);
                                            }
                                        }];
}

- (void)outputAccelertionData:(CMAcceleration)acceleration {
    UIInterfaceOrientation orientationNew;
    
    if (acceleration.x >= 0.75) {
        orientationNew = UIInterfaceOrientationLandscapeLeft;
    }
    else if (acceleration.x <= -0.75) {
        orientationNew = UIInterfaceOrientationLandscapeRight;
    }
    else if (acceleration.y <= -0.75) {
        orientationNew = UIInterfaceOrientationPortrait;
    }
    else if (acceleration.y >= 0.75) {
        orientationNew = UIInterfaceOrientationPortraitUpsideDown;
    }
    else {
        // Consider same as last time
        return;
    }
    
    if (orientationNew == orientationLast)
        return;
    orientationLast = orientationNew;
    
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
