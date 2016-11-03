//
//  DetailViewController.h
//  音乐播放器
//
//  Created by Topsky on 2016/10/31.
//  Copyright © 2016年 Topsky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKYLyricView.h"
#import "SKYSlider.h"

@protocol DetailViewControllerDelegate <NSObject>

-(void)playOrPauseMusic;
-(void)playNext;
-(void)playPrev;
@end

@interface DetailViewController : UIViewController

@property (nonatomic,strong) UIImageView *bgImgView;
@property (nonatomic,strong) UIScrollView *mScrollView;
@property (nonatomic,strong) UIImageView *centerImgView;
@property (nonatomic,strong) SKYLyricView *lyricView;
@property (nonatomic,strong) SKYSlider *mSlider;
@property (nonatomic,strong) UIProgressView *mProgressView;
@property (nonatomic,strong) UILabel *leftLabel;
@property (nonatomic,strong) UILabel *rightLabel;
@property (nonatomic,strong) UIButton *prevBtn;
@property (nonatomic,strong) UIButton *playBtn;
@property (nonatomic,strong) UIButton *nextBtn;
@property (nonatomic,strong) NSString *musicName;
@property (nonatomic,assign) BOOL isRotate;
@property (nonatomic,strong) id<DetailViewControllerDelegate> delegate;

- (void)startAnimation;
- (void)endAnimation;

@end
