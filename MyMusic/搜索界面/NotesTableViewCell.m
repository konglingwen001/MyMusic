//
//  NotesTableViewCell.m
//  MyMusic
//
//  Created by 孔令文 on 2017/5/12.
//  Copyright © 2017年 孔令文. All rights reserved.
//

#import "NotesTableViewCell.h"
#import "NotesModel2.h"

@implementation NotesTableViewCell {
    NotesModel2 *notesModel;
    NSDictionary *guitarNotes;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    notesModel = [NotesModel2 sharedInstance];
    guitarNotes = [notesModel getRootNotes];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    // 获取触摸点在当前cell中的坐标
    UITouch *touch = touches.allObjects[0];
    CGPoint point = [touch locationInView:[touch view]];
    
    // 计算触摸点所在的音符位置
    BOOL result = [self calRectFromPoint:point];
    
    // 刷新吉他谱
    if (result == YES && [self.delegate respondsToSelector:@selector(reloadNotesData)]) {
        [self.delegate reloadNotesData];
    }
}

/*!
 * @brief 判断触摸位置是否在吉他谱内
 * @discussion 根据point坐标判断触摸位置是否在吉他谱内
 * @param point 触摸位置坐标
 * @return YES 触摸位置在吉他谱内
 * @return NO 触摸位置不在吉他谱内
 */
-(BOOL)isOutsideOfGuitarNotes:(CGPoint)point {
    
    // 判断X坐标是否在吉他谱内
    if (point.x < 50 || point.x > [UIScreen mainScreen].bounds.size.width - 50) {
        return YES;
    }
    
    // 判断Y坐标是否在吉他谱内
    if (point.y < 7.5) {
        return YES;
    } else if (15 + 75 + 7.5 < point.y) {
        return YES;
    }
    
    return NO;
}

/*!
 * @brief 计算触摸位置所在的音符位置
 * @discussion 根据触摸位置坐标计算所在的音符位置，当当前编辑音符位置改变时，返回YES并刷新吉他谱，否则返回NO，不刷新吉他谱
 * @param point 触摸位置坐标
 * @return YES 触摸位置在吉他谱内，刷新吉他谱
 * @return NO 触摸位置不在吉他谱内，不用刷新吉他谱
 */
-(BOOL)calRectFromPoint:(CGPoint)point {
    
    NSMutableDictionary *resultDic = [[NSMutableDictionary alloc] init];
    
    int barStartX = 50;     // 小节行起始X坐标
    int barStartY = 15;     // 小节行起始Y坐标
    
    // 当点击位置在吉他谱外面时，不改变编辑框位置
    if ([self isOutsideOfGuitarNotes:point]) {
        return NO;
    }
    
    NSDictionary *lineSizeDic = [notesModel getNotesSize][_lineNo];
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
    
    NSMutableArray *noteNoArray = [notesModel getNoteNoArrayWithBarNo:barNo];
    for (int noteNo = 0; noteNo < noteNoArray.count; noteNo++) {
        NSDictionary *note = noteNoArray[noteNo][0];
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
            if (noteNo == noteNoArray.count - 1) {
                [resultDic setValue:[NSNumber numberWithInt:barNo] forKey:@"barNo"];
                [resultDic setValue:[NSNumber numberWithInt:noteNo] forKey:@"noteNo"];
                break;
            }
        }
        
    }
    
    // 当音符编辑框位置没有改变时，不刷新吉他谱
    if ([resultDic isEqualToDictionary:[notesModel currentEditNotePos]]) {
        return NO;
    }
    
    // 更新音符编辑框位置，并刷新吉他谱
    [notesModel setCurrentEditNotePos:resultDic];
    return YES;
}



@end
