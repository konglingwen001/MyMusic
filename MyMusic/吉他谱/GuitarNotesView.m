//
//  GuitarNotesView.m
//  MyMusic
//
//  Created by 孔令文 on 2017/4/25.
//  Copyright © 2017年 孔令文. All rights reserved.
//

#import "GuitarNotesView.h"

@implementation GuitarNotesView

-(void)addNoteView:(UIView *)noteView withBeatNo:(int)beatNo withNoteNo:(int)noteNo withStringNo:(int)stringNo {
    [noteView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.noteStackView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [noteView setBackgroundColor:[UIColor whiteColor]];
    [self.noteStackView addSubview:noteView];
    
    [noteView addConstraint:[NSLayoutConstraint constraintWithItem:noteView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1 constant:15]];
    [noteView addConstraint:[NSLayoutConstraint constraintWithItem:noteView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:15]];
    
    UIView *chordView;
    switch (stringNo) {
        case 1:
            chordView = self.chord1;
            break;
        case 2:
            chordView = self.chord2;
            break;
        case 3:
            chordView = self.chord3;
            break;
        case 4:
            chordView = self.chord4;
            break;
        case 5:
            chordView = self.chord5;
            break;
        case 6:
            chordView = self.chord6;
            break;
        default:
            chordView = self.chord1;
            break;
    }
    [self.noteStackView addConstraint:[NSLayoutConstraint constraintWithItem:noteView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:chordView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [self.noteStackView addConstraint:[NSLayoutConstraint constraintWithItem:noteView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:chordView attribute:NSLayoutAttributeLeft multiplier:1 constant:(beatNo * 30 + noteNo * 15)]];
    
}

-(void)layoutSubviews {
    CGRect frame = self.frame;
    frame = CGRectMake(100, 100, 300, 150);
    self.frame = frame;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
