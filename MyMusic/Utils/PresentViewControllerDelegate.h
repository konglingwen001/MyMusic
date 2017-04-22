//
//  PresentViewControllerDelegate.h
//  MyMusic
//
//  Created by 孔令文 on 2017/4/15.
//  Copyright © 2017年 孔令文. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PresentViewControllerDelegate <NSObject>

-(void)presentViewController:(UIViewController *)viewController fromView:(UIView *)sourceView;

@end
