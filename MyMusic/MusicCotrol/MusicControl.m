//
//  MusicControl.m
//  MyMusic
//
//  Created by 孔令文 on 2017/3/25.
//  Copyright © 2017年 孔令文. All rights reserved.
//

#import "MusicControl.h"
#import "ModelDataController.h"


@interface MusicControl ()

/*! @brief 播放器实例 */
@property (nonatomic, strong) MPMusicPlayerController *musicController;

/*! @brief 播放列表实例 */
@property (nonatomic, strong) ModelDataController *modelDataController;

/*! @brief 计时器 */
@property (nonatomic, strong) NSTimer *musicTimer;

@end

@implementation MusicControl

int flag = 0;

#pragma mark ---- 单例模式生成实例

static id _instance = nil;

/*!
 * @brief 获取单例播放器类
 
 * @return 播放器实例
 */
+(instancetype)sharedInstance {
    if (_instance == nil) {
        _instance = [[self alloc] init];
    }
    return _instance;
}

+(instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

-(instancetype)init {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super init];
        [_instance setMusicController:[MPMusicPlayerController applicationMusicPlayer]];
        [_instance setModelDataController:[ModelDataController sharedInstance]];
        _musicTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateProgress:) userInfo:nil repeats:YES];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playStateDidChanged:) name:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:nil];
        
    });
    return _instance;
}

-(id)copy {
    return _instance;
}

-(id)mutableCopy {
    return _instance;
}

/*!
 * @brief 销毁实例
 * @discussion 销毁实例，去除通知
 */
-(void)dealloc {
    [self removeObserver:self forKeyPath:MPMusicPlayerControllerPlaybackStateDidChangeNotification];
}

/*!
 * @brief 播放状态改变
 * @discussion 播放状态改变，当播放状态为正在播放时，添加计时器，用于更新播放时间和播放进度条
 */
-(void)playStateDidChanged:(NSNotification *)noti {
    switch ([_musicController playbackState]) {
        case MPMusicPlaybackStatePlaying:
            [self addMusicTimer];
            break;
            
        default:
            break;
    }
}

-(MPMusicPlayerController *)getMusicPlayerController {
    return _musicController;
}

/*!
 * @brief 添加计时器
 * @discussion 添加计时器
 */
-(void)addMusicTimer {
    if (_musicTimer == nil) {
        _musicTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateProgress:) userInfo:nil repeats:YES];
    }
}

/*!
 * @brief 删除计时器
 * @discussion 删除计时器
 */
-(void)removeMusicTimer {
    if (_musicTimer != nil) {
        [_musicTimer invalidate];
        _musicTimer = nil;
    }
}

/*!
 * @brief 更新播放进度
 * @discussion 更新播放进度，包括进度条和时间Label
 */
-(void)updateProgress:(id) sender {
    [_musicToolView updateProgressTime];
}

/*!
 * @brief 设定当前播放列表
 * @discussion 设定当前播放列表
 */
-(void)setSongs:(NSMutableArray *)newSongs {
    //songs = newSongs;
    [_modelDataController setNowPlayingSongs:newSongs];
    
}

/*!
 * @brief 播放歌曲
 * @discussion 播放歌曲
 */
-(void)play {
    [_musicController play];
}

/*!
 * @brief 播放指定歌曲
 * @discussion 播放指定歌曲
 */
-(void)play:(long)index {
    MPMediaItem *item = [[_modelDataController getNowPlayingSongs] objectAtIndex:index];
    NSLog(@"%@", [item title]);
    [_musicController setNowPlayingItem:item];
    [_musicController play];
}

/*!
 * @brief 暂停
 * @discussion 暂停
 */
-(void)pause {
    [_musicController pause];
}

/*!
 * @brief 下一曲
 * @discussion 下一曲
 */
-(void)next {
    [_musicController skipToNextItem];
    [_musicController play];
}

/*!
 * @brief 上一曲
 * @discussion 上一曲
 */
-(void)previous {
    [_musicController skipToPreviousItem];
    [_musicController play];
}

/*!
 * @brief 时间格式转换
 * @discussion 将double类型的时间(second)转换为MM:SS的格式
 */
-(NSString *)musicTimeFormat:(double) time {
    int minutes = time / 60;
    int seconds = (int)(time) % 60;
    NSString *minutesStr;
    NSString *secondsStr;
    if (minutes / 10 > 0) {
        minutesStr = [NSString stringWithFormat:@"%d", minutes];
    } else {
        minutesStr = [NSString stringWithFormat:@"0%d", minutes];
    }
    
    if (seconds / 10 > 0) {
        secondsStr = [NSString stringWithFormat:@"%d", seconds];
    } else {
        secondsStr = [NSString stringWithFormat:@"0%d", seconds];
    }
    return [NSString stringWithFormat:@"%@:%@", minutesStr, secondsStr];
}

/*!
 * @brief 获取当前播放歌曲总时间
 * @discussion 以double类型获取当前播放歌曲总时间
 */
-(double)getTotalTimeVal {
    return [[_musicController nowPlayingItem] playbackDuration];
}

/*!
 * @brief 获取当前播放歌曲总时间
 * @discussion 以MM:SS格式获取当前播放歌曲总时间
 */
-(NSString *)getTotalTimeStr {
    NSTimeInterval totalTime = [[_musicController nowPlayingItem] playbackDuration];
    return [self musicTimeFormat:totalTime];
}

/*!
 * @brief 获取当前播放歌曲的播放进度时间
 * @discussion 以double类型获取当前播放歌曲的播放进度时间
 */
-(double)getCurrentTimeVal {
    return [_musicController currentPlaybackTime];
}

/*!
 * @brief 获取当前播放歌曲的播放进度时间
 * @discussion 以MM:SS格式获取当前播放歌曲的播放进度时间
 */
-(NSString *)getCurrentTimeStr {
    NSTimeInterval currentTime = [_musicController currentPlaybackTime];
    return [self musicTimeFormat:currentTime];
}

/*!
 * @brief 更改播放进度
 * @discussion 更改播放进度
 */
-(void)setCurrentTime:(float)currentTime {
    [_musicController setCurrentPlaybackTime:currentTime];
}

/*!
 * @brief 获取播放状态
 * @discussion 获取播放状态
 */
-(MPMusicPlaybackState)getMusicPlayState {
    return [_musicController playbackState];
}

/*!
 * @brief 获取系统音量控制器
 * @discussion 获取系统音量控制器
 */
-(UISlider *)getSystemVolumeSlider {
    static UISlider *volumeSlider = nil;
    if (volumeSlider == nil) {
        MPVolumeView *volumeView = [[MPVolumeView alloc] init];
        for (UIView *subView in volumeView.subviews) {
            if ([[subView.class description] isEqualToString:@"MPVolumeSlider"]) {
                volumeSlider = (UISlider *)subView;
                break;
            }
        }
    }
    return volumeSlider;
}

/*!
 * @brief 获取系统当前音量
 * @discussion 获取系统当前音量
 */
-(float)getSystemVolume {
    return [self getSystemVolumeSlider].value;
}

/*!
 * @brief 设定系统音量
 * @discussion 设定系统音量
 */
-(void)setSystemVolume:(float)volume {
    [[self getSystemVolumeSlider] setValue:volume];
}

/*!
 * @brief 设定循环模式
 * @discussion 设定循环模式
 */
-(void)setRepeatMode:(int) repeatMode {
    if (repeatMode == 1) {
        // 随机模式
        [_musicController setShuffleMode:MPMusicShuffleModeSongs];
    } else if (repeatMode == 0) {
        // 全部循环
        [_musicController setShuffleMode:MPMusicShuffleModeOff];
        [_musicController setRepeatMode:MPMusicRepeatModeAll];
    } else if (repeatMode == 2) {
        
        // 单曲循环
        [_musicController setShuffleMode:MPMusicShuffleModeOff];
        [_musicController setRepeatMode:MPMusicRepeatModeOne];
    }
    
}

-(long)getIndexOfNowPlayingItem {
    MPMediaItem *nowPlayingItem = [_musicController nowPlayingItem];
    int index = 0;
    for (MPMediaItem *item in [_modelDataController getNowPlayingSongs]) {
        if (nowPlayingItem == item) {
            break;
        }
        index++;
    }
    if (index == [_modelDataController getNowPlayingSongsCount]) {
        index = -1;
    }
    return index;
    
}

-(void)deleteItem:(long)index {
    if (index == [self getIndexOfNowPlayingItem]) {
        [_musicController pause];
    }
    
    [_modelDataController deleteFromNowPlayingSongsAtIndex:index];
    [_musicController setQueueWithItemCollection:[MPMediaItemCollection collectionWithItems:[_modelDataController getNowPlayingSongs]]];
}

@end
