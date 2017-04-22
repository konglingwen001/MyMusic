//
//  ModelDataController.h
//  MyMusic
//
//  Created by 孔令文 on 2017/4/13.
//  Copyright © 2017年 孔令文. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ModelDataController : NSObject

+(instancetype)sharedInstance;

-(long)getAllSongsCount;
-(NSMutableArray *)getAllSongs;
-(long)getLikedSongsCount;
-(NSMutableArray *)getLikedSongs;
-(long)getRecentlyPlayedSongsCount;
-(NSMutableArray *)getRecentlyPlayedSongs;
-(long)getDownloadSongsCount;
-(NSMutableArray *)getDownloadSongs;
-(long)getNowPlayingSongsCount;
-(NSMutableArray *)getNowPlayingSongs;
-(NSMutableArray *)getNowPlayingSongsWithPersistentID;
-(void)setNowPlayingSongs:(NSArray *)songs;
-(void)setNowPlayingSongsWithPersistentID:(NSArray *)songsID;
-(void)deleteFromNowPlayingSongsAtIndex:(long)index;

-(int)getTabBarSelectedIndex;
-(void)setTabBarSelectedIndex:(int)selectedIndex;

-(NSString *)getTitleOfAllSongsAtIndex:(long)index;
-(NSString *)getArtistOfAllSongsAtIndex:(long)index;
-(NSString *)getTitleOfLikedSongsAtIndex:(long)index;
-(NSString *)getArtistOfLikedSongsAtIndex:(long)index;
-(NSString *)getTitleOfRecentlyPlayedSongsAtIndex:(long)index;
-(NSString *)getArtistOfRecentlyPlayedSongsAtIndex:(long)index;
-(NSString *)getTitleOfDownloadSongsAtIndex:(long)index;
-(NSString *)getArtistOfDownloadSongsAtIndex:(long)index;
-(NSString *)getTitleOfNowPlayingSongsAtIndex:(long)index;
-(NSString *)getArtistOfNowPlayingSongsAtIndex:(long)index;

-(void)addMyMusicList:(NSString *)listName;
-(int)getMyMuiscListNum;
-(long)getMyMusicListItemCount:(long) index;
-(NSArray *)getMyMusicList:(long) index;
-(NSString *)getMyMusicListName:(long) index;

@end
