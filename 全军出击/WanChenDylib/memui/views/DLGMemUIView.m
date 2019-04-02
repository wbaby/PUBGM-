//
//  DLGMemUIView.m
//  memui
//
//  Created by Liu Junqi on 11/11/2016.
//  Copyright © 2016 Liu Junqi. All rights reserved.
//

#import "DLGMemUIView.h"
#import "DLGMemUIViewCell.h"
#import "SCLAlertView.h"
#import "AESUtility.h"
#import <AdSupport/AdSupport.h>
#import <CommonCrypto/CommonCrypto.h>
#define MaxResultCount  500

@interface DLGMemUIView () <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, DLGMemUIViewCellDelegate> {
    search_result_t *chainArray;
}

@property (nonatomic) UIButton *btnConsole;
@property (nonatomic) UITapGestureRecognizer *tapGesture;

@property (nonatomic) CGRect rcCollapsedFrame;
@property (nonatomic) CGRect rcExpandedFrame;

@property (nonatomic) UIView *vContent;
@property (nonatomic) UILabel *lblType;
@property (nonatomic) UIView *vSearch;
@property (nonatomic) UITextField *tfValue;
@property (nonatomic) UIButton *btnSearch;

@property (nonatomic) UIView *vOption;
@property (nonatomic) UISegmentedControl *scComparison;
@property (nonatomic) UISegmentedControl *scUValueType;
@property (nonatomic) UISegmentedControl *scSValueType;

@property (nonatomic) UIView *vResult;
@property (nonatomic) UILabel *lblResult;
@property (nonatomic) UITableView *tvResult;

@property (nonatomic) UIView *vMore;
@property (nonatomic) UIButton *btnReset;
@property (nonatomic) UIButton *btnMemory;
@property (nonatomic) UIButton *btnRefresh;

@property (nonatomic) UIView *vMemoryContent;
@property (nonatomic) UIView *vMemory;
@property (nonatomic) UITextField *tfMemorySize;
@property (nonatomic) UITextField *tfMemory;
@property (nonatomic) UIButton *btnSearchMemory;

@property (nonatomic) UITextView *tvMemory;
@property (nonatomic) UIButton *btnBackFromMemory;

@property (nonatomic, weak) UIView *vShowingContent;

@property (nonatomic) NSLayoutConstraint *lcUValueTypeTopMargin;

@property (nonatomic) BOOL isUnsignedValueType;
@property (nonatomic) NSInteger selectedValueTypeIndex;
@property (nonatomic) NSInteger selectedComparisonIndex;
@property (nonatomic, weak) UITextField *tfFocused;
@property (nonatomic)DLGMemValueKind dlgmemvalueKind;

@property (nonatomic) BOOL tianxianareyouok;
@end

@implementation DLGMemUIView

+ (instancetype)instance
{
    static DLGMemUIView *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[DLGMemUIView alloc] init];
    });
    return _instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initVars];
        [self initViews];
    }
    return self;
}

- (void)initVars {
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    self.rcExpandedFrame = screenBounds;
    self.rcCollapsedFrame = CGRectMake(0, 0, DLG_DEBUG_CONSOLE_VIEW_SIZE, DLG_DEBUG_CONSOLE_VIEW_SIZE);
    
    _shouldNotBeDragged = NO;
    _expanded = NO;
    self.isUnsignedValueType = NO;
    self.selectedValueTypeIndex = 2;
    self.selectedComparisonIndex = 2;
    self.tianxianareyouok   =   NO;
}

- (void)initViews {
    self.backgroundColor = [UIColor blackColor];
    self.clipsToBounds = YES;
    self.frame = self.rcCollapsedFrame;
    self.layer.cornerRadius = CGRectGetWidth(self.bounds) / 2;
    [self initConsoleButton];
    [self initContents];
    [self initMemoryContents];
    self.vShowingContent = self.vContent;
}

- (void)initConsoleButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    [button setTitle:@"辅助" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self addSubview:button];
    NSDictionary *views = NSDictionaryOfVariableBindings(button);
    NSArray *ch = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[button]|"
                                                          options:0
                                                          metrics:nil
                                                            views:views];
    [self addConstraints:ch];
    NSArray *cv = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[button]|"
                                                          options:0
                                                          metrics:nil
                                                            views:views];
    [self addConstraints:cv];
    [button addTarget:self action:@selector(onConsoleButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.btnConsole = button;
}

- (void)doExpand {
    [self expand];
}

- (void)doCollapse {
    [self collapse];
    self.btnConsole.hidden = NO;
    [self.tfValue resignFirstResponder];
}

#pragma mark - Init Content View
- (void)initContents {
    [self initContentView];
    [self initSearchView];
    [self initOptionView];
    [self initResultView];
    [self initMoreView];
    self.vContent.hidden = YES;
}

- (void)initContentView {
    UIView *v = [[UIView alloc] init];
    v.translatesAutoresizingMaskIntoConstraints = NO;
    v.backgroundColor = [UIColor clearColor];
    [self addSubview:v];
    
    NSDictionary *views = @{@"v":v};
    NSArray *ch = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[v]|" options:0 metrics:nil views:views];
    [self addConstraints:ch];
    NSArray *cv = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[v]|" options:0 metrics:nil views:views];
    [self addConstraints:cv];
    
    self.vContent = v;
}

#pragma mark - Init Search View
- (void)initSearchView {
    [self initSearchViewContainer];
    [self initSearchValueType];
    [self initSearchButton];
    [self initSearchValueInput];
}

- (void)initSearchViewContainer {
    UIView *v = [[UIView alloc] init];
    v.translatesAutoresizingMaskIntoConstraints = NO;
    v.backgroundColor = [UIColor clearColor];
    [self.vContent addSubview:v];
    
    NSDictionary *views = @{@"v":v};
    NSArray *ch = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[v]-8-|" options:0 metrics:nil views:views];
    [self.vContent addConstraints:ch];
    NSArray *cv = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[v(32)]" options:0 metrics:nil views:views];
    [self.vContent addConstraints:cv];
    
    self.vSearch = v;
}

- (void)initSearchValueType {
    UILabel *lbl = [[UILabel alloc] init];
    lbl.translatesAutoresizingMaskIntoConstraints = NO;
    lbl.backgroundColor = [UIColor clearColor];
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.textColor = [UIColor whiteColor];
    lbl.text = @"SInt";
    [self.vSearch addSubview:lbl];
    
    NSDictionary *views = @{@"lbl":lbl};
    NSArray *ch = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[lbl(64)]" options:0 metrics:nil views:views];
    [self.vSearch addConstraints:ch];
    NSArray *cv = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[lbl]|" options:0 metrics:nil views:views];
    [self.vSearch addConstraints:cv];
    
    self.lblType = lbl;
}

- (void)initSearchButton {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.translatesAutoresizingMaskIntoConstraints = NO;
    [btn setTitle:@"Search" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(onSearchTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.vSearch addSubview:btn];
    
    NSDictionary *views = @{@"btn":btn};
    NSArray *ch = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[btn(64)]|" options:0 metrics:nil views:views];
    [self.vSearch addConstraints:ch];
    NSArray *cv = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[btn]|" options:0 metrics:nil views:views];
    [self.vSearch addConstraints:cv];
    
    self.btnSearch = btn;
}

- (void)initSearchValueInput {
    UITextField *tf = [[UITextField alloc] init];
    tf.translatesAutoresizingMaskIntoConstraints = NO;
    tf.delegate = self;
    tf.borderStyle = UITextBorderStyleRoundedRect;
    tf.backgroundColor = [UIColor whiteColor];
    tf.textColor = [UIColor blackColor];
    tf.placeholder = @"Enter the value";
    tf.returnKeyType = UIReturnKeySearch;
    tf.keyboardType = UIKeyboardTypeDefault;
    tf.clearButtonMode = UITextFieldViewModeWhileEditing;
    tf.spellCheckingType = UITextSpellCheckingTypeNo;
    tf.autocapitalizationType = UITextAutocapitalizationTypeNone;
    tf.autocorrectionType = UITextAutocorrectionTypeNo;
    tf.enabled = YES;
    [self.vSearch addSubview:tf];
    
    NSDictionary *views = @{@"lbl":self.lblType, @"btn":self.btnSearch, @"input":tf};
    NSArray *ch = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[lbl]-2-[input][btn]" options:0 metrics:nil views:views];
    [self.vSearch addConstraints:ch];
    NSArray *cv = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[input]|" options:0 metrics:nil views:views];
    [self.vSearch addConstraints:cv];
    
    self.tfValue = tf;
}

#pragma mark - Init Option View
- (void)initOptionView {
    [self initOptionViewContainer];
    [self initComparisonSegmentedControl];
    [self initUValueTypeSegmentedControl];
    [self initSValueTypeSegmentedControl];
}

- (void)initOptionViewContainer {
    UIView *v = [[UIView alloc] init];
    v.translatesAutoresizingMaskIntoConstraints = NO;
    v.backgroundColor = [UIColor clearColor];
    [self.vContent addSubview:v];
    
    NSDictionary *views = @{@"vv":self.vSearch, @"v":v};
    NSArray *ch = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[v]-8-|" options:0 metrics:nil views:views];
    [self addConstraints:ch];
    NSArray *cv = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[vv]-8-[v]" options:0 metrics:nil views:views];
    [self.vContent addConstraints:cv];
    
    self.vOption = v;
}

- (void)initComparisonSegmentedControl {
    UISegmentedControl *sc = [[UISegmentedControl alloc] initWithItems:@[@"<", @"<=", @"=", @">=", @">"]];
    sc.translatesAutoresizingMaskIntoConstraints = NO;
    [sc setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
    [sc setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateSelected];
    sc.selectedSegmentIndex = 2;
    [sc addTarget:self action:@selector(onComparisonChanged:) forControlEvents:UIControlEventValueChanged];
    [self.vOption addSubview:sc];
    
    NSDictionary *views = @{@"sc":sc};
    NSArray *ch = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[sc]|" options:0 metrics:nil views:views];
    [self.vOption addConstraints:ch];
    NSArray *cv = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[sc]" options:0 metrics:nil views:views];
    [self.vOption addConstraints:cv];
    
    self.scComparison = sc;
}

- (void)initUValueTypeSegmentedControl {
    UISegmentedControl *sc = [[UISegmentedControl alloc] initWithItems:@[@"UByte", @"UShort", @"UInt", @"ULong", @"Float"]];
    sc.translatesAutoresizingMaskIntoConstraints = NO;
    [sc setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
    [sc setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateSelected];
    sc.selectedSegmentIndex = -1;
    sc.selected = NO;
    [sc addTarget:self action:@selector(onValueTypeChanged:) forControlEvents:UIControlEventValueChanged];
    [self.vOption addSubview:sc];
    
    NSDictionary *views = @{@"cmp":self.scComparison, @"sc":sc};
    NSArray *ch = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[sc]|" options:0 metrics:nil views:views];
    [self.vOption addConstraints:ch];
    NSArray *cv = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[cmp]-8-[sc]" options:0 metrics:nil views:views];
    [self.vOption addConstraints:cv];
    self.lcUValueTypeTopMargin = [cv firstObject];
    self.scUValueType = sc;
}

- (void)initSValueTypeSegmentedControl {
    UISegmentedControl *sc = [[UISegmentedControl alloc] initWithItems:@[@"SByte", @"SShort", @"SInt", @"SLong", @"Double"]];
    sc.translatesAutoresizingMaskIntoConstraints = NO;
    [sc setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
    [sc setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateSelected];
    sc.selectedSegmentIndex = 2;
    sc.selected = YES;
    [sc addTarget:self action:@selector(onValueTypeChanged:) forControlEvents:UIControlEventValueChanged];
    [self.vOption addSubview:sc];
    
    NSDictionary *views = @{@"usc":self.scUValueType, @"sc":sc};
    NSArray *ch = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[sc]|" options:0 metrics:nil views:views];
    [self.vOption addConstraints:ch];
    NSArray *cv = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[usc][sc]|" options:0 metrics:nil views:views];
    [self.vOption addConstraints:cv];
    
    self.scSValueType = sc;
}

#pragma mark - Init Result View
- (void)initResultView {
    [self initResultViewContainer];
    [self initResultLabel];
    [self initResultTableView];
}

- (void)initResultViewContainer {
    UIView *v = [[UIView alloc] init];
    v.translatesAutoresizingMaskIntoConstraints = NO;
    v.backgroundColor = [UIColor clearColor];
    [self.vContent addSubview:v];
    
    NSDictionary *views = @{@"vv":self.vOption, @"v":v};
    NSArray *ch = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[v]-8-|" options:0 metrics:nil views:views];
    [self.vContent addConstraints:ch];
    NSArray *cv = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[vv]-8-[v]" options:0 metrics:nil views:views];
    [self.vContent addConstraints:cv];
    
    self.vResult = v;
}

- (void)initResultLabel {
    UILabel *lbl = [[UILabel alloc] init];
    lbl.translatesAutoresizingMaskIntoConstraints = NO;
    lbl.backgroundColor = [UIColor clearColor];
    lbl.textAlignment = NSTextAlignmentLeft;
    lbl.textColor = [UIColor whiteColor];
    lbl.text = @"3手指触摸三次屏幕隐藏图标";
    [self.vResult addSubview:lbl];
    
    NSDictionary *views = @{@"lbl":lbl};
    NSArray *ch = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[lbl]|" options:0 metrics:nil views:views];
    [self.vResult addConstraints:ch];
    NSArray *cv = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[lbl]" options:0 metrics:nil views:views];
    [self.vResult addConstraints:cv];
    
    self.lblResult = lbl;
}

- (void)initResultTableView {
    UITableView *tv = [[UITableView alloc] init];
    tv.translatesAutoresizingMaskIntoConstraints = NO;
    tv.delegate = self;
    tv.dataSource = self;
    tv.backgroundColor = [UIColor clearColor];
    tv.separatorStyle = UITableViewCellSeparatorStyleNone;
    tv.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    [self.vResult addSubview:tv];
    
    NSDictionary *views = @{@"lbl":self.lblResult, @"tv":tv};
    NSArray *ch = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tv]|" options:0 metrics:nil views:views];
    [self.vResult addConstraints:ch];
    NSArray *cv = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[lbl]-8-[tv]|" options:0 metrics:nil views:views];
    [self.vResult addConstraints:cv];
    
    [tv registerClass:[DLGMemUIViewCell class] forCellReuseIdentifier:DLGMemUIViewCellID];
    self.tvResult = tv;
}

#pragma mark - Init More View
- (void)initMoreView {
    [self initMoreViewContainer];
    [self initResetButton];
    [self initRefreshButton];
    [self initMemoryButton];
}

- (void)initMoreViewContainer {
    UIView *v = [[UIView alloc] init];
    v.translatesAutoresizingMaskIntoConstraints = NO;
    v.backgroundColor = [UIColor clearColor];
    [self.vContent addSubview:v];
    
    NSDictionary *views = @{@"vv":self.vResult, @"v":v};
    NSArray *ch = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[v]-8-|" options:0 metrics:nil views:views];
    [self.vContent addConstraints:ch];
    NSArray *cv = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[vv]-8-[v(32)]|" options:0 metrics:nil views:views];
    [self.vContent addConstraints:cv];
    
    self.vMore = v;
}

- (void)initResetButton {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.translatesAutoresizingMaskIntoConstraints = NO;
    [btn setTitle:@"重置" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(onResetTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.vMore addSubview:btn];
    
    NSDictionary *views = @{@"btn":btn};
    NSArray *ch = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[btn(64)]" options:0 metrics:nil views:views];
    [self.vMore addConstraints:ch];
    NSArray *cv = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[btn]|" options:0 metrics:nil views:views];
    [self.vMore addConstraints:cv];
    
    self.btnReset = btn;
}

- (void)initRefreshButton {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.translatesAutoresizingMaskIntoConstraints = NO;
    [btn setTitle:@"刷新" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(onRefreshTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.vMore addSubview:btn];
    
    NSDictionary *views = @{@"btn":btn};
    NSArray *ch = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[btn(64)]|" options:0 metrics:nil views:views];
    [self.vMore addConstraints:ch];
    NSArray *cv = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[btn]|" options:0 metrics:nil views:views];
    [self.vMore addConstraints:cv];
    
    self.btnRefresh = btn;
}

- (void)initMemoryButton {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.translatesAutoresizingMaskIntoConstraints = NO;
    [btn setTitle:@"论坛iosGods.cn出品" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(onMemoryTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.vMore addSubview:btn];
    
    NSDictionary *views = @{@"reset":self.btnReset, @"btn":btn, @"refresh":self.btnRefresh};
    NSArray *ch = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[reset][btn][refresh]" options:0 metrics:nil views:views];
    [self.vMore addConstraints:ch];
    NSArray *cv = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[btn]|" options:0 metrics:nil views:views];
    [self.vMore addConstraints:cv];
    
    self.btnMemory = btn;
}

#pragma mark - Init Memory Content View
- (void)initMemoryContents {
    [self initMemoryContentView];
    [self initMemoryView];
    self.vMemoryContent.hidden = YES;
}

- (void)initMemoryContentView {
    UIView *v = [[UIView alloc] init];
    v.translatesAutoresizingMaskIntoConstraints = NO;
    v.backgroundColor = [UIColor clearColor];
    [self addSubview:v];
    
    NSDictionary *views = @{@"v":v};
    NSArray *ch = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[v]|" options:0 metrics:nil views:views];
    [self addConstraints:ch];
    NSArray *cv = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[v]|" options:0 metrics:nil views:views];
    [self addConstraints:cv];
    
    self.vMemoryContent = v;
}

#pragma mark - Init Memory View
- (void)initMemoryView {
    [self initMemoryViewContainer];
    [self initMemorySearchButton];
    [self initMemorySizeInput];
    [self initMemoryInput];
    [self initMemoryTextView];
    [self initBackFromMemoryButton];
}

- (void)initMemoryViewContainer {
    UIView *v = [[UIView alloc] init];
    v.translatesAutoresizingMaskIntoConstraints = NO;
    v.backgroundColor = [UIColor clearColor];
    [self.vMemoryContent addSubview:v];
    
    NSDictionary *views = @{@"v":v};
    NSArray *ch = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[v]-8-|" options:0 metrics:nil views:views];
    [self.vMemoryContent addConstraints:ch];
    NSArray *cv = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[v(32)]" options:0 metrics:nil views:views];
    [self.vMemoryContent addConstraints:cv];
    
    self.vMemory = v;
}

- (void)initMemorySearchButton {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.translatesAutoresizingMaskIntoConstraints = NO;
    [btn setTitle:@"搜索" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(onSearchMemoryTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.vMemory addSubview:btn];
    
    NSDictionary *views = @{@"btn":btn};
    NSArray *ch = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[btn(64)]|" options:0 metrics:nil views:views];
    [self.vMemory addConstraints:ch];
    NSArray *cv = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[btn]|" options:0 metrics:nil views:views];
    [self.vMemory addConstraints:cv];
    
    self.btnSearchMemory = btn;
}

- (void)initMemorySizeInput {
    UITextField *tf = [[UITextField alloc] init];
    tf.translatesAutoresizingMaskIntoConstraints = NO;
    tf.delegate = self;
    tf.borderStyle = UITextBorderStyleRoundedRect;
    tf.backgroundColor = [UIColor whiteColor];
    tf.textColor = [UIColor blackColor];
    tf.text = @"1024";
    tf.placeholder = @"Size";
    tf.returnKeyType = UIReturnKeyNext;
    tf.keyboardType = UIKeyboardTypeDefault;
    tf.clearButtonMode = UITextFieldViewModeNever;
    tf.spellCheckingType = UITextSpellCheckingTypeNo;
    tf.autocapitalizationType = UITextAutocapitalizationTypeNone;
    tf.autocorrectionType = UITextAutocorrectionTypeNo;
    tf.enabled = YES;
    [self.vMemory addSubview:tf];
    
    NSDictionary *views = @{@"tf":tf};
    NSArray *ch = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tf(64)]" options:0 metrics:nil views:views];
    [self.vMemory addConstraints:ch];
    NSArray *cv = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[tf]|" options:0 metrics:nil views:views];
    [self.vMemory addConstraints:cv];
    
    self.tfMemorySize = tf;
}

- (void)initMemoryInput {
    UITextField *tf = [[UITextField alloc] init];
    tf.translatesAutoresizingMaskIntoConstraints = NO;
    tf.delegate = self;
    tf.borderStyle = UITextBorderStyleRoundedRect;
    tf.backgroundColor = [UIColor whiteColor];
    tf.textColor = [UIColor blackColor];
    tf.text = @"0";
    tf.placeholder = @"Enter the address";
    tf.returnKeyType = UIReturnKeySearch;
    tf.keyboardType = UIKeyboardTypeDefault;
    tf.clearButtonMode = UITextFieldViewModeWhileEditing;
    tf.spellCheckingType = UITextSpellCheckingTypeNo;
    tf.autocapitalizationType = UITextAutocapitalizationTypeNone;
    tf.autocorrectionType = UITextAutocorrectionTypeNo;
    tf.enabled = YES;
    [self.vMemory addSubview:tf];
    
    NSDictionary *views = @{@"sz":self.tfMemorySize, @"tf":tf, @"btn":self.btnSearchMemory};
    NSArray *ch = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[sz]-8-[tf][btn]" options:0 metrics:nil views:views];
    [self.vMemory addConstraints:ch];
    NSArray *cv = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[tf]|" options:0 metrics:nil views:views];
    [self.vMemory addConstraints:cv];
    
    self.tfMemory = tf;
}

- (void)initMemoryTextView {
    UITextView *tv = [[UITextView alloc] init];
    tv.translatesAutoresizingMaskIntoConstraints = NO;
    tv.font = [UIFont fontWithName:@"Courier New" size:12];
    tv.backgroundColor = [UIColor clearColor];
    tv.textColor = [UIColor whiteColor];
    tv.textAlignment = NSTextAlignmentCenter;
    tv.editable = NO;
    tv.selectable = YES;
    [self.vMemoryContent addSubview:tv];
    
    NSDictionary *views = @{@"v":self.vMemory, @"tv":tv};
    NSArray *ch = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tv]|" options:0 metrics:nil views:views];
    [self.vMemoryContent addConstraints:ch];
    NSArray *cv = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[v]-8-[tv]" options:0 metrics:nil views:views];
    [self.vMemoryContent addConstraints:cv];
    
    self.tvMemory = tv;
}

- (void)initBackFromMemoryButton {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.translatesAutoresizingMaskIntoConstraints = NO;
    [btn setTitle:@"返回" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(onBackFromMemoryTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.vMemoryContent addSubview:btn];
    
    NSDictionary *views = @{@"tv":self.tvMemory, @"btn":btn};
    NSArray *ch = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[btn]|" options:0 metrics:nil views:views];
    [self.vMemoryContent addConstraints:ch];
    NSArray *cv = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[tv][btn(32)]|" options:0 metrics:nil views:views];
    [self.vMemoryContent addConstraints:cv];
    
    self.btnBackFromMemory = btn;
}

#pragma mark - Setter / Getter
- (void)setChainCount:(NSInteger)chainCount {
    _chainCount = chainCount;
    self.lblResult.text = [NSString stringWithFormat:@"Found %lld.", (long long)chainCount];
    if (chainCount > 0) {
        self.lcUValueTypeTopMargin.constant = -CGRectGetHeight(self.scUValueType.frame) * 2;
        self.scUValueType.hidden = YES;
        self.scSValueType.hidden = YES;
    } else {
        self.lcUValueTypeTopMargin.constant = 8;
        self.scUValueType.hidden = NO;
        self.scSValueType.hidden = NO;
    }
}

- (void)setChain:(search_result_chain_t)chain {
    _chain = chain;
    if (chainArray) {
        free(chainArray);
        chainArray = NULL;
    }
    
    if (self.chainCount > 0 && self.chainCount <= MaxResultCount) {
        chainArray = malloc(sizeof(search_result_t) * self.chainCount);
        search_result_chain_t c = chain;
        int i = 0;
        while (i < self.chainCount) {
            if (c->result) chainArray[i++] = c->result;
            c = c->next;
            if (c == NULL) break;
        }
        if (i < self.chainCount) self.chainCount = i;
    }
    if (chainArray==NULL) {
        return;
    }
    //=========================修改器==============================
    
    else if (self.dlgmemvalueKind==DLGMemValueTypexiugaiqi)
    {
        [self.tvResult reloadData];
    }
    
    //================================================================
    else if (self.dlgmemvalueKind==DLGMemValueTypeweijiashu)//微加速
    {
        for (int index=0; index<self.chainCount; index++)
        {
            search_result_t result = chainArray[index];
            NSString *address = [NSString stringWithFormat:@"%llX", result->address];
            if ([self.delegate respondsToSelector:@selector(DLGMemUIModifyValue:address:type:)]) {
                DLGMemValueType type = DLGMemValueTypeDouble;
                [self.delegate DLGMemUIModifyValue:@"0.00000000000015" address:address type:type];
            }
        }
    }
    else if (self.dlgmemvalueKind==DLGMemValueTypechaojijiashu)//超级加速
    {
        for (int index=0; index<self.chainCount; index++)
        {
            search_result_t result = chainArray[index];
            NSString *address = [NSString stringWithFormat:@"%llX", result->address];
            if ([self.delegate respondsToSelector:@selector(DLGMemUIModifyValue:address:type:)]) {
                DLGMemValueType type = DLGMemValueTypeDouble;
                [self.delegate DLGMemUIModifyValue:@"0.0000000000015" address:address type:type];
            }
        }
    }
    else if (self.dlgmemvalueKind==DLGMemValueTypetianxian1)//天线1
    {
        for (int index=0; index<self.chainCount; index++)
        {
            search_result_t result = chainArray[index];
            NSString *address = [NSString stringWithFormat:@"%llX", result->address];
            if ([self.delegate respondsToSelector:@selector(DLGMemUIModifyValue:address:type:)]) {
                DLGMemValueType type = DLGMemValueTypeDouble;
                [self.delegate DLGMemUIModifyValue:@"99999" address:address type:type];
            }
        }
    }
    else if (self.dlgmemvalueKind==DLGMemValueTypetianxian2)//天线1
    {
        for (int index=0; index<self.chainCount; index++)
        {
            search_result_t result = chainArray[index];
            NSString *address = [NSString stringWithFormat:@"%llX", result->address];
            if ([self.delegate respondsToSelector:@selector(DLGMemUIModifyValue:address:type:)]) {
                DLGMemValueType type = DLGMemValueTypeFloat;
                [self.delegate DLGMemUIModifyValue:@"9999" address:address type:type];
            }
        }
    }
    else if (self.dlgmemvalueKind==DLGMemValueTypegaotiao)//高跳
    {
        for (int index=0; index<self.chainCount; index++)
        {
            search_result_t result = chainArray[index];
            NSString *address = [NSString stringWithFormat:@"%llX", result->address];
            if ([self.delegate respondsToSelector:@selector(DLGMemUIModifyValue:address:type:)]) {
                DLGMemValueType type = DLGMemValueTypeDouble;
                [self.delegate DLGMemUIModifyValue:@"9.799835061195899e+21" address:address type:type];
            }
        }
    }
    else if (self.dlgmemvalueKind==DLGMemValueTypechuchao)//
    {
        for (int index=0; index<self.chainCount; index++)
        {
            search_result_t result = chainArray[index];
            NSString *address = [NSString stringWithFormat:@"%llX", result->address];
            if ([self.delegate respondsToSelector:@selector(DLGMemUIModifyValue:address:type:)]) {
                DLGMemValueType type = DLGMemValueTypeUnsignedLong;
                [self.delegate DLGMemUIModifyValue:@"500" address:address type:type];
            }
        }
    }
    /*
     //这些示例
     //批量全改 比如全改0 DLGMemValueTypekaitongjichang对应枚举 在DLGMemUIViewDelegate.h
     else if (self.dlgmemvalueKind==DLGMemValueTypepigutianxian)//屁股天线
     {
     for (int index=0; index<self.chainCount; index++)
     {
     search_result_t result = chainArray[index];
     NSString *address = [NSString stringWithFormat:@"%llX", result->address];
     if ([self.delegate respondsToSelector:@selector(DLGMemUIModifyValue:address:type:)]) {
     DLGMemValueType type = DLGMemValueTypeUnsignedInt;
     [self.delegate DLGMemUIModifyValue:@"0" address:address type:type];
     }
     }
     }
     
     //修改前几个 比如修改前5个 0代表1 4代表5 以此类推
     else if (self.dlgmemvalueKind==DLGMemValueTypekaitongjichang)
     {
     for (int index=0; index<4; index++)
     {
     search_result_t result = chainArray[index];
     NSString *address = [NSString stringWithFormat:@"%llX", result->address];
     NSString *value = [self valueStringFromResult:result];
     if ([self.delegate respondsToSelector:@selector(DLGMemUIModifyValue:address:type:)]) {
     DLGMemValueType type = DLGMemValueTypeDouble;
     [self.delegate DLGMemUIModifyValue:@"1548112659116032" address:address type:type];
     //            }
     }
     }
     }
     
     
     //修改搜索出来的尾号第一个 比如增加了判断改所有结果中8c4结尾的第一个
     else if (self.dlgmemvalueKind==DLGMemValueTypekaitongjichang)
     {
     for (int a=0; a<self.chainCount; a++)
     {
     search_result_t result = chainArray[a];
     NSString *address = [NSString stringWithFormat:@"%llX", result->address];
     if ([[address substringFromIndex:address.length-3] isEqualToString:@"8c4"]) {
     if ([self.delegate respondsToSelector:@selector(DLGMemUIModifyValue:address:type:)]) {
     DLGMemValueType type = DLGMemValueTypeUnsignedInt;
     [self.delegate DLGMemUIModifyValue:@"1147207680" address:address type:type];
     }
     }
     }
     }
     //=========================修改器==============================
     
     else if (self.dlgmemvalueKind==DLGMemValueTypexiugaiqi)
     {
     [self.tvResult reloadData];
     }
     
     //================================================================
     
     */
    ////////////////////////一段代码修改完毕 以此类推////////////////////////
    if (self.dlgmemvalueKind!=DLGMemValueTypexiugaiqi) {
        if ([self.delegate respondsToSelector:@selector(DLGMemUIReset)]) {
            [self.delegate DLGMemUIReset];
        }
    }
}

- (void)shoudonggaima
{
    _shouldNotBeDragged = YES;
    CGRect frame = self.rcCollapsedFrame;
    frame.origin = self.frame.origin;
    self.rcCollapsedFrame = frame;
    self.btnConsole.hidden = YES;
    self.layer.cornerRadius = 0;
    [UIView animateWithDuration:0.2f
                          delay:0.0f
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.frame = self.rcExpandedFrame;
                         self.alpha = DLG_DEBUG_CONSOLE_VIEW_MAX_ALPHA;
                     }
                     completion:^(BOOL finished) {
                         self.frame = self.rcExpandedFrame;
                         self.alpha = DLG_DEBUG_CONSOLE_VIEW_MAX_ALPHA;
                         self.vShowingContent.hidden = NO;
                         self->_expanded = YES;
                     }];
    
    [self addGesture];
}

#pragma mark - Gesture

- (void)addGesture {
    if (self.tapGesture != nil) return;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:tap];
    
    self.tapGesture = tap;
}

- (void)removeGesture {
    if (self.tapGesture == nil) { return; }
    
    [self removeGestureRecognizer:self.tapGesture];
    self.tapGesture = nil;
}

#pragma mark - Events
- (void)onSearchTapped:(id)sender {
    [self.tfValue resignFirstResponder];
    if ([self.delegate respondsToSelector:@selector(DLGMemUISearchValue:type:comparison:)]) {
        NSString *value = self.tfValue.text;
        if (value.length == 0) return;
        DLGMemValueType type = [self currentValueType];
        DLGMemComparison comparison = [self currentComparison];
        switch (self.selectedComparisonIndex) {
            case 0: comparison = DLGMemComparisonLT; break;
            case 1: comparison = DLGMemComparisonLE; break;
            case 2: comparison = DLGMemComparisonEQ; break;
            case 3: comparison = DLGMemComparisonGE; break;
            case 4: comparison = DLGMemComparisonGT; break;
        }
        [self.delegate DLGMemUISearchValue:value type:type comparison:comparison];
    }
}

- (void)onResetTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(DLGMemUIReset)]) {
        [self.delegate DLGMemUIReset];
    }
}

- (void)onRefreshTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(DLGMemUIRefresh)]) {
        [self.delegate DLGMemUIRefresh];
    }
}

- (void)onMemoryTapped:(id)sender {
    if (self.tvMemory.text.length == 0) {
        [self showMemory:self.tfMemory.text];
    } else {
        [self showMemory];
    }
}

- (void)onComparisonChanged:(id)sender {
    self.selectedComparisonIndex = self.scComparison.selectedSegmentIndex;
}

- (void)onValueTypeChanged:(id)sender {
    BOOL isUnsigned = (sender == self.scUValueType);
    UISegmentedControl *sc = isUnsigned ? self.scUValueType : self.scSValueType;
    UISegmentedControl *sc2 = isUnsigned ? self.scSValueType : self.scUValueType;
    sc.selected = YES;
    sc2.selected = NO;
    sc2.selectedSegmentIndex = -1;
    self.isUnsignedValueType = isUnsigned;
    self.selectedValueTypeIndex = sc.selectedSegmentIndex;
    self.lblType.text = [self stringFromValueType:[self currentValueType]];
}

- (void)onSearchMemoryTapped:(id)sender {
    [self.tfMemory resignFirstResponder];
    [self.tfMemorySize resignFirstResponder];
    NSString *address = self.tfMemory.text;
    NSString *size = self.tfMemorySize.text;
    if (address.length == 0) return;
    if ([self.delegate respondsToSelector:@selector(DLGMemUIMemory:size:)]) {
        NSString *memory = [self.delegate DLGMemUIMemory:address size:size];
        self.tvMemory.text = memory;
    }
}

- (void)onBackFromMemoryTapped:(id)sender {
    self.vMemoryContent.hidden = YES;
    self.vContent.hidden = NO;
    self.vShowingContent = self.vContent;
    self.tvMemory.text = @"";
}

- (void)showMemory {
    self.vContent.hidden = YES;
    self.vMemoryContent.hidden = NO;
    self.vShowingContent = self.vMemoryContent;
}

- (void)showMemory:(NSString *)address {
    [self showMemory];
    self.tfMemory.text = address;
    self.tvMemory.text = @"";
    [self onSearchMemoryTapped:nil];
}

- (void)onConsoleButtonTapped:(id)sender {
    [self doExpand];
}
- (NSMutableString *)encryptMd5:(NSString *)origingString{
    //md5加密
    const char *cStr = [origingString UTF8String];
    unsigned char digest[16];
    
    CC_MD5( cStr,(CC_LONG)strlen(cStr), digest ); // This is the md5 call
    
    //加密成md5的字符串
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    NSLog(@"output=====%@",output);
    return output;
}

#pragma mark - Expand & Collapse
- (void)expand {
    
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    
    
    
    
    /*/===================================================================
     //子菜单显示
     [alert addButton:@"基本功能1" actionBlock:^(void) {
     SCLAlertView *alertxxxxxxxxxxxxx = [[SCLAlertView alloc] initWithNewWindow];
     
     [alertxxxxxxxxxxxxx addButton:@"修改器" actionBlock:^(void) {
     self.dlgmemvalueKind    =   DLGMemValueTypexiugaiqi;
     [self shoudonggaima];
     }];
     alertxxxxxxxxxxxxx.shouldDismissOnTapOutside    =   YES;
     [alertxxxxxxxxxxxxx showSuccess:@"iosGods.cn" subTitle:@"欢迎您使用" closeButtonTitle:@"取消" duration:0.0f];
     }];
     ////子菜单显示
     //主菜单显示
     [alert addButton:@"修改器" actionBlock:^(void) {
     SCLAlertView *alertxxxxxxxxxxxxx = [[SCLAlertView alloc] initWithNewWindow];
     self.dlgmemvalueKind    =   DLGMemValueTypexiugaiqi;
     [self shoudonggaima];
     
     alertxxxxxxxxxxxxx.shouldDismissOnTapOutside    =   YES;
     
     }];
     //主菜单显示
     ===================================================================*/
    
    
    [alert addButton:@"手动修改器" actionBlock:^(void) {
        SCLAlertView *alertxxxxxxxxxxxxx = [[SCLAlertView alloc] initWithNewWindow];
        self.dlgmemvalueKind    =   DLGMemValueTypexiugaiqi;
        [self shoudonggaima];
        
        alertxxxxxxxxxxxxx.shouldDismissOnTapOutside    =   YES;
        
    }];
    //===================================================================
    //第一个菜单名称
    [alert addButton:@"加速/天线/高跳/除草" actionBlock:^(void) {
        SCLAlertView *alertxxxxxxxxxxxxx = [[SCLAlertView alloc] initWithNewWindow];
        
        [alertxxxxxxxxxxxxx addButton:@"微加速" actionBlock:^(void) {
            
            if ([self.delegate respondsToSelector:@selector(DLGMemUISearchValue:type:comparison:)]) {
                self.dlgmemvalueKind    =   DLGMemValueTypeweijiashu;
                NSString *value = @"3.009032636233833e-29";
                if (value.length == 0) return;
                DLGMemValueType type = DLGMemValueTypeDouble;
                DLGMemComparison comparison = DLGMemComparisonEQ;
                //               dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.delegate DLGMemUISearchValue:value type:type comparison:comparison];
                //                });
            }
            
        }];
        
        
        [alertxxxxxxxxxxxxx addButton:@"超级加速" actionBlock:^(void) {
            
            if ([self.delegate respondsToSelector:@selector(DLGMemUISearchValue:type:comparison:)]) {
                self.dlgmemvalueKind    =   DLGMemValueTypechaojijiashu;
                NSString *value = @"3.009032636233833e-29";
                if (value.length == 0) return;
                DLGMemValueType type = DLGMemValueTypeDouble;
                DLGMemComparison comparison = DLGMemComparisonEQ;
                //               dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.delegate DLGMemUISearchValue:value type:type comparison:comparison];
                //                });
            }
            
        }];
        [alertxxxxxxxxxxxxx addButton:@"高跳" actionBlock:^(void) {
            
            if ([self.delegate respondsToSelector:@selector(DLGMemUISearchValue:type:comparison:)]) {
                self.dlgmemvalueKind    =   DLGMemValueTypegaotiao;
                NSString *value = @"9.799835061195899e+18";
                if (value.length == 0) return;
                DLGMemValueType type = DLGMemValueTypeDouble;
                DLGMemComparison comparison = DLGMemComparisonEQ;
                //               dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.delegate DLGMemUISearchValue:value type:type comparison:comparison];
                //                });
            }
            
        }];
        [alertxxxxxxxxxxxxx addButton:@"天线1" actionBlock:^(void) {
            
            if ([self.delegate respondsToSelector:@selector(DLGMemUISearchValue:type:comparison:)]) {
                self.dlgmemvalueKind    =   DLGMemValueTypetianxian1;
                NSString *value = @"0.007812501672160507";
                if (value.length == 0) return;
                DLGMemValueType type = DLGMemValueTypeDouble;
                DLGMemComparison comparison = DLGMemComparisonEQ;
                //               dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.delegate DLGMemUISearchValue:value type:type comparison:comparison];
                //                });
            }
            
        }];
        [alertxxxxxxxxxxxxx addButton:@"天线2" actionBlock:^(void) {
            
            if ([self.delegate respondsToSelector:@selector(DLGMemUISearchValue:type:comparison:)]) {
                self.dlgmemvalueKind    =   DLGMemValueTypetianxian2;
                NSString *value = @"0.9965747";
                if (value.length == 0) return;
                DLGMemValueType type = DLGMemValueTypeFloat;
                DLGMemComparison comparison = DLGMemComparisonEQ;
                //               dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.delegate DLGMemUISearchValue:value type:type comparison:comparison];
                //                });
            }
            
        }];
        [alertxxxxxxxxxxxxx addButton:@"除草" actionBlock:^(void) {
            
            if ([self.delegate respondsToSelector:@selector(DLGMemUISearchValue:type:comparison:)]) {
                self.dlgmemvalueKind    =   DLGMemValueTypechuchao;
                NSString *value = @"100000000";
                if (value.length == 0) return;
                DLGMemValueType type = DLGMemValueTypeUnsignedLong;
                DLGMemComparison comparison = DLGMemComparisonEQ;
                //               dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.delegate DLGMemUISearchValue:value type:type comparison:comparison];
                //                });
            }
            
        }];
        
        //子菜单结尾
        alertxxxxxxxxxxxxx.shouldDismissOnTapOutside    =   YES;
        [alertxxxxxxxxxxxxx showSuccess:@"iosGods.cn" subTitle:@"QQ350722326" closeButtonTitle:@"取消" duration:0.0f];
    }];
    //菜单结束
    //第一个菜单名称
    //菜单结束
    //===================================================================
    //总带单取消按钮////
    alert.soundURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/right_answer.mp3", [NSBundle mainBundle].resourcePath]];
    
    [alert showSuccess:@"iosGods.cn" subTitle:@"QQ350722326" closeButtonTitle:@"取消" duration:0.0f];
    
}
//总带单取消按钮结束////
//===================================================================

//修改器代码
#pragma mark - Gesture

- (void)collapse {
    _shouldNotBeDragged = NO;
    CGRect frame = self.rcExpandedFrame;
    frame.origin = self.frame.origin;
    self.rcExpandedFrame = frame;
    self.layer.cornerRadius = CGRectGetWidth(self.rcCollapsedFrame) / 2;
    self.vShowingContent.hidden = YES;
    [self.tfFocused resignFirstResponder];
    [self removeGesture];
    [UIView animateWithDuration:0.2f
                          delay:0.0f
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.frame = self.rcCollapsedFrame;
                         self.alpha = DLG_DEBUG_CONSOLE_VIEW_MIN_ALPHA;
                     }
                     completion:^(BOOL finished) {
                         self.frame = self.rcCollapsedFrame;
                         self.alpha = DLG_DEBUG_CONSOLE_VIEW_MIN_ALPHA;
                         self->_expanded = NO;
                     }];
}


- (void)handleGesture:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        CGPoint pt = [sender locationInView:self.window];
        CGRect frameInScreen = self.tfValue.frame;
        frameInScreen.origin.x += CGRectGetMinX(self.frame);
        frameInScreen.origin.y += CGRectGetMinY(self.frame);
        if (CGRectContainsPoint(frameInScreen, pt)) {
            if ([self.tfValue canBecomeFirstResponder]) {
                [self.tfValue becomeFirstResponder];
            }
        } else {
            [self doCollapse];
        }
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.tfValue) {
        if (textField.returnKeyType == UIReturnKeySearch) {
            [self onSearchTapped:nil];
        }
    } else if (textField == self.tfMemory) {
        if (textField.returnKeyType == UIReturnKeySearch) {
            [self onSearchMemoryTapped:nil];
        }
    } else if (textField == self.tfMemorySize) {
        if (textField.returnKeyType == UIReturnKeyNext) {
            [self.tfMemory becomeFirstResponder];
        }
    } else {
        [textField resignFirstResponder];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.tfFocused = textField;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.chainCount > MaxResultCount) return 0;
    return self.chainCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return DLGMemUIViewCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DLGMemUIViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DLGMemUIViewCellID forIndexPath:indexPath];
    cell.delegate = self;
    cell.textFieldDelegate = self;
    
    NSInteger index = indexPath.row;
    search_result_t result = chainArray[index];
    NSString *address = [NSString stringWithFormat:@"%llX", result->address];
    NSString *value = [self valueStringFromResult:result];
    cell.address = address;
    cell.value = value;
    cell.modifying = NO;
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger index = indexPath.row;
    search_result_t result = chainArray[index];
    NSString *address = [NSString stringWithFormat:@"%llX", result->address];
    [self showMemory:address];
}

#pragma mark - DLGMemUIViewCellDelegate
- (void)DLGMemUIViewCellModify:(NSString *)address value:(NSString *)value {
    if ([self.delegate respondsToSelector:@selector(DLGMemUIModifyValue:address:type:)]) {
        DLGMemValueType type = [self currentValueType];
        [self.delegate DLGMemUIModifyValue:value address:address type:type];
    }
}

- (void)DLGMemUIViewCellViewMemory:(NSString *)address {
    [self showMemory:address];
}

#pragma mark - Utils
- (NSString *)valueStringFromResult:(search_result_t)result {
    NSString *value = nil;
    int type = result->type;
    if (type == SearchResultValueTypeUInt8) {
        uint8_t v = *(uint8_t *)(result->value);
        value = [NSString stringWithFormat:@"%u", v];
    } else if (type == SearchResultValueTypeSInt8) {
        int8_t v = *(int8_t *)(result->value);
        value = [NSString stringWithFormat:@"%d", v];
    } else if (type == SearchResultValueTypeUInt16) {
        uint16_t v = *(uint16_t *)(result->value);
        value = [NSString stringWithFormat:@"%u", v];
    } else if (type == SearchResultValueTypeSInt16) {
        int16_t v = *(int16_t *)(result->value);
        value = [NSString stringWithFormat:@"%d", v];
    } else if (type == SearchResultValueTypeUInt32) {
        uint32_t v = *(uint32_t *)(result->value);
        value = [NSString stringWithFormat:@"%u", v];
    } else if (type == SearchResultValueTypeSInt32) {
        int32_t v = *(int32_t *)(result->value);
        value = [NSString stringWithFormat:@"%d", v];
    } else if (type == SearchResultValueTypeUInt64) {
        uint64_t v = *(uint64_t *)(result->value);
        value = [NSString stringWithFormat:@"%llu", v];
    } else if (type == SearchResultValueTypeSInt64) {
        int64_t v = *(int64_t *)(result->value);
        value = [NSString stringWithFormat:@"%lld", v];
    } else if (type == SearchResultValueTypeFloat) {
        float v = *(float *)(result->value);
        value = [NSString stringWithFormat:@"%f", v];
    } else if (type == SearchResultValueTypeDouble) {
        double v = *(double *)(result->value);
        value = [NSString stringWithFormat:@"%f", v];
    } else {
        NSMutableString *ms = [NSMutableString string];
        char *v = (char *)(result->value);
        for (int i = 0; i < result->size; ++i) {
            printf("%02X ", v[i]);
            [ms appendFormat:@"%02X ", v[i]];
        }
        value = ms;
    }
    return value;
}

- (DLGMemValueType)currentValueType {
    DLGMemValueType type = DLGMemValueTypeSignedInt;
    switch (self.selectedValueTypeIndex) {
        case 0: type = self.isUnsignedValueType ? DLGMemValueTypeUnsignedByte : DLGMemValueTypeSignedByte; break;
        case 1: type = self.isUnsignedValueType ? DLGMemValueTypeUnsignedShort : DLGMemValueTypeSignedShort; break;
        case 2: type = self.isUnsignedValueType ? DLGMemValueTypeUnsignedInt : DLGMemValueTypeSignedInt; break;
        case 3: type = self.isUnsignedValueType ? DLGMemValueTypeUnsignedLong : DLGMemValueTypeSignedLong; break;
        case 4: type = self.isUnsignedValueType ? DLGMemValueTypeFloat : DLGMemValueTypeDouble; break;
    }
    return type;
}

- (DLGMemComparison)currentComparison {
    DLGMemComparison comparison = DLGMemComparisonEQ;
    switch (self.selectedComparisonIndex) {
        case 0: comparison = DLGMemComparisonLT; break;
        case 1: comparison = DLGMemComparisonLE; break;
        case 2: comparison = DLGMemComparisonEQ; break;
        case 3: comparison = DLGMemComparisonGE; break;
        case 4: comparison = DLGMemComparisonGT; break;
    }
    return comparison;
}

- (NSString *)stringFromValueType:(DLGMemValueType)type {
    switch (type) {
        case DLGMemValueTypeUnsignedByte: return @"UByte";
        case DLGMemValueTypeSignedByte: return @"SByte";
        case DLGMemValueTypeUnsignedShort: return @"UShort";
        case DLGMemValueTypeSignedShort: return @"SShort";
        case DLGMemValueTypeUnsignedInt: return @"UInt";
        case DLGMemValueTypeSignedInt: return @"SInt";
        case DLGMemValueTypeUnsignedLong: return @"ULong";
        case DLGMemValueTypeSignedLong: return @"SLong";
        case DLGMemValueTypeFloat: return @"Float";
        case DLGMemValueTypeDouble: return @"Double";
        default: return @"--";
    }
}

@end
