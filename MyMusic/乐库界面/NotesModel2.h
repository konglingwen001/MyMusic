//
//  NotesModel2.h
//  MyMusic
//
//  Created by 孔令文 on 2017/5/9.
//  Copyright © 2017年 孔令文. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NotesModel2 : NSObject

@property (strong, nonatomic) NSMutableDictionary * currentEditNotePos;

+(instancetype)sharedInstance;

-(void)setGuitarNotesWithNotesName:(NSString *)notesName;
-(NSMutableDictionary *)getRootNotes;
-(void)calNotesSize;
-(NSMutableArray *)getBarNoArray;
-(NSMutableArray *)getNoteNoArrayWithBarNo:(int)barNo;

-(NSMutableArray *)getNotesArrayWithBarNo:(int)barNo andNoteNo:(int)noteNo;

-(NSMutableDictionary *)getNoteWithBarNo:(int)barNo andNoteNo:(int)noteNo andStringNo:(int)stringNo;

-(NSArray *)getNotesSize;
-(void)insertBarAfterBarNo:(int)barNo;

-(void)setNoteFret:(int)fretNo;

@end
