//
//  DLGMemUIView.h
//  memui
//
//  Created by Liu Junqi on 11/11/2016.
//  Copyright © 2016 Liu Junqi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DLGMemUIViewDelegate.h"
#include "search_result_def.h"

#define DLG_DEBUG_CONSOLE_VIEW_SIZE 35 //图标大小

#define DLG_DEBUG_CONSOLE_VIEW_MIN_ALPHA 0.5f //透明度
#define DLG_DEBUG_CONSOLE_VIEW_MAX_ALPHA 0.8f

@interface DLGMemUIView : UIView

@property (nonatomic) id<DLGMemUIViewDelegate> delegate;
@property (nonatomic) UIWindow *window;
@property (nonatomic, readonly) BOOL shouldNotBeDragged;
@property (nonatomic, readonly) BOOL expanded;

@property (nonatomic) NSInteger chainCount;
@property (nonatomic) search_result_chain_t chain;

+ (instancetype)instance;
- (void)doExpand;
- (void)doCollapse;

@end
