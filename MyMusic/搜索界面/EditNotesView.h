//
//  EditNotesView.h
//  MyMusic
//
//  Created by 孔令文 on 2017/5/14.
//  Copyright © 2017年 孔令文. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotesTableViewDelegate.h"

@interface EditNotesView : UIView

@property (strong, nonatomic) id<NotesTableViewDelegate> delegate;

@property (strong, nonatomic) IBOutlet UIButton *btnNum0;
@property (strong, nonatomic) IBOutlet UIButton *btnNum1;
@property (strong, nonatomic) IBOutlet UIButton *btnNum2;
@property (strong, nonatomic) IBOutlet UIButton *btnNum3;
@property (strong, nonatomic) IBOutlet UIButton *btnNum4;
@property (strong, nonatomic) IBOutlet UIButton *btnNum5;
@property (strong, nonatomic) IBOutlet UIButton *btnNum6;
@property (strong, nonatomic) IBOutlet UIButton *btnNum7;
@property (strong, nonatomic) IBOutlet UIButton *btnNum8;
@property (strong, nonatomic) IBOutlet UIButton *btnNum9;
@property (strong, nonatomic) IBOutlet UIButton *btnInsertBar;
@property (strong, nonatomic) IBOutlet UIButton *btnRemoveBar;
@property (strong, nonatomic) IBOutlet UIButton *btnRemoveNote;

+(instancetype)makeView;

@end
