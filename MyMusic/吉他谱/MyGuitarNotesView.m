//
//  MyGuitarNotesView.m
//  MyMusic
//
//  Created by 孔令文 on 2017/4/30.
//  Copyright © 2017年 孔令文. All rights reserved.
//

#import "MyGuitarNotesView.h"
#import "MusicUtils.h"
#import "NotesModel.h"

@implementation MyGuitarNotesView {
    NotesModel *notesModel;
    MusicUtils *musicUtils;
    NSDictionary *guitarNotes;
    int barNum;
    UIImageView *imageView;
    UIImage *notesImage;
}

-(instancetype)initWithNotes:(NSDictionary *)notesDic {
    if (self = [super init]) {
        notesModel = [[NotesModel alloc] initWithNotesName:@"天空之城"];
        guitarNotes = notesDic;
        barNum = [[guitarNotes valueForKey:@"BarNum"] intValue];
        self.delegate = self;
        
        [self setFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 100)];
        [self setBackgroundColor:[UIColor whiteColor]];
        notesImage = [self drawImageAtImageContext];
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
    
    CGSize size = CGSizeMake([UIScreen mainScreen].bounds.size.width, 150 * (barNum / 4 + 1));
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    [notesImage drawInRect:CGRectMake(0, 0, notesImage.size.width, notesImage.size.height)];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(context, 0, 1, 1, 1);
    CGContextFillRect(context, [self calRectFromPoint:point]);
    CGContextStrokePath(context);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    imageView.image = newImage;
    UIGraphicsEndImageContext();
}

-(CGRect)calRectFromPoint:(CGPoint)point {
    int rowNo = (point.y - 15) / 150;
    int colNo = (point.x - 50) / 150;
    
    if (150 * rowNo + 15 + 75 + 7.5 < point.y) {
        return CGRectZero;
    }
    
    int barNo = rowNo * 4 + colNo;
    int startX, startY;
    float barStartX = 50 + colNo * 150;
    float barStartY = 15 + rowNo * 150;
    
    int stringNo = (point.y + 7.5) / 15;
    startY = stringNo * 15 - 7.5;
    startX = point.x;
    return CGRectMake(startX, startY, 15, 15);
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"scroll");
}

/*!
 * @brief 描画吉他谱
 * @discussion 在内存图片中描画吉他谱，返回画好的图片
 */
-(UIImage *)drawImageAtImageContext {
    
    int lineNum = (int)[notesModel getNotesSize].count;
    CGSize size = CGSizeMake([UIScreen mainScreen].bounds.size.width, 150 * lineNum);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetRGBStrokeColor(context, 0, 0, 0, 1);
    
    
    for (int lineNo = 0; lineNo < lineNum; lineNo++) {
        [self drawBarInLine:lineNo withContext:context];
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
- (void)drawBarInLine:(int)lineNo withContext:(CGContextRef)context {
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
    NSArray *barWidthArr = [noteSizeDic valueForKey:@"barWidth"];
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
        
        NSArray *beatNotes = [notesModel getBeatNotesWithBarNo:barNo];
        for (int beatNo = 0; beatNo < beatNotes.count; beatNo++) {
            NSDictionary *beatDic = [beatNotes objectAtIndex:beatNo];
            NSArray *noteNoArr = [beatDic objectForKey:@"NoteNo"];
            for (int noteNo = 0; noteNo < noteNoArr.count; noteNo++) {
                NSDictionary *notesDic = [noteNoArr objectAtIndex:noteNo];
                NSArray *notes = [notesDic objectForKey:@"Note"];
                NSDictionary *firstNote = [notes objectAtIndex:0];
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
                
                for (int i = 0; i < notes.count; i++) {

                    NSDictionary *note = [notes objectAtIndex:i];
                    int stringNo = [[note valueForKey:@"StringNo"] intValue];
                    
                    NSString *fretNo = [note valueForKey:@"FretNo"];
                    CGSize noteSize = [MusicUtils calSize:fretNo WithFont:[UIFont systemFontOfSize:12.0]];
                    
                    notePosY = barStartY + (stringNo - 1) * 15 - noteSize.height / 2 + 0.5;
                    
                    CGContextSetRGBFillColor(context, 0, 1, 0, 1);
                    CGContextFillRect(context, CGRectMake(notePosX, notePosY, noteSize.width, noteSize.height));
                    
                    CGContextSetRGBStrokeColor(context, 0, 0, 0, 1);
                    [fretNo drawAtPoint:CGPointMake(notePosX, notePosY) withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:12.0], NSFontAttributeName, [UIColor blackColor], NSForegroundColorAttributeName, nil]];
                }
            }
        }
    }
}


@end
