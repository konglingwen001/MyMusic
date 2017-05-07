//
//  NotesModel.h
//  MyMusic
//
//  Created by 孔令文 on 2017/4/29.
//  Copyright © 2017年 孔令文. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NotesModel : NSObject

-(instancetype)initWithNotesName:(NSString *)notesName;
-(NSDictionary *)getRootNotes;
-(NSArray *)getBeatNotesWithBarNo:(int)barNo;
-(void)calNotesSize;
-(NSArray *)getNotesSize;

@end
