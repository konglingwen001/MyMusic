//
//  NavigatorView.m
//  MyMusic
//
//  Created by 孔令文 on 2017/4/9.
//  Copyright © 2017年 孔令文. All rights reserved.
//

#import "NavigatorView.h"
#import "NavigatorItem.h"

@implementation NavigatorView
{
NavigatorItem *searchItem;
NavigatorItem *myMusicItem;
NavigatorItem *musicLibraryItem;
NavigatorItem *toolItem;
NavigatorItem *settingItem;
}

/*!
 * @brief 实例化
 * @discussion xib实例化
 */
+(instancetype)makeItem {
    return [[[NSBundle mainBundle] loadNibNamed:@"NavigatorView" owner:self options:nil] firstObject];
}

-(void)awakeFromNib {
    [super awakeFromNib];
    
    
    [self addNavigatorItems];
    [self setNavigatorItemConstraint];
    [self addTargets];
}

-(void)addTargets {
    [searchItem addTarget:self action:@selector(searchItemClicked)];
    [myMusicItem addTarget:self action:@selector(myMusicItemClicked)];
    [musicLibraryItem addTarget:self action:@selector(musicLibraryItemClicked)];
    [toolItem addTarget:self action:@selector(toolItemClicked)];
    [settingItem addTarget:self action:@selector(settingItemClicked)];
}

-(void)searchItemClicked {
    NSLog(@"searchItem");
    [searchItem setSelected:YES withImage:[UIImage imageNamed:@"搜索2.png"]];
    [myMusicItem setSelected:NO withImage:[UIImage imageNamed:@"我的音乐1.png"]];
    [musicLibraryItem setSelected:NO withImage:[UIImage imageNamed:@"乐库1.png"]];
    [toolItem setSelected:NO withImage:[UIImage imageNamed:@"工具1.png"]];
    if ([self.delegate respondsToSelector:@selector(myTabBarView:didSelectItemAtIndex:)]) {
        [self.delegate myTabBarView:self didSelectItemAtIndex:0];
    }
}

-(void)myMusicItemClicked {
    NSLog(@"myMusicItem");
    [searchItem setSelected:NO withImage:[UIImage imageNamed:@"搜索1.png"]];
    [myMusicItem setSelected:YES withImage:[UIImage imageNamed:@"我的音乐2.png"]];
    [musicLibraryItem setSelected:NO withImage:[UIImage imageNamed:@"乐库1.png"]];
    [toolItem setSelected:NO withImage:[UIImage imageNamed:@"工具1.png"]];
    if ([self.delegate respondsToSelector:@selector(myTabBarView:didSelectItemAtIndex:)]) {
        [self.delegate myTabBarView:self didSelectItemAtIndex:1];
    }
}

-(void)musicLibraryItemClicked {
    NSLog(@"musicLibraryItem");
    [searchItem setSelected:NO withImage:[UIImage imageNamed:@"搜索1.png"]];
    [myMusicItem setSelected:NO withImage:[UIImage imageNamed:@"我的音乐1.png"]];
    [musicLibraryItem setSelected:YES withImage:[UIImage imageNamed:@"乐库2.png"]];
    [toolItem setSelected:NO withImage:[UIImage imageNamed:@"工具1.png"]];
    if ([self.delegate respondsToSelector:@selector(myTabBarView:didSelectItemAtIndex:)]) {
        [self.delegate myTabBarView:self didSelectItemAtIndex:2];
    }
}

-(void)toolItemClicked {
    NSLog(@"toolItem");
    [searchItem setSelected:NO withImage:[UIImage imageNamed:@"搜索1.png"]];
    [myMusicItem setSelected:NO withImage:[UIImage imageNamed:@"我的音乐1.png"]];
    [musicLibraryItem setSelected:NO withImage:[UIImage imageNamed:@"乐库1.png"]];
    [toolItem setSelected:YES withImage:[UIImage imageNamed:@"工具2.png"]];
    if ([self.delegate respondsToSelector:@selector(myTabBarView:didSelectItemAtIndex:)]) {
        [self.delegate myTabBarView:self didSelectItemAtIndex:3];
    }
}

-(void)settingItemClicked {
    NSLog(@"settingItem");
    [searchItem setSelected:NO withImage:[UIImage imageNamed:@"搜索1.png"]];
    [myMusicItem setSelected:NO withImage:[UIImage imageNamed:@"我的音乐1.png"]];
    [musicLibraryItem setSelected:NO withImage:[UIImage imageNamed:@"乐库1.png"]];
    [toolItem setSelected:NO withImage:[UIImage imageNamed:@"工具1.png"]];
    if ([self.delegate respondsToSelector:@selector(myTabBarView:didSelectItemAtIndex:)]) {
        [self.delegate myTabBarView:self didSelectItemAtIndex:4];
    }
}

-(void)addNavigatorItems {
    
    searchItem = [[[NSBundle mainBundle] loadNibNamed:@"NavigatorItem" owner:self options:nil] firstObject];
    [searchItem setImage:[UIImage imageNamed:@"搜索1.png"]];
    [searchItem setName:@"搜索"];
    [searchItem setTag:0];
    [searchItem setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:searchItem];
    
    myMusicItem = [[[NSBundle mainBundle] loadNibNamed:@"NavigatorItem" owner:self options:nil] firstObject];
    [myMusicItem setImage:[UIImage imageNamed:@"我的音乐1.png"]];
    [myMusicItem setName:@"我的音乐"];
    [searchItem setTag:1];
    [myMusicItem setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:myMusicItem];
    
    musicLibraryItem = [[[NSBundle mainBundle] loadNibNamed:@"NavigatorItem" owner:self options:nil] firstObject];
    [musicLibraryItem setImage:[UIImage imageNamed:@"乐库1.png"]];
    [musicLibraryItem setName:@"乐库"];
    [searchItem setTag:2];
    [musicLibraryItem setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:musicLibraryItem];
    
    toolItem = [[[NSBundle mainBundle] loadNibNamed:@"NavigatorItem" owner:self options:nil] firstObject];
    [toolItem setImage:[UIImage imageNamed:@"工具1.png"]];
    [toolItem setName:@"工具"];
    [searchItem setTag:3];
    [toolItem setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:toolItem];
    
    settingItem = [[[NSBundle mainBundle] loadNibNamed:@"NavigatorItem" owner:self options:nil] firstObject];
    [settingItem setImage:[UIImage imageNamed:@"设置.png"]];
    [settingItem setName:@"设置"];
    [searchItem setTag:4];
    [settingItem setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:settingItem];
    
}

-(void)setNavigatorItemConstraint {
    
    // 播放控制器约束添加
    NSLayoutConstraint *searchItemLeft = [NSLayoutConstraint constraintWithItem:searchItem attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1 constant:10];
    NSLayoutConstraint *searchItemVerticalCenter = [NSLayoutConstraint constraintWithItem:searchItem attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    NSLayoutConstraint *searchItemWidth = [NSLayoutConstraint constraintWithItem:searchItem attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1 constant:50];
    NSLayoutConstraint *searchItemHeight = [NSLayoutConstraint constraintWithItem:searchItem attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:60];
    [searchItem addConstraint:searchItemWidth];
    [searchItem addConstraint:searchItemHeight];
    
    NSLayoutConstraint *myMusicItemRight = [NSLayoutConstraint constraintWithItem:myMusicItem attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:musicLibraryItem attribute:NSLayoutAttributeLeading multiplier:1 constant:-20];
    NSLayoutConstraint *myMusicItemVerticalCenter = [NSLayoutConstraint constraintWithItem:myMusicItem attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    NSLayoutConstraint *myMusicItemWidth = [NSLayoutConstraint constraintWithItem:myMusicItem attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1 constant:50];
    NSLayoutConstraint *myMusicItemHeight = [NSLayoutConstraint constraintWithItem:myMusicItem attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:60];
    [myMusicItem addConstraint:myMusicItemWidth];
    [myMusicItem addConstraint:myMusicItemHeight];
    
    NSLayoutConstraint *musicLibraryItemHosizontalCenter = [NSLayoutConstraint constraintWithItem:musicLibraryItem attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    NSLayoutConstraint *musicLibraryItemVerticalCenter = [NSLayoutConstraint constraintWithItem:musicLibraryItem attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    NSLayoutConstraint *musicLibraryItemWidth = [NSLayoutConstraint constraintWithItem:musicLibraryItem attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1 constant:50];
    NSLayoutConstraint *musicLibraryItemHeight = [NSLayoutConstraint constraintWithItem:musicLibraryItem attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:60];
    [musicLibraryItem addConstraint:musicLibraryItemWidth];
    [musicLibraryItem addConstraint:musicLibraryItemHeight];
    
    NSLayoutConstraint *toolItemLeft = [NSLayoutConstraint constraintWithItem:toolItem attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:musicLibraryItem attribute:NSLayoutAttributeTrailing multiplier:1 constant:20];
    NSLayoutConstraint *toolItemVerticalCenter = [NSLayoutConstraint constraintWithItem:toolItem attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    NSLayoutConstraint *toolItemWidth = [NSLayoutConstraint constraintWithItem:toolItem attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1 constant:50];
    NSLayoutConstraint *toolItemHeight = [NSLayoutConstraint constraintWithItem:toolItem attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:60];
    [toolItem addConstraint:toolItemWidth];
    [toolItem addConstraint:toolItemHeight];
    
    NSLayoutConstraint *settingItemRight = [NSLayoutConstraint constraintWithItem:settingItem attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1 constant:-10];
    NSLayoutConstraint *settingItemVerticalCenter = [NSLayoutConstraint constraintWithItem:settingItem attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    NSLayoutConstraint *settingItemWidth = [NSLayoutConstraint constraintWithItem:settingItem attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1 constant:50];
    NSLayoutConstraint *settingItemHeight = [NSLayoutConstraint constraintWithItem:settingItem attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:60];
    [settingItem addConstraint:settingItemWidth];
    [settingItem addConstraint:settingItemHeight];
    
    NSArray *constraints = [NSArray arrayWithObjects:searchItemLeft, searchItemVerticalCenter, myMusicItemRight, myMusicItemVerticalCenter, musicLibraryItemVerticalCenter, musicLibraryItemHosizontalCenter, toolItemLeft, toolItemVerticalCenter, settingItemRight, settingItemVerticalCenter, nil];
    [self addConstraints:constraints];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
