//
//  MusicControl.h
//  MyMusic
//
//  Created by 孔令文 on 2017/3/25.
//  Copyright © 2017年 孔令文. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "MusicToolView.h"

@interface MusicControl : NSObject

@property (nonatomic, strong) MusicToolView *musicToolView;

+(instancetype)sharedInstance;
-(MPMusicPlayerController *)getMusicPlayerController;
-(void)addMusicTimer;
-(void)removeMusicTimer;
-(void)setSongs:(NSMutableArray *)songs;
-(void)play;
-(void)play:(long) index;
-(void)pause;
-(void)next;
-(void)previous;
-(NSString *)musicTimeFormat:(double) time;
-(double)getTotalTimeVal;
-(NSString *)getTotalTimeStr;
-(double)getCurrentTimeVal;
-(NSString *)getCurrentTimeStr;
-(void)setCurrentTime:(float) currentTime;
-(MPMusicPlaybackState)getMusicPlayState;
-(float)getSystemVolume;
-(void)setSystemVolume:(float)volume;
-(void)setRepeatMode:(int) repeatMode;
-(long)getIndexOfNowPlayingItem;
-(void)deleteItem:(long)index;
@end
