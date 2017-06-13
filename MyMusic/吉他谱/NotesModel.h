//
//  NotesModel.h
//  MyMusic
//
//  Created by 孔令文 on 2017/5/9.
//  Copyright © 2017年 孔令文. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NotesModel : NSObject

@property (strong, nonatomic) NSMutableDictionary * currentEditNotePos;

+(instancetype)sharedInstance;

-(void)setGuitarNotesWithNotesTitle:(NSString *)notesTitle;
-(NSMutableDictionary *)getRootNotes;
-(void)calNotesSize;
-(NSMutableArray *)getBarNoArray;
-(NSMutableArray *)getNoteNoArrayWithBarNo:(int)barNo;

-(NSMutableDictionary *)getNotesArrayWithBarNo:(int)barNo andNoteNo:(int)noteNo;

-(NSMutableDictionary *)getNoteWithBarNo:(int)barNo andNoteNo:(int)noteNo andStringNo:(int)stringNo;
-(NSString *)getNoteTypeWithBarNo:(int)barNo andNoteNo:(int)noteNo;

-(NSArray *)getNotesSize;
-(void)insertBarAfterBarNo:(int)barNo;

-(void)setNoteFret:(int)fretNo;
-(void)removeEditNote;
-(void)removeBar;

-(void)copyFileFrom:(NSString *)from To:(NSString *)to;
-(BOOL)writeToTmpDirectory:(NSMutableDictionary *)rootDic withGuitarNotesTitle:(NSString *)guitarNotesTitle;
-(void)save;

-(void)test;

@end
