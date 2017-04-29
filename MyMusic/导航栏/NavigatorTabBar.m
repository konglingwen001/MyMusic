//
//  NavigatorView.m
//  MyMusic
//
//  Created by 孔令文 on 2017/4/9.
//  Copyright © 2017年 孔令文. All rights reserved.
//

#import "NavigatorTabBar.h"
#import "NavigatorItem.h"

@implementation NavigatorTabBar

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.tabBarView];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // 重新设置NavigatorTabBar的frame，在initWithFrame中设置的没有效果
    CGRect frame = self.frame;
    frame.origin.y = 20;
    frame.size.height = 80;
    self.frame = frame;
    
    // 设置tabBarView的frame
    self.tabBarView.frame = self.bounds;
    // 把tabBarView带到最前面，覆盖tabBar的内容
    [self bringSubviewToFront:self.tabBarView];
}

#pragma mark - Getter

- (NavigatorView *)tabBarView
{
    if (_tabBarView == nil) {
        // xib的加载方式
        _tabBarView = [[[NSBundle mainBundle] loadNibNamed:@"NavigatorView" owner:nil options:nil] lastObject];
    }
    
    return _tabBarView;
}

@end
