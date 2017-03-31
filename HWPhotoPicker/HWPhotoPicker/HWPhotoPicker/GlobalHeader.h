//
//  PrefixHeader.pch
//  HWPhotoPicker
//
//  Created by yellowei on 17/3/31.
//  Copyright © 2017年 yellowei. All rights reserved.
//

#ifndef PrefixHeader_pch
#define PrefixHeader_pch

// Include any system framework and library headers here that should be included in all compilation units.
// You will also need to set the Prefix Header build setting of one or more of your targets to reference this file.

//#ifdef DEBUG
//#define DLog(...) NSLog(@"%s(%p) %@", __PRETTY_FUNCTION__, self, [NSString stringWithFormat:__VA_ARGS__])
//#else
//#define DLog(...)
//#endif


#ifdef DEBUG
#define DLog(fmt,...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define DLog(...)
#define MKLog(...)
#endif


#define ECBlockSet __weak __typeof(&*self)weakSelf = self;
#define ECBlockGet(name) __strong __typeof(&*self)name = weakSelf;

#define kECScreenWidth     [UIScreen mainScreen].bounds.size.width
#define kECScreenHeight    [UIScreen mainScreen].bounds.size.height

#define ECColorWithHEX(hex) [UIColor colorWithRed:(float)((hex & 0xFF0000) >> 16)/255.0 green:(float)((hex & 0xFF00) >> 8)/255.0 blue:(float)(hex & 0xFF)/255.0 alpha:1.0]
#define ECBGRColorWithHEX(hex) [UIColor colorWithRed:(float)(hex & 0xFF)/255.0 green:(float)((hex & 0xFF00) >> 8)/255.0 blue:(float)((hex & 0xFF0000) >> 16)/255.0 alpha:1.0]
#define ECColorWithRGB(R,G,B,A) [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:A]

#define kECBackgroundColor  ECColorWithHEX(0xf2f6f7)
#define kECBlackColor1  ECColorWithHEX(0x1a1a1a)
#define kECBlackColor2  ECColorWithHEX(0x333333)
#define kECBlackColor3  ECColorWithHEX(0x888888)
#define kECBlackColor4  ECColorWithHEX(0xbfbfbf)
#define kECBlackColor5  ECColorWithHEX(0xececec)
#define kECBlackColor6  ECColorWithHEX(0xf9f9f9)
#define kECWhiteColor  ECColorWithHEX(0xffffff)
#define kECBlueColor  ECColorWithHEX(0x00b0ff)
#define kECRedColor  ECColorWithHEX(0xcc3d3d)
#define kECRedColor1  ECColorWithHEX(0xf42c24)
#define kECRedColor2  ECColorWithHEX(0xf85d5a)
#define kECOrangeColor  ECColorWithHEX(0xffa033)
#define kECOrangeColor1  ECColorWithHEX(0xe96f14)
#define kECOrangeColor2  ECColorWithHEX(0xf1a532)
#define kECGreenColor  ECColorWithHEX(0x9cce3c)
#define kECClearColor  [UIColor clearColor]


#define kECGreenColor1  ECColorWithHEX(0xb2eee9)
#define kECGreenColor2  ECColorWithHEX(0x00c5b5)
#define kECGreenColor3  ECColorWithHEX(0x00a289)
#define kECGreenColor4  ECColorWithHEX(0x0aa721)
#define kECGreenColor5  ECColorWithHEX(0x1ac852)

//-----------------自定义常量-----------------
#define kNavHeight 64.0f //导航栏高度
#define kStateBarHeight 20.0f //导航栏高度
#define kTabbarHeight 49.0f //导航栏高度


#import "NSString+ECExtensions.h"
#import "UIView+Extension.h"

#endif /* PrefixHeader_pch */
