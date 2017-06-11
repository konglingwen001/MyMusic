//
//  ToolView.m
//  MyMusic
//
//  Created by 孔令文 on 2017/4/10.
//  Copyright © 2017年 孔令文. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import "ToolViewController.h"

@interface ToolViewController ()<AVAudioPlayerDelegate, AVAudioRecorderDelegate>

// 录音存储路径
@property (nonatomic, strong) NSURL *recordFile;

// 录音
@property (nonatomic, strong) AVAudioRecorder *recorder;

// 播放
@property (nonatomic, strong) AVAudioPlayer *player;

// 录音状态（是否在录音）
@property (nonatomic, assign) BOOL isRecording;

@end

@implementation ToolViewController {
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.sampler = [[YYSampler alloc] init];
    
    NSURL *presetURL;
    presetURL = [[NSBundle mainBundle] URLForResource:@"GeneralUser GS SoftSynth v1.44"
                                        withExtension:@"sf2"];
    [_sampler loadFromDLSOrSoundFont:presetURL withPatch:24];
    
}
- (IBAction)startRecord:(id)sender {
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *sessionError;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    if (session == nil) {
        NSLog(@"");
    } else {
        [session setActive:YES error:nil];
    }
    
    if (!self.isRecording) {
        NSMutableDictionary *recordSetting = [NSMutableDictionary dictionary];
        [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
        [recordSetting setValue:[NSNumber numberWithFloat:8000.0f] forKey:AVSampleRateKey];
        [recordSetting setValue:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
        [recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityLow] forKey:AVEncoderAudioQualityKey];
        
        self.recordFile = [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingString:[NSString stringWithFormat:@"/%@.caf", @"test"]]];
        
        NSError *error;
        self.recorder = [[AVAudioRecorder alloc] initWithURL:self.recordFile settings:recordSetting error:&error];
        self.recorder.meteringEnabled = YES;
        [self.recorder prepareToRecord];
        [self.recorder record];
    }
    
}
- (IBAction)stopRecord:(id)sender {
    [self.recorder stop];
}
- (IBAction)startPlay:(id)sender {
    NSError *error;
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:self.recordFile error:&error];
    if (self.player == nil) {
        NSLog(@"没有录音文件");
    }
    [self.player play];
}
- (IBAction)stopPlay:(id)sender {
    
    [self.sampler triggerNote:30 isOn:YES];
    //[self.player stop];
}
- (IBAction)test:(id)sender {
    UIButton *button = (UIButton *)sender;
    [self.sampler triggerNote:button.tag isOn:YES];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
