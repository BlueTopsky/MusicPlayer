//
//  LyricTableViewCell.m
//  音乐播放器
//
//  Created by Topsky on 2016/10/28.
//  Copyright © 2016年 Topsky. All rights reserved.
//

#import "LyricTableViewCell.h"
#import <Masonry.h>

@implementation LyricTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)initView{
    self.backgroundColor=[UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.labelMain = [SKYLabel new];
    _labelMain.textAlignment = NSTextAlignmentCenter;
    _labelMain.font = [UIFont systemFontOfSize:15];
    _labelMain.textColor = [UIColor whiteColor];
    [self.contentView addSubview:_labelMain];
    [_labelMain mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
}

@end
