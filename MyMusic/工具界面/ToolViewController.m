//
//  ToolView.m
//  MyMusic
//
//  Created by 孔令文 on 2017/4/10.
//  Copyright © 2017年 孔令文. All rights reserved.
//

#import "ToolViewController.h"
#import "TestView.h"
#import "GuitarNotesView.h"

@implementation ToolViewController

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
    
    GuitarNotesView *testView = [[[NSBundle mainBundle] loadNibNamed:@"GuitarNotesView" owner:self options:nil]firstObject];
    [self.view addSubview:testView];
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"天空之城" ofType:@"plist"];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    NSArray *beatArr = [[[[dic valueForKey:@"GuitarNotes"] valueForKey:@"BarNo"] objectAtIndex:0] valueForKey:@"BeatNo"];
    
    for (int beatNo = 0; beatNo < beatArr.count; beatNo++) {
        NSDictionary *beatDic = [beatArr objectAtIndex:beatNo];
        NSArray *noteNoArr = [beatDic objectForKey:@"NoteNo"];
        for (int noteNo = 0; noteNo < noteNoArr.count; noteNo++) {
            NSDictionary *notesDic = [noteNoArr objectAtIndex:noteNo];
            NSArray *notes = [notesDic objectForKey:@"Note"];
            for (int i = 0; i < notes.count; i++) {
                NSDictionary *note = [notes objectAtIndex:i];
                // 设定吉他音
                UILabel *label = [[UILabel alloc] init];
                [label setText:[note valueForKey:@"FretNo"]];
                [label setTextAlignment:NSTextAlignmentCenter];
                [label setFont:[UIFont systemFontOfSize:12.0]];
                //[label setAdjustsFontSizeToFitWidth:YES];
                [testView addNoteView:label withBeatNo:beatNo withNoteNo:noteNo withStringNo:[[note valueForKey:@"StringNo"] intValue]];
            }
        }
    }
    
//    TestView *testView1 = [[[NSBundle mainBundle] loadNibNamed:@"TestView" owner:self options:nil]firstObject];
//    [testView1 setFrame:CGRectMake(100, 100, 100, 100)];
//    [testView1 setBackgroundColor:[UIColor redColor]];
//    [self.view addSubview:testView1];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
