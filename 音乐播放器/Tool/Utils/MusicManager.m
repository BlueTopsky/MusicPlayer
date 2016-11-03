//
//  MusicManager.m
//  音乐播放器
//
//  Created by Topsky on 2016/10/27.
//  Copyright © 2016年 Topsky. All rights reserved.
//

#import "MusicManager.h"

static void *kStatusKVOKey = &kStatusKVOKey;
static void *kDurationKVOKey = &kDurationKVOKey;
static void *kBufferingRatioKVOKey = &kBufferingRatioKVOKey;

@interface MusicManager ()
{
    BOOL isUpdatingLrc;
}
@property(nonatomic,strong) NSTimer *timer;

@end

@implementation MusicManager

+(id)sharedInstance{
    static MusicManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MusicManager alloc]init];
        [instance initData];
    });
    return instance;
}

-(void)initData{
    self.currentIndex = -1;
    self.lastIndex = -1;
}

+(NSArray *)lyricListWithName:(NSString *)name {
    
    NSMutableArray *resArray = [NSMutableArray array];
    
    NSString *path = [[NSBundle mainBundle]pathForResource:name ofType:nil];
    NSString *originString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    NSArray *lines = [originString componentsSeparatedByString:@"\n"];
    
    for (NSString *line in lines) {
        // 正则表达式
        NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:@"\\[[0-9][0-9]:[0-9][0-9]\\.[0-9][0-9]\\]" options:0 error:nil];
        NSArray *arr = [regular matchesInString:line options:NSMatchingReportCompletion range:NSMakeRange(0, line.length)];
        // 正文
        NSTextCheckingResult *lastResult = [arr lastObject];
        
        NSString *strText = [line substringFromIndex: lastResult.range.location + lastResult.range.length ];
        
        for (NSTextCheckingResult *result in arr) {
            // 时间文本
            NSString *strTimer = [line substringWithRange:result.range];
            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
            formatter.dateFormat = @"[mm:ss.SS]";
            NSDate *dateModel =  [formatter dateFromString:strTimer];
            NSDate *dateZero =  [formatter dateFromString:@"[00:00.00]"];
            
            SKYLyric *lyric = [SKYLyric new];
            lyric.beginTime = [dateModel timeIntervalSinceDate:dateZero];
            lyric.content = strText;
            [resArray addObject:lyric];
            
        }
    }
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"beginTime" ascending:YES];
    return [resArray sortedArrayUsingDescriptors:@[sort]];
    
}

-(void)resetStreamer{
    
    [self _cancelStreamer];
    
    if ([_delegate respondsToSelector:@selector(didPlayMusicAtIndex:withLastIndex:)]) {
        if (isUpdatingLrc) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kUpdateMusicProgressInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [_delegate didPlayMusicAtIndex:_currentIndex withLastIndex:_lastIndex];
            });
        }else{
            [_delegate didPlayMusicAtIndex:_currentIndex withLastIndex:_lastIndex];
        }
    }
    //_currentMusic = _musics[_currentIndex];
    self.streamer = [DOUAudioStreamer streamerWithAudioFile:_currentMusic];
    [DOUAudioStreamer setHintWithAudioFile:_currentMusic];
    
    [_streamer addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:kStatusKVOKey];
    [_streamer addObserver:self forKeyPath:@"duration" options:NSKeyValueObservingOptionNew context:kDurationKVOKey];
    [_streamer addObserver:self forKeyPath:@"bufferingRatio" options:NSKeyValueObservingOptionNew context:kBufferingRatioKVOKey];
}

- (void)_cancelStreamer
{
    if (self.streamer != nil) {
        [self pauseMusic];
        [_streamer removeObserver:self forKeyPath:@"status"];
        [_streamer removeObserver:self forKeyPath:@"duration"];
        [_streamer removeObserver:self forKeyPath:@"bufferingRatio"];
        self.streamer = nil;
    }
}

-(void)playMusic{
    [_streamer play];
    [self startUpdateMusicProgress];
}

-(void)pauseMusic{
    [_streamer pause];
    [self stopUpdateMusicProgress];
}

-(void)playMusicAtIndex:(NSInteger)index{
    if (_musics == nil || index >= _musics.count) {
        return;
    }
    _lastIndex = _currentIndex;
    _currentIndex = index;
    _currentMusic = _musics[_currentIndex];
    [self resetStreamer];
    [self playMusic];
}

-(void)playNextMusic{
    if (_musics == nil || _musics.count <= 0) {
        return;
    }
    _lastIndex = _currentIndex;
    if (_currentIndex == _musics.count-1) {
        _currentIndex = 0;
    }else{
        _currentIndex++;
    }
    _currentMusic = _musics[_currentIndex];
    [self resetStreamer];
    [self playMusic];
}

-(void)playPrevMusic{
    if (_musics == nil || _musics.count <= 0) {
        return;
    }
    _lastIndex = _currentIndex;
    if (_currentIndex == 0) {
        _currentIndex = _musics.count-1;
    }else{
        _currentIndex--;
    }
    _currentMusic = _musics[_currentIndex];
    [self resetStreamer];
    [self playMusic];
}

- (void) startUpdateMusicProgress {
    if (self.timer) {
        return;
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:kUpdateMusicProgressInterval target:self selector:@selector(updateLyricProgress) userInfo:nil repeats:YES];
}

- (void) stopUpdateMusicProgress{
    
    [self.timer invalidate];
    self.timer = nil;
}

/// 更新歌词进度
- (void) updateLyricProgress {
    if (isUpdatingLrc) {
        return;
    }
    if (_streamer.duration == 0.0) {
        return;
    }
    isUpdatingLrc = YES;
    NSInteger nextLyricIndex = -1;
    for (NSInteger i = 0; i < _currentMusic.lrcArray.count; ++i) {
        SKYLyric *lyric = _currentMusic.lrcArray[i];
        //      第一次找到大于当前播放时间的那句歌词就是下一句歌词（因为歌词是升序排列的）
        if (lyric.beginTime > _streamer.currentTime) {
            nextLyricIndex = i;
            break;
        }
    }
    
    // 如果没有找到下一句的歌词，那么当前的歌词就是最后一句
    //  歌词进度
    CGFloat lyricProgress = 0;
    //  当前的歌词
    SKYLyric *currentLyric = nil;
    //  当前的索引
    NSInteger currentIndex = 0;
    
    if (nextLyricIndex == 0) {//播放第一行歌词
        nextLyricIndex = 1;
        currentIndex = 0;
        currentLyric = _currentMusic.lrcArray[currentIndex];
        lyricProgress = (_streamer.currentTime - currentLyric.beginTime) / (_streamer.duration - currentLyric.beginTime);
    }else if (nextLyricIndex == -1){//播放最后一行歌词
        currentIndex = _currentMusic.lrcArray.count-1;
        currentLyric = _currentMusic.lrcArray[currentIndex];
        lyricProgress = (_streamer.currentTime - currentLyric.beginTime) / (_streamer.duration - currentLyric.beginTime);
    }else{
        //    NSLog(@"%zd",nextLyricIndex);
        currentIndex = nextLyricIndex-1;
        SKYLyric *nextLyric = _currentMusic.lrcArray[nextLyricIndex];
        currentLyric = _currentMusic.lrcArray[nextLyricIndex-1];
        //  计算歌曲播放的进度
        //    (我当前播放时间-当前的开始时间) / (下一句歌词的开始时间-当前歌词的开始时间)
        lyricProgress = (_streamer.currentTime - currentLyric.beginTime) / (nextLyric.beginTime - currentLyric.beginTime);
    }
    //  回调
    if ([self.delegate respondsToSelector:@selector(didUpdateLyricProgress:withLyric:atIndex:andCurrentTime:andDuration:)]) {
        [self.delegate didUpdateLyricProgress:lyricProgress withLyric:currentLyric atIndex:currentIndex andCurrentTime:_streamer.currentTime andDuration:_streamer.duration];
    }
    isUpdatingLrc = NO;
}

#pragma mark ----------observeValueForKeyPath----------

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == kStatusKVOKey) {
        [self performSelector:@selector(_updateStatus)
                     onThread:[NSThread mainThread]
                   withObject:nil
                waitUntilDone:NO];
    }
    else if (context == kDurationKVOKey) {
        [self performSelector:@selector(_timerAction:)
                     onThread:[NSThread mainThread]
                   withObject:nil
                waitUntilDone:NO];
    }
    else if (context == kBufferingRatioKVOKey) {
        [self performSelector:@selector(_updateBufferingStatus)
                     onThread:[NSThread mainThread]
                   withObject:nil
                waitUntilDone:NO];
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)_timerAction:(id)timer
{
    
}

- (void)_updateStatus
{
    if ([_delegate respondsToSelector:@selector(didChangeStatus:)]) {
        [_delegate didChangeStatus:[_streamer status]];
    }
}

- (void)_updateBufferingStatus
{
    float bufferValue = [_streamer bufferingRatio];
    if ([_delegate respondsToSelector:@selector(didBufferSizeChanged:)]) {
        [_delegate didBufferSizeChanged:bufferValue];
    }
    //NSLog(@"Buffering-->%@",[NSString stringWithFormat:@"Received %.2f/%.2f MB (%.2f %%), Speed %.2f MB/s", (double)[_streamer receivedLength] / 1024 / 1024, (double)[_streamer expectedLength] / 1024 / 1024, [_streamer bufferingRatio] * 100.0, (double)[_streamer downloadSpeed] / 1024 / 1024]);
}

@end
