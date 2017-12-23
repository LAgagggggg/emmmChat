//
//  EmmmChatViewController.m
//  emmmChat
//
//  Created by 李嘉银 on 15/12/2017.
//  Copyright © 2017 李嘉银. All rights reserved.
//
#define backgroundGreyColor [UIColor colorWithRed:246/255. green:246/255. blue:246/255. alpha:1]
#define deepBlueColor [UIColor colorWithRed:55/255. green:125/255. blue:255/255. alpha:1]
#define statusBarHeight [[UIApplication sharedApplication] statusBarFrame].size.height
#define lightBlueColor [UIColor colorWithRed:225/255. green:238/255. blue:253/255. alpha:1]
#define MAXHEIGHTofInputView 80.f

#import "EmmmChatViewController.h"

@interface EmmmChatViewController ()
@property(strong,nonatomic)UIView * navigationView;
@property(strong,nonatomic)UIView * bottomMessageView;
@property(strong,nonatomic)UITextView * messageInputView;
@property(strong,nonatomic)UIView * btnPopView;
@property(strong,nonatomic)NSArray * btnArr;
@property BOOL btnsAlreadyPoped;
@end

@implementation EmmmChatViewController

-(instancetype)initWithContact:(EmmmContact *)contact{
    self = [super init];
    self.view.backgroundColor=backgroundGreyColor;
    //uigesturerecognizer用于判断点击注销输入
    UITapGestureRecognizer * tap=[[UITapGestureRecognizer alloc]init];
    tap.delegate=self;
    [self.view addGestureRecognizer:tap];
    //导航栏
    self.navigationView=[[UIView alloc]init];
    self.navigationView.backgroundColor=deepBlueColor;
    [self.view addSubview:self.navigationView];
    [self.navigationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.top.equalTo(self.view.mas_top).with.offset(statusBarHeight);
        make.height.equalTo(@(41.5));
    }];
    UIButton * backBtn=[UIButton buttonWithType:UIButtonTypeSystem];
    [backBtn addTarget:self action:@selector(returnToMain) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setImage:[UIImage imageNamed:@"返回"] forState:UIControlStateNormal];
    UIButton * menuBtn=[UIButton buttonWithType:UIButtonTypeSystem];
    [menuBtn setImage:[UIImage imageNamed:@"菜单 (1)"] forState:UIControlStateNormal];
    [self.navigationView addSubview:backBtn];
    [self.navigationView addSubview:menuBtn];
    [backBtn setTintColor:[UIColor whiteColor]];
    [menuBtn setTintColor:[UIColor whiteColor]];
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.navigationView.mas_left).with.offset(11);
        make.top.equalTo(self.navigationView.mas_top).with.offset(8);
        make.height.equalTo(@(28.5));
        make.width.equalTo(backBtn.mas_height);
    }];
    [menuBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.navigationView.mas_right).with.offset(-15.5);
        make.top.equalTo(self.navigationView.mas_top).with.offset(8);
        make.height.equalTo(@(28.5));
        make.width.equalTo(menuBtn.mas_height);
    }];
    //输入框
    self.bottomMessageView=[[UIView alloc]init];
    self.bottomMessageView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:self.bottomMessageView];
    self.messageInputView=[[UITextView alloc]initWithFrame:CGRectMake(40, 10, [UIScreen mainScreen].bounds.size.width-42.5-40, 32.5)];
    self.messageInputView.backgroundColor=lightBlueColor;
    self.messageInputView.delegate=self;
    self.messageInputView.layer.cornerRadius=10.f;
    self.messageInputView.layoutManager.allowsNonContiguousLayout=YES;
    [self.messageInputView setFont:[UIFont systemFontOfSize:13]];
    [self.bottomMessageView addSubview:self.messageInputView];
    [self.bottomMessageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom);
        make.height.equalTo(self.messageInputView.mas_height).with.offset(18);
    }];
    UIButton * moreBtn=[UIButton buttonWithType:UIButtonTypeSystem];
    [moreBtn addTarget:self action:@selector(PopMoreBtn) forControlEvents:UIControlEventTouchUpInside];
    [moreBtn setImage:[UIImage imageNamed:@"添加"] forState:UIControlStateNormal];
    UIButton * stickerBtn=[UIButton buttonWithType:UIButtonTypeSystem];
    [stickerBtn setImage:[UIImage imageNamed:@"表情"] forState:UIControlStateNormal];
    [self.bottomMessageView addSubview:moreBtn];
    [self.bottomMessageView addSubview:stickerBtn];
    [moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomMessageView.mas_left).with.offset(8);
        make.bottom.equalTo(self.bottomMessageView.mas_bottom).with.offset(-11);
        make.height.equalTo(@(26));
        make.width.equalTo(moreBtn.mas_height);
    }];
    [stickerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.bottomMessageView.mas_right).with.offset(-9.5);
        make.bottom.equalTo(self.bottomMessageView.mas_bottom).with.offset(-11);
        make.height.equalTo(@(26));
        make.width.equalTo(stickerBtn.mas_height);
    }];
    //textview随键盘移动
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)                                           name:UIKeyboardWillChangeFrameNotification object:nil];
    return self;
}
//弹出更多按钮
-(void)PopMoreBtn{
    CGFloat edgeMargin=15;
    CGFloat btnAmounts=5;
    CGFloat btnSize=45;
    CGFloat betweenMargin=([UIScreen mainScreen].bounds.size.width-2*edgeMargin-5*btnSize)/(btnAmounts-1);
    if (!self.btnPopView) {
        self.btnPopView=[[UIView alloc]init];
        [self.bottomMessageView addSubview:self.btnPopView];
        [self.btnPopView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.bottomMessageView.mas_right);
            make.left.equalTo(self.bottomMessageView.mas_left);
            make.bottom.equalTo(self.bottomMessageView.mas_top).with.offset(-14);
            make.height.equalTo(@(45));
        }];
        self.btnPopView.backgroundColor=[UIColor clearColor];
        EmmmAttachmentWrapperView * btn1=[[EmmmAttachmentWrapperView alloc]initWithImage:[UIImage imageNamed:@"照片"]];
        EmmmAttachmentWrapperView * btn2=[[EmmmAttachmentWrapperView alloc]initWithImage:[UIImage imageNamed:@"拍照"]];
        EmmmAttachmentWrapperView * btn3=[[EmmmAttachmentWrapperView alloc]initWithImage:[UIImage imageNamed:@"语音"]];
        EmmmAttachmentWrapperView * btn4=[[EmmmAttachmentWrapperView alloc]initWithImage:[UIImage imageNamed:@"视频"]];
        EmmmAttachmentWrapperView * btn5=[[EmmmAttachmentWrapperView alloc]initWithImage:[UIImage imageNamed:@"红包"]];
        self.btnArr=@[btn1,btn2,btn3,btn4,btn5];
        for (EmmmAttachmentWrapperView * btn in self.btnArr) {
            [self.btnPopView addSubview:btn];
            [UIView animateWithDuration:1.0 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseIn animations:^{
                [btn setFrame:CGRectMake(edgeMargin+[self.btnArr indexOfObject:btn]*(betweenMargin+btnSize), 0, btnSize, btnSize)];
            } completion:nil];
            
        }
        self.btnsAlreadyPoped=YES;
    }
    else{
        if (self.btnsAlreadyPoped==YES) {
            for (EmmmAttachmentWrapperView * btn in self.btnArr) {
                [self.btnPopView addSubview:btn];
                [UIView animateWithDuration:1.0 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    [btn setFrame:CGRectMake(-2*btnSize, 0, btnSize, btnSize)];
                } completion:nil];
            }
            self.btnsAlreadyPoped=NO;
        }
        else{
            for (EmmmAttachmentWrapperView * btn in self.btnArr) {
                [self.btnPopView addSubview:btn];
                [UIView animateWithDuration:1.0 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseIn animations:^{
                    [btn setFrame:CGRectMake(edgeMargin+[self.btnArr indexOfObject:btn]*(betweenMargin+btnSize), 0, btnSize, btnSize)];
                } completion:nil];
            }
            self.btnsAlreadyPoped=YES;
        }
    }
    
}
//监控textview改变
-(void)textViewDidChange:(UITextView *)textView{//TextView自适应尺寸
    //保存包裹textview的view的y值
    float wrappperViewY=self.bottomMessageView.frame.origin.y;
    float originalHeight=textView.frame.size.height;
    //获取合适的高度
    float textViewHeight =  [self.messageInputView sizeThatFits:CGSizeMake(self.messageInputView.frame.size.width, MAXFLOAT)].height;
    if (textViewHeight <= MAXHEIGHTofInputView && textViewHeight > 32.5) {
        CGRect frame= self.messageInputView.frame;
        frame.size.height=textViewHeight;
        self.messageInputView.frame = frame;
        [self.view layoutIfNeeded];
    }
    else if(textViewHeight < 32.5){
        CGRect frame= self.messageInputView.frame;
        frame.size.height=32.5;
        self.messageInputView.frame = frame;
        [self.view layoutIfNeeded];
    }
//    NSLog(@"%@",NSStringFromCGRect(self.bottomMessageView.frame));
    //
    float changedHeight=self.messageInputView.frame.size.height-originalHeight;
    CGRect frame=self.bottomMessageView.frame;
    frame.origin.y=wrappperViewY-changedHeight;
    self.bottomMessageView.frame=frame;
}
//弹出键盘时
-(void)keyboardWillShow:(NSNotification *)notification{
    NSDictionary *userInfo = [notification userInfo];
    NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [value CGRectValue];
    CGRect frame=self.bottomMessageView.frame;
    frame.origin.y=keyboardRect.origin.y-frame.size.height;
    self.bottomMessageView.frame=frame;
//    NSLog(@"%@",NSStringFromCGRect(frame));
}
//返回键
-(void)returnToMain{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//设置右滑返回
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
//     self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
}
//识别点击注销textview
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if (![touch.view isDescendantOfView:self.messageInputView]) {
        if ([self.messageInputView isFirstResponder]) {
            [self.messageInputView resignFirstResponder];
        }
    }
    return NO;
}


@end
