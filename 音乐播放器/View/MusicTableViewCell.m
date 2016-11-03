//
//  MusicTableViewCell.m
//  音乐播放器
//
//  Created by Topsky on 2016/10/27.
//  Copyright © 2016年 Topsky. All rights reserved.
//

#import "MusicTableViewCell.h"
#import <Masonry.h>

@implementation MusicTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)initView{
    self.backgroundColor=[UIColor whiteColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.leftView = [UIView new];
    self.leftView.backgroundColor = [UIColor greenColor];
    self.leftView.hidden = YES;
    [self.contentView addSubview:self.leftView];
    [self.leftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(self.contentView);
        make.width.equalTo(@5);
    }];
    
    self.labelMain = [UILabel new];
    self.labelMain.font = [UIFont systemFontOfSize:15];
    self.labelMain.textColor = [UIColor colorWithRed:125/255.0 green:125/255.0 blue:125/255.0 alpha:1.0];
    [self.contentView addSubview:self.labelMain];
    [self.labelMain mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(@20);
        make.right.equalTo(self.contentView.mas_right).offset(-10);
    }];
    
    UIView *lineView = [UIView new];
    lineView.backgroundColor = [UIColor colorWithRed:225/255.0 green:225/255.0 blue:225/255.0 alpha:1.0];
    [self.contentView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@0.3);
        make.left.right.bottom.equalTo(self.contentView);
    }];
}

@end
