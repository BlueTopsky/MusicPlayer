//
//  SKYLyricView.h
//  音乐播放器
//
//  Created by Topsky on 2016/11/1.
//  Copyright © 2016年 Topsky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKYLyric.h"
@interface SKYLyricView : UIView

@property (nonatomic,strong) NSArray <SKYLyric *>*lyrics;
@property (nonatomic,assign) CGFloat rowHeight;
@property (nonatomic,assign) NSInteger currentLyricIndex;
@property (nonatomic,assign) CGFloat progress;

@end
