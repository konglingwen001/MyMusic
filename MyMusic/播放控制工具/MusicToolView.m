
//
//  MusicToolView.m
//  MyMusic
//
//  Created by 孔令文 on 2017/3/22.
//  Copyright © 2017年 孔令文. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import "MusicToolView.h"
#import "MusicControl.h"
#import "PopupPlayingListViewController.h"

@interface MusicToolView()

/*! @brief 上一曲 */
@property (strong, nonatomic) IBOutlet UIButton *btnPrevious;

/*! @brief 播放/暂停 */
@property (strong, nonatomic) IBOutlet UIButton *btnPlayPause;

/*! @brief 下一曲 */
@property (strong, nonatomic) IBOutlet UIButton *btnNext;

/*! @brief 歌曲播放进度条 */
@property (strong, nonatomic) IBOutlet UISlider *timeSlider;

/*! @brief 显示播放列表 */
@property (strong, nonatomic) IBOutlet UIButton *btnShowPlayingList;

/*! @brief 循环模式 */
@property (strong, nonatomic) IBOutlet UIButton *btnRepeatMode;

/*! @brief 静音 */
@property (strong, nonatomic) IBOutlet UIButton *btnVolume;

/*! @brief 音量 */
@property (strong, nonatomic) IBOutlet UISlider *volumeSlider;

/*! @brief 当前时间/总时间 */
@property (strong, nonatomic) IBOutlet UILabel *lblTimeInfo;
@property (strong, nonatomic) IBOutlet UIToolbar *playListToolBar;

@end

@implementation MusicToolView
MusicControl *_musicController;
static float volume;
static int repeatMode = 0;

/*!
 * @brief 实例化
 * @discussion xib实例化
 */
+(instancetype)makeItem {
    return [[[NSBundle mainBundle] loadNibNamed:@"MusicToolView" owner:self options:nil] firstObject];
}

-(void)awakeFromNib {
    [super awakeFromNib];
    [self customInit];
}

/*!
 * @brief 初始化
 * @discussion 初始化各控件状态
 */
-(void)customInit {
    _musicController = [MusicControl sharedInstance];
    
    // 播放/暂停按钮初期化
    MPMusicPlaybackState musicPlaybackState = [_musicController getMusicPlayState];
    if (musicPlaybackState == MPMusicPlaybackStatePaused) {
        [self.btnPlayPause setImage:[UIImage imageNamed:@"暂停.png"] forState:UIControlStateNormal];
    } else if (musicPlaybackState == MPMusicPlaybackStatePlaying) {
        [self.btnPlayPause setImage:[UIImage imageNamed:@"播放.png"] forState:UIControlStateNormal];
    }
    
    // 播放进度条初期化
    double time = [_musicController getTotalTimeVal];
    self.timeSlider.maximumValue = time;
    [self.timeSlider setMinimumValue:0.0];
    [self.timeSlider setValue:[_musicController getCurrentTimeVal]];
    
    [self.lblTimeInfo setText:@"ffasdasd"];
    
    [self.volumeSlider setValue:[_musicController getSystemVolume]];
    
    // 循环模式
    [_musicController setRepeatMode:repeatMode];
    switch (repeatMode) {
        case 0:
            [self.btnRepeatMode setImage:[UIImage imageNamed:@"列表循环.png"] forState:UIControlStateNormal];
            break;
        case 1:
            [self.btnRepeatMode setImage:[UIImage imageNamed:@"随机.png"] forState:UIControlStateNormal];
            break;
        case 2:
            [self.btnRepeatMode setImage:[UIImage imageNamed:@"单曲循环.png"] forState:UIControlStateNormal];
            break;
        default:
            break;
    }
    
}

/*!
 * @brief 上一曲
 * @discussion 播放上一曲
 */
- (IBAction)playPrevious:(id)sender {
    [_musicController previous];
    
}

/*!
 * @brief 下一曲
 * @discussion 播放下一曲
 */
- (IBAction)playNext:(id)sender {
    [_musicController next];
}

/*!
 * @brief 播放/暂停
 * @discussion 播放状态切换
 */
- (IBAction)playPause:(id)sender {
    MPMusicPlaybackState musicPlaybackState = [_musicController getMusicPlayState];
    if (musicPlaybackState == MPMusicPlaybackStatePaused) {
        [self.btnPlayPause setImage:[UIImage imageNamed:@"播放.png"] forState:UIControlStateNormal];
        [_musicController play];
    } else if (musicPlaybackState == MPMusicPlaybackStatePlaying) {
        [self.btnPlayPause setImage:[UIImage imageNamed:@"暂停.png"] forState:UIControlStateNormal];
        [_musicController pause];
    }
}

/*!
 * @brief 播放进度调节
 * @discussion 拖动进度条改变播放进度，拖动时歌曲正常播放，不受拖动影响，歌曲当前时间跟进度条同步改变，当手离开进度条时，才改变歌曲播放进度
 */
- (IBAction)moveToTime:(id)sender {
    [self.lblTimeInfo setText:[NSString stringWithFormat:@"%@/%@", [_musicController musicTimeFormat:self.timeSlider.value], [_musicController getTotalTimeStr]]];
}

/*!
 * @brief 手在控件外离开
 * @discussion 更新歌曲播放进度，并重新开始定时器
 */
- (IBAction)touchUpOutside:(id)sender {
    [_musicController setCurrentTime:self.timeSlider.value];
    [_musicController addMusicTimer];
}

/*!
 * @brief 手在控件内离开
 * @discussion 更新歌曲播放进度，并重新开始定时器
 */
- (IBAction)touchUpInside:(id)sender {
    [_musicController setCurrentTime:self.timeSlider.value];
    [_musicController addMusicTimer];
}
- (IBAction)touchDragOutside:(id)sender {
    //NSLog(@"touchDragOutside");
}
- (IBAction)touchDragExit:(id)sender {
    //NSLog(@"touchDragExit");
}
- (IBAction)touchDragInside:(id)sender {
    //NSLog(@"touchDragInside");
}
- (IBAction)touchDragEnter:(id)sender {
    //NSLog(@"touchDragEnter");
}
- (IBAction)touchDownRepeat:(id)sender {
    //NSLog(@"touchDownRepeat");
}
- (IBAction)touchDown:(id)sender {
    [_musicController removeMusicTimer];
}

/*!
 * @brief 静音开关
 * @discussion 有声音时点击，切换到静音；静音时点击，切换到之前的音量，另外切换时图标也根据静音状态正确切换
 */
- (IBAction)setMute:(id)sender {
    float currentVolume = [_musicController getSystemVolume];
    if (currentVolume > 0.0) {
        volume = currentVolume;
        [self.btnVolume setImage:[UIImage imageNamed:@"静音.png"] forState:UIControlStateNormal];
        [_musicController setSystemVolume:0.0];
    } else {
        [self.btnVolume setImage:[UIImage imageNamed:@"声音.png"] forState:UIControlStateNormal];
        [_musicController setSystemVolume:volume];
    }
}

/*!
 * @brief 音量设置
 * @discussion 拖动进度条改变系统音量
 */
- (IBAction)changeVolume:(id)sender {
    [_musicController setSystemVolume:[self.volumeSlider value]];
}

/*!
 * @brief 音量进度条更新
 * @discussion 调节系统音量时，音量进度条也要同步更新
 */
-(void)updateVolumeSlider:(float)volume {
    [self.volumeSlider setValue:volume];
}

/*!
 * @brief 歌曲进度条更新
 * @discussion 定时器每间隔一秒调用一次，更新进度条和当前时间label
 */
-(void)updateProgressTime {
    [self.lblTimeInfo setText:[NSString stringWithFormat:@"%@/%@", [_musicController getCurrentTimeStr], [_musicController getTotalTimeStr]]];
    [self.timeSlider setMaximumValue:[_musicController getTotalTimeVal]];
    [self.timeSlider setValue:[_musicController getCurrentTimeVal]];
}

/*!
 * @brief 切换循环模式
 * @discussion 切换循环模式
 */
- (IBAction)changeRepeatMode:(id)sender {
    repeatMode = (repeatMode + 1) % 3;
    [_musicController setRepeatMode:repeatMode];
    switch (repeatMode) {
        case 0:
            [self.btnRepeatMode setImage:[UIImage imageNamed:@"列表循环.png"] forState:UIControlStateNormal];
            break;
        case 1:
            [self.btnRepeatMode setImage:[UIImage imageNamed:@"随机.png"] forState:UIControlStateNormal];
            break;
        case 2:
            [self.btnRepeatMode setImage:[UIImage imageNamed:@"单曲循环.png"] forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}
- (IBAction)showPlayingList:(id)sender {
    
    
    PopupPlayingListViewController *popupPlayingList = [[PopupPlayingListViewController alloc] init];
    if ([self.delegate respondsToSelector:@selector(presentViewController:fromView:)]) {
        [self.delegate presentViewController:popupPlayingList fromView:self.btnShowPlayingList];
    }
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
