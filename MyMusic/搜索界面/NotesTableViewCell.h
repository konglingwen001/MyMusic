//
//  NotesTableViewCell.h
//  MyMusic
//
//  Created by 孔令文 on 2017/5/12.
//  Copyright © 2017年 孔令文. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotesTableViewDelegate.h"


@interface NotesTableViewCell : UITableViewCell

@property (assign, nonatomic) long lineNo;

@property (strong, nonatomic) IBOutlet UIImageView *notesView;

@property (strong, nonatomic) id<NotesTableViewDelegate> delegate;

@end
