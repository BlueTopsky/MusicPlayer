//
//  SKYLyricView.m
//  音乐播放器
//
//  Created by Topsky on 2016/11/1.
//  Copyright © 2016年 Topsky. All rights reserved.
//

#import "SKYLyricView.h"
#import <Masonry.h>
#import "SKYLabel.h"
#import "MusicManager.h"

@interface SKYLyricView ()<UIScrollViewDelegate>

@property (nonatomic,weak) UIScrollView *hScrollView;
@property (nonatomic,strong) NSMutableArray *lyricLabels;

@end

@implementation SKYLyricView

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self=[super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self=[super initWithCoder:aDecoder]) {
        [self setupUI];
    }
    return self;
}

-(void)setupUI
{
    self.lyricLabels=[NSMutableArray array];
    UIScrollView *hScrollView=[[UIScrollView alloc]init];
    [self addSubview:hScrollView];
    self.hScrollView=hScrollView;
    
    [hScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    hScrollView.backgroundColor=[UIColor clearColor];
    
    CGFloat screenW=[UIScreen mainScreen].bounds.size.width;
    
    hScrollView.contentSize=CGSizeMake(2*screenW, 0);
    hScrollView.showsHorizontalScrollIndicator=NO;
    hScrollView.pagingEnabled=YES;
    hScrollView.bounces=NO;
    hScrollView.delegate=self;
    
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat offset=(self.bounds.size.height-self.rowHeight)*0.5;
    self.hScrollView.contentInset=UIEdgeInsetsMake(offset, 0, offset, 0);
    self.hScrollView.contentOffset=CGPointMake(0, -offset);
    
}

-(void)setLyrics:(NSArray<SKYLyric *> *)lyrics
{
    [self.hScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.lyricLabels removeAllObjects];
    _lyrics=lyrics;
    self.hScrollView.contentSize=CGSizeMake(0, self.rowHeight*lyrics.count);
    
    [lyrics enumerateObjectsUsingBlock:^(SKYLyric * _Nonnull lineLyric, NSUInteger idx, BOOL * _Nonnull stop) {
        SKYLabel *lineLabel=[[SKYLabel alloc]init];
        [self.hScrollView addSubview:lineLabel];
        [self.lyricLabels addObject:lineLabel];
        [lineLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.hScrollView).offset(self.rowHeight*idx);
            make.centerX.equalTo(self.hScrollView);
            make.height.mas_equalTo(self.rowHeight);
        }];
        lineLabel.text=lineLyric.content;
        lineLabel.textAlignment=NSTextAlignmentCenter;
        lineLabel.textColor=[UIColor whiteColor];
    }];
}

-(void)setCurrentLyricIndex:(NSInteger)currentLyricIndex
{
    if (_currentLyricIndex==currentLyricIndex) {
        return;
    }
    if (_currentLyricIndex < self.lyricLabels.count) {
        SKYLabel *preLyricLabel=self.lyricLabels[_currentLyricIndex];
        preLyricLabel.font=[UIFont systemFontOfSize:17];
        preLyricLabel.progress=0;
    }
    
    _currentLyricIndex=currentLyricIndex;
    
    if (currentLyricIndex < self.lyricLabels.count) {
        SKYLabel *lyricLabel=self.lyricLabels[currentLyricIndex];
        lyricLabel.font=[UIFont systemFontOfSize:20];
        [self scrollToIndex:currentLyricIndex];
    }
    
}


-(void)setProgress:(CGFloat)progress
{
    _progress=progress;
    if (_currentLyricIndex >= self.lyricLabels.count) {
        return;
    }
    SKYLabel *lyricLabel=self.lyricLabels[_currentLyricIndex];
    lyricLabel.progress=progress;
    
}

-(void)scrollToIndex:(NSInteger)index
{
    if (self.hScrollView.isDragging) {
        return;
    }
    
    CGFloat offsetY=self.rowHeight*index-self.hScrollView.contentInset.top;
    
    [self.hScrollView setContentOffset:CGPointMake(0, offsetY) animated:YES];
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    /*
    NSInteger index=(self.hScrollView.contentOffset.y+self.hScrollView.contentInset.top)/self.rowHeight;
    if (index < 0 || index > self.lyrics.count-1) {
        return;
    }
    
    NSTimeInterval beginTime=self.lyrics[index].beginTime;
     */
}


-(CGFloat)rowHeight
{
    if (_rowHeight==0) {
        return 44;
    }
    return _rowHeight;
}

@end
