//
//  NavigatorItem.h
//  MyMusic
//
//  Created by 孔令文 on 2017/4/9.
//  Copyright © 2017年 孔令文. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NavigatorItem : UIView

-(void)setImage:(UIImage *)image;
-(void)setName:(NSString *)itemName;
-(void)setSelected:(BOOL)boolVal withImage:(UIImage *)image;
-(void)addTarget:(id)target action:(SEL)action;

@end
