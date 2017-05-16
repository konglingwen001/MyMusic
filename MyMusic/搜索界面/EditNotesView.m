//
//  EditNotesView.m
//  MyMusic
//
//  Created by 孔令文 on 2017/5/14.
//  Copyright © 2017年 孔令文. All rights reserved.
//

#import "EditNotesView.h"
#import "NotesModel2.h"

@interface EditNotesView ()

@property (strong, nonatomic) NotesModel2 * notesModel;

@end

@implementation EditNotesView

-(NotesModel2 *)notesModel {
    if (_notesModel == nil) {
        _notesModel = [NotesModel2 sharedInstance];
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

- (IBAction)removeBar:(id)sender {
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
