//
//  myMusicTableViewCell.h
//  MyMusic
//
//  Created by 孔令文 on 2017/4/15.
//  Copyright © 2017年 孔令文. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PresentViewControllerDelegate.h"

@interface MyMusicTableViewCell : UITableViewCell

@property (nonatomic, weak) id<PresentViewControllerDelegate> delegate;

@property (strong, nonatomic) IBOutlet UILabel *lblSongName;
@property (strong, nonatomic) IBOutlet UILabel *lblArtistName;
@property (strong, nonatomic) IBOutlet UIButton *btnShowItemSet;

@end
