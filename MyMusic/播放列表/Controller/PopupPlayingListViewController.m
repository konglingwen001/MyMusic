//
//  PopupPlayingListViewController.m
//  MyMusic
//
//  Created by 孔令文 on 2017/3/28.
//  Copyright © 2017年 孔令文. All rights reserved.
//

#import "PopupPlayingListViewController.h"
#import "MusicControl.h"
#import "PlayListTableViewCell.h"
#import "MusicUtils.h"
#import "ModelDataController.h"

@interface PopupPlayingListViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UILabel *lblPlayListTitle;
@property (strong, nonatomic) IBOutlet UITableView *playListTable;
@property (strong, nonatomic) IBOutlet UIButton *btnClose;

@end

@implementation PopupPlayingListViewController
{
    MusicControl *musicController;
    ModelDataController *modelDataController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    musicController = [MusicControl sharedInstance];
    modelDataController = [ModelDataController sharedInstance];
    
    self.playListTable.delegate = self;
    self.playListTable.dataSource = self;
    
    [self.playListTable registerNib:[UINib nibWithNibName:@"PlayListTableViewCell" bundle:nil] forCellReuseIdentifier:@"playListItem"];
    
    //[self.lblPlayListTitle setText:[NSString stringWithFormat:@"播放列表(%d)", [modelDataController getNowPlayingSongsCount]]];
    
    MPMusicPlayerController *musicPlayer = [musicController getMusicPlayerController];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nowPlayingItemDidChanged:) name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:musicPlayer];
    [musicPlayer beginGeneratingPlaybackNotifications];
    
}

-(void)nowPlayingItemDidChanged:(NSNotification *)noti {
    [self.playListTable reloadData];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)playListClose:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [modelDataController getNowPlayingSongsCount];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PlayListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"playListItem" forIndexPath:indexPath];

    cell.lblMusicName.text = [modelDataController getTitleOfNowPlayingSongsAtIndex:indexPath.row];
    cell.lblArtistName.text = [modelDataController getArtistOfNowPlayingSongsAtIndex:indexPath.row];
    
    // 根据字符串长度调整Label尺寸
    CGSize songNameSize = [MusicUtils calSize:cell.lblMusicName.text WithFont:[UIFont systemFontOfSize:17.0]];
    CGSize artistNameSize = [MusicUtils calSize:cell.lblArtistName.text WithFont:[UIFont systemFontOfSize:12.0]];
    
    // 当歌曲名和歌手名长度超过View时，隐藏歌手名，反之显示歌手名，并且更新歌手名Label尺寸
    if (songNameSize.width + artistNameSize.width > cell.musicInfoView.frame.size.width) {
        [cell.lblArtistName setHidden:YES];
    } else {
        [cell.lblArtistName setHidden:NO];
        cell.lblArtistName.frame = CGRectMake(cell.lblArtistName.frame.origin.x, cell.lblArtistName.frame.origin.y, artistNameSize.width, artistNameSize.height);
    }
    
    // 更新歌曲名Label尺寸
    cell.lblMusicName.frame = CGRectMake(cell.lblMusicName.frame.origin.x, cell.lblMusicName.frame.origin.y, songNameSize.width, songNameSize.height);
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(PlayListTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == [musicController getIndexOfNowPlayingItem]) {
        [cell.lblMusicName setTextColor:[UIColor cyanColor]];
        [cell.lblArtistName setTextColor:[UIColor cyanColor]];
    } else {
        [cell.lblMusicName setTextColor:[UIColor blackColor]];
        [cell.lblArtistName setTextColor:[UIColor blackColor]];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView reloadData];
    [musicController pause];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [musicController play:indexPath.row];
    });
}

- (IBAction)deleteItem:(id)sender {
    
    PlayListTableViewCell *cell = (PlayListTableViewCell *)[[sender superview] superview];
    NSIndexPath *indexPath = [self.playListTable indexPathForCell:cell];
    [musicController deleteItem:indexPath.row];
    [self.playListTable reloadData];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
