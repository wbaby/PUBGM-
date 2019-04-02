//
//  DLGMemUIViewDelegate.h
//  memui
//
//  Created by Liu Junqi on 4/23/18.
//  Copyright © 2018 DeviLeo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DLGMemUIView;
//这里增加功能 添加功能//
//步骤1搜索（添加功能） 添加每个功能枚举代码
//步骤2搜索（添加菜单）按示例添加菜单和对应搜索代码 搜索方式按示例
//步骤3搜索（修改后代码）按菜单枚举添加修改后的代码 注意代码修改方式 改第几个 全改 还是改前几个 按尾号修改等等
//
typedef enum : NSUInteger {
    DLGMemValueTypexiugaiqi,//修改器
    DLGMemValueTypeweijiashu,//微加速
    DLGMemValueTypechaojijiashu,//超级加速
    DLGMemValueTypetianxian1,//天线1
    DLGMemValueTypetianxian2,//天线2
    DLGMemValueTypetianxian3,//天线3
    DLGMemValueTypegaotiao,//高跳D
    DLGMemValueTypechuchao,//除草

} DLGMemValueKind;
typedef enum : NSUInteger {
    DLGMemValueTypeUnsignedByte,
    DLGMemValueTypeSignedByte,
    DLGMemValueTypeUnsignedShort,
    DLGMemValueTypeSignedShort,
    DLGMemValueTypeUnsignedInt,
    DLGMemValueTypeSignedInt,
    DLGMemValueTypeUnsignedLong,
    DLGMemValueTypeSignedLong,
    DLGMemValueTypeFloat,
    DLGMemValueTypeDouble,
} DLGMemValueType;

typedef enum : NSUInteger {
    DLGMemComparisonLT, // <
    DLGMemComparisonLE, // <=
    DLGMemComparisonEQ, // =
    DLGMemComparisonGE, // >=
    DLGMemComparisonGT, // >
} DLGMemComparison;

@protocol DLGMemUIViewDelegate <NSObject>

@optional
- (void)DLGMemUILaunched:(DLGMemUIView *)view;
- (void)DLGMemUISearchValue:(NSString *)value type:(DLGMemValueType)type comparison:(DLGMemComparison)comparison;
- (void)DLGMemUIModifyValue:(NSString *)value address:(NSString *)address type:(DLGMemValueType)type;
- (void)DLGMemUIRefresh;
- (void)DLGMemUIReset;
- (NSString *)DLGMemUIMemory:(NSString *)address size:(NSString *)size;

@end
