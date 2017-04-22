//
//  PlayListTableViewCell.h
//  MyMusic
//
//  Created by 孔令文 on 2017/4/1.
//  Copyright © 2017年 孔令文. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayListTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *lblMusicName;
@property (strong, nonatomic) IBOutlet UIButton *btnDelete;
@property (strong, nonatomic) IBOutlet UILabel *lblArtistName;
@property (strong, nonatomic) IBOutlet UIView *musicInfoView;

@end
