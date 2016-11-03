//
//  SKYMusic.h
//  音乐播放器
//
//  Created by Topsky on 2016/10/27.
//  Copyright © 2016年 Topsky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DOUAudioFile.h"

typedef NS_ENUM(NSInteger, SKYMusicType) {
    SKYMusicTypeLocal,//本地歌曲
    SKYMusicTypeRemote//网络歌曲
};

@interface SKYMusic : NSObject <DOUAudioFile>

@property (nonatomic, copy) NSString *image;///<图片
@property (nonatomic, copy) NSString *lrc;///<歌词文件
@property (nonatomic, strong) NSArray *lrcArray;///<歌词文件
@property (nonatomic, strong) NSURL *audioFileURL;///<音乐文件
@property (nonatomic, copy) NSString *name;///<歌曲的名称
@property (nonatomic, copy) NSString *singer;
@property (nonatomic, copy) NSString *album;///<专辑
@property (nonatomic, assign) SKYMusicType type;

@end
