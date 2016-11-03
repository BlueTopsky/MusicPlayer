//
//  ViewController.m
//  音乐播放器
//
//  Created by Topsky on 2016/10/27.
//  Copyright © 2016年 Topsky. All rights reserved.
//

#import "ViewController.h"
#import <Masonry.h>
#import "SKYMusic.h"
#import <AVFoundation/AVFoundation.h>
#import "MusicTableViewCell.h"
#import "MusicManager.h"
#import "DetailViewController.h"
#import <MediaPlayer/MediaPlayer.h>


@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,MusicManagerDelegate,DetailViewControllerDelegate>
{
    UITableView *mTableView;
    NSMutableArray *musicArray;
    UIImageView *iconImgView;
    UILabel *nameLabel;
    UIButton *playBtn;
    UIButton *playTypeBtn;
    MusicManager *manager;
    
    NSTimer *mTimer;
    DetailViewController *detailVC;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1.0];
    [self setting];
    musicArray = [NSMutableArray array];

    manager = [MusicManager sharedInstance];
    manager.delegate = self;
    [manager setMusics:musicArray];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1.0];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor colorWithRed:45/255.0 green:45/255.0 blue:45/255.0 alpha:1.0];
    titleLabel.text = @"我的音乐";
    [self.view addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(@20);
        make.height.equalTo(@44);
    }];
    
    mTableView = [UITableView new];
    mTableView.delegate = self;
    mTableView.dataSource = self;
    mTableView.tableFooterView = [UIImageView new];
    mTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:mTableView];
    [mTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(@-44);
        make.top.equalTo(titleLabel.mas_bottom);
    }];
    [self addBottomView];
    
    detailVC = [[DetailViewController alloc]init];
    detailVC.delegate = self;
    
    //添加歌曲
    NSArray *nameArray = @[@"小苹果", @"月半小夜曲", @"稳稳的幸福", @"泡沫"];
    for (int i=0; i<nameArray.count; i++) {
        SKYMusic *music = [SKYMusic new];
        if ([[NSBundle mainBundle]pathForResource:nameArray[i] ofType:@"mp3"] == nil) {
            continue;
        }
        music.audioFileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:nameArray[i] ofType:@"mp3"]];
        music.name = nameArray[i];
        NSString *path = [[NSBundle mainBundle]pathForResource:[music.name stringByAppendingString:@".jpg"] ofType:nil];
        NSFileManager * fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:path]){
            music.image = @"4.jpg";
        }else{
            music.image = [music.name stringByAppendingString:@".jpg"];
        }
        if (i == 1) {
            music.singer = @"李克勤";
        }
        music.type = SKYMusicTypeLocal;
        music.lrc = [NSString stringWithFormat:@"%@.lrc",nameArray[i]];
        music.lrcArray = [MusicManager lyricListWithName:music.lrc];
        [musicArray addObject:music];
    }
}

-(void)addBottomView{
    UIView *bottomView = [UIView new];
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomView];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(mTableView.mas_bottom);
    }];
    
    UIView *lineView = [UIView new];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [bottomView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@0.3);
        make.top.left.right.equalTo(bottomView);
    }];
    
    iconImgView = [UIImageView new];
    iconImgView.backgroundColor = [UIColor clearColor];
    iconImgView.layer.cornerRadius = 18;
    iconImgView.clipsToBounds = YES;
    iconImgView.contentMode = UIViewContentModeScaleAspectFill;
    [bottomView addSubview:iconImgView];
    [iconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@4);
        make.left.equalTo(@6);
        make.width.height.equalTo(@36);
    }];
    
    nameLabel = [UILabel new];
    nameLabel.textColor = [UIColor colorWithRed:75/255.0 green:75/255.0 blue:75/255.0 alpha:1.0];
    nameLabel.font = [UIFont systemFontOfSize:16];
    nameLabel.textAlignment = NSTextAlignmentLeft;
    nameLabel.text = @"QQ音乐,听我想听的歌";
    [bottomView addSubview:nameLabel];
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(iconImgView.mas_right).offset(4);
        make.centerY.equalTo(bottomView);
        make.right.equalTo(@-92);
    }];
    
    playBtn = [UIButton new];
    [playBtn setImage:[UIImage imageNamed:@"player_btn_play_normal"] forState:UIControlStateNormal];
    [playBtn addTarget:self action:@selector(playOrPauseMusic) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:playBtn];
    [playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@36);
        make.left.equalTo(nameLabel.mas_right).offset(4);
        make.centerY.equalTo(bottomView);
    }];
    
    playTypeBtn = [UIButton new];
    [playTypeBtn setImage:[UIImage imageNamed:@"player_btn_next_normal"] forState:UIControlStateNormal];
    [playTypeBtn addTarget:self action:@selector(playNext) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:playTypeBtn];
    [playTypeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@36);
        make.left.equalTo(playBtn.mas_right).offset(8);
        make.centerY.equalTo(bottomView);
    }];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(goDetailPlayingView)];
    bottomView.userInteractionEnabled = YES;
    [bottomView addGestureRecognizer:tap];
    
}

-(void)goDetailPlayingView{
    if (manager.currentIndex != -1) {
        [self presentViewController:detailVC animated:YES completion:nil];
    }
}

-(void)setting
{
    NSError *error=nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    if (error) {
        NSLog(@"注册播放类别失败:%@",error);
    }
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioSessionInterruptionNotifation:) name:AVAudioSessionInterruptionNotification object:nil];
}

-(void)audioSessionInterruptionNotifation:(NSNotification *)notification
{
    AVAudioSessionInterruptionType type=[notification.userInfo[AVAudioSessionInterruptionTypeKey] intValue];
    if (type==AVAudioSessionInterruptionTypeBegan) {
        [self playOrPauseMusic];
    }else if (type==AVAudioSessionInterruptionTypeEnded)
    {
        [self playOrPauseMusic];
    }else{
        NSLog(@"意外情况发生");
    }
}

-(void)remoteControlReceivedWithEvent:(UIEvent *)event
{
    switch (event.subtype) {
        case UIEventSubtypeRemoteControlPlay:
        case UIEventSubtypeRemoteControlPause:
            [self playOrPauseMusic];
            break;
        case UIEventSubtypeRemoteControlNextTrack:
            [self playNext];
            break;
        case UIEventSubtypeRemoteControlPreviousTrack:
            [self playPrev];
            break;
        default:
            break;
    }
}

//锁屏界面 显示歌曲基本信息
-(void)updateScreenMusicInfo {
    MPMediaItemArtwork *artWork = [[MPMediaItemArtwork alloc] initWithImage:[UIImage imageNamed:manager.currentMusic.image]];
    NSDictionary *dic = @{MPMediaItemPropertyTitle:manager.currentMusic.name,
                          MPMediaItemPropertyArtist:manager.currentMusic.singer ? manager.currentMusic.singer : @"不知道谁唱的",
                          MPMediaItemPropertyArtwork:artWork,
                          MPMediaItemPropertyPlaybackDuration:[NSNumber numberWithFloat:(float)manager.streamer.duration]
                          };
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dic];
}

#pragma mark ----------UITableViewDelegate,UITableViewDataSource----------

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return musicArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"cellId";
    MusicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[MusicTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    SKYMusic *music = musicArray[indexPath.row];
    cell.labelMain.text = music.name;
    if (manager.currentIndex == indexPath.row) {
        cell.leftView.hidden = NO;
    }else{
        cell.leftView.hidden = YES;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [manager playMusicAtIndex:indexPath.row];
}

#pragma mark ----------MusicManagerDelegate----------

-(void)didPlayMusicAtIndex:(NSInteger)current withLastIndex:(NSInteger)last{
    SKYMusic *music = manager.musics[manager.currentIndex];
    nameLabel.text = music.name;
    [detailVC setMusicName:music.name];
    UIImage *iconImage = [UIImage imageNamed:music.image];
    iconImgView.image = iconImage;
    detailVC.bgImgView.image = iconImage;
    detailVC.centerImgView.image = iconImage;
    
    if (last != -1) {
        NSIndexPath *lastIndex = [NSIndexPath indexPathForRow:last inSection:0];
        [mTableView reloadRowsAtIndexPaths:@[lastIndex] withRowAnimation:UITableViewRowAnimationFade];
    }
    NSIndexPath *nowIndex = [NSIndexPath indexPathForRow:current inSection:0];
    [mTableView reloadRowsAtIndexPaths:@[nowIndex] withRowAnimation:UITableViewRowAnimationFade];
    
    //更换歌词
    detailVC.lyricView.lyrics = [manager.musics[manager.currentIndex] lrcArray];
    detailVC.mProgressView.progress = 0;
    
}

-(void)didChangeStatus:(DOUAudioStreamerStatus)status{
    switch (status) {
        case DOUAudioStreamerPlaying:
            NSLog(@"Playing");
            [playBtn setImage:[UIImage imageNamed:@"player_btn_pause_normal"] forState:UIControlStateNormal];
            [detailVC.playBtn setImage:[UIImage imageNamed:@"player_btn_pause_normal"] forState:UIControlStateNormal];
            if (!detailVC.isRotate) {
                [detailVC startAnimation];
            }
            [self updateScreenMusicInfo];
            break;
            
        case DOUAudioStreamerPaused:
            [playBtn setImage:[UIImage imageNamed:@"player_btn_play_normal"] forState:UIControlStateNormal];
            [detailVC.playBtn setImage:[UIImage imageNamed:@"player_btn_play_normal"] forState:UIControlStateNormal];
            [detailVC endAnimation];
            NSLog(@"Paused");
            break;
            
        case DOUAudioStreamerIdle:
            NSLog(@"idle");
            [playBtn setImage:[UIImage imageNamed:@"player_btn_play_normal"] forState:UIControlStateNormal];
            [detailVC.playBtn setImage:[UIImage imageNamed:@"player_btn_play_normal"] forState:UIControlStateNormal];
            [detailVC endAnimation];
            
            [self playNext];
            break;
            
        case DOUAudioStreamerFinished:
            NSLog(@"finished");
            [playBtn setImage:[UIImage imageNamed:@"player_btn_play_normal"] forState:UIControlStateNormal];
            [detailVC.playBtn setImage:[UIImage imageNamed:@"player_btn_play_normal"] forState:UIControlStateNormal];
            [detailVC endAnimation];
            
            [self playNext];
            break;
            
        case DOUAudioStreamerBuffering:
            NSLog(@"buffering");
            [playBtn setImage:[UIImage imageNamed:@"player_btn_play_normal"] forState:UIControlStateNormal];
            [detailVC.playBtn setImage:[UIImage imageNamed:@"player_btn_play_normal"] forState:UIControlStateNormal];
            [detailVC endAnimation];
            break;
            
        case DOUAudioStreamerError:
            NSLog(@"error");
            [playBtn setImage:[UIImage imageNamed:@"player_btn_play_normal"] forState:UIControlStateNormal];
            [detailVC.playBtn setImage:[UIImage imageNamed:@"player_btn_play_normal"] forState:UIControlStateNormal];
            [detailVC endAnimation];
            
            [self playNext];
            break;
    }
}

-(void)didBufferSizeChanged:(float)bufferValue{
    detailVC.mProgressView.progress = bufferValue;
}

-(void)didUpdateLyricProgress:(CGFloat)progress withLyric:(SKYLyric *)lineLyric atIndex:(NSInteger)index andCurrentTime:(NSTimeInterval)currentTime andDuration:(NSTimeInterval)duration{
    //给歌词视图设置当前播放的索引
    detailVC.lyricView.currentLyricIndex=index;
    detailVC.lyricView.progress=progress;
    if (manager.currentMusic.type == SKYMusicTypeLocal) {
        detailVC.mProgressView.progress = 1;
    }
    [self didUpdateProgressWithCurrentTime:currentTime andDuration:duration];
}

- (void)didUpdateProgressWithCurrentTime:(NSTimeInterval)currentTime andDuration:(NSTimeInterval)duration{
    if (duration == 0.0) {
        [detailVC.mSlider setValue:0.0f animated:NO];
        detailVC.leftLabel.text = @"00:00";
        detailVC.rightLabel.text = @"00:00";
        return;
    }
    [detailVC.mSlider setValue:currentTime / duration animated:YES];
    
    int min = (int)(currentTime/60);
    int sec = (int)currentTime - min*60;
    detailVC.leftLabel.text = [NSString stringWithFormat:@"%02d:%02d",min,sec];
    
    int min2 = (int)(duration/60);
    int sec2 = (int)duration - min2*60;
    detailVC.rightLabel.text = [NSString stringWithFormat:@"%02d:%02d",min2,sec2];
}

#pragma mark ----------DetailViewControllerDelegate----------

-(void)playOrPauseMusic{
    if ([manager.streamer status] == DOUAudioStreamerPlaying) {
        [manager pauseMusic];
    }else if ([manager.streamer status] == DOUAudioStreamerPaused){
        [manager playMusic];
    }
}

-(void)playNext{
    [manager playNextMusic];
}

-(void)playPrev{
    [manager playPrevMusic];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleDefault;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
