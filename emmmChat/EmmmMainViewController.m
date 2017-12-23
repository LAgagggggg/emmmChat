//
//  EmmmMainViewController.m
//  emmmChat
//
//  Created by 李嘉银 on 14/12/2017.
//  Copyright © 2017 李嘉银. All rights reserved.
//
#define tableViewStartPosition (127.f-[[UIApplication sharedApplication] statusBarFrame].size.height)
#define lightBlueColor [UIColor colorWithRed:225/255. green:238/255. blue:253/255. alpha:1]

#import "EmmmMainViewController.h"

@interface EmmmMainViewController ()
@property(strong,nonatomic)UIView * topView;
@property(strong,nonatomic)UIView * switcherWrapper;
@property(strong,nonatomic)UITableView * contactTableView;
@property(strong,nonatomic)UIView * headerSearchView;
@property(strong,nonatomic)UITextField * searchBar;
@property(strong,nonatomic)NSMutableArray<EmmmContact *> * contactArr;
@property MyDataBase * db;
@end

static NSString * const reuseIdentifier = @"Cell";
static float scrollStartPosition;
@implementation EmmmMainViewController

-(instancetype)init{
    self=[super init];
    self.view.backgroundColor=[UIColor whiteColor];
    //TableView
    self.contactTableView=[[UITableView alloc]init];
    self.contactTableView.delegate=self;
    self.contactTableView.dataSource=self;
    self.contactTableView.separatorStyle=UITextBorderStyleNone;
    [self.contactTableView registerClass:[EmmmContactCell class] forCellReuseIdentifier:reuseIdentifier];
    self.contactTableView.backgroundColor=[UIColor clearColor];
    [self.view addSubview:self.contactTableView];
    [self.contactTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).with.offset(0);
        make.bottom.equalTo(self.view.mas_bottom).with.offset(0);
        make.left.equalTo(self.view.mas_left).with.offset(14.5);
        make.right.equalTo(self.view.mas_right).with.offset(-14.5);
    }];
    //搜索栏
    self.contactTableView.tableHeaderView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.contactTableView.frame.size.width, 47.5)];
    self.contactTableView.tableHeaderView.backgroundColor=[UIColor clearColor];
    self.headerSearchView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width-29, 40)];
    self.headerSearchView.backgroundColor=lightBlueColor;
    self.headerSearchView.layer.cornerRadius=10.f;
    [self.contactTableView.tableHeaderView addSubview:self.headerSearchView];
    self.searchBar=[[UITextField alloc]init];
    self.searchBar.borderStyle=UITextBorderStyleRoundedRect;
    self.searchBar.placeholder=@"添加用户";
    UITapGestureRecognizer * tap=[[UITapGestureRecognizer alloc]init];//emmm用来取消编辑
    tap.delegate=self;
    [self.view addGestureRecognizer:tap];
    [self.headerSearchView addSubview:self.searchBar];
    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headerSearchView.mas_top).with.offset(7.5);
        make.bottom.equalTo(self.headerSearchView.mas_bottom).with.offset(-7.5);
        make.left.equalTo(self.headerSearchView.mas_left).with.offset(11);
        make.right.equalTo(self.headerSearchView.mas_right).with.offset(-39);
    }];
    UIButton * addBtn=[UIButton buttonWithType:UIButtonTypeSystem];
    [self.headerSearchView addSubview:addBtn];
    [addBtn setImage:[UIImage imageNamed:@"添加"] forState:UIControlStateNormal];
    [addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headerSearchView.mas_top).with.offset(7.5);
        make.left.equalTo(self.searchBar.mas_right).with.offset(10);
        make.right.equalTo(self.headerSearchView.mas_right).with.offset(-8);
        make.height.equalTo(addBtn.mas_width);
    }];
    //顶部图标及切换按钮
    self.topView=[[UIView alloc]init];
    [self.view addSubview:self.topView];
    self.topView.backgroundColor=[UIColor clearColor];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).with.offset([[UIApplication sharedApplication] statusBarFrame].size.height);
        make.left.equalTo(self.view.mas_left).with.offset(0);
        make.height.equalTo(@(107));
        make.right.equalTo(self.view.mas_right).with.offset(0);
    }];
    UIButton * topIconBtn=[UIButton buttonWithType:UIButtonTypeSystem];
    [topIconBtn setImage:[UIImage imageNamed:@"icon-z1"] forState:UIControlStateNormal];
    [self.topView addSubview:topIconBtn];
    [topIconBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topView.mas_top).with.offset(11.5);
        make.left.equalTo(self.topView.mas_left).with.offset(14.5);
        make.height.equalTo(@(35));
        make.width.equalTo(@(148.f));
    }];
    [topIconBtn addTarget:self action:@selector(PullMenu) forControlEvents:UIControlEventTouchUpInside];
        //切换按钮
    self.switcherWrapper=[[UIView alloc]init];
    [self.topView addSubview:self.switcherWrapper];
    self.switcherWrapper.backgroundColor=lightBlueColor;
    self.switcherWrapper.layer.cornerRadius=10.f;
    [self.switcherWrapper mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topView.mas_top).with.offset(47.5);
        make.left.equalTo(self.topView.mas_left).with.offset(135.5);
        make.right.equalTo(self.topView.mas_right).with.offset(-135.5);
        make.height.equalTo(@(44));
    }];
    //设置tableview的offset
    self.contactTableView.contentInset = UIEdgeInsetsMake(tableViewStartPosition, 0, 0, 0);
    scrollStartPosition=self.contactTableView.contentOffset.y;
    self.db=[MyDataBase sharedInstance];
    return self;
}

-(NSMutableArray *)contactArr{
    if (!_contactArr) {
        if ([self.db open])
        {
            NSString * sql=@"CREATE TABLE IF NOT EXISTS contactOf%@ (name text PRIMARY KEY AUTOINCREMENT, iconImage blob, lastMessage text,lastMessageTime text,unReaderCount integer);";
            BOOL result = [self.db executeUpdateWithFormat:sql,self.userName];
            if (result)
            {
                NSLog(@"创建表成功");
            }
        }
    }
    return _contactArr;
}

-(void)PullMenu{// 弹出左边菜单
    NSUserDefaults * defaults=[NSUserDefaults standardUserDefaults];
    [defaults setBool:NO forKey:@"loginSuccess"];
    [self.navigationController popViewControllerAnimated:YES]; 
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}
-(void)viewDidAppear:(BOOL)animated{
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    EmmmContact * contact=[[EmmmContact alloc]init];
    contact.name=@"emmm";
    contact.iconImage=[UIImage imageNamed:@"ScreenShot"];
    contact.lastMessage=@"last message";
    contact.lastMessageTime=@"3 minutes ago";
    contact.unReaderCount=2;
    EmmmContactCell * cell=[self.contactTableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    [cell SetWithContact:contact];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 72.5f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    EmmmContact * contact=[[EmmmContact alloc]init];
    contact.name=@"emmm";
    contact.iconImage=[UIImage imageNamed:@"ScreenShot"];
    contact.lastMessage=@"last message";
    contact.lastMessageTime=@"3 minutes ago";
    contact.unReaderCount=2;
    EmmmChatViewController * vc=[[EmmmChatViewController alloc]initWithContact:contact];
    [self.navigationController pushViewController:vc animated:YES];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if (![touch.view isDescendantOfView:self.searchBar]&&[self.searchBar isFirstResponder]) {
        [self.searchBar resignFirstResponder];
    }
    return NO;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{//页面向上移动时头部消失
//    NSLog(@"%lf",scrollView.contentOffset.y);
    CGFloat initPosition=tableViewStartPosition+[[UIApplication sharedApplication] statusBarFrame].size.height;
    CGFloat disappearOffset=90.f;
    if (scrollView.contentOffset.y>=-initPosition&&scrollView.contentOffset.y<=(-initPosition)+disappearOffset) {
        CGFloat ratio=1-(scrollView.contentOffset.y+initPosition)/90;
        [self.topView setAlpha:ratio];
        self.topView.layer.affineTransform=CGAffineTransformMakeTranslation(0, -(1-ratio)*disappearOffset*2/3);
    }
    if (scrollView.contentOffset.y<=-initPosition) {
        [self.topView setAlpha:1];
        self.topView.layer.affineTransform=CGAffineTransformMakeTranslation(0, 0);
    }
    else if (scrollView.contentOffset.y>=(-initPosition)+disappearOffset){
        [self.topView setAlpha:0];
        self.topView.layer.affineTransform=CGAffineTransformMakeTranslation(0,-(disappearOffset*2/3));
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    for (UIView *subview in tableView.subviews)
    {
        if ([subview isKindOfClass:NSClassFromString(@"UISwipeActionPullView")] )
        {
            subview.backgroundColor=[UIColor clearColor];
            subview.subviews[0].layer.cornerRadius=10.f;
            subview.subviews[0].layer.masksToBounds=YES;
        }
    }
    return YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}



@end
