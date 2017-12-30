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
#define INITHEIGHTOFINPUTVIEW 32

#import "EmmmChatViewController.h"

@interface EmmmChatViewController ()
@property(strong,nonatomic)UIView * navigationView;
@property(strong,nonatomic)UIView * bottomMessageView;
@property(strong,nonatomic)UITextView * messageInputView;
@property(strong,nonatomic)UIView * btnPopView;
@property(strong,nonatomic)NSArray * btnArr;
@property(strong,nonatomic)UIImage * friendIcon;
@property(strong,nonatomic)NSString * friendName;
@property(strong,nonatomic)UITableView * chatTableView;
@property(strong,nonatomic)NSMutableArray * messagesArr;
@property CGFloat currentTableViewInset;
@property BOOL btnsAlreadyPoped;
@end

@implementation EmmmChatViewController

static NSString * const myReuseIdentifier = @"myCell";
static NSString * const friendRuseIdentifier = @"friendCell";

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
    self.messageInputView=[[UITextView alloc]initWithFrame:CGRectMake(40, 10, [UIScreen mainScreen].bounds.size.width-42.5-40, INITHEIGHTOFINPUTVIEW)];
    self.messageInputView.backgroundColor=lightBlueColor;
    self.messageInputView.delegate=self;
    self.messageInputView.returnKeyType=UIReturnKeySend;
    self.messageInputView.layer.cornerRadius=10.f;
    self.messageInputView.layoutManager.allowsNonContiguousLayout=YES;
    [self.messageInputView setFont:[UIFont systemFontOfSize:14]];
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
    //设置TableView
    self.chatTableView=[[UITableView alloc]init];
    self.chatTableView.backgroundColor=[UIColor clearColor];
    [self.view addSubview:self.chatTableView];
    [self.view sendSubviewToBack:self.chatTableView];
    self.chatTableView.showsVerticalScrollIndicator=NO;
    [self.chatTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.bottomMessageView.mas_top);
        make.top.equalTo(self.navigationView.mas_bottom);
    }];
    self.chatTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    [self.chatTableView registerClass:[EmmmChatTableViewTowardCell class] forCellReuseIdentifier:myReuseIdentifier];
    [self.chatTableView registerClass:[EmmmChatTableViewReceivedCell class] forCellReuseIdentifier:friendRuseIdentifier];
    self.chatTableView.estimatedRowHeight=44;
    self.chatTableView.rowHeight=UITableViewAutomaticDimension;
    self.chatTableView.delegate=self;
    self.chatTableView.dataSource=self;
    //kvo监听bottomview的y值变化以上下移动tableView
//    [self.bottomMessageView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    //设置对方信息
    self.friendIcon=contact.iconImage;
    self.friendName=contact.name;
    return self;
}
//懒加载数据数组
-(NSMutableArray *)messagesArr{
    if (!_messagesArr) {
        _messagesArr=[[NSMutableArray alloc]init];
        EmmmMessage * msg1=[[EmmmMessage alloc]initMessageWithText:@"hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh" andFrom:self.userName To:self.friendName];
        EmmmMessage * msg2=[[EmmmMessage alloc]initMessageWithText:@"永和有永和路，中和有中和路，中和的中和路有接永和的中和路，永和的永和路沒接中和的永和路；永和的中和路有接永和的永和路，中和的永和路沒接中和的中和路。永和有中正路，中和有中正路，永和的中正路用景平路接中和的中正路；永和有中山路，中和有中山路，永和的中山路直接接上了中和的中山路。永和的中正路接上了永和的中山路，中和的中正路卻不接中和的中山路。中正橋下來不是中正路，但永和有中正路；秀朗橋下來也不是秀朗路，但永和也有秀朗路。永福橋下來不是永福路，永和沒有永福路；福和橋下來不是福和路，但福和路接的是永福橋。" andFrom:self.userName To:self.friendName];
        EmmmMessage * msg3=[[EmmmMessage alloc]initMessageWithText:@"黑化黑灰化肥黑灰会挥发发灰黑化肥黑灰化肥挥发；灰化灰黑化肥灰黑会发挥发黑灰化肥灰黑化肥发挥" andFrom:self.userName To:self.friendName];
        EmmmMessage * msg4=[[EmmmMessage alloc]initMessageWithText:@"hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh" andFrom:self.userName To:self.friendName];
        EmmmMessage * msg5=[[EmmmMessage alloc]initMessageWithText:@"永和有永和路，中和有中和路，中和的中和路有接永和的中和路，永和的永和路沒接中和的永和路；永和的中和路有接永和的永和路，中和的永和路沒接中和的中和路。永和有中正路，中和有中正路，永和的中正路用景平路接中和的中正路；永和有中山路，中和有中山路，永和的中山路直接接上了中和的中山路。永和的中正路接上了永和的中山路，中和的中正路卻不接中和的中山路。中正橋下來不是中正路，但永和有中正路；秀朗橋下來也不是秀朗路，但永和也有秀朗路。永福橋下來不是永福路，永和沒有永福路；福和橋下來不是福和路，但福和路接的是永福橋。" andFrom:self.userName To:self.friendName];
        EmmmMessage * msg6=[[EmmmMessage alloc]initMessageWithText:@"黑化黑灰化肥黑灰会挥发发灰黑化肥黑灰化肥挥发；灰化灰黑化肥灰黑会发挥发黑灰化肥灰黑化肥发挥" andFrom:self.userName To:self.friendName];
        [_messagesArr addObjectsFromArray:@[msg1,msg2,msg3,msg4,msg5,msg6]];
    }
    return _messagesArr;
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
    CGPoint p1=[self.messageInputView convertPoint:self.messageInputView.frame.origin toView:self.view];
    //获取合适的高度
    float textViewHeight =  [self.messageInputView sizeThatFits:CGSizeMake(self.messageInputView.frame.size.width, MAXFLOAT)].height;
    if (textViewHeight <= MAXHEIGHTofInputView && textViewHeight > INITHEIGHTOFINPUTVIEW) {
        CGRect frame= self.messageInputView.frame;
        frame.size.height=textViewHeight;
        self.messageInputView.frame = frame;
        [self.view layoutIfNeeded];
    }
    else if(textViewHeight < INITHEIGHTOFINPUTVIEW){
        CGRect frame= self.messageInputView.frame;
        frame.size.height=INITHEIGHTOFINPUTVIEW;
        self.messageInputView.frame = frame;
        [self.view layoutIfNeeded];
    }
    float changedHeight=self.messageInputView.frame.size.height-originalHeight;
    CGRect frame=self.bottomMessageView.frame;
    frame.origin.y=wrappperViewY-changedHeight;
    self.bottomMessageView.frame=frame;
    CGPoint p2=[self.messageInputView convertPoint:self.messageInputView.frame.origin toView:self.view];
    CGFloat change=p1.y-p2.y;
    NSLog(@"%lf",change);
    self.currentTableViewInset+=change;
    self.chatTableView.contentInset = UIEdgeInsetsMake(0, 0,self.currentTableViewInset,0);
    [self.chatTableView setContentOffset:CGPointMake(0, self.chatTableView.contentSize.height-self.chatTableView.frame.size.height+self.currentTableViewInset) animated:YES];
}
//弹出键盘时
-(void)keyboardWillShow:(NSNotification *)notification{
    NSDictionary *userInfo = [notification userInfo];
    NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [value CGRectValue];
    //tableView滚动
    self.currentTableViewInset=keyboardRect.size.height;
    self.chatTableView.contentInset = UIEdgeInsetsMake(0, 0,self.currentTableViewInset,0);
    [self.chatTableView setContentOffset:CGPointMake(0, self.chatTableView.contentSize.height-self.chatTableView.frame.size.height+self.currentTableViewInset) animated:YES];
    CGRect frame=self.bottomMessageView.frame;
    frame.origin.y=keyboardRect.origin.y-frame.size.height;
    self.bottomMessageView.frame=frame;
}
//设定键盘的返回键
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        [self SendTextMessage:self.messageInputView.text];
        self.messageInputView.text=@"";
        return NO;
    }
    return YES;
}
//发送消息
-(void)SendTextMessage:(NSString *)text{
    EmmmMessage * msg=[[EmmmMessage alloc]initMessageWithText:text andFrom:self.userName To:self.friendName];
    [self.messagesArr addObject:msg];
    [self.chatTableView reloadData];
    [self.view layoutIfNeeded];
    [self.chatTableView setContentOffset:CGPointMake(0, self.chatTableView.contentSize.height-self.chatTableView.frame.size.height+self.currentTableViewInset) animated:YES];
}
//返回键
-(void)returnToMain{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

//设置右滑返回
- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.chatTableView setContentOffset:CGPointMake(0, self.chatTableView.contentSize.height-self.chatTableView.frame.size.height) animated:NO]; 
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.chatTableView setContentOffset:CGPointMake(0, self.chatTableView.contentSize.height-self.chatTableView.frame.size.height) animated:NO]; 
}
//识别点击注销textview
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if (![touch.view isDescendantOfView:self.messageInputView]) {
        if ([self.messageInputView isFirstResponder]) {
            [self.messageInputView resignFirstResponder];
            [UIView animateWithDuration:0.2 animations:^{
                self.chatTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
            }];
            self.currentTableViewInset=0;
        }
    }
    return NO;
}


- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    EmmmMessage * msg=self.messagesArr[indexPath.row];
    if ([msg.fromUser isEqualToString:self.userName]) {
        EmmmChatTableViewTowardCell * cell=[self.chatTableView dequeueReusableCellWithIdentifier:myReuseIdentifier forIndexPath:indexPath];
        [cell setWithIcon:self.myIcon andMessage:msg];
        return cell;
    }
    else{
        EmmmChatTableViewTowardCell * cell=[self.chatTableView dequeueReusableCellWithIdentifier:myReuseIdentifier forIndexPath:indexPath];
        [cell setWithIcon:self.friendIcon andMessage:msg];
        return cell;
    }
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messagesArr.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end
