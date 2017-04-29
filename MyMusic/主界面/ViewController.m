//
//  ViewController.m
//  MyMusic
//
//  Created by 孔令文 on 2017/3/19.
//  Copyright © 2017年 孔令文. All rights reserved.
//
#import <MediaPlayer/MediaPlayer.h>
#import "ViewController.h"
#import "MusicControl.h"
#import "MusicToolView.h"
#import "SearchViewController.h"
#import "MyMusicViewController.h"
#import "MusicLibraryViewController.h"
#import "ToolViewController.h"
#import "ModelDataController.h"
#import "NavigatorTabBar.h"

@interface ViewController ()<PresentViewControllerDelegate, NavigatorDelegate>

@property (nonatomic, strong) MusicControl *musicController;

@property (nonatomic, strong) ModelDataController *modelDataController;

@end

@implementation ViewController {
    MusicToolView *musicToolView;
    NavigatorView *navigatorView;
    UIView *containerView;
    UIView *itemView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _musicController = [MusicControl sharedInstance];
    _modelDataController = [ModelDataController sharedInstance];
    
    // 导航栏
    
    NavigatorTabBar *myTabBar = [[NavigatorTabBar alloc] init];
    myTabBar.tabBarView.delegate = self;
    [self setValue:myTabBar forKey:@"tabBar"];
    
    SearchViewController *searchViewController = [[SearchViewController alloc] init];
    MyMusicViewController *myMusicViewController = [[MyMusicViewController alloc] init];
    MusicLibraryViewController *musicLibraryViewController = [[MusicLibraryViewController alloc] init];
    ToolViewController *toolViewController = [[ToolViewController alloc] init];
    //SettingViewController *settingViewController = [[SettingViewController alloc] init];

    [self addChildViewController:searchViewController];
    [self addChildViewController:myMusicViewController];
    [self addChildViewController:musicLibraryViewController];
    [self addChildViewController:toolViewController];
    //[self addChildViewController:settingViewController];
    
    // 播放控制器
    musicToolView = [MusicToolView makeItem];
    _musicController.musicToolView = musicToolView;
    musicToolView.delegate = self;
    //[musicToolView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [musicToolView setFrame:CGRectMake(0, self.view.frame.size.height - 80, self.view.frame.size.width, 80)];
    [self.view addSubview:musicToolView];
    
    
    // 监听系统音量改变
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(volumeDidChanged:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [self.view bringSubviewToFront:musicToolView];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)myTabBarView:(NavigatorView *)view didSelectItemAtIndex:(NSInteger)index {
    self.selectedIndex = index;
}

/*! 
 * @brief 监听系统音量
 * @discussion 监听系统音量变化，当系统音量变化时，更新音量进度条
 */
-(void)volumeDidChanged:(NSNotification *)noti {
    float volume = [[[noti userInfo] valueForKey:@"AVSystemController_AudioVolumeNotificationParameter"] floatValue];
    [musicToolView updateVolumeSlider:volume];
}

/*!
 * @brief 更新播放进度
 * @discussion 计时器触发时间，每秒更新歌曲播放进度
 */
-(void)updateProgress:(id) sender {
    [musicToolView updateProgressTime];
}

-(void)presentViewController:(UIViewController *)viewController fromView:(UIView *)sourceView {
    viewController.modalPresentationStyle = UIModalPresentationPopover; 
    UIPopoverPresentationController *presentationController = [viewController popoverPresentationController];
    presentationController.permittedArrowDirections = UIPopoverArrowDirectionDown;
    presentationController.sourceView = sourceView;
    presentationController.sourceRect = sourceView.bounds;
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
