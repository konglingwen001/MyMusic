//
//  myMusicTableViewCell.m
//  MyMusic
//
//  Created by 孔令文 on 2017/4/15.
//  Copyright © 2017年 孔令文. All rights reserved.
//

#import "MyMusicTableViewCell.h"
#import "ItemSetTableViewController.h"

@implementation MyMusicTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)showItemSet:(id)sender {
    ItemSetTableViewController *popupItemSet = [[ItemSetTableViewController alloc] init];
    if ([self.delegate respondsToSelector:@selector(presentViewController:fromView:)]) {
        [self.delegate presentViewController:popupItemSet fromView:self.btnShowItemSet];
    }
    
}

@end
