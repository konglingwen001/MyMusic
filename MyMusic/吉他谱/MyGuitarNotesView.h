//
//  MyGuitarNotesView.h
//  MyMusic
//
//  Created by 孔令文 on 2017/4/30.
//  Copyright © 2017年 孔令文. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyGuitarNotesView : UIScrollView<UIScrollViewDelegate>

-(instancetype)initWithNotes:(NSDictionary *)notesDic;

@end
