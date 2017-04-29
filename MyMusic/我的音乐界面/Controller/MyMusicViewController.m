//
//  MyMusicView.m
//  MyMusic
//
//  Created by 孔令文 on 2017/4/10.
//  Copyright © 2017年 孔令文. All rights reserved.
//

#import "MyMusicViewController.h"
#import "ModelDataController.h"
#import "MyMusicTableViewCell.h"
#import "MusicUtils.h"
#import "MusicControl.h"
#import "CreateMyMusicListViewController.h"

@interface MyMusicViewController () <UITableViewDelegate, UITableViewDataSource, PresentViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UITableView *masterTableView;
@property (strong, nonatomic) IBOutlet UITableView *detailTableView;

@end

@implementation MyMusicViewController

{

    ModelDataController *modelDataController;
    MusicControl *musicController;

    int masterTableViewSelectedSection;
    int masterTableViewSelectedIndex;
    
    Boolean selectedListDidChanged;
    
    enum {
        ALL_SONGS = 0,
        DOWNLOAD_SONGS,
        RECENTLY_PLAYED_SONGS,
        LIKED_SONGS
    } ListType;

}

#pragma mark ---- 单例模式生成实例

//static id _instance = nil;
//
///*!
// * @brief 获取单例播放器类
// 
// * @return 播放器实例
// */
//+(instancetype)sharedInstance {
//    if (_instance == nil) {
//        _instance = [[self alloc] init];
//    }
//    return _instance;
//}
//
//+(instancetype)allocWithZone:(struct _NSZone *)zone {
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        _instance = [super allocWithZone:zone];
//    });
//    return _instance;
//}
//
//-(instancetype)init {
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        _instance = [super init];
//        
//    });
//    return _instance;
//}
//
//-(id)copy {
//    return _instance;
//}
//
//-(id)mutableCopy {
//    return _instance;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    modelDataController = [ModelDataController sharedInstance];
    musicController = [MusicControl sharedInstance];
    
    self.masterTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.masterTableView.bounds.size.width, 0.01f)];
    self.masterTableView.delegate = self;
    self.masterTableView.dataSource = self;
    self.detailTableView.delegate = self;
    self.detailTableView.dataSource = self;
    
    [self.masterTableView selectRowAtIndexPath:0 animated:YES scrollPosition:UITableViewScrollPositionTop];
    //[self.detailTableView reloadData];
    [self.detailTableView registerNib:[UINib nibWithNibName:@"MyMusicTableViewCell" bundle:nil] forCellReuseIdentifier:@"songItem"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didMyMusicListChanged:) name:@"didMyMusicListChanged" object:nil];
}

-(void)didMyMusicListChanged:(NSNotification *)noti {
    [self.masterTableView reloadData];
}

-(void)presentViewController:(UIViewController *)viewController fromView:(UIView *)sourceView {
    viewController.modalPresentationStyle = UIModalPresentationPopover;
    UIPopoverPresentationController *presentationController = [viewController popoverPresentationController];
    presentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    presentationController.sourceView = sourceView;
    presentationController.sourceRect = sourceView.bounds;
    [self presentViewController:viewController animated:YES completion:nil];
}

#pragma mark -- dataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.masterTableView) {
        return 2;
    } else {
        return 1;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.masterTableView) {
        if (section == 0) {
            return 4;
        } else {
            long num = [modelDataController getMyMuiscListNum] + 2;
            return num;
        }
    } else {
        if (masterTableViewSelectedSection == 0) {
            switch (masterTableViewSelectedIndex) {
                case ALL_SONGS:
                    return [modelDataController getAllSongsCount];
                case DOWNLOAD_SONGS:
                    return [modelDataController getDownloadSongsCount];
                case RECENTLY_PLAYED_SONGS:
                    return [modelDataController getRecentlyPlayedSongsCount];
                case LIKED_SONGS:
                    return [modelDataController getLikedSongsCount];
                default:
                    return 0;
            }
        } else {
            if (masterTableViewSelectedIndex == 0) {
                return [modelDataController getMyMuiscListNum];
            } else if (masterTableViewSelectedIndex <= [modelDataController getMyMuiscListNum]) {
                return [modelDataController getMyMusicListItemCount:masterTableViewSelectedIndex - 1];
            } else {
                return 0;
            }
        }
    }
    
}

-(UITableViewCell *)getCellOfMasterTableViewWithIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case ALL_SONGS:
                [cell.textLabel setText:@"全部歌曲"];
                [cell.detailTextLabel setText:@"20首"];
                [cell.imageView setImage:[UIImage imageNamed:@"全部歌曲.png"]];
                break;
            case DOWNLOAD_SONGS:
                [cell.textLabel setText:@"下载歌曲"];
                [cell.detailTextLabel setText:@"20首"];
                [cell.imageView setImage:[UIImage imageNamed:@"下载歌曲.png"]];
                break;
            case RECENTLY_PLAYED_SONGS:
                [cell.textLabel setText:@"最近播放"];
                [cell.detailTextLabel setText:@"20首"];
                [cell.imageView setImage:[UIImage imageNamed:@"最近播放.png"]];
                break;
            case LIKED_SONGS:
                [cell.textLabel setText:@"我喜欢"];
                [cell.detailTextLabel setText:@"20首"];
                [cell.imageView setImage:[UIImage imageNamed:@"我喜欢.png"]];
                break;
                
            default:
                break;
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [cell.textLabel setText:@"我的歌单"];
            [cell.textLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
            [cell addConstraint:[NSLayoutConstraint constraintWithItem:cell.textLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
            [cell addConstraint:[NSLayoutConstraint constraintWithItem:cell.textLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
        } else if (indexPath.row == ([modelDataController getMyMuiscListNum] + 1)) {
            [cell.textLabel setText:@"添加歌单"];
        } else {
            [cell.textLabel setText:[modelDataController getMyMusicListName:indexPath.row - 1]];
        }
    }
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    return cell;
}

-(UITableViewCell *)getCellOfDetailTableViewWithIndexPath:(NSIndexPath *)indexPath {
    if (masterTableViewSelectedSection == 0) {
        MyMusicTableViewCell *cell = [self.detailTableView dequeueReusableCellWithIdentifier:@"songItem" forIndexPath:indexPath];
        cell.delegate = self;
        switch (masterTableViewSelectedIndex) {
            case ALL_SONGS:
                cell.lblSongName.text = [modelDataController getTitleOfAllSongsAtIndex:indexPath.row];
                cell.lblArtistName.text = [modelDataController getArtistOfAllSongsAtIndex:indexPath.row];
                break;
            case DOWNLOAD_SONGS:
                cell.lblSongName.text = [modelDataController getTitleOfDownloadSongsAtIndex:indexPath.row];
                cell.lblArtistName.text = [modelDataController getArtistOfDownloadSongsAtIndex:indexPath.row];
                break;
            case RECENTLY_PLAYED_SONGS:
                cell.lblSongName.text = [modelDataController getTitleOfRecentlyPlayedSongsAtIndex:indexPath.row];
                cell.lblArtistName.text = [modelDataController getArtistOfRecentlyPlayedSongsAtIndex:indexPath.row];
                break;
            case LIKED_SONGS:
                cell.lblSongName.text = [modelDataController getTitleOfLikedSongsAtIndex:indexPath.row];
                cell.lblArtistName.text = [modelDataController getArtistOfLikedSongsAtIndex:indexPath.row];
                break;
            default:
                break;
        }
        CGSize songNameSize = [MusicUtils calSize:cell.lblSongName.text WithFont:[UIFont systemFontOfSize:17.0]];
        CGSize artistNameSize = [MusicUtils calSize:cell.lblArtistName.text WithFont:[UIFont systemFontOfSize:12.0]];
        
        [cell.lblSongName setFrame:CGRectMake(cell.lblSongName.frame.origin.x, cell.lblSongName.frame.origin.y, songNameSize.width, songNameSize.height)];
        [cell.lblArtistName setFrame:CGRectMake(cell.lblArtistName.frame.origin.x, cell.lblArtistName.frame.origin.y, artistNameSize.width, artistNameSize.height)];
        
        // 当前播放歌曲和其他歌曲显示颜色设置
        if (indexPath.row == [musicController getIndexOfNowPlayingItem]) {
            [cell.lblSongName setTextColor:[UIColor cyanColor]];
            [cell.lblArtistName setTextColor:[UIColor cyanColor]];
        } else {
            [cell.lblSongName setTextColor:[UIColor blackColor]];
            [cell.lblArtistName setTextColor:[UIColor blackColor]];
        }
        
        return cell;
    } else {
        
        if (masterTableViewSelectedIndex == 0) {
            UITableViewCell *cell = [[UITableViewCell alloc] init];
            [cell.textLabel setText:[modelDataController getMyMusicListName:indexPath.row]];
            return cell;
        } else if (masterTableViewSelectedIndex <= [modelDataController getMyMuiscListNum]) {
            MyMusicTableViewCell *cell = [self.detailTableView dequeueReusableCellWithIdentifier:@"songItem" forIndexPath:indexPath];
            cell.delegate = self;
            cell.lblSongName.text = [[[modelDataController getMyMusicList:masterTableViewSelectedIndex - 1] objectAtIndex:indexPath.row] title];
            cell.lblArtistName.text = [[[modelDataController getMyMusicList:masterTableViewSelectedIndex - 1] objectAtIndex:indexPath.row] artist];
            CGSize songNameSize = [MusicUtils calSize:cell.lblSongName.text WithFont:[UIFont systemFontOfSize:17.0]];
            CGSize artistNameSize = [MusicUtils calSize:cell.lblArtistName.text WithFont:[UIFont systemFontOfSize:12.0]];
            
            [cell.lblSongName setFrame:CGRectMake(cell.lblSongName.frame.origin.x, cell.lblSongName.frame.origin.y, songNameSize.width, songNameSize.height)];
            [cell.lblArtistName setFrame:CGRectMake(cell.lblArtistName.frame.origin.x, cell.lblArtistName.frame.origin.y, artistNameSize.width, artistNameSize.height)];
            
            // 当前播放歌曲和其他歌曲显示颜色设置
            if (indexPath.row == [musicController getIndexOfNowPlayingItem]) {
                [cell.lblSongName setTextColor:[UIColor cyanColor]];
                [cell.lblArtistName setTextColor:[UIColor cyanColor]];
            } else {
                [cell.lblSongName setTextColor:[UIColor blackColor]];
                [cell.lblArtistName setTextColor:[UIColor blackColor]];
            }
            
            return cell;
        } else {
            return nil;
        }
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (tableView == self.masterTableView) {
        cell = [self getCellOfMasterTableViewWithIndexPath:indexPath];
    } else {
        cell = [self getCellOfDetailTableViewWithIndexPath:indexPath];
    }
    return cell;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.masterTableView) {
        if (indexPath.section == 0) {
            return 50;
        } else {
            return 60;
        }
    } else {
        return 55;
    }
}

#pragma mark -- delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.masterTableView) {
        
        masterTableViewSelectedSection = indexPath.section;
        masterTableViewSelectedIndex = indexPath.row;
        
        if (indexPath.section == 0) {
            [self.detailTableView reloadData];
        } else {
            if (indexPath.row == ([modelDataController getMyMuiscListNum] + 1)) {
                CreateMyMusicListViewController *createMyMusicListViewController = [[CreateMyMusicListViewController alloc] init];
                createMyMusicListViewController.modalPresentationStyle = UIModalPresentationFormSheet;
                
                [self presentViewController:createMyMusicListViewController animated:YES completion:nil];
            } else {
                [self.detailTableView reloadData];
            }
        }
        
        
    } else {
        
        [tableView reloadData];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        NSMutableArray *songs;
        switch (masterTableViewSelectedIndex) {
            case ALL_SONGS:
                songs = [modelDataController getAllSongs];
                break;
            case DOWNLOAD_SONGS:
                songs = [modelDataController getDownloadSongs];
                break;
            case RECENTLY_PLAYED_SONGS:
                songs = [modelDataController getRecentlyPlayedSongs];
                break;
            case LIKED_SONGS:
                songs = [modelDataController getLikedSongs];
                break;
            default:
                songs = [modelDataController getAllSongs];
                break;
        }
        
        [musicController setSongs:songs];
        [musicController play:indexPath.row];
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
