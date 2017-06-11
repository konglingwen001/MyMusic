//
//  EditNotesView.m
//  MyMusic
//
//  Created by 孔令文 on 2017/5/14.
//  Copyright © 2017年 孔令文. All rights reserved.
//

#import "EditNotesView.h"
#import "NotesModel.h"

@interface EditNotesView ()

@property (strong, nonatomic) NotesModel * notesModel;

@end

@implementation EditNotesView

-(NotesModel *)notesModel {
    if (_notesModel == nil) {
        _notesModel = [NotesModel sharedInstance];
    }
    return _notesModel;
}

+(instancetype)makeView {
    return [[[NSBundle mainBundle] loadNibNamed:@"EditNotesView" owner:self options:nil] firstObject];
}

- (IBAction)num0Clicked:(id)sender {
    
    int num = (int)[sender tag];
    
    [self.notesModel setNoteFret:num];
    
    if ([self.delegate respondsToSelector:@selector(reloadNotesData)]) {
        [self.delegate reloadNotesData];
    }
}

- (IBAction)insertBar:(id)sender {
    NSDictionary *notePos = [self.notesModel currentEditNotePos];
    int barNo = [[notePos valueForKey:@"barNo"] intValue];
    [self.notesModel insertBarAfterBarNo:barNo];
    if ([self.delegate respondsToSelector:@selector(reloadNotesData)]) {
        [self.delegate reloadNotesData];
    }
}
- (IBAction)removeNote:(id)sender {
    [self.notesModel removeEditNote];
    if ([self.delegate respondsToSelector:@selector(reloadNotesData)]) {
        [self.delegate reloadNotesData];
    }
}

- (IBAction)removeBar:(id)sender {
    [self.notesModel removeBar];
    if ([self.delegate respondsToSelector:@selector(reloadNotesData)]) {
        [self.delegate reloadNotesData];
    }
}
- (IBAction)testPlay:(id)sender {
    if ([self.delegate respondsToSelector:@selector(testPlay)]) {
        [self.delegate testPlay];
    }
}

- (IBAction)testStop:(id)sender {
    if ([self.delegate respondsToSelector:@selector(testStop)]) {
        [self.delegate testStop];
    }
}
- (IBAction)test:(id)sender {
    [self.notesModel test];
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
