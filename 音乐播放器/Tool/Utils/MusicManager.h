//
//  MusicManager.h
//  音乐播放器
//
//  Created by Topsky on 2016/10/27.
//  Copyright © 2016年 Topsky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DOUAudioStreamer.h"
#import "DOUAudioStreamer+Options.h"
#import "SKYLyric.h"
#import "SKYMusic.h"

static NSTimeInterval const kUpdateMusicProgressInterval = 0.005;

@protocol MusicManagerDelegate <NSObject>

-(void)didUpdateLyricProgress:(CGFloat) progress withLyric:(SKYLyric *)lineLyric atIndex:(NSInteger)index andCurrentTime:(NSTimeInterval)currentTime andDuration:(NSTimeInterval)duration;//更新歌词进度回调
-(void)didPlayMusicAtIndex:(NSInteger)current withLastIndex:(NSInteger)last;//切换歌曲回调
-(void)didChangeStatus:(DOUAudioStreamerStatus)status;
-(void)didBufferSizeChanged:(float)bufferValue;
@end

@interface MusicManager : NSObject

@property (strong, nonatomic) NSArray *musics;
@property (strong, nonatomic) SKYMusic *currentMusic;
@property (assign, nonatomic) NSInteger currentIndex;
@property (assign, nonatomic) NSInteger lastIndex;
@property (strong, nonatomic) DOUAudioStreamer *streamer;
@property (nonatomic,retain) id<MusicManagerDelegate> delegate;

+(id)sharedInstance;
+(NSArray *)lyricListWithName:(NSString *)name;//解析歌词

-(void)playMusic;//播放
-(void)pauseMusic;//暂停
-(void)playMusicAtIndex:(NSInteger)index;//播放某首歌曲
-(void)playNextMusic;//下一曲
-(void)playPrevMusic;//上一曲

@end
