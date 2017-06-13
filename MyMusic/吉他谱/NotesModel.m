//
//  NotesModel.m
//  MyMusic
//
//  Created by 孔令文 on 2017/5/9.
//  Copyright © 2017年 孔令文. All rights reserved.
//

#import "NotesModel.h"

@implementation NotesModel {
    NSMutableDictionary *rootNoteDic;
    NSMutableArray *notesSizeArray;
    
    NSFileManager *fileManager;
    NSString *documentPath;
    NSString *tmpPath;
}

static const int minimWidth = 15 * 1.5 * 1.5 * 1.5;
static const int crotchetaWidth = 15 * 1.5 * 1.5;
static const int quaverWidth = 15 * 1.5;
static const int demiquaverWidth = 15;

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
        
        _currentEditNotePos = [[NSMutableDictionary alloc] init];
        [_currentEditNotePos setValue:@0 forKey:@"barNo"];
        [_currentEditNotePos setValue:@0 forKey:@"noteNo"];
        [_currentEditNotePos setValue:@1 forKey:@"stringNo"];
        
        fileManager = [NSFileManager defaultManager];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        documentPath = [paths[0] stringByAppendingString:@"/"];
        tmpPath = NSTemporaryDirectory();
        
    });
    return _instance;
}

-(id)copy {
    return _instance;
}

-(id)mutableCopy {
    return _instance;
}

/*!
 * @brief 根据吉他谱名设定吉他谱根节点信息
 * @discussion 初始化本类时，根据吉他谱名notesName设定吉他谱根节点信息
 * @param notesTitle 吉他谱标题
 */
-(void)setGuitarNotesWithNotesTitle:(NSString *)notesTitle {
    rootNoteDic = [self getGuitarNotesFromGuitarNotesTitle:notesTitle];
    notesSizeArray = [[NSMutableArray alloc] init];
    [self calNotesSize];
}

/*!
 * @brief 获取吉他谱根节点信息
 * @discussion 获取吉他谱根节点信息
 * @return 吉他谱根节点信息
 */
-(NSMutableDictionary *)getRootNotes {
    return rootNoteDic;
}

/*!
 * @brief 获取所有小节
 * @discussion 获取所有小节
 * @return 所有小节信息
 */
-(NSMutableArray *)getBarNoArray {
    return [[self getRootNotes] valueForKey:@"GuitarNotes"];
}

/*!
 * @brief 获取指定小节
 * @discussion 根据barNo获取指定小节
 * @param barNo 小节序号
 * @return 小节信息
 */
-(NSMutableArray *)getNoteNoArrayWithBarNo:(int)barNo {
    return [self getBarNoArray][barNo];
}

/*!
 * @brief 获取指定音符序号的一组音符
 * @discussion 根据barNo，noteNo获取指定位置的一组音符
 * @param barNo 小节序号
 * @param noteNo 音符序号
 * @return 音符数组
 */
-(NSMutableDictionary *)getNotesArrayWithBarNo:(int)barNo andNoteNo:(int)noteNo {
    return [self getNoteNoArrayWithBarNo:barNo][noteNo];
}

/*!
 * @brief 获取指定音符序号的音符种类
 * @discussion 根据barNo，noteNo获取指定位置的音符种类
 * @param barNo 小节序号
 * @param noteNo 音符序号
 * @return 音符种类
 */
-(NSString *)getNoteTypeWithBarNo:(int)barNo andNoteNo:(int)noteNo {
    NSMutableDictionary *notesDic = [self getNotesArrayWithBarNo:barNo andNoteNo:noteNo];
    NSString *noteType = [notesDic valueForKey:@"NoteType"];
    return noteType;
}

/*!
 * @brief 获取指定位置的单个音符
 * @discussion 根据barNo，noteNo和stringNo获取指定位置的单个音符
 * @param barNo 小节序号
 * @param noteNo 音符序号
 * @param stringNo 吉他弦序号
 * @return 音符信息
 */
-(NSMutableDictionary *)getNoteWithBarNo:(int)barNo andNoteNo:(int)noteNo andStringNo:(int)stringNo {
    NSMutableDictionary *notesDic = [self getNotesArrayWithBarNo:barNo andNoteNo:noteNo];
    NSMutableArray *notes = [notesDic valueForKey:@"noteArray"];
    for (NSMutableDictionary *noteDic in notes) {
        if ([[noteDic valueForKey:@"StringNo"] isEqualToNumber:[NSNumber numberWithInt:stringNo]]) {
            return noteDic;
        }
    }
    return nil;
}

-(NSArray *)getNotesSize {
    return notesSizeArray;
}

/*!
 * @brief 插入小节
 * @discussion 在指定序号的小节后插入新的小节，新插入的小节自带一个空白音符
 * @param barNo 小节序号
 */
-(void)insertBarAfterBarNo:(int)barNo {
    NSMutableArray *barNoArray = [self getBarNoArray];
    [barNoArray insertObject:[[NSMutableArray alloc] init] atIndex:barNo + 1];
    [self insertBlankNoteAtBarNo:barNo + 1];
    [self calNotesSize];
}

/*!
 * @brief 删除小节
 * @discussion 删除音符编辑框所在位置的小节
 */
-(void)removeBar {
    int barNo = [[self.currentEditNotePos valueForKey:@"barNo"] intValue];
    NSMutableArray *barNoArray = [self getBarNoArray];
    
    if (barNo == barNoArray.count - 1) {
        [self.currentEditNotePos setValue:[NSNumber numberWithInt:barNo - 1] forKey:@"barNo"];
        [self.currentEditNotePos setValue:[NSNumber numberWithInt:0] forKey:@"noteNo"];
        [self.currentEditNotePos setValue:[NSNumber numberWithInt:1] forKey:@"stringNo"];
    }
    
    [barNoArray removeObjectAtIndex:barNo];
    [self calNotesSize];
}

/*!
 * @brief 插入空白占位音符
 * @discussion 在小节最后插入空白的占位音符
 * @param barNo 小节序号
 */
-(void)insertBlankNoteAtBarNo:(int)barNo {
    NSMutableArray *noteNoArray = [self getNoteNoArrayWithBarNo:barNo];
    
    NSMutableDictionary *notesDic = [[NSMutableDictionary alloc] init];
    
    NSMutableArray *notes = [[NSMutableArray alloc] init];
    NSMutableDictionary *note = [[NSMutableDictionary alloc] init];
    [note setValue:[NSNumber numberWithInt:-1] forKey:@"StringNo"];
    [note setValue:[NSNumber numberWithInt:-1] forKey:@"FretNo"];
    [note setValue:@"Normal" forKey:@"PlayType"];
    [notes addObject:note];
    
    [notesDic setValue:@"4" forKey:@"NoteType"];
    [notesDic setValue:notes forKey:@"noteArray"];
    
    [noteNoArray addObject:notesDic];
}

-(void)test {
    
//    NSMutableArray *barNoArray = [self getBarNoArray];
//    NSMutableArray *newBarNoArray = [[NSMutableArray alloc] init];
//    for (NSArray *noteNoArray in barNoArray) {
//        
//        NSMutableArray *newNoteNoArray = [[NSMutableArray alloc] init];
//        
//        for (NSArray *noteArray in noteNoArray) {
//            NSMutableDictionary *newNotesDic = [[NSMutableDictionary alloc] init];
//            NSString *noteType = [noteArray[0] valueForKey:@"NoteType"];
//            for (NSMutableDictionary *note in noteArray) {
//                [note removeObjectForKey:@"NoteType"];
//            }
//            [newNotesDic setValue:noteType forKey:@"NoteType"];
//            [newNotesDic setValue:noteArray forKey:@"noteArray"];
//            [newNoteNoArray addObject:newNotesDic];
//        }
//        [newBarNoArray addObject:newNoteNoArray];
//    }
//    
//    NSMutableDictionary *newRootDic = [[NSMutableDictionary alloc] init];
//    [newRootDic setValue:[NSNumber numberWithInt:52] forKey:@"BarNum"];
//    [newRootDic setValue:@"1" forKey:@"Flat"];
//    [newRootDic setValue:@"1" forKey:@"Time"];
//    [newRootDic setValue:newBarNoArray forKey:@"GuitarNotes"];

//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *path = [paths objectAtIndex:0];
//    NSString *newPath = [path stringByAppendingPathComponent:@"test.plist"];
//
//    //NSString *path = @"/Users/konglingwen/Downloads/test.plist";
//    BOOL result = [rootNoteDic writeToFile:newPath atomically:YES];
//    NSLog(@"%@", newPath);
    
    NSArray *barNoArray = [self getBarNoArray];
    for (int barNo = 0; barNo < barNoArray.count; barNo++) {
        NSArray *noteNoArray = barNoArray[barNo];
        for (int noteNo = 0; noteNo < noteNoArray.count; noteNo++) {
            NSDictionary *noteNoDic = noteNoArray[noteNo];
            NSArray *notes = [noteNoDic valueForKey:@"noteArray"];
            for (NSDictionary *note in notes) {
                int stringNo = [[note valueForKey:@"StringNo"] intValue];
                if (stringNo < 1 || stringNo > 6) {
                    NSLog(@"barNo=%d, noteNo=%d", barNo, noteNo);
                }
            }
        }
        
    }
}

/*!
 * @brief 计算吉他谱相关尺寸
 * @discussion 遍历所有小节，用最小音符尺寸计算小节宽度，累加小节宽度，当累加的小节宽度大于吉他谱宽度时，丢弃最后一小节，将剩余的小节作为当前行显示，并重新计算音符宽度和小节宽度
 */
-(void)calNotesSize {
    
    int minimNum = 0;           // 单个小节二分音符个数
    int crotchetaNum = 0;       // 单个小节四分音符个数
    int quaverNum = 0;          // 单个小节八分音符个数
    int demiquaverNum = 0;      // 单个小节十六分音符个数
    
    int minimSum = 0;           // 整行二分音符总数
    int crotchetaSum = 0;       // 整行四分音符总数
    int quaverSum = 0;          // 整行八分音符总数
    int demiquaverSum = 0;      // 整行十六分音符总数
    
    float currentMinimWidth = 0;
    float currentCrotchetaWidth = 0;
    float currentQuaverWidth = 0;
    float currentDemiquaverWidth = 0;
    float guitarNotesWidth = [UIScreen mainScreen].bounds.size.width - 100;
    
    int startBarNo = 0;         // 每行第一小节的barNo
    float lineBarWidth = 0;     // 行所有小节总宽度
    NSArray *barNoArray = [self getBarNoArray];
    [notesSizeArray removeAllObjects];
    for (int barNo = 0; barNo < barNoArray.count; barNo++) {
        NSDictionary *sizeDic = [self calBarSizeWithNoteNoArray:barNoArray[barNo] withDemiquaverWidth:demiquaverWidth withQuaverWidth:quaverWidth withCrotchetaWidth:crotchetaWidth withMinimWidth:minimWidth];
        
        minimNum = [[sizeDic valueForKey:@"minimNum"] intValue];
        crotchetaNum = [[sizeDic valueForKey:@"crotchetaNum"] intValue];
        quaverNum = [[sizeDic valueForKey:@"quaverNum"] intValue];
        demiquaverNum = [[sizeDic valueForKey:@"demiquaverNum"] intValue];
        
        // 计算小节宽度总和
        lineBarWidth += [[sizeDic valueForKey:@"barWidth"] floatValue];
            
        // 当前行所有小节宽度总和小于吉他谱宽度时，累加音符数
        if (lineBarWidth < guitarNotesWidth) {
            minimSum += minimNum;
            crotchetaSum += crotchetaNum;
            quaverSum += quaverNum;
            demiquaverSum += demiquaverNum;
        } else {
            NSMutableDictionary *lineDic = [[NSMutableDictionary alloc] init];
            [lineDic setValue:[NSNumber numberWithInt:startBarNo] forKey:@"startBarNo"];
            [lineDic setValue:[NSNumber numberWithInteger:barNo - startBarNo] forKey:@"barNum"];
            
            // 音符个数减去最后要丢弃的一小节的音符数，重新计算音符宽度
            currentDemiquaverWidth = guitarNotesWidth / (demiquaverSum + quaverSum * 1.5 + crotchetaSum * 1.5 * 1.5 + minimSum * 1.5 * 1.5 * 1.5);
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
                NSDictionary *resultDic = [self calBarSizeWithNoteNoArray:barNoArray[i] withDemiquaverWidth:currentDemiquaverWidth withQuaverWidth:currentQuaverWidth withCrotchetaWidth:currentCrotchetaWidth withMinimWidth:currentMinimWidth];
                lineBarWidth += [[resultDic valueForKey:@"barWidth"] floatValue];
                [barWidthArray addObject:[NSNumber numberWithFloat:lineBarWidth]];
            }
            [barWidthArray addObject:[NSNumber numberWithFloat:guitarNotesWidth]];
            [lineDic setValue:[barWidthArray copy] forKey:@"barWidthArray"];
            [notesSizeArray addObject:lineDic];
            
            // 重置参数
            // 下一行小节开始序号，设置为丢弃的小节序号
            // 小节序号减一，从丢弃的小节序号重新开始计算
            startBarNo = barNo--;
            
            // 行所有小节宽度初始值设置为丢弃小节的宽度
            lineBarWidth = 0;
            minimSum = 0;
            crotchetaSum = 0;
            quaverSum = 0;
            demiquaverSum = 0;
            
        }
        
        
    }
    
    // 最后一行，以最小音符长度计算尺寸
    
    // 计算行小节宽度
    NSMutableArray *barWidthArray = [[NSMutableArray alloc] init];
    lineBarWidth = 0;
    [barWidthArray addObject:@0];
    for (int i = startBarNo; i < barNoArray.count; i++) {
        NSDictionary *resultDic = [self calBarSizeWithNoteNoArray:barNoArray[i] withDemiquaverWidth:demiquaverWidth withQuaverWidth:quaverWidth withCrotchetaWidth:crotchetaWidth withMinimWidth:minimWidth];
        lineBarWidth += [[resultDic valueForKey:@"barWidth"] floatValue];
        [barWidthArray addObject:[NSNumber numberWithFloat:lineBarWidth]];
    }
    
    // 保存
    NSMutableDictionary *lineDic = [[NSMutableDictionary alloc] init];
    [lineDic setValue:[NSNumber numberWithInt:startBarNo] forKey:@"startBarNo"];
    [lineDic setValue:[NSNumber numberWithLong:barNoArray.count - startBarNo] forKey:@"barNum"];
    [lineDic setValue:[NSNumber numberWithFloat:demiquaverWidth] forKey:@"demiquaverWidth"];
    [lineDic setValue:[NSNumber numberWithFloat:quaverWidth] forKey:@"quaverWidth"];
    [lineDic setValue:[NSNumber numberWithFloat:crotchetaWidth] forKey:@"crotchetaWidth"];
    [lineDic setValue:[NSNumber numberWithFloat:minimWidth] forKey:@"minimWidth"];
    [lineDic setValue:[barWidthArray copy] forKey:@"barWidthArray"];
    [notesSizeArray addObject:lineDic];
    
}

/*!
 * @brief 计算小节相关尺寸
 * @return 尺寸字典，包括小节宽度，二分音符个数，四分音符个数，八分音符个数，十六分音符个数（包括小节结束最后音符的宽度）
 * @param noteNoArray 音符数据
 * @param currentDemiquaverWidth 十六分音符宽度
 * @param currentQuaverWidth 八分音符宽度
 * @param currentCrotchetaWidth 四分音符宽度
 * @param currentMinimWidth 二分音符宽度
 */
-(NSDictionary *)calBarSizeWithNoteNoArray:(NSArray *)noteNoArray withDemiquaverWidth:(float)currentDemiquaverWidth withQuaverWidth:(float)currentQuaverWidth withCrotchetaWidth:(float)currentCrotchetaWidth withMinimWidth:(float)currentMinimWidth {
    // 当前小节宽度初始化
    float barWidth = 0;
    
    // 音符个数初始化
    int minimNum = 0;
    int crotchetaNum = 0;
    int quaverNum = 0;
    int demiquaverNum = 0;
    
    // 统计音符总数
    NSString *noteType = @"";//[notesDic valueForKey:@"NoteType"];
    for (int noteNo = 0; noteNo < noteNoArray.count; noteNo++) {
        noteType = [noteNoArray[noteNo] valueForKey:@"NoteType"];
        if ([noteType isEqualToString:@"2"]) {
            minimNum++;
        } else if ([noteType isEqualToString:@"4"]) {
            crotchetaNum++;
        } else if ([noteType isEqualToString:@"8"]) {
            quaverNum++;
        } else if ([noteType isEqualToString:@"16"]) {
            demiquaverNum++;
        }
    }
    
    // 最后一个音符宽度
    if ([noteType isEqualToString:@"2"]) {
        minimNum++;
    } else if ([noteType isEqualToString:@"4"]) {
        crotchetaNum++;
    } else if ([noteType isEqualToString:@"8"]) {
        quaverNum++;
    } else if ([noteType isEqualToString:@"16"]) {
        demiquaverNum++;
    }
    
    // 计算小节宽度总和
    barWidth = minimNum * currentMinimWidth + crotchetaNum * currentCrotchetaWidth + quaverNum * currentQuaverWidth + demiquaverNum * currentDemiquaverWidth;
    
    // 保存结果并返回
    NSMutableDictionary *resultDic = [[NSMutableDictionary alloc] init];
    [resultDic setValue:[NSNumber numberWithFloat:barWidth] forKey:@"barWidth"];
    [resultDic setValue:[NSNumber numberWithInteger:minimNum] forKey:@"mininNum"];
    [resultDic setValue:[NSNumber numberWithInteger:crotchetaNum] forKey:@"crotchetaNum"];
    [resultDic setValue:[NSNumber numberWithInteger:quaverNum] forKey:@"quaverNum"];
    [resultDic setValue:[NSNumber numberWithInteger:demiquaverNum] forKey:@"demiquaverNum"];
    
    return resultDic;
}

/*!
 * @brief 变更吉他音符
 * @discussion 变更音符编辑框指定位置的音符
 * @param fretNo 吉他品编号（音符）
 */
-(void)setNoteFret:(int)fretNo {
    
    // 获取音符编辑框所在的位置，包括小节序号、音符序号、吉他弦号
    int barNo = [[self.currentEditNotePos valueForKey:@"barNo"] intValue];
    int noteNo = [[self.currentEditNotePos valueForKey:@"noteNo"] intValue];
    int stringNo = [[self.currentEditNotePos valueForKey:@"stringNo"] intValue];
    
    // -------------------------------------------------------------------------------------------------------START
    // 修改音符前判断，如果所修改的音符位置该小节最后一个音符位置，并且该小节音符不满时，在该小节最后添加一个空占位音符，用于选中编辑
    
    NSArray *noteNoArray = [self getNoteNoArrayWithBarNo:barNo];
    
    // 判断小节音符是否正确与完全
    BOOL barIsCorrect = [self checkBarStateAtBarNo:barNo];
    
    if (noteNo == noteNoArray.count - 1 && barIsCorrect == NO) {
        // 在小节末尾添加占位空音符
        [self insertBlankNoteAtBarNo:barNo];
        
        // 重新计算吉他谱尺寸
        [self calNotesSize];
    }
    
    // -------------------------------------------------------------------------------------------------------END
    
    // -------------------------------------------------------------------------------------------------------START
    // 修改音符
    
    NSMutableArray *notesArray = [[self getNotesArrayWithBarNo:barNo andNoteNo:noteNo] valueForKey:@"noteArray"];
    NSMutableDictionary *editNote = [self getNoteWithBarNo:barNo andNoteNo:noteNo andStringNo:stringNo];
    if (editNote == nil) {  // 当音符编辑框所在位置没有音符时，添加新的音符
        
        NSMutableDictionary *mutableEditNote = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:stringNo], @"StringNo", [NSNumber numberWithInt:fretNo], @"FretNo", [notesArray[0] valueForKey:@"PlayType"], @"PlayType", nil];
        [notesArray addObject:mutableEditNote];
        //[self addNote:mutableEditNote atBarNo:barNo andNoteNo:noteNo];
        
    } else {    // 当音符编辑框所在位置有音符时，修改原有音符
        
        int oldFretNo = [[editNote valueForKey:@"FretNo"] intValue];
        // 当原有音符为1或2时，将原有音符乘以10再加上输入音符，结果作为新的音符
        if (oldFretNo == 1 || oldFretNo == 2) {
            fretNo = oldFretNo * 10 + fretNo;
        }
        [editNote setValue:[NSNumber numberWithInt:fretNo] forKey:@"FretNo"];
        
    }
    
    // 如果修改位置存在空白占位音符，则删除空白占位音符
    [self removeBlankNote];
    
    // -------------------------------------------------------------------------------------------------------END
    
}

/*!
 * @brief 删除指定位置的音符
 * @discussion 通过barNo、noteNo和stringNo删除指定位置的音符
 */
-(void)removeEditNote {
    
    // 获取音符编辑框所在的位置，包括小节序号、音符序号、吉他弦号
    int barNo = [[self.currentEditNotePos valueForKey:@"barNo"] intValue];
    int noteNo = [[self.currentEditNotePos valueForKey:@"noteNo"] intValue];
    int stringNo = [[self.currentEditNotePos valueForKey:@"stringNo"] intValue];
    
    int tmpStringNo = 0;
    NSMutableArray *notesArray = [[self getNotesArrayWithBarNo:barNo andNoteNo:noteNo] valueForKey:@"noteArray"];
    
    // 删除音符
    for (NSDictionary *note in notesArray) {
        tmpStringNo = [[note valueForKey:@"StringNo"] intValue];
        if (tmpStringNo == stringNo) {
            [notesArray removeObject:note];
            break;
        }
    }
    
    // 当删除音符后，该位置音符总数为0时，删除该音符序号
    if (notesArray.count == 0) {
        [[self getNoteNoArrayWithBarNo:barNo] removeObjectAtIndex:noteNo];
    }
    
    // 重新计算吉他谱尺寸
    [self calNotesSize];
    
}

/*!
 * @brief 删除空白占位音符
 * @discussion 通过barNo、noteNo删除空白占位音符
 */
-(void)removeBlankNote {
    // 获取音符编辑框所在的位置，包括小节序号、音符序号、吉他弦号
    int barNo = [[self.currentEditNotePos valueForKey:@"barNo"] intValue];
    int noteNo = [[self.currentEditNotePos valueForKey:@"noteNo"] intValue];
    
    NSMutableArray *notesArray = [[self getNotesArrayWithBarNo:barNo andNoteNo:noteNo] valueForKey:@"noteArray"];
    NSDictionary *note = notesArray[0];
    int tmpFretNo = [[note valueForKey:@"FretNo"] intValue];
    int tmpStringNo = [[note valueForKey:@"StringNo"] intValue];
    if (tmpFretNo == -1 && tmpStringNo == -1) {
        [notesArray removeObject:note];
    }
}

/*!
 * @brief 检查小节是否正确和完整
 * @discussion 检查小节音符是否满足节拍数和时间长度，判定方法：小节所有音符的音符种类倒数和相加等于一，则正确且完整，否则错误
 * @param barNo 小节序号
 * @return YES 小节音符正确且完整 NO 小节音符不正确或不完整
 */
-(BOOL)checkBarStateAtBarNo:(int)barNo {
    float noteType = 0;
    float noteTypeSum = 0;
    NSMutableArray *noteNoArray = [self getNoteNoArrayWithBarNo:barNo];
    for (int noteNo = 0; noteNo < noteNoArray.count; noteNo++) {
        noteType = [[self getNoteTypeWithBarNo:barNo andNoteNo:noteNo] floatValue];
        noteTypeSum += 1.0f / noteType;
    }
    
    return (noteTypeSum == 1);
}

-(void)addNote:(NSDictionary *)editNote atBarNo:(int)barNo andNoteNo:(int)noteNo {
    NSMutableDictionary *tmpRootDic = [[NSMutableDictionary alloc] init];
    [tmpRootDic setValue:[rootNoteDic valueForKey:@"BarNum"] forKey:@"BarNum"];
    [tmpRootDic setValue:[rootNoteDic valueForKey:@"Flat"] forKey:@"Flat"];
    [tmpRootDic setValue:[rootNoteDic valueForKey:@"Time"] forKey:@"Time"];
    NSMutableArray *tmpBarNoArray = [[NSMutableArray alloc] init];
    
    NSArray *barNoArray = [rootNoteDic valueForKey:@"GuitarNotes"];
    for (int tmpBarNo = 0; tmpBarNo < barNoArray.count; tmpBarNo++) {
        NSArray *noteNoArray = barNoArray[tmpBarNo];
        if (tmpBarNo == barNo) {
            NSMutableArray *tmpNoteNoArray = [[NSMutableArray alloc] init];
            for (int tmpNoteNo = 0; tmpNoteNo < noteNoArray.count; tmpNoteNo++) {
                NSArray *notesArray = noteNoArray[tmpNoteNo];
                if (tmpNoteNo == noteNo) {
                    NSMutableArray *tmpNotesArray = [notesArray mutableCopy];
                    [tmpNotesArray addObject:editNote];
                    [tmpNoteNoArray addObject:tmpNotesArray];
                } else {
                    [tmpNoteNoArray addObject:notesArray];
                }
            }
            [tmpBarNoArray addObject:tmpNoteNoArray];
        } else {
            [tmpBarNoArray addObject:noteNoArray];
        }
    }
    [tmpRootDic setValue:tmpBarNoArray forKey:@"GuitarNotes"];
    rootNoteDic = tmpRootDic;
    
}


/**
 将文件从from复制到to

 @param from 源文件路径
 @param to 目的文件路径
 */
-(void)copyFileFrom:(NSString *)from To:(NSString *)to {
    [fileManager copyItemAtPath:from toPath:to error:nil];
}


/**
 通过吉他谱名获取temp路径下的文件

 @param guitarNotesTitle 吉他谱名
 @return 吉他谱数据
 */
-(NSMutableDictionary *)getGuitarNotesFromGuitarNotesTitle:(NSString *)guitarNotesTitle {
    NSString *path = NSTemporaryDirectory();
    NSString *plistPath = [[path stringByAppendingString:guitarNotesTitle] stringByAppendingString:@".plist"];
    //NSLog(@"%@", plistPath);
    NSMutableDictionary *rootDic = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    return rootDic;
}


/**
 将吉他谱数据保存到temp路径下

 @param rootDic 吉他谱数据
 @param guitarNotesTitle 吉他谱名
 @return 保存成功YES 保存失败NO
 */
-(BOOL)writeToTmpDirectory:(NSMutableDictionary *)rootDic withGuitarNotesTitle:(NSString *)guitarNotesTitle {
    NSString *file = [[tmpPath stringByAppendingString:guitarNotesTitle] stringByAppendingString:@".plist"];
    BOOL result = [rootDic writeToFile:file atomically:YES];
    return result;
}


/**
 保存吉他谱到document路径下
 */
-(void)save {
    NSString *fileName = [[rootNoteDic valueForKey:@"GuitarNotesName"] stringByAppendingString:@".plist"];
    NSString *filePath = [documentPath stringByAppendingString:fileName];
    NSString *tmpFilePath = [tmpPath stringByAppendingString:fileName];
    [fileManager removeItemAtPath:tmpFilePath error:nil];
    [rootNoteDic writeToFile:filePath atomically:YES];
}

@end
