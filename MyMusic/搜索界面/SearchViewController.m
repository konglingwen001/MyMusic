//
//  SearchView.m
//  MyMusic
//
//  Created by 孔令文 on 2017/4/10.
//  Copyright © 2017年 孔令文. All rights reserved.
//

#import "SearchViewController.h"

@implementation SearchViewController

#pragma mark ---- 单例模式生成实例

static id _instance = nil;

/*!
 * @brief 获取单例播放器类
 
 * @return 播放器实例
 */
+(instancetype)sharedInstance {
    if (_instance == nil) {
        _instance = [[self alloc] init];
    }
    return _instance;
}

+(instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

-(instancetype)init {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super init];
        
    });
    return _instance;
}

-(id)copy {
    return _instance;
}

-(id)mutableCopy {
    return _instance;
}

-(void)viewDidLoad {
    [super viewDidLoad];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
