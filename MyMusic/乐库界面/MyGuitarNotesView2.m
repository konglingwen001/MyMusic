//
//  MyGuitarNotesView2.m
//  MyMusic
//
//  Created by 孔令文 on 2017/5/9.
//  Copyright © 2017年 孔令文. All rights reserved.
//

#import "MyGuitarNotesView2.h"
#import "MusicUtils.h"
#import "NotesModel2.h"

@implementation MyGuitarNotesView2 {
    NotesModel2 *notesModel;
    MusicUtils *musicUtils;
    NSDictionary *guitarNotes;
    int barNum;
    UIImageView *imageView;
    UIImage *notesImage;
    
    NSDictionary *notePos;
}

-(instancetype)initWithNotes:(NSDictionary *)notesDic {
    if (self = [super init]) {
        notesModel = [NotesModel2 sharedInstance];
        guitarNotes = notesDic;
        self.delegate = self;
        
        [self setFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 100)];
        [self setBackgroundColor:[UIColor whiteColor]];
        notesImage = [self drawImageAtImageContext:CGPointZero];
        imageView = [[UIImageView alloc] initWithImage:notesImage];
        [self addSubview:imageView];
    }
    return self;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = touches.allObjects[0];
    CGPoint point = [touch locationInView:[touch view]];
    NSLog(@"x=%f, y=%f", point.x, point.y);
    imageView.image = [self drawImageAtImageContext:point];
}

-(BOOL)isOutsideOfGuitarNotes:(CGPoint)point {
    NSArray *notesSize = [notesModel getNotesSize];
    int lineNo = (point.y + 7.5 - 15) / 150;
    int lineStartY = lineNo * 150 + 15;
    
    if (point.x < 50 || point.x > [UIScreen mainScreen].bounds.size.width - 50) {
        return YES;
    }
    
    if (lineNo == 0) {
        if (point.y < lineStartY - 7.5) {
            return YES;
        } else if (lineStartY + 75 + 7.5 < point.y && (lineStartY + 150 - 7.5) > point.y) {
            return YES;
        }
    } else if (lineNo == notesSize.count) {
        if (point.y > lineStartY + 75 + 7.5) {
            return YES;
        }
    } else if (lineNo > notesSize.count) {
        return YES;
    }else {
        if (lineStartY + 75 + 7.5 < point.y && (lineStartY + 150 - 7.5) > point.y) {
            return YES;
        }
    }
    return NO;
}

-(NSDictionary *)calRectFromPoint:(CGPoint)point {
    
    NSMutableDictionary *resultDic = [[NSMutableDictionary alloc] init];
    
    int rowNo = (point.y - 7.5) / 150;
    int barStartX = 50;
    int barStartY = 15 + rowNo * 150;
    
    // 第一次打开吉他谱界面，将编辑框放在最开始的地方
    if (point.x == 0 && point.y == 0) {
        [resultDic setValue:[NSNumber numberWithInt:0] forKey:@"stringNo"];
        [resultDic setValue:[NSNumber numberWithInt:0] forKey:@"barNo"];
        [resultDic setValue:[NSNumber numberWithInt:0] forKey:@"noteNo"];
        return resultDic;
    }
    
    // 当点击位置在吉他谱外面时，不改变编辑框位置
    if ([self isOutsideOfGuitarNotes:point]) {
        [resultDic setValue:[notePos valueForKey:@"stringNo"] forKey:@"stringNo"];
        [resultDic setValue:[notePos valueForKey:@"barNo"] forKey:@"barNo"];
        [resultDic setValue:[notePos valueForKey:@"noteNo"] forKey:@"noteNo"];
        return resultDic;
    }
    
    NSDictionary *lineSizeDic = [notesModel getNotesSize][rowNo];
    float minimWidth = [[lineSizeDic valueForKey:@"minimWidth"] floatValue];
    float crotchetaWidth = [[lineSizeDic valueForKey:@"crotchetaWidth"] floatValue];
    float quaverWidth = [[lineSizeDic valueForKey:@"quaverWidth"] floatValue];
    float demiquaverWidth = [[lineSizeDic valueForKey:@"demiquaverWidth"] floatValue];
    int barNo = [[lineSizeDic valueForKey:@"startBarNo"] intValue];
    
    NSArray *barWidthArray = [lineSizeDic valueForKey:@"barWidthArray"];
    
    // 判断触摸位置所属的小节，i从1开始，因为barWidthArray[0] == 0
    for (int i = 1; i < barWidthArray.count; i++) {
        float width = [barWidthArray[i] floatValue];
        if (point.x > 50 + width) {
            barNo++;
            barStartX = 50 + width;
        } else {
            break;
        }
    }
    
    int stringNo = (int)((point.y - barStartY + 7.5) / 15) + 1;
    [resultDic setValue:[NSNumber numberWithInt:stringNo] forKey:@"stringNo"];
    int addPosX = barStartX;
    float currentWidth = 0;
    
    NSArray *notesArray = [guitarNotes valueForKey:@"GuitarNotes"][barNo];
    for (int noteNo = 0; noteNo < notesArray.count; noteNo++) {
        NSDictionary *note = notesArray[noteNo][0];
        NSString *noteType = [note valueForKey:@"NoteType"];
        
        if ([noteType isEqualToString:@"2"]) {
            currentWidth = minimWidth;
        } else if ([noteType isEqualToString:@"4"]) {
            currentWidth = crotchetaWidth;
        } else if ([noteType isEqualToString:@"8"]) {
            currentWidth = quaverWidth;
        } else if ([noteType isEqualToString:@"16"]) {
            currentWidth =  demiquaverWidth;
        }
        addPosX += currentWidth;
        
        if (point.x < addPosX) {
            
            if (noteNo == 0) {
                [resultDic setValue:[NSNumber numberWithInt:barNo] forKey:@"barNo"];
                [resultDic setValue:[NSNumber numberWithInt:noteNo] forKey:@"noteNo"];
            } else if (point.x > addPosX - currentWidth / 2) {
                [resultDic setValue:[NSNumber numberWithInt:barNo] forKey:@"barNo"];
                [resultDic setValue:[NSNumber numberWithInt:noteNo] forKey:@"noteNo"];
            } else {
                [resultDic setValue:[NSNumber numberWithInt:barNo] forKey:@"barNo"];
                [resultDic setValue:[NSNumber numberWithInt:noteNo - 1] forKey:@"noteNo"];
            }
            break;
        } else {
            if (noteNo == notesArray.count - 1) {
                [resultDic setValue:[NSNumber numberWithInt:barNo] forKey:@"barNo"];
                [resultDic setValue:[NSNumber numberWithInt:noteNo] forKey:@"noteNo"];
                break;
            }
        }
        
    }
    
    return resultDic;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //NSLog(@"scroll");
}

/*!
 * @brief 描画吉他谱
 * @discussion 在内存图片中描画吉他谱，返回画好的图片
 */
-(UIImage *)drawImageAtImageContext:(CGPoint)point {
    
    notePos = [self calRectFromPoint:point];
    NSLog(@"%@",notePos);
    
    int lineNum = (int)[notesModel getNotesSize].count;
    CGSize size = CGSizeMake([UIScreen mainScreen].bounds.size.width, 150 * lineNum);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetRGBStrokeColor(context, 0, 0, 0, 1);
    
    for (int lineNo = 0; lineNo < lineNum; lineNo++) {
        [self drawBarInLine:lineNo withEditNote:notePos withContext:context];
    }
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
    float barStartY = lineNo * 150 + 15;
    float offsetY = 15;
    
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
    int notePosX = 0, notePosY = 0;
    for (int barNo = startBarNo; barNo < startBarNo + lineBarNum; barNo++) {
        
        // 小节开始X坐标设置
        notePosX = barStartX + [barWidthArr[barNo - startBarNo] floatValue];
        
        NSArray *notesArray = [guitarNotes valueForKey:@"GuitarNotes"][barNo];
        for (int noteNo = 0; noteNo < notesArray.count; noteNo++) {
            NSArray *notes = notesArray[noteNo];
            NSDictionary *firstNote = notes[0];
            NSString *noteType = [firstNote valueForKey:@"NoteType"];
            
            // 设定音符X坐标
            if ([noteType isEqualToString:@"2"]) {
                notePosX += [[noteSizeDic valueForKey:@"minimWidth"] floatValue];
            } else if ([noteType isEqualToString:@"4"]) {
                notePosX += [[noteSizeDic valueForKey:@"crotchetaWidth"] floatValue];
            } else if ([noteType isEqualToString:@"8"]) {
                notePosX += [[noteSizeDic valueForKey:@"quaverWidth"] floatValue];
            } else if ([noteType isEqualToString:@"16"]) {
                notePosX += [[noteSizeDic valueForKey:@"demiquaverWidth"] floatValue];
            }
            
            if (barNo == editBarNo && noteNo == editNoteNo) {
                
                NSString *fretNo = [[notes[0] valueForKey:@"FretNo"]stringValue];
                CGSize noteSize = [MusicUtils calSize:fretNo WithFont:[UIFont systemFontOfSize:12.0]];
                
                CGContextSetRGBFillColor(context, 0, 1, 0, 1);
                notePosY = barStartY + (editStringNo - 1) * 15 - noteSize.height / 2 + 1;
                CGContextFillRect(context, CGRectMake(notePosX - (15 / 2 - noteSize.width / 2) - 0.5, notePosY, 15, 15));
            }
            
            for (int i = 0; i < notes.count; i++) {
                
                NSDictionary *note = [notes objectAtIndex:i];
                int stringNo = [[note valueForKey:@"StringNo"] intValue];
                
                NSString *fretNo = [[note valueForKey:@"FretNo"]stringValue];
                CGSize noteSize = [MusicUtils calSize:fretNo WithFont:[UIFont systemFontOfSize:12.0]];
                
                notePosY = barStartY + (stringNo - 1) * 15 - noteSize.height / 2 + 0.5;
                
                if (barNo != editBarNo || noteNo != editNoteNo || stringNo != editStringNo) {
                    CGContextSetRGBFillColor(context, 1, 1, 1, 1);
                    CGContextFillRect(context, CGRectMake(notePosX, notePosY, noteSize.width, noteSize.height));
                }
                
                CGContextSetRGBStrokeColor(context, 0, 0, 0, 1);
                [fretNo drawAtPoint:CGPointMake(notePosX, notePosY) withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:12.0], NSFontAttributeName, [UIColor blackColor], NSForegroundColorAttributeName, nil]];
            }
        }
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
