//
//  SKYLabel.m
//  音乐播放器
//
//  Created by Topsky on 2016/11/1.
//  Copyright © 2016年 Topsky. All rights reserved.
//

#import "SKYLabel.h"

@implementation SKYLabel

-(void)setProgress:(CGFloat)progress {
    
    _progress = progress;
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    [[UIColor greenColor] setFill];
    UIRectFillUsingBlendMode(CGRectMake(0, 0, _progress * rect.size.width, rect.size.height), kCGBlendModeSourceIn);
}

@end
