//
//  NotesModel.m
//  MyMusic
//
//  Created by 孔令文 on 2017/4/29.
//  Copyright © 2017年 孔令文. All rights reserved.
//

#import "NotesModel.h"

@implementation NotesModel {
    NSDictionary *rootNoteDic;
    NSMutableArray *notesSizeArray;
}

static const int minimWidth = 15 * 1.5 * 1.5 * 1.5;
static const int crotchetaWidth = 15 * 1.5 * 1.5;
static const int quaverWidth = 15 * 1.5;
static const int demiquaverWidth = 15;

/*!
 * @brief 初始化吉他谱
 * @return 用吉他谱文件名初始化吉他谱
 * @param notesName 吉他谱文件名
 */
-(instancetype)initWithNotesName:(NSString *)notesName {
    if (self = [super init]) {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:notesName ofType:@"plist"];
        rootNoteDic = [NSDictionary dictionaryWithContentsOfFile:plistPath];
        notesSizeArray = [[NSMutableArray alloc] init];
        [self calNotesSize];
    }
    return self;
}

-(NSDictionary *)getRootNotes {
    return rootNoteDic;
}

-(NSArray *)getBeatNotesWithBarNo:(int)barNo {
    return [[[[rootNoteDic valueForKey:@"GuitarNotes"] valueForKey:@"BarNo"] objectAtIndex:barNo] valueForKey:@"BeatNo"];
}

-(NSArray *)getNotesSize {
    return notesSizeArray;
}

/*!
 * @brief 计算吉他谱相关尺寸
 * @discussion 遍历所有小节，用最小音符尺寸计算小节宽度，累加小节宽度，当累加的小节宽度大于吉他谱宽度时，丢弃最后一小节，将剩余的小节作为当前行显示，并重新计算音符宽度和小节宽度
 */
-(void)calNotesSize {
    
    int lineBarWidth = 0;
    
    int minimNum = 0;           // 二分音符个数
    int crotchetaNum = 0;       // 四分音符个数
    int quaverNum = 0;          // 八分音符个数
    int demiquaverNum = 0;      // 十六分音符个数
    
    float currentMinimWidth = 0;
    float currentCrotchetaWidth = 0;
    float currentQuaverWidth = 0;
    float currentDemiquaverWidth = 0;
    float guitarNotesWidth = [UIScreen mainScreen].bounds.size.width - 100;
    
    int startBarNo = 0;         // 每行第一小节的barNo
    NSArray *barNoArray = [[rootNoteDic valueForKey:@"GuitarNotes"] valueForKey:@"BarNo"];
    for (int barNo = 0; barNo < barNoArray.count; barNo++) {
        
        NSDictionary *sizeDic = [self calBarSizeWithBeatsNotes:barNoArray[barNo] withDemiquaverWidth:demiquaverWidth withQuaverWidth:quaverWidth withCrotchetaWidth:crotchetaWidth withMinimWidth:minimWidth];
        
        // 累计改行所有小节宽度
        lineBarWidth += [[sizeDic valueForKey:@"barWidth"] floatValue];
        
        // 累计各音符数
        minimNum += [[sizeDic valueForKey:@"minimNum"] intValue];
        crotchetaNum += [[sizeDic valueForKey:@"crotchetaNum"] intValue];
        quaverNum += [[sizeDic valueForKey:@"quaverNum"] intValue];
        demiquaverNum += [[sizeDic valueForKey:@"demiquaverNum"] intValue];
        
        // 当前行所有小节宽度总和大于吉他谱宽度时，将最后一小节放到下一行，并重新计算各音符宽度
        if (lineBarWidth > guitarNotesWidth || barNo == barNoArray.count - 1) {
            NSMutableDictionary *lineDic = [[NSMutableDictionary alloc] init];
            [lineDic setValue:[NSNumber numberWithInt:startBarNo] forKey:@"startBarNo"];
            [lineDic setValue:[NSNumber numberWithInteger:barNo - startBarNo] forKey:@"barNum"];
            
            // 根据每行能容纳的小节数重新计算音符宽度，保存在字典中
            int lastDemiquaverNum = [[sizeDic valueForKey:@"demiquaverNum"] intValue];
            int lastQuaverNum = [[sizeDic valueForKey:@"quaverNum"] intValue];
            int lastCrotchetaNum = [[sizeDic valueForKey:@"crotchetaNum"] intValue];
            int lastMinimNum = [[sizeDic valueForKey:@"minimNum"] intValue];
            
            // 音符个数减去最后要丢弃的一小节的音符数，重新计算音符宽度
            currentDemiquaverWidth = guitarNotesWidth / ((demiquaverNum - lastDemiquaverNum) + (quaverNum - lastQuaverNum) * 1.5 + (crotchetaNum - lastCrotchetaNum) * 1.5 * 1.5 + (minimNum - lastMinimNum) * 1.5 * 1.5 * 1.5);
            currentQuaverWidth = currentDemiquaverWidth * 1.5;
            currentCrotchetaWidth = currentQuaverWidth * 1.5;
            currentMinimWidth = currentCrotchetaWidth * 1.5;
            [lineDic setValue:[NSNumber numberWithFloat:currentDemiquaverWidth] forKey:@"demiquaverWidth"];
            [lineDic setValue:[NSNumber numberWithFloat:currentQuaverWidth] forKey:@"quaverWidth"];
            [lineDic setValue:[NSNumber numberWithFloat:currentCrotchetaWidth] forKey:@"crotchetaWidth"];
            [lineDic setValue:[NSNumber numberWithFloat:currentMinimWidth] forKey:@"minimWidth"];
            
            // 通过计算得到的音符宽度重新计算小节宽度，保存在数组中
            lineBarWidth = 0;
            NSMutableArray *barWidthArray = [[NSMutableArray alloc] init];
            [barWidthArray addObject:@0];
            for (int i = startBarNo; i < barNo - 1; i++) {
                NSDictionary *resultDic = [self calBarSizeWithBeatsNotes:barNoArray[i] withDemiquaverWidth:currentDemiquaverWidth withQuaverWidth:currentQuaverWidth withCrotchetaWidth:currentCrotchetaWidth withMinimWidth:currentMinimWidth];
                lineBarWidth += [[resultDic valueForKey:@"barWidth"] floatValue];
                [barWidthArray addObject:[NSNumber numberWithFloat:lineBarWidth]];
            }
            [barWidthArray addObject:[NSNumber numberWithFloat:guitarNotesWidth]];
            [lineDic setValue:[barWidthArray copy] forKey:@"barWidth"];
            [notesSizeArray addObject:lineDic];
            
            // 重置参数
            // 下一行小节开始序号，设置为丢弃的小节序号
            // 小节序号减一，从丢弃的小节序号重新开始计算
            if (barNo != barNoArray.count - 1) {
                startBarNo = barNo--;
            }
            
            // 行所有小节宽度初始值设置为丢弃小节的宽度
            lineBarWidth = 0;
            // 临时变量清零
            minimNum = 0;
            crotchetaNum = 0;
            quaverNum = 0;
            demiquaverNum = 0;
        }
    }

}

/*!
 * @brief 计算小节相关尺寸
 * @return 尺寸字典，包括小节宽度，二分音符个数，四分音符个数，八分音符个数，十六分音符个数（包括小节结束最后音符的宽度）
 * @param beatNotes 音符数据
 * @param currentDemiquaverWidth 十六分音符宽度
 * @param currentQuaverWidth 八分音符宽度
 * @param currentCrotchetaWidth 四分音符宽度
 * @param currentMinimWidth 二分音符宽度
 */
-(NSDictionary *)calBarSizeWithBeatsNotes:(NSDictionary *)beatNotes withDemiquaverWidth:(float)currentDemiquaverWidth withQuaverWidth:(float)currentQuaverWidth withCrotchetaWidth:(float)currentCrotchetaWidth withMinimWidth:(float)currentMinimWidth {
    // 当前小节宽度初始化
    float currentBarWidth = 0;
    int currentMinimNum = 0;
    int currentCrotchetaNum = 0;
    int currentQuaverNum = 0;
    int currentDemiquaverNum = 0;
    
    NSString *noteType = @"";
    
    // 计算当前小节宽度（不包括最后一个音符后的宽度）
    NSArray *beatNoArray = [beatNotes valueForKey:@"BeatNo"];
    for (NSDictionary *notesDic in beatNoArray) {
        NSArray *noteNoArr = [notesDic valueForKey:@"NoteNo"];
        for (NSDictionary *notes in noteNoArr) {
            // 统计音符种类个数，并计算每行总宽度
            NSDictionary *note = [[notes valueForKey:@"Note"] objectAtIndex:0];
            noteType = [note valueForKey:@"NoteType"];
            if ([noteType isEqualToString:@"2"]) {
                currentMinimNum++;
                currentBarWidth += currentMinimWidth;
            } else if ([noteType isEqualToString:@"4"]) {
                currentCrotchetaNum++;
                currentBarWidth += currentCrotchetaWidth;
            } else if ([noteType isEqualToString:@"8"]) {
                currentQuaverNum++;
                currentBarWidth += currentQuaverWidth;
            } else if ([noteType isEqualToString:@"16"]) {
                currentDemiquaverNum++;
                currentBarWidth += currentDemiquaverWidth;
            }
        }
    }
    
    // 最后一个音符到小节结束的宽度
    NSArray *noteNoArr = [[beatNoArray objectAtIndex:beatNoArray.count - 1] valueForKey:@"NoteNo"];
    NSDictionary *note = [[[noteNoArr objectAtIndex:noteNoArr.count - 1] valueForKey:@"Note"] objectAtIndex:0];
    noteType = [note valueForKey:@"NoteType"];
    if ([noteType isEqualToString:@"2"]) {
        currentMinimNum++;
        currentBarWidth += currentMinimWidth;
    } else if ([noteType isEqualToString:@"4"]) {
        currentCrotchetaNum++;
        currentBarWidth += currentCrotchetaWidth;
    } else if ([noteType isEqualToString:@"8"]) {
        currentQuaverNum++;
        currentBarWidth += currentQuaverWidth;
    } else if ([noteType isEqualToString:@"16"]) {
        currentDemiquaverNum++;
        currentBarWidth += currentDemiquaverWidth;
    }
    
    // 保存结果并返回
    NSMutableDictionary *resultDic = [[NSMutableDictionary alloc] init];
    [resultDic setValue:[NSNumber numberWithFloat:currentBarWidth] forKey:@"barWidth"];
    [resultDic setValue:[NSNumber numberWithInteger:currentMinimNum] forKey:@"mininNum"];
    [resultDic setValue:[NSNumber numberWithInteger:currentCrotchetaNum] forKey:@"crotchetaNum"];
    [resultDic setValue:[NSNumber numberWithInteger:currentQuaverNum] forKey:@"quaverNum"];
    [resultDic setValue:[NSNumber numberWithInteger:currentDemiquaverNum] forKey:@"demiquaverNum"];
    
    return resultDic;
}

@end
