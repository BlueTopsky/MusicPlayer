//
//  DetailViewController.m
//  音乐播放器
//
//  Created by Topsky on 2016/10/31.
//  Copyright © 2016年 Topsky. All rights reserved.
//

#import "DetailViewController.h"
#import <Masonry.h>
#import "UIImage+SKYExtension.h"
#import "LyricTableViewCell.h"
#import "SKYMusic.h"
#import "MusicManager.h"
#import "SKYLyric.h"

@interface DetailViewController ()<UIScrollViewDelegate>
{
    UINavigationBar *topBar;
    MusicManager *manager;
}
@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    manager = [MusicManager sharedInstance];
    SKYMusic *music = manager.musics[manager.currentIndex];
    
    self.bgImgView = [UIImageView new];
    _bgImgView.contentMode = UIViewContentModeScaleAspectFill;
    _bgImgView.image = [UIImage imageNamed:music.image];
    [self.view addSubview:_bgImgView];
    [_bgImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    //毛玻璃效果
    UINavigationBar *navBar=[[UINavigationBar alloc] init];
    navBar.barStyle=UIBarStyleBlack;
    [_bgImgView addSubview:navBar];
    [navBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_bgImgView);
    }];
    
    
    topBar = [[UINavigationBar alloc]init];
    topBar.shadowImage = [[UIImage alloc]init];
    [topBar setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor]] forBarMetrics:UIBarMetricsDefault];
    [topBar setTintColor:[UIColor whiteColor]];
    topBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    //创建一个导航栏集合
    UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:_musicName];
    //创建一个左边按钮
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(clickLeftButton)];
    //创建一个右边按钮
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc]initWithTitle:@"..." style:UIBarButtonItemStylePlain target:self action:@selector(clickRightButton)];
    //把导航栏集合添加入导航栏中，设置动画关闭
    [topBar pushNavigationItem:navigationItem animated:NO];
    //把左右两个按钮添加入导航栏集合中
    [navigationItem setLeftBarButtonItem:leftButton];
    [navigationItem setRightBarButtonItem:rightButton];
    //把导航栏添加到视图中
    [self.view addSubview:topBar];
    [topBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@20);
        make.height.equalTo(@44);
        make.left.right.equalTo(self.view);
    }];
    
    self.mScrollView = [[UIScrollView alloc]init];
    _mScrollView.backgroundColor=[UIColor clearColor];
    _mScrollView.delegate=self;
    //是否反弹
    _mScrollView.bounces=NO;
    //是否整页滑动
    _mScrollView.pagingEnabled = YES;
    //是否显示水平方向的滚动条
    _mScrollView.showsHorizontalScrollIndicator = NO;
    _mScrollView.userInteractionEnabled = YES;
    _mScrollView.scrollEnabled = YES;
    [self.view addSubview:_mScrollView];
    [_mScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(topBar.mas_bottom);
        make.bottom.equalTo(self.view.mas_bottom).offset(-150);
    }];
    
    [self setScrollViewUI];
    
    self.playBtn = [UIButton new];
    _playBtn.backgroundColor = [UIColor clearColor];
    if ([manager.streamer status] == DOUAudioStreamerPlaying) {
        [_playBtn setImage:[UIImage imageNamed:@"player_btn_pause_normal"] forState:UIControlStateNormal];
    }else{
        [_playBtn setImage:[UIImage imageNamed:@"player_btn_play_normal"] forState:UIControlStateNormal];
    }
    
    [_playBtn addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_playBtn];
    [_playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.width.height.equalTo(@36);
        make.bottom.equalTo(self.view.mas_bottom).offset(-30);
    }];
    
    self.prevBtn = [UIButton new];
    _prevBtn.backgroundColor = [UIColor clearColor];
    [_prevBtn setImage:[UIImage imageNamed:@"player_btn_pre_normal"] forState:UIControlStateNormal];
    [_prevBtn addTarget:self action:@selector(prev) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_prevBtn];
    [_prevBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_playBtn);
        make.width.height.equalTo(_playBtn);
        make.centerX.equalTo(_playBtn).multipliedBy(0.5);
    }];
    
    self.nextBtn = [UIButton new];
    _nextBtn.backgroundColor = [UIColor clearColor];
    [_nextBtn setImage:[UIImage imageNamed:@"player_btn_next_normal"] forState:UIControlStateNormal];
    [_nextBtn addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_nextBtn];
    [_nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_playBtn);
        make.width.height.equalTo(_playBtn);
        make.centerX.equalTo(_playBtn).multipliedBy(1.5);
    }];
    
    self.leftLabel = [UILabel new];
    _leftLabel.font = [UIFont systemFontOfSize:14.0f];
    _leftLabel.backgroundColor = [UIColor clearColor];
    _leftLabel.textColor = [UIColor whiteColor];
    _leftLabel.textAlignment = NSTextAlignmentCenter;
    _leftLabel.text = @"00:00";
    [self.view addSubview:_leftLabel];
    [_leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_playBtn.mas_top).offset(-25);
        make.left.equalTo(self.view);
        make.height.equalTo(@10);
        make.width.equalTo(@60);
    }];
    
    self.rightLabel = [UILabel new];
    _rightLabel.font = [UIFont systemFontOfSize:14.0f];
    _rightLabel.backgroundColor = [UIColor clearColor];
    _rightLabel.textColor = [UIColor whiteColor];
    _rightLabel.textAlignment = NSTextAlignmentCenter;
    _rightLabel.text = @"00:00";
    [self.view addSubview:_rightLabel];
    [_rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_leftLabel);
        make.right.equalTo(self.view);
        make.height.equalTo(@10);
        make.width.equalTo(_leftLabel);
    }];
    
    self.mProgressView = [UIProgressView new];
    _mProgressView.layer.cornerRadius = 2;
    _mProgressView.layer.masksToBounds = YES;
    _mProgressView.progressTintColor = [UIColor whiteColor];
    _mProgressView.trackTintColor = [UIColor lightGrayColor];
    _mProgressView.progress = 0;
    [self.view addSubview:_mProgressView];
    [_mProgressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_leftLabel.mas_right);
        make.right.equalTo(_rightLabel.mas_left);
        make.centerY.equalTo(_leftLabel);
        make.height.equalTo(@3);
    }];
    
    self.mSlider = [[SKYSlider alloc]init];
    _mSlider.minimumValue = 0;
    _mSlider.minimumTrackTintColor=[UIColor greenColor];
    _mSlider.maximumValue = 1;
    _mSlider.maximumTrackTintColor=[UIColor clearColor];
    _mSlider.thumbTintColor = [UIColor greenColor];
    _mSlider.value = 0;
    [_mSlider addTarget:self action:@selector(updateValue:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_mSlider];
    [_mSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_leftLabel.mas_right);
        make.right.equalTo(_rightLabel.mas_left);
        make.centerY.equalTo(_leftLabel);
        make.height.equalTo(@3);
    }];
}

-(void)setScrollViewUI{
    
    self.centerImgView = [UIImageView new];
    _centerImgView.backgroundColor = [UIColor greenColor];
    _centerImgView.contentMode = UIViewContentModeScaleAspectFill;
    _centerImgView.layer.cornerRadius = 100;
    _centerImgView.layer.masksToBounds = YES;
    
    _centerImgView.image = _bgImgView.image;
    [_mScrollView addSubview:_centerImgView];
    [_centerImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_mScrollView);
        make.centerX.equalTo(_mScrollView);
        make.width.height.equalTo(@199);
    }];
    
    self.lyricView = [SKYLyricView new];
    _lyricView.backgroundColor = [UIColor clearColor];
    [_mScrollView addSubview:_lyricView];
    [_lyricView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_mScrollView);
        make.centerX.equalTo(_centerImgView.mas_centerX).multipliedBy(3);
        make.width.height.equalTo(_mScrollView);
    }];
    _lyricView.lyrics = [manager.musics[manager.currentIndex] lrcArray];
    
    [_mScrollView setContentSize:CGSizeMake(_mScrollView.bounds.size.width*2, _mScrollView.bounds.size.height)];
    [_mScrollView setContentOffset:CGPointMake(0, 0) animated:NO];
    
    [self addAnimation];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self.mScrollView setContentSize:CGSizeMake(self.mScrollView.bounds.size.width*2, self.mScrollView.bounds.size.height)];
}
/// 添加动画
- (void)addAnimation{
    
    CABasicAnimation *monkeyAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    monkeyAnimation.toValue = [NSNumber numberWithFloat:2.0 *M_PI];
    monkeyAnimation.duration = 20.0f;
    monkeyAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    monkeyAnimation.cumulative = NO;
    monkeyAnimation.removedOnCompletion = NO; //No Remove
    monkeyAnimation.fillMode = kCAFillModeForwards;
    monkeyAnimation.repeatCount = FLT_MAX;
    [_centerImgView.layer addAnimation:monkeyAnimation forKey:@"AnimatedKey"];
    [_centerImgView stopAnimating];
    _centerImgView.layer.speed = 0.0;
    if ([manager.streamer status] == DOUAudioStreamerPlaying) {
        [self startAnimation];
    }
}

// 停止
-(void)endAnimation
{
    _isRotate = NO;
    CFTimeInterval pausedTime = [_centerImgView.layer convertTime:CACurrentMediaTime() fromLayer:nil];
    _centerImgView.layer.speed = 0.0;
    _centerImgView.layer.timeOffset = pausedTime;
}

// 恢复
-(void)startAnimation
{
    _isRotate = YES;
    CFTimeInterval pausedTime = _centerImgView.layer.timeOffset;
    _centerImgView.layer.speed = 1.0;
    _centerImgView.layer.timeOffset = 0.0;
    _centerImgView.layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [_centerImgView.layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    _centerImgView.layer.beginTime = timeSincePause;
}

-(void)setMusicName:(NSString *)musicName{
    _musicName = musicName;
    topBar.topItem.title = musicName;
}

-(void)clickLeftButton{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)clickRightButton{
    
}

-(void)updateValue:(UISlider *)slider{
    [manager.streamer setCurrentTime:manager.streamer.duration*slider.value];
}

-(void)play{
    if ([_delegate respondsToSelector:@selector(playOrPauseMusic)]) {
        [_delegate playOrPauseMusic];
    }
}

-(void)prev{
    if ([_delegate respondsToSelector:@selector(playPrev)]) {
        [_delegate playPrev];
    }
}

-(void)next{
    if ([_delegate respondsToSelector:@selector(playNext)]) {
        [_delegate playNext];
    }
}

#pragma mark ----------UIScrollViewDelegate----------

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
