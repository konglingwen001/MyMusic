//
//  NavigatorView.h
//  MyMusic
//
//  Created by 孔令文 on 2017/4/9.
//  Copyright © 2017年 孔令文. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NavigatorDelegate <NSObject>

-(void)showViewController:(int)viewControllerType;

@end

@interface NavigatorView : UIView

@property (nonatomic, assign) id<NavigatorDelegate> delegate;

+(instancetype)makeItem;

@end
