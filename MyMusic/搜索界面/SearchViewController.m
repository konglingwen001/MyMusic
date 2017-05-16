//
//  SearchView.m
//  MyMusic
//
//  Created by 孔令文 on 2017/4/10.
//  Copyright © 2017年 孔令文. All rights reserved.
//

#import "SearchViewController.h"
#import "NotesModel2.h"
#import "NotesTableViewCell.h"
#import "MusicUtils.h"
#import "EditNotesView.h"

#define EDIT_NOTE_SIZE 15.0f

@interface SearchViewController ()<UITableViewDataSource, UITableViewDelegate, NotesTableViewDelegate>



@end

@implementation SearchViewController {
    NotesModel2 *notesModel;
    
    UITableView *notesTableView;
    EditNotesView *editNotesView;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    notesModel = [NotesModel2 sharedInstance];
    [notesModel setGuitarNotesWithNotesName:@"天空之城version3"];
    
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
    [notesTableView setFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 200)];
    [editNotesView setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 200, [UIScreen mainScreen].bounds.size.width, 100)];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [notesModel getNotesSize].count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
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
-(UIImage *)drawNotesLine:(int)lineNo inCell:(UITableViewCell *)cell {
    
    UIGraphicsBeginImageContextWithOptions(cell.bounds.size, NO, 0.0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetRGBStrokeColor(context, 0, 0, 0, 1);
    
    [self drawBarInLine:lineNo withEditNote:[notesModel currentEditNotePos] withContext:context];
    
    CGContextStrokePath(context);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

/*!
 * @brief 描画一行吉他谱
 * @discussion 描画行号为lineNo的行的吉他谱线和音符
 */
- (void)drawBarInLine:(int)lineNo withEditNote:(NSDictionary *)editNotePos withContext:(CGContextRef)context {
    
    int editBarNo = [[editNotePos valueForKey:@"barNo"] intValue];
    int editNoteNo = [[editNotePos valueForKey:@"noteNo"] intValue];
    int editStringNo = [[editNotePos valueForKey:@"stringNo"] intValue];
    
    float barStartX = 50;
    float barStartY = EDIT_NOTE_SIZE;
    float offsetY = EDIT_NOTE_SIZE;
    
    // 绘制吉他6弦
    CGContextSetLineWidth(context, 1);
    CGPoint points1[] = {CGPointMake(50, barStartY), CGPointMake(718, barStartY),
        CGPointMake(50, barStartY + offsetY), CGPointMake(718, barStartY + offsetY),
        CGPointMake(50, barStartY + offsetY * 2), CGPointMake(718, barStartY + offsetY * 2),
        CGPointMake(50, barStartY + offsetY * 3), CGPointMake(718, barStartY + offsetY * 3),
        CGPointMake(50, barStartY + offsetY * 4), CGPointMake(718, barStartY + offsetY * 4),
        CGPointMake(50, barStartY + offsetY * 5), CGPointMake(718, barStartY + offsetY * 5)};
    CGContextStrokeLineSegments(context, points1, 12);
    
    // 绘制吉他谱小节线
    NSArray *noteSizeArray = [notesModel getNotesSize];
    NSDictionary *noteSizeDic = [noteSizeArray objectAtIndex:lineNo];
    int lineBarNum = [[noteSizeDic valueForKey:@"barNum"] intValue];
    NSArray *barWidthArr = [noteSizeDic valueForKey:@"barWidthArray"];
    CGContextSetLineWidth(context, 2);
    CGPoint *pointBarLine = (CGPoint *)malloc(sizeof(CGPoint) * barWidthArr.count * 2);
    for (int i = 0; i < barWidthArr.count * 2; i += 2) {
        pointBarLine[i] = CGPointMake(50 + [barWidthArr[i / 2] floatValue], barStartY);
        pointBarLine[i + 1] = CGPointMake(50 + [barWidthArr[i / 2] floatValue], barStartY + offsetY * 5);
    }
    CGContextStrokeLineSegments(context, pointBarLine, barWidthArr.count * 2);
    free(pointBarLine);
    
    // 绘制吉他音符
    int startBarNo = [[noteSizeDic valueForKey:@"startBarNo"] intValue];
    int noteCenterX = 0, noteCenterY = 0; // 音符中心坐标
    for (int barNo = startBarNo; barNo < startBarNo + lineBarNum; barNo++) {
        
        // 小节开始X坐标设置
        noteCenterX = barStartX + [barWidthArr[barNo - startBarNo] floatValue];
        
        NSArray *notesArray = [[notesModel getRootNotes] valueForKey:@"GuitarNotes"][barNo];
        for (int noteNo = 0; noteNo < notesArray.count; noteNo++) {
            NSArray *notes = notesArray[noteNo];
            NSDictionary *firstNote = notes[0];
            NSString *noteType = [firstNote valueForKey:@"NoteType"];
            
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
 * @brief 刷新吉他谱
 * @discussion 当音符编辑框位置改变时，刷新吉他谱，该方法由cell通过NotesTableViewDelegate传过来
 */
-(void)reloadNotesData {
    [notesTableView reloadData];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
