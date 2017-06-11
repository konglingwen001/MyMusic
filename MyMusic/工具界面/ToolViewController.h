//
//  ToolView.h
//  MyMusic
//
//  Created by 孔令文 on 2017/4/10.
//  Copyright © 2017年 孔令文. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYSampler.h"

@interface ToolViewController : UIViewController<UIScrollViewDelegate>

@property (nonatomic, retain) YYSampler *sampler;

@end
