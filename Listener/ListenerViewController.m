//
//  ListenerViewController.m
//  Listener
//
//  Created by li yajie on 11/25/12.
//  Copyright (c) 2012 com.coamee. All rights reserved.
//

#import "ListenerViewController.h"

@interface ListenerViewController ()

@end

@implementation ListenerViewController
{
    AVAudioRecorder * recorder;
    NSTimer * internalTimer;
    double soundLevel;
}


-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
       
    }
    return self;
}
-(void) timerCallback:(NSTimer*)timer {
    [recorder updateMeters];
    double peakPowerForChannel = pow(10, (0.05 * [recorder peakPowerForChannel:0]));
    soundLevel =  0.05 * peakPowerForChannel + soundLevel * 0.95;
    if (soundLevel - 0.95 < 0 ) {
        [_mSilderView setValue:soundLevel * 100 animated:YES];
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
//    NSArray *fontFanimies = [UIFont familyNames];
//    for (NSString* familiy in fontFanimies) {
//        NSLog(@"the font family %@",familiy);
//        NSLog(@"the font\n");
//        NSLog(@"%@",[UIFont fontNamesForFamilyName:familiy]);
//    }
    NSString * soundPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
   soundPath =  [soundPath stringByAppendingPathComponent:@"RecordedFile"];
    NSURL *url = [NSURL fileURLWithPath:soundPath];
    
    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithFloat: 44100.0],                 AVSampleRateKey,
                              [NSNumber numberWithInt: kAudioFormatAppleLossless], AVFormatIDKey,
                              [NSNumber numberWithInt: 1],                         AVNumberOfChannelsKey,
                              [NSNumber numberWithInt: AVAudioQualityMax],         AVEncoderAudioQualityKey,
                              nil];
    
    NSError *error;
    recorder = [[AVAudioRecorder alloc]initWithURL:url settings:settings error:&error];
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(8.0, 8.0), NO, 0);
    //透明的图片
     UIImage * transparentImage =  UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    _mSilderView.value = 0.f;
    _mSilderView.minimumValue = 0.f;
    _mSilderView.maximumValue = 100.f;
    [_mSilderView setMinimumTrackImage:transparentImage forState:UIControlStateNormal];
    [_mSilderView setMaximumTrackImage:[UIImage imageNamed:@"max"] forState:UIControlStateNormal];
    [_mSilderView setMaximumTrackImage:[UIImage imageNamed:@"max"] forState:UIControlStateHighlighted];
    [_mSilderView setThumbImage:transparentImage forState:UIControlStateNormal];
    [_mSilderView setThumbImage:transparentImage forState:UIControlStateHighlighted];
    if (recorder && !error) {
        [recorder prepareToRecord];
        recorder.meteringEnabled = YES;
        [recorder record];
        internalTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerCallback:) userInfo:nil repeats:YES];
    } else {
        NSLog(@"construct error %@",[error description]);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)dealloc {
    if (recorder && recorder.isRecording) {
        [recorder stop];
        [recorder release];
        recorder = nil;
    }
    [internalTimer release];
    [_mSilderView release];
    [_mProgressView release];
    [super dealloc];
}
@end
