//
//  MusicUtils.m
//  MyMusic
//
//  Created by 孔令文 on 2017/4/2.
//  Copyright © 2017年 孔令文. All rights reserved.
//

#import "MusicUtils.h"

@implementation MusicUtils

/*!
 * @brief 根据字符创长度获取控件尺寸
 * @discussion 根据字符创长度获取控件尺寸
 * @param text 字符串
 * @param font 字体信息
 */
+(CGSize)calSize:(NSString *) text WithFont:(UIFont *)font {
    CGSize size = [text sizeWithAttributes:@{NSFontAttributeName:font}];
    
    // 向上取整
    size = CGSizeMake(ceilf(size.width), ceilf(size.height));
    return size;
}

@end
