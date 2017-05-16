//
//  MusicLibraryView.m
//  MyMusic
//
//  Created by 孔令文 on 2017/4/10.
//  Copyright © 2017年 孔令文. All rights reserved.
//

#import "MusicLibraryViewController.h"
#import "NotesModel2.h"
#import "MyGuitarNotesView2.h"

@implementation MusicLibraryViewController {
    NotesModel2 *notesModel;
    MyGuitarNotesView2 *testView;
    int barNum;
}

#pragma mark ---- 单例模式生成实例

//static id _instance = nil;
//
///*!
// * @brief 获取单例播放器类
// 
// * @return 播放器实例
// */
//+(instancetype)sharedInstance {
//    if (_instance == nil) {
//        _instance = [[self alloc] init];
//    }
//    return _instance;
//}
//
//+(instancetype)allocWithZone:(struct _NSZone *)zone {
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        _instance = [super allocWithZone:zone];
//    });
//    return _instance;
//}
//
//-(instancetype)init {
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        _instance = [super init];
//        
//    });
//    return _instance;
//}
//
//-(id)copy {
//    return _instance;
//}
//
//-(id)mutableCopy {
//    return _instance;
//}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    notesModel = [NotesModel2 sharedInstance];
    [notesModel setGuitarNotesWithNotesName:@"天空之城version3"];
    int lineNum = (int)[notesModel getNotesSize].count;
    NSDictionary *rootNoteDic = [notesModel getRootNotes];
    barNum = [[rootNoteDic valueForKey:@"BarNum"] intValue];
    
    testView = [[MyGuitarNotesView2 alloc] initWithNotes:rootNoteDic];
    [testView setFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 100)];
    [testView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:testView];
    
    [testView setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, 15 + lineNum * 150)];
    [testView setScrollEnabled:YES];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
