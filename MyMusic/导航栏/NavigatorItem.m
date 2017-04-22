//
//  NavigatorItem.m
//  MyMusic
//
//  Created by 孔令文 on 2017/4/9.
//  Copyright © 2017年 孔令文. All rights reserved.
//

#import "NavigatorItem.h"

@interface NavigatorItem ()
@property (strong, nonatomic) IBOutlet UIImageView *itemImage;
@property (strong, nonatomic) IBOutlet UILabel *itemName;
@property (strong, nonatomic) IBOutlet UIButton *button;

@end

@implementation NavigatorItem

-(void)awakeFromNib {
    [super awakeFromNib];
}

-(void)setName:(NSString *)itemName {
    [self.itemName setText:itemName];
}

-(void)setImage:(UIImage *)image {
    [self.itemImage setImage:image];
}

- (void)addTarget:(id)target action:(SEL)action {
    [self.button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

-(void)setSelected:(BOOL)boolVal withImage:(UIImage *)image {
    self.itemImage.image = image;
    if (boolVal == YES) {
        
        [self.itemName setTextColor:[UIColor greenColor]];
    } else {
        [self.itemName setTextColor:[UIColor colorWithRed:0xe6 green:0xe6 blue:0xe6 alpha:200]];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
