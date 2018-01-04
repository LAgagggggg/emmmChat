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
#define MSG_EACH_FETCH 5

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
@property(strong,nonatomic)UIActivityIndicatorView *reloadIndicator;
@property CGFloat currentTableViewInset;
@property BOOL btnsAlreadyPoped;
@property NSInteger sqlFetchFromIndex;
@property BOOL reloadLock;
@property MyDataBase * db;
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
        make.top.equalTo(self.navigationView.mas_top);
    }];
    self.chatTableView.tableHeaderView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 41.5)];
    UIView * HeaderView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 41.5)];
    HeaderView.backgroundColor=[UIColor clearColor];
    [self.chatTableView.tableHeaderView addSubview:HeaderView];
    self.reloadIndicator= [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.reloadIndicator.center = HeaderView.center;
    [HeaderView addSubview:self.reloadIndicator];
    [self.reloadIndicator setHidesWhenStopped:NO];
    self.chatTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    [self.chatTableView registerClass:[EmmmChatTableViewTowardCell class] forCellReuseIdentifier:myReuseIdentifier];
    [self.chatTableView registerClass:[EmmmChatTableViewReceivedCell class] forCellReuseIdentifier:friendRuseIdentifier];
    self.chatTableView.estimatedRowHeight=80;
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
        self.db=[MyDataBase sharedInstance];
        if ([self.db open])
        {
            NSUInteger count = [self.db intForQuery:@"select count(*) from msgT where (fromUser=? AND toUser=?) OR (fromUser=? AND toUser=?);",self.userName,self.friendName,self.friendName,self.userName];
            self.sqlFetchFromIndex=count-MSG_EACH_FETCH;
            if (self.sqlFetchFromIndex<0) {
                self.sqlFetchFromIndex=0;
            }
            NSString * sql=[NSString stringWithFormat:@"select * from msgT where (fromUser=? AND toUser=?) OR (fromUser=? AND toUser=?) LIMIT %ld,%d;",(long)self.sqlFetchFromIndex,MSG_EACH_FETCH];
            FMResultSet *resultSet = [self.db executeQuery:sql,self.userName,self.friendName,self.friendName,self.userName];
            while ([resultSet next]) {
                EmmmMessage * msg=[[EmmmMessage alloc]initMessageWithText:[resultSet stringForColumn:@"content"] andFrom:[resultSet stringForColumn:@"fromUser"] To:[resultSet stringForColumn:@"toUser"]];
                msg.sentDate=[resultSet dateForColumn:@"create_time"];
                [self.messagesArr addObject:msg];
            }
            [resultSet close];
        }

        [self.db close];
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
    [self keepUICorrect];
}
-(void)keepUICorrect{
    //保存包裹textview的view的y值
    float wrappperViewY=self.bottomMessageView.frame.origin.y;
    float originalHeight=self.messageInputView.frame.size.height;
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
    if(self.chatTableView.contentSize.height-self.chatTableView.frame.size.height+self.currentTableViewInset>0){
        self.currentTableViewInset+=change;
        self.chatTableView.contentInset = UIEdgeInsetsMake(0, 0,self.currentTableViewInset,0);
        [self.chatTableView setContentOffset:CGPointMake(0, self.chatTableView.contentSize.height-self.chatTableView.frame.size.height+self.currentTableViewInset) animated:YES];
    }
}
//弹出键盘时
-(void)keyboardWillShow:(NSNotification *)notification{
    NSDictionary *userInfo = [notification userInfo];
    NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [value CGRectValue];
    //tableView滚动
    self.currentTableViewInset=keyboardRect.size.height;
    if(self.chatTableView.contentSize.height-self.chatTableView.frame.size.height+self.currentTableViewInset>0){
        self.chatTableView.contentInset = UIEdgeInsetsMake(0, 0,self.currentTableViewInset,0);
        [self.chatTableView setContentOffset:CGPointMake(0, self.chatTableView.contentSize.height-self.chatTableView.frame.size.height+self.currentTableViewInset) animated:YES];
    }
    CGRect frame=self.bottomMessageView.frame;
    frame.origin.y=keyboardRect.origin.y-frame.size.height;
    self.bottomMessageView.frame=frame;
}
//设定键盘的返回键
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        [self SendTextMessage:self.messageInputView.text];
        self.messageInputView.text=@"";
        [self keepUICorrect];
        return NO;
    }
    return YES;
}
//发送消息
-(void)SendTextMessage:(NSString *)text{
    EmmmMessage * msg=[[EmmmMessage alloc]initMessageWithText:text andFrom:self.userName To:self.friendName];
    [self.messagesArr addObject:msg];
    [self.chatTableView reloadData];
    if ([self.db open]) {
        if ([msg WriteWithFMDB:self.db andTableName:@"msgT"]) {
            NSLog(@"信息写入成功");
        }
        [self.db close];
    }
    if(self.chatTableView.contentSize.height-self.chatTableView.frame.size.height+self.currentTableViewInset>0){
        [self.chatTableView setContentOffset:CGPointMake(0, self.chatTableView.contentSize.height-self.chatTableView.frame.size.height+self.currentTableViewInset) animated:YES];
    }
    
}
//返回键
-(void)returnToMain{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.chatTableView reloadData];//设置tableview出现在最底端
    dispatch_async(dispatch_get_main_queue(),^{
        if (self.chatTableView.contentSize.height >self.chatTableView.frame.size.height) {
            [self.chatTableView setContentOffset:CGPointMake(0, self.chatTableView.contentSize.height -self.chatTableView.bounds.size.height) animated:NO];
        }
    });
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
        EmmmChatTableViewReceivedCell * cell=[self.chatTableView dequeueReusableCellWithIdentifier:friendRuseIdentifier forIndexPath:indexPath];
        [cell setWithIcon:self.friendIcon andMessage:msg];
        return cell;
    }
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messagesArr.count;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.y<-60) {
        [scrollView setContentOffset:CGPointMake(0, -60) animated:NO];
    }
    NSLog(@"%lf",scrollView.contentSize.height);
}

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    if (scrollView.contentOffset.y<=-60&&self.reloadLock==NO) {
        float beforeHeight= scrollView.contentSize.height;
        self.reloadLock=YES;
        if (self.sqlFetchFromIndex>0) {
            [scrollView setContentInset:UIEdgeInsetsMake(60, 0, 0, 0)];
            [self.reloadIndicator startAnimating];
            self.sqlFetchFromIndex-=MSG_EACH_FETCH;
            if (self.sqlFetchFromIndex<0) {
                self.sqlFetchFromIndex=0;
            }
            if ([self.db open]) {
                NSString * sql=[NSString stringWithFormat:@"select * from msgT where (fromUser=? AND toUser=?) OR (fromUser=? AND toUser=?) LIMIT %ld,%d;",(long)self.sqlFetchFromIndex,MSG_EACH_FETCH];
                FMResultSet *resultSet = [self.db executeQuery:sql,self.userName,self.friendName,self.friendName,self.userName];
                NSMutableArray * temp=[[NSMutableArray alloc]init];
                while ([resultSet next]) {
                    EmmmMessage * msg=[[EmmmMessage alloc]initMessageWithText:[resultSet stringForColumn:@"content"] andFrom:[resultSet stringForColumn:@"fromUser"] To:[resultSet stringForColumn:@"toUser"]];
                    msg.sentDate=[resultSet dateForColumn:@"create_time"];
                    [temp insertObject:msg atIndex:0];
                }
                for (EmmmMessage * msg in temp) {
                    [self.messagesArr insertObject:msg atIndex:0];
                }
                [resultSet close];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    self.reloadLock=NO;
                    [self.reloadIndicator stopAnimating];
                    [self.chatTableView reloadData];
                    float currHeight= scrollView.contentSize.height;
                    [scrollView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
                    [scrollView setContentOffset:CGPointMake(0,currHeight-beforeHeight-60) animated:NO];
                });
            }
            [self.db close];
        }
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end
