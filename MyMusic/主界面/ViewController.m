//
//  ViewController.m
//  MyMusic
//
//  Created by 孔令文 on 2017/3/19.
//  Copyright © 2017年 孔令文. All rights reserved.
//
#import <MediaPlayer/MediaPlayer.h>
#import "ViewController.h"
#import "NavigatorView.h"
#import "MusicControl.h"
#import "MusicToolView.h"
#import "SearchViewController.h"
#import "MyMusicViewController.h"
#import "MusicLibraryViewController.h"
#import "ToolViewController.h"
#import "ModelDataController.h"

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
    navigatorView = [NavigatorView makeItem];
    navigatorView.delegate = self;
    [navigatorView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:navigatorView];
    
    // 中间内容界面
    containerView = [[UIView alloc] init];
    [containerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:containerView];
    [self showViewController:[_modelDataController getTabBarSelectedIndex]];
    
    // 播放控制器
    musicToolView = [MusicToolView makeItem];
    _musicController.musicToolView = musicToolView;
    musicToolView.delegate = self;
    [musicToolView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:musicToolView];
    
    // 导航栏约束添加
    NSLayoutConstraint *naviLeft = [NSLayoutConstraint constraintWithItem:navigatorView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
    NSLayoutConstraint *naviRight = [NSLayoutConstraint constraintWithItem:navigatorView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
    NSLayoutConstraint *naviTop = [NSLayoutConstraint constraintWithItem:navigatorView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:20];
    NSLayoutConstraint *naviHeight = [NSLayoutConstraint constraintWithItem:navigatorView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:100];
    
    NSArray *naviConstraints = @[naviLeft, naviRight, naviTop];
    [self.view addConstraints:naviConstraints];
    [navigatorView addConstraint:naviHeight];
    
    // 中间内容界面约束添加
    NSLayoutConstraint *containerViewLeft = [NSLayoutConstraint constraintWithItem:containerView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
    NSLayoutConstraint *containerViewRight = [NSLayoutConstraint constraintWithItem:containerView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
    NSLayoutConstraint *containerViewTop = [NSLayoutConstraint constraintWithItem:containerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:navigatorView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    NSLayoutConstraint *containerViewBottom = [NSLayoutConstraint constraintWithItem:containerView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:musicToolView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    NSArray *containerConstraints = @[containerViewLeft, containerViewRight, containerViewTop, containerViewBottom];
    [self.view addConstraints:containerConstraints];
    
    // 播放控制器约束添加
    NSLayoutConstraint *musicToolLeft = [NSLayoutConstraint constraintWithItem:musicToolView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
    NSLayoutConstraint *musicToolRight = [NSLayoutConstraint constraintWithItem:musicToolView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
    NSLayoutConstraint *musicToolBottom = [NSLayoutConstraint constraintWithItem:musicToolView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:10];
    NSLayoutConstraint *musicToolHeight = [NSLayoutConstraint constraintWithItem:musicToolView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:100];
    
    NSArray *musicToolConstraints = @[musicToolLeft, musicToolRight, musicToolBottom];
    [self.view addConstraints:musicToolConstraints];
    [musicToolView addConstraint:musicToolHeight];
    
    
    // 监听系统音量改变
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(volumeDidChanged:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)showViewController:(int)viewControllerType {
    
    UIViewController *itemViewController;
    switch (viewControllerType) {
        case 0:
            // 搜索界面
            itemViewController = [[SearchViewController alloc] init];
            itemView = [[[SearchViewController alloc] init] view];
            break;
        case 1:
            // 我的音乐界面
            itemViewController = [[MyMusicViewController alloc] init];
            itemView = [[[MyMusicViewController alloc] init] view];
            break;
        case 2:
            // 乐库界面
            itemViewController = [[MusicLibraryViewController alloc] init];
            itemView = [[[MusicLibraryViewController alloc] init] view];
            break;
        case 3:
            // 工具界面
            itemViewController = [[ToolViewController alloc] init];
            itemView = [[[ToolViewController alloc] init] view];
            break;
            
        default:
            break;
    }
    [_modelDataController setTabBarSelectedIndex:viewControllerType];
    [containerView addSubview:itemView];
    [self addContainerConstraints:itemView];
    [itemView layoutIfNeeded];
    [itemView layoutSubviews];
    
    
    //[self presentViewController:itemViewController animated:YES completion:nil];
}

-(void)addContainerConstraints:(UIView *)view {
    [view setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSLayoutConstraint *containerViewLeft = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:containerView attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
    NSLayoutConstraint *containerViewRight = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:containerView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
    NSLayoutConstraint *containerViewTop = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:containerView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    NSLayoutConstraint *containerViewBottom = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:containerView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    NSArray *containerConstraints = @[containerViewLeft, containerViewRight, containerViewTop, containerViewBottom];
    [containerView addConstraints:containerConstraints];
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
