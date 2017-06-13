//
//  NotesTableViewController.m
//  MyMusic
//
//  Created by 孔令文 on 2017/6/4.
//  Copyright © 2017年 孔令文. All rights reserved.
//

#import "NotesViewController.h"
#import "NotesModel.h"
#import "NotesTableViewCell.h"
#import "MusicUtils.h"
#import "EditNotesView.h"
#import "YYSampler.h"

#define EDIT_NOTE_SIZE 15.0f

@interface NotesViewController ()<UITableViewDelegate, UITableViewDataSource, NotesTableViewDelegate>

@property (nonatomic, retain) YYSampler *sampler;

@property (nonatomic, strong) dispatch_source_t timer;//定时器开始执行的延时时间

@end

@implementation NotesViewController {
    NotesModel *notesModel;
    
    UITableView *notesTableView;
    EditNotesView *editNotesView;
    NSArray *tuneArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    notesModel = [NotesModel sharedInstance];
    [notesModel setGuitarNotesWithNotesTitle:self.guitarNotesTitle];
    
    // Navigator设定
    self.title = self.guitarNotesTitle;
    UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    self.navigationItem.leftBarButtonItem = leftBtn;
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(save)];
    self.navigationItem.rightBarButtonItem = rightBtn;
    
    // 音符播放组件
    tuneArray = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"C_Ionian_tune" ofType:@"plist"]];
    self.sampler = [[YYSampler alloc] init];
    NSURL *presetURL;
    presetURL = [[NSBundle mainBundle] URLForResource:@"default" withExtension:@"sf2"];
    [_sampler loadFromDLSOrSoundFont:presetURL withPatch:24];
    
    // 吉他谱
    notesTableView = [[UITableView alloc] init];
    [notesTableView registerNib:[UINib nibWithNibName:@"NotesTableViewCell" bundle:nil] forCellReuseIdentifier:@"notesLine"];
    notesTableView.delegate = self;
    notesTableView.dataSource = self;
    notesTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:notesTableView];
    
    // 编辑吉他谱
    editNotesView = [EditNotesView makeView];
    editNotesView.delegate = self;
    [self.view addSubview:editNotesView];
}

-(void)viewWillAppear:(BOOL)animated {
    [notesTableView setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 200)];
    [editNotesView setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 200, [UIScreen mainScreen].bounds.size.width, 200)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/**
 释放当前界面，返回
 */
-(void)goBack {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"取消" message:@"吉他谱未保存，是否确定退出?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertVC addAction:okAction];
    [alertVC addAction:cancelAction];
    [self presentViewController:alertVC animated:YES completion:nil];
    
}


/**
 保存吉他谱
 */
-(void)save {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"保存" message:@"即将保存吉他谱，是否确定?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [notesModel save];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertVC addAction:okAction];
    [alertVC addAction:cancelAction];
    [self presentViewController:alertVC animated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [notesModel getNotesSize].count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NotesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"notesLine" forIndexPath:indexPath];
    cell.delegate = self;
    UIImage *image = [self drawNotesLine:indexPath.row inCell:cell];
    cell.notesView.image = image;
    cell.lineNo = indexPath.row;
    return cell;
}

/*!
 * @brief 吉他谱单行高度
 * @discussion 返回吉他谱单行高度
 */
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 150;
}

/*!
 * @brief 绘制一行吉他谱
 * @discussion 描画行号为lineNo的行的吉他谱线和音符，并以UIImage形式返回
 */
-(UIImage *)drawNotesLine:(long)lineNo inCell:(UITableViewCell *)cell {
    
    UIGraphicsBeginImageContextWithOptions(cell.bounds.size, NO, 0.0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetRGBStrokeColor(context, 0, 0, 0, 1);
    
    [self drawBarInLine:lineNo withContext:context];
    
    CGContextStrokePath(context);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

/*!
 * @brief 描画一行谱线和小节线
 * @discussion 描画行号为lineNo的谱线和小节线
 */
-(void)drawNoteLineInLine:(long)lineNo withContext:(CGContextRef)context {
    
    float barStartY = EDIT_NOTE_SIZE;
    float offsetY = EDIT_NOTE_SIZE;
    
    // 绘制吉他6弦
    NSArray *noteSizeArray = [notesModel getNotesSize];
    NSDictionary *noteSizeDic = [noteSizeArray objectAtIndex:lineNo];
    NSArray *barWidthArr = [noteSizeDic valueForKey:@"barWidthArray"];
    float lineStart = 50;
    float lineEnd = lineStart + [[barWidthArr lastObject] floatValue];
    CGContextSetLineWidth(context, 1);
    CGPoint points1[] = {CGPointMake(lineStart, barStartY), CGPointMake(lineEnd, barStartY),
        CGPointMake(lineStart, barStartY + offsetY), CGPointMake(lineEnd, barStartY + offsetY),
        CGPointMake(lineStart, barStartY + offsetY * 2), CGPointMake(lineEnd, barStartY + offsetY * 2),
        CGPointMake(lineStart, barStartY + offsetY * 3), CGPointMake(lineEnd, barStartY + offsetY * 3),
        CGPointMake(lineStart, barStartY + offsetY * 4), CGPointMake(lineEnd, barStartY + offsetY * 4),
        CGPointMake(lineStart, barStartY + offsetY * 5), CGPointMake(lineEnd, barStartY + offsetY * 5)};
    CGContextStrokeLineSegments(context, points1, 12);
    
    // 绘制吉他谱小节线
    CGContextSetLineWidth(context, 2);
    CGPoint *pointBarLine = (CGPoint *)malloc(sizeof(CGPoint) * barWidthArr.count * 2);
    for (int i = 0; i < barWidthArr.count * 2; i += 2) {
        pointBarLine[i] = CGPointMake(50 + [barWidthArr[i / 2] floatValue], barStartY);
        pointBarLine[i + 1] = CGPointMake(50 + [barWidthArr[i / 2] floatValue], barStartY + offsetY * 5);
    }
    CGContextStrokeLineSegments(context, pointBarLine, barWidthArr.count * 2);
    free(pointBarLine);
}

/*!
 * @brief 描画一行所有音符
 * @discussion 描画行号为lineNo的所有音符
 */
-(void)drawNotesInLine:(long)lineNo withContext:(CGContextRef)context {
    NSDictionary *editNotePos = [notesModel currentEditNotePos];
    int editBarNo = [[editNotePos valueForKey:@"barNo"] intValue];
    int editNoteNo = [[editNotePos valueForKey:@"noteNo"] intValue];
    int editStringNo = [[editNotePos valueForKey:@"stringNo"] intValue];
    
    float barStartX = 50;
    float barStartY = EDIT_NOTE_SIZE;
    float offsetY = EDIT_NOTE_SIZE;
    
    
    NSArray *noteSizeArray = [notesModel getNotesSize];
    NSDictionary *noteSizeDic = [noteSizeArray objectAtIndex:lineNo];
    int lineBarNum = [[noteSizeDic valueForKey:@"barNum"] intValue];
    NSArray *barWidthArr = [noteSizeDic valueForKey:@"barWidthArray"];
    
    // 绘制吉他音符
    int startBarNo = [[noteSizeDic valueForKey:@"startBarNo"] intValue];
    int noteCenterX = 0, noteCenterY = 0; // 音符中心坐标
    for (int barNo = startBarNo; barNo < startBarNo + lineBarNum; barNo++) {
        
        // 小节开始X坐标设置
        noteCenterX = barStartX + [barWidthArr[barNo - startBarNo] floatValue];
        
        NSArray *noteNoArray = [notesModel getNoteNoArrayWithBarNo:barNo];
        for (int noteNo = 0; noteNo < noteNoArray.count; noteNo++) {
            NSArray *notes = [noteNoArray[noteNo] valueForKey:@"noteArray"];
            NSString *noteType = [notesModel getNoteTypeWithBarNo:barNo andNoteNo:noteNo];
            
            // 设定音符X坐标
            if ([noteType isEqualToString:@"2"]) {
                noteCenterX += [[noteSizeDic valueForKey:@"minimWidth"] floatValue];
            } else if ([noteType isEqualToString:@"4"]) {
                noteCenterX += [[noteSizeDic valueForKey:@"crotchetaWidth"] floatValue];
            } else if ([noteType isEqualToString:@"8"]) {
                noteCenterX += [[noteSizeDic valueForKey:@"quaverWidth"] floatValue];
            } else if ([noteType isEqualToString:@"16"]) {
                noteCenterX += [[noteSizeDic valueForKey:@"demiquaverWidth"] floatValue];
            }
            
            // 根据触摸位置所在的音符位置绘制音符编辑框
            if (barNo == editBarNo && noteNo == editNoteNo) {
                CGContextSetRGBFillColor(context, 0, 1, 0, 1);
                noteCenterY = barStartY + (editStringNo - 1) * offsetY + 0.5;
                CGContextFillRect(context, CGRectMake(noteCenterX - EDIT_NOTE_SIZE / 2, noteCenterY- EDIT_NOTE_SIZE / 2, EDIT_NOTE_SIZE, EDIT_NOTE_SIZE));
            }
            
            for (int i = 0; i < notes.count; i++) {
                
                NSDictionary *note = [notes objectAtIndex:i];
                int stringNo = [[note valueForKey:@"StringNo"] intValue];
                
                NSString *fretNo = [[note valueForKey:@"FretNo"] stringValue];
                CGSize fretNoSize = [MusicUtils calSize:fretNo WithFont:[UIFont systemFontOfSize:12.0f]];
                
                noteCenterY = barStartY + (stringNo - 1) * offsetY + 0.5;
                
                // 没有被选中的音符绘制白色背景，避免横线贯穿音符
                if (!(barNo == editBarNo && noteNo == editNoteNo && stringNo == editStringNo)) {
                    CGContextSetRGBFillColor(context, 1, 1, 1, 1);
                    CGContextFillRect(context, CGRectMake(noteCenterX - fretNoSize.width / 2, noteCenterY - fretNoSize.height / 2, fretNoSize.width, fretNoSize.height));
                }
                
                // 绘制音符(音符为空时不绘制)
                if (stringNo != -1 && ![fretNo isEqualToString:@"-1"]) {
                    CGContextSetRGBStrokeColor(context, 0, 0, 0, 1);
                    [fretNo drawAtPoint:CGPointMake(noteCenterX - fretNoSize.width / 2, noteCenterY - fretNoSize.height / 2) withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:12.0], NSFontAttributeName, [UIColor blackColor], NSForegroundColorAttributeName, nil]];
                }
                
            }
        }
    }
}

/*!
 * @brief 描画符干
 * @discussion 描画行号为lineNo的音符符干
 */
-(void)drawStemInLine:(long)lineNo withContext:(CGContextRef)context {
    NSString *flat = [[notesModel getRootNotes] valueForKey:@"Flat"];
    int flatNum = [[flat componentsSeparatedByString:@"/"][0] intValue];
    NSString *noteType = [flat componentsSeparatedByString:@"/"][1];
    
    NSArray *noteSizeArray = [notesModel getNotesSize];
    NSDictionary *noteSizeDic = [noteSizeArray objectAtIndex:lineNo];
    int lineBarNum = [[noteSizeDic valueForKey:@"barNum"] intValue];
    NSArray *barWidthArr = [noteSizeDic valueForKey:@"barWidthArray"];
    
    // 绘制符干
    int startBarNo = [[noteSizeDic valueForKey:@"startBarNo"] intValue];
    float barStartX = 50, barStartY = EDIT_NOTE_SIZE;
    int noteCenterX = 0; // 音符中心坐标
    for (int barNo = startBarNo; barNo < startBarNo + lineBarNum; barNo++) {
        // 小节开始X坐标设置
        noteCenterX = barStartX + [barWidthArr[barNo - startBarNo] floatValue];
        
        float currentNoteWidth = 0;
        NSMutableDictionary *preNoteData = [[NSMutableDictionary alloc] init];
        NSArray *noteNoArray = [notesModel getNoteNoArrayWithBarNo:barNo];
        for (int noteNo = 0; noteNo < noteNoArray.count; noteNo++) {
            NSString *noteType = [notesModel getNoteTypeWithBarNo:barNo andNoteNo:noteNo];
            
            // 设定符干X坐标
            if ([noteType isEqualToString:@"2"]) {
                noteCenterX += [[noteSizeDic valueForKey:@"minimWidth"] floatValue];
            } else if ([noteType isEqualToString:@"4"]) {
                noteCenterX += [[noteSizeDic valueForKey:@"crotchetaWidth"] floatValue];
            } else if ([noteType isEqualToString:@"8"]) {
                currentNoteWidth = [[noteSizeDic valueForKey:@"quaverWidth"] floatValue];
                noteCenterX += currentNoteWidth;
                
                // 判断前一个音符种类
                if (preNoteData.count == 0) {
                    // 当前音符为音符的开始音符，保存
                    [preNoteData setValue:noteType forKey:@"NoteType"];
                } else {
                    NSString *preNoteType = [preNoteData valueForKey:@"NoteType"];
                    if ([preNoteType isEqualToString:@"8"]) {
                        // 前一个音符为八分音符
                        // 绘制符干连接线
                        CGContextSetLineWidth(context, 2);
                        CGPoint point[] = {CGPointMake(noteCenterX, 150 - 15), CGPointMake(noteCenterX - currentNoteWidth, 150 - 15)};
                        CGContextStrokeLineSegments(context, point, 2);
                        [preNoteData removeAllObjects];
                    } else if ([preNoteType isEqualToString:@"16"]) {
                        
                    }
                }
            } else if ([noteType isEqualToString:@"16"]) {
                noteCenterX += [[noteSizeDic valueForKey:@"demiquaverWidth"] floatValue];
            }
            
            // 绘制符干
            CGContextSetLineWidth(context, 1);
            CGPoint point1[] = {CGPointMake(noteCenterX, barStartY + 90), CGPointMake(noteCenterX, 150 - 15)};
            CGContextStrokeLineSegments(context, point1, 2);
            
        }
    }
}

/*!
 * @brief 描画一行吉他谱
 * @discussion 描画行号为lineNo的行的吉他谱线和音符
 */
- (void)drawBarInLine:(long)lineNo withContext:(CGContextRef)context {
    
    // 绘制谱线和小节线
    [self drawNoteLineInLine:lineNo withContext:context];
    
    // 绘制改行所有音符
    [self drawNotesInLine:lineNo withContext:context];
    
    // 绘制符干
    [self drawStemInLine:lineNo withContext:context];
}

/*!
 * @brief 刷新吉他谱
 * @discussion 当音符编辑框位置改变时，刷新吉他谱，该方法由cell通过NotesTableViewDelegate传过来
 */
-(void)reloadNotesData {
    [notesTableView reloadData];
}

-(void)testPlay {
    
    NSArray *barNoArray = [notesModel getBarNoArray];
    __block NSString *preNoteType = [barNoArray[0][0] valueForKey:@"NoteType"];
    
    float crotchetaTime = 0.6;
    float quaverTime = 0.3;
    __block int barNo = 0;
    __block int noteNo = 0;
    NSTimeInterval delayTime = 0.0f;
    __block NSTimeInterval timeInterval = crotchetaTime;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    __block dispatch_time_t startDelayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC));
    dispatch_source_set_timer(_timer, startDelayTime, timeInterval * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(_timer, ^{
        
        NSDictionary *notesDic = barNoArray[barNo][noteNo++];
        NSArray *notes = [notesDic valueForKey:@"noteArray"];
        for (NSDictionary *note in notes) {
            int fretNo = [[note valueForKey:@"FretNo"] intValue];
            int stringNo = [[note valueForKey:@"StringNo"] intValue];
            if (stringNo < 1 || stringNo > 6) {
                continue;
            }
            int tune = [tuneArray[stringNo - 1] intValue] + fretNo;
            [self.sampler triggerNote:tune isOn:YES];
        }
        
        NSString *noteType = [notesDic valueForKey:@"NoteType"];
        if (![noteType isEqualToString:preNoteType]) {
            preNoteType = noteType;
            if ([noteType isEqualToString:@"4"]) {
                timeInterval = crotchetaTime;
            } else if ([noteType isEqualToString:@"8"]) {
                timeInterval = quaverTime;
            }
            startDelayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeInterval * NSEC_PER_SEC));
            dispatch_source_set_timer(_timer, startDelayTime, timeInterval * NSEC_PER_SEC, 0);
        }
        
        if (noteNo == [barNoArray[barNo] count]) {
            noteNo = 0;
            barNo++;
        }
        
    });
    dispatch_resume(_timer);
}

-(void)testStop {
    dispatch_source_cancel(_timer);
}

@end
