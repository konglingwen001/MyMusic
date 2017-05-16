//
//  MyGuitarNotesView2.h
//  MyMusic
//
//  Created by 孔令文 on 2017/5/9.
//  Copyright © 2017年 孔令文. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyGuitarNotesView2 : UIScrollView<UIScrollViewDelegate>

-(instancetype)initWithNotes:(NSDictionary *)notesDic;

@end
