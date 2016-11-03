//
//  UIImage+SKYExtension.h
//  MyCategory
//
//  Created by Topsky on 16/9/26.
//  Copyright © 2016年 Topsky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (SKYExtension)

#pragma mark - color
//根据颜色生成纯色图片
+ (UIImage *)imageWithColor:(UIColor *)color;

//取图片某一像素的颜色
- (UIColor *)colorAtPixel:(CGPoint)point;

//获得灰度图
- (UIImage *)convertToGrayImage;

#pragma mark - rotate
//纠正图片的方向
- (UIImage *)fixOrientation;

//按给定的方向旋转图片
- (UIImage*)rotate:(UIImageOrientation)orient;

//垂直翻转
- (UIImage *)flipVertical;

//水平翻转
- (UIImage *)flipHorizontal;

//将图片旋转degrees角度
- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees;

//将图片旋转radians弧度
- (UIImage *)imageRotatedByRadians:(CGFloat)radians;

#pragma mark - subImage
//截取当前image对象rect区域内的图像
- (UIImage *)subImageWithRect:(CGRect)rect;

//压缩图片至指定尺寸
- (UIImage *)rescaleImageToSize:(CGSize)size;

//压缩图片至指定像素
- (UIImage *)rescaleImageToPX:(CGFloat)toPX;

//在指定的size里面生成一个平铺的图片
- (UIImage *)getTiledImageWithSize:(CGSize)size;

//UIView转化为UIImage
+ (UIImage *)imageFromView:(UIView *)view;

//将两个图片生成一张图片
+ (UIImage*)mergeImage:(UIImage*)firstImage withImage:(UIImage*)secondImage;

#pragma mark - gif
//用一个Gif生成UIImage，传入一个GIFData
+ (UIImage *)animatedImageWithAnimatedGIFData:(NSData *)theData;

//用一个Gif生成UIImage，传入一个GIF路径
+ (UIImage *)animatedImageWithAnimatedGIFURL:(NSURL *)theURL;

@end
