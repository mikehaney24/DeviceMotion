//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "MainScene.h"
#import <CoreMotion/CoreMotion.h>

@interface MainScene ()

@property (strong, nonatomic) CMMotionManager *motionManager;

@property (strong, nonatomic) CCLabelTTF *yaw;
@property (strong, nonatomic) CCLabelTTF *pitch;
@property (strong, nonatomic) CCLabelTTF *roll;

@property (strong, nonatomic) CCSlider *yawSlider;
@property (strong, nonatomic) CCSlider *pitchSlider;
@property (strong, nonatomic) CCSlider *rollSlider;

@end

@implementation MainScene

- (id)init
{
    self = [super init];
    if (self) {
        self.motionManager = [[CMMotionManager alloc] init];
        self.motionManager.deviceMotionUpdateInterval = (1.0 / 60);
    }
    return self;
}

- (void)onEnter
{
    [super onEnter];
    [self startDeviceMotion];
}

- (void)onExit
{
    [self stopDeviceMotion];
    [super onExit];
}

- (float)normalizeRadians:(float)value
{
    // y = (x - A) / (B - A) * (D - C) + C
    float A = -M_PI/4;
    float B = +M_PI/4;
    float C = 0;
    float D = 1;
    
    // Handle upper boundary
    if (value >= B) {
        return D;
    }
    
    // Handle lower boundary
    if (value <= A) {
        return C;
    }
    
    // Handle divide-by-zero case
    if (B - A == 0) {
        return D;
    }
    
    return (value - A) / (B - A) * (D - C) + C;
}

- (void)startDeviceMotion
{
    __weak typeof(self) weakSelf = self;
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [self.motionManager
        startDeviceMotionUpdatesToQueue:queue
        withHandler:^(CMDeviceMotion *motion, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf handleDeviceMotionUpdate:motion];
            });
        }];
}

- (void)handleDeviceMotionUpdate:(CMDeviceMotion *)motion
{
    float yaw = motion.attitude.yaw;
    float pitch = motion.attitude.pitch;
    float roll = motion.attitude.roll;
    self.yaw.string = [NSString stringWithFormat:@"%0.4f", yaw];
    self.pitch.string = [NSString stringWithFormat:@"%0.4f", pitch];
    self.roll.string = [NSString stringWithFormat:@"%0.4f", roll];
    self.yawSlider.sliderValue = [self normalizeRadians:yaw];
    self.pitchSlider.sliderValue = [self normalizeRadians:pitch];
    self.rollSlider.sliderValue = [self normalizeRadians:roll];
}

- (void)stopDeviceMotion
{
    [self.motionManager stopDeviceMotionUpdates];
}

@end
