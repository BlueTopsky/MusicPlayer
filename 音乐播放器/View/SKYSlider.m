//
//  SKYSlider.m
//  音乐播放器
//
//  Created by Topsky on 2016/11/3.
//  Copyright © 2016年 Topsky. All rights reserved.
//

#import "SKYSlider.h"

@implementation SKYSlider

- (CGRect)trackRectForBounds:(CGRect)bounds {
    return CGRectMake(0, 0, bounds.size.width, 3);
}

@end
