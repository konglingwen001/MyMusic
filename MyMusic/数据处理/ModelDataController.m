//
//  ModelDataController.m
//  MyMusic
//
//  Created by 孔令文 on 2017/4/13.
//  Copyright © 2017年 孔令文. All rights reserved.
//

#import "ModelDataController.h"
#import <MediaPlayer/MediaPlayer.h>

@implementation ModelDataController

{
    enum {
        ALL_SONGS = 0,
        LIKED_SONGS,
        RECENTLY_PLAYED_SONGS,
        DOWNLOAD_SONGS,
        NOW_PLAYING_SONGS
    } MusicListType;

    NSMutableArray *allSongs;
    NSMutableArray *likedSongs;
    NSMutableArray *recentlyPlayedSongs;
    NSMutableArray *downloadSongs;
    NSMutableArray *nowPlayingSongs;

    int myMusicListNum;
    NSMutableDictionary *myMusicList;
    
    int tabBarSelectedIndex;
}

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
        
        allSongs = [[[MPMediaQuery songsQuery] items] mutableCopy];
        likedSongs = [[[NSUserDefaults standardUserDefaults] valueForKey:@"likedSongs"] mutableCopy];
        recentlyPlayedSongs = [[[NSUserDefaults standardUserDefaults] valueForKey:@"recentlyPlayedSongs"] mutableCopy];
        downloadSongs = [[[NSUserDefaults standardUserDefaults] valueForKey:@"downloadSongs"] mutableCopy];
        [self setNowPlayingSongsWithPersistentID:[[[NSUserDefaults standardUserDefaults] valueForKey:@"nowPlayingSongs"] mutableCopy]];
        myMusicListNum = [[[NSUserDefaults standardUserDefaults] valueForKey:@"myMusicListNum"] intValue];
        myMusicList = [[[NSUserDefaults standardUserDefaults] valueForKey:@"myMusicList"] mutableCopy];
        
        tabBarSelectedIndex = [[[NSUserDefaults standardUserDefaults] valueForKey:@"tabBarSelectedIndex"] intValue];
        
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
 * @brief 获取全部歌曲数
 * @discussion 获取全部歌曲数
 */
-(long)getAllSongsCount {
    return allSongs.count;
}

/*!
 * @brief 获取全部歌曲实例
 * @discussion 获取全部歌曲实例
 */
-(NSMutableArray *)getAllSongs {
    return allSongs;
}

/*!
 * @brief 获取喜欢歌曲数
 * @discussion 获取喜欢歌曲数
 */
-(long)getLikedSongsCount {
    return likedSongs.count;
}

/*!
 * @brief 获取喜欢歌曲实例
 * @discussion 获取喜欢歌曲实例
 */
-(NSMutableArray *)getLikedSongs {
    return likedSongs;
}


/*!
 * @brief 获取最近播放歌曲数
 * @discussion 获取最近播放歌曲数
 */
-(long)getRecentlyPlayedSongsCount {
    return recentlyPlayedSongs.count;
}

/*!
 * @brief 获取最近播放歌曲实例
 * @discussion 获取最近播放歌曲实例
 */
-(NSMutableArray *)getRecentlyPlayedSongs {
    return recentlyPlayedSongs;
}

/*!
 * @brief 获取下载歌曲数
 * @discussion 获取下载歌曲数
 */
-(long)getDownloadSongsCount {
    return downloadSongs.count;
}

/*!
 * @brief 获取下载歌曲实例
 * @discussion 获取下载歌曲实例
 */
-(NSMutableArray *)getDownloadSongs {
    return downloadSongs;
}

/*!
 * @brief 获取播放列表歌曲数
 * @discussion 获取播放列表歌曲数
 */
-(long)getNowPlayingSongsCount {
    return nowPlayingSongs.count;
}

/*!
 * @brief 获取播放列表歌曲实例
 * @discussion 获取播放列表歌曲实例
 */
-(NSMutableArray *)getNowPlayingSongs {
    return nowPlayingSongs;
}

/*!
 * @brief 设定播放列表
 * @discussion 将songs设定为播放列表歌曲
 */
-(void)setNowPlayingSongs:(NSArray *)songs {
    if (nowPlayingSongs == nil) {
        nowPlayingSongs = [[NSMutableArray alloc] init];
    } else {
        if (nowPlayingSongs.count > 0) {
            if (nowPlayingSongs.count == songs.count) {
                
                // 判断选择列表有没有改变
                if ([self isEqualToSongs:songs]) {
                    // 没有改变，直接返回，不重新设置播放queue
                    return;
                } else {
                    // 改变了，清空nowPlayingSongs，并重新设置播放queue
                    [nowPlayingSongs removeAllObjects];
                }
            } else {
                [nowPlayingSongs removeAllObjects];
            }
            
            
        }
    }

    for (MPMediaItem *item in songs) {
        [nowPlayingSongs addObject:item];
    }
    [[MPMusicPlayerController applicationMusicPlayer] setQueueWithItemCollection:[MPMediaItemCollection collectionWithItems:nowPlayingSongs]];
}

-(Boolean)isEqualToSongs:(NSArray *)songs {
    Boolean flag = YES;
    for (int i = 0; i < nowPlayingSongs.count; i++) {
        MPMediaItem *item1 = [nowPlayingSongs objectAtIndex:i];
        MPMediaItem *item2 = [songs objectAtIndex:i];
        if ([item1 persistentID] != [item2 persistentID]) {
            flag = NO;
            break;
        }
    }
    return flag;
}

/*!
 * @brief 通过persistentID获取歌曲实例
 * @discussion 通过persistentID获取歌曲实例
 */
-(NSMutableArray *)getNowPlayingSongsWithPersistentID {
    NSMutableArray *songsID = [[NSMutableArray alloc] init];
    for (MPMediaItem *item in nowPlayingSongs) {
        [songsID addObject:@([item persistentID])];
    }
    return songsID;
}

/*!
 * @brief 通过persistentID设定播放列表歌曲
 * @discussion 通过persistentID设定播放列表歌曲
 */
-(void)setNowPlayingSongsWithPersistentID:(NSMutableArray *)songsID {
    if (nowPlayingSongs == nil) {
        nowPlayingSongs = [[NSMutableArray alloc] init];
    } else {
        if (nowPlayingSongs.count > 0) {
            [nowPlayingSongs removeAllObjects];
        }
    }
    
    for (id persistentID in songsID) {
        for (MPMediaItem *item in allSongs) {
            if ([persistentID isEqual:@([item persistentID])]) {
                [nowPlayingSongs addObject:item];
                break;
            };
        }
    }
}

/*!
 * @brief 获取主菜单选择状态
 * @discussion 获取主菜单选择状态
 */
-(int)getTabBarSelectedIndex {
    return tabBarSelectedIndex;
}

/*!
 * @brief 设定主菜单选择状态
 * @discussion 设定主菜单选择状态
 */
-(void)setTabBarSelectedIndex:(int)selectedIndex {
    tabBarSelectedIndex = selectedIndex;
}

/*!
 * @brief 从播放列表中删除指定歌曲
 * @discussion 从播放列表中删除指定歌曲
 */
-(void)deleteFromNowPlayingSongsAtIndex:(long)index {
    [nowPlayingSongs removeObjectAtIndex:index];
    [[MPMusicPlayerController applicationMusicPlayer] setQueueWithItemCollection:[MPMediaItemCollection collectionWithItems:nowPlayingSongs]];
}

/*!
 * @brief 从全部歌曲中获取指定歌曲名
 * @discussion 从全部歌曲中获取指定歌曲名
 */
-(NSString *)getTitleOfAllSongsAtIndex:(long)index {
    return [[allSongs objectAtIndex:index] title];
}

/*!
 * @brief 从全部歌曲中获取指定歌曲歌手名
 * @discussion 从全部歌曲中获取指定歌曲歌手名
 */
-(NSString *)getArtistOfAllSongsAtIndex:(long)index {
    return [[allSongs objectAtIndex:index] artist];
}

/*!
 * @brief 从喜欢歌曲中获取指定歌曲名
 * @discussion 从喜欢歌曲中获取指定歌曲名
 */
-(NSString *)getTitleOfLikedSongsAtIndex:(long)index {
    return [[likedSongs objectAtIndex:index] title];
}

/*!
 * @brief 从喜欢歌曲中获取指定歌曲歌手名
 * @discussion 从喜欢歌曲中获取指定歌曲歌手名
 */
-(NSString *)getArtistOfLikedSongsAtIndex:(long)index {
    return [[likedSongs objectAtIndex:index] artist];
}

/*!
 * @brief 从播放历史歌曲中获取指定歌曲名
 * @discussion 从播放历史歌曲中获取指定歌曲名
 */
-(NSString *)getTitleOfRecentlyPlayedSongsAtIndex:(long)index {
    return [[recentlyPlayedSongs objectAtIndex:index] title];
}

/*!
 * @brief 从播放历史歌曲中获取指定歌曲歌手名
 * @discussion 从播放历史歌曲中获取指定歌曲歌手名
 */
-(NSString *)getArtistOfRecentlyPlayedSongsAtIndex:(long)index {
    return [[recentlyPlayedSongs objectAtIndex:index] artist];
}

/*!
 * @brief 从下载歌曲中获取指定歌曲名
 * @discussion 从下载歌曲中获取指定歌曲名
 */
-(NSString *)getTitleOfDownloadSongsAtIndex:(long)index {
    return [[downloadSongs objectAtIndex:index] title];
}

/*!
 * @brief 从下载歌曲中获取指定歌曲歌手名
 * @discussion 从下载歌曲中获取指定歌曲歌手名
 */
-(NSString *)getArtistOfDownloadSongsAtIndex:(long)index {
    return [[downloadSongs objectAtIndex:index] artist];
}

/*!
 * @brief 从播放列表中获取指定歌曲名
 * @discussion 从播放列表中获取指定歌曲名
 */
-(NSString *)getTitleOfNowPlayingSongsAtIndex:(long)index {
    return [[nowPlayingSongs objectAtIndex:index] title];
}

/*!
 * @brief 从播放列表中获取指定歌曲歌手名
 * @discussion 从播放列表中获取指定歌曲歌手名
 */
-(NSString *)getArtistOfNowPlayingSongsAtIndex:(long)index {
    return [[nowPlayingSongs objectAtIndex:index] artist];
}

/*!
 * @brief 添加名为listName的自建歌单
 * @discussion 添加名为listName的自建歌单
 */
-(void)addMyMusicList:(NSString *)listName {
    [myMusicList setValue:[[NSMutableArray alloc] init] forKey:listName];
}

/*!
 * @brief 获取自建歌单数
 * @discussion 获取自建歌单数
 */
-(int)getMyMuiscListNum {
    return [[myMusicList allKeys] count];
}

/*!
 * @brief 获取指定自建歌单名
 * @discussion 获取指定自建歌单名
 */
-(NSString *)getMyMusicListName:(long)index {
    return [[myMusicList allKeys] objectAtIndex:index];
}

/*!
 * @brief 获取指定歌单中歌曲数
 * @discussion 获取指定歌单中歌曲数
 */
-(long)getMyMusicListItemCount:(long)index {
    return [[[myMusicList allValues] objectAtIndex:index] count];
}

/*!
 * @brief 获取指定歌单实例
 * @discussion 获取指定歌单实例
 */
-(NSArray *)getMyMusicList:(long)index {
    return [[myMusicList allValues] objectAtIndex:index];
}

@end
