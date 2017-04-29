//
//  GuitarNotesView.h
//  MyMusic
//
//  Created by 孔令文 on 2017/4/25.
//  Copyright © 2017年 孔令文. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GuitarNotesView : UIView
@property (strong, nonatomic) IBOutlet UIView *notes;
@property (strong, nonatomic) IBOutlet UIStackView *noteStackView;
@property (strong, nonatomic) IBOutlet UILabel *lblBarNo;
@property (strong, nonatomic) IBOutlet UIView *chord1;
@property (strong, nonatomic) IBOutlet UIView *chord2;
@property (strong, nonatomic) IBOutlet UIView *chord3;
@property (strong, nonatomic) IBOutlet UIView *chord4;
@property (strong, nonatomic) IBOutlet UIView *chord5;
@property (strong, nonatomic) IBOutlet UIView *chord6;

-(void)addNoteView:(UIView *)noteView withBeatNo:(int)beatNo withNoteNo:(int)noteNo withStringNo:(int)stringNo;

@end
