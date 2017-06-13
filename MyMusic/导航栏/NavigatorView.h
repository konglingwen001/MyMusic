//
//  NavigatorView.h
//  MyMusic
//
//  Created by 孔令文 on 2017/4/9.
//  Copyright © 2017年 孔令文. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NavigatorView;

@protocol NavigatorDelegate <NSObject>

- (void)myTabBarView:(NavigatorView *)view didSelectItemAtIndex:(NSInteger)index;

@end

@interface NavigatorView : UIView

@property (nonatomic, weak) id<NavigatorDelegate> delegate;

+(instancetype)makeItem;

@end
