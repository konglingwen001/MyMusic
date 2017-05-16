//
//  ToolView.m
//  MyMusic
//
//  Created by 孔令文 on 2017/4/10.
//  Copyright © 2017年 孔令文. All rights reserved.
//

#import "ToolViewController.h"
#import "MyGuitarNotesView.h"
#import "NotesModel.h"
#import "MusicUtils.h"

@implementation ToolViewController {
    NotesModel *notesModel;
    MyGuitarNotesView *testView;
    int barNum;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    notesModel = [[NotesModel alloc] initWithNotesName:@"天空之城version1"];
    int lineNum = (int)[notesModel getNotesSize].count;
    NSDictionary *rootNoteDic = [notesModel getRootNotes];
    barNum = [[rootNoteDic valueForKey:@"BarNum"] intValue];
    
    testView = [[MyGuitarNotesView alloc] initWithNotes:rootNoteDic];
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
