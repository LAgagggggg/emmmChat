//
//  EmmmMainViewController.m
//  emmmChat
//
//  Created by 李嘉银 on 14/12/2017.
//  Copyright © 2017 李嘉银. All rights reserved.
//
#define tableViewStartPosition (127.f-[[UIApplication sharedApplication] statusBarFrame].size.height)
#define lightBlueColor [UIColor colorWithRed:225/255. green:238/255. blue:253/255. alpha:1]
#define animationDURATION 0.4

#import "EmmmMainViewController.h"

@interface EmmmMainViewController ()
@property(strong,nonatomic)UIView * mainWrapperView;
@property(strong,nonatomic)UIView * topView;
@property(strong,nonatomic)UIView * switcherWrapper;
@property(strong,nonatomic)UITableView * contactTableView;
@property(strong,nonatomic)UIView * headerSearchView;
@property(strong,nonatomic)UITextField * searchBar;
@property(strong,nonatomic)NSMutableArray<EmmmContact *> * contactArr;
@property(strong,nonatomic)NSString * tableName;
@property(strong,nonatomic)UIImage * myIcon;
@property(strong,nonatomic)EmmmPullMenuView * pullMenuView;
@property MyDataBase * db;
@end

static NSString * const reuseIdentifier = @"Cell";
static float scrollStartPosition;
@implementation EmmmMainViewController

-(instancetype)initWithUserName:(NSString *)userName{
    self=[super init];
    self.userName=userName;
    self.view.backgroundColor=[UIColor blackColor];
    //设置一个view作为除侧拉菜单view外的父控件
    self.mainWrapperView=[[UIView alloc]initWithFrame:self.view.frame];
    self.mainWrapperView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:self.mainWrapperView];
    //TableView
    self.contactTableView=[[UITableView alloc]init];
    self.contactTableView.delegate=self;
    self.contactTableView.dataSource=self;
    self.contactTableView.separatorStyle=UITextBorderStyleNone;
    [self.contactTableView registerClass:[EmmmContactCell class] forCellReuseIdentifier:reuseIdentifier];
    self.contactTableView.backgroundColor=[UIColor clearColor];
    [self.mainWrapperView addSubview:self.contactTableView];
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
    [self.mainWrapperView addSubview:self.topView];
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
    self.myIcon=[UIImage imageNamed:@"ScreenShot"];
    //添加侧拉菜单
    UITapGestureRecognizer * tapToChooseAvatar=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapToChooseAvatar:)];
    self.pullMenuView=[[EmmmPullMenuView alloc]initWithIcon:self.myIcon andTapGestureRecognizer:tapToChooseAvatar];
    [self.view addSubview:self.pullMenuView];
    UIPanGestureRecognizer * pan=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
    [self.pullMenuView addGestureRecognizer:pan];
    self.pullMenuView.hidden=YES;
    //侧拉菜单中的两个按钮
    [self.pullMenuView.logoutBtn addTarget:self action:@selector(QuitLogin) forControlEvents:UIControlEventTouchUpInside];
    [self.pullMenuView.changePasswordBtn addTarget:self action:@selector(ChangePassword) forControlEvents:UIControlEventTouchUpInside];
    return self;
}

-(void)tapToChooseAvatar:(UITapGestureRecognizer *)tap{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            UIImagePickerController * library=[[UIImagePickerController alloc]init];
            NSArray * availableType =[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            library.mediaTypes=availableType;
            library.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
            library.delegate=self;
            library.allowsEditing=YES;
            [self presentViewController:library animated:YES completion:nil];
        }
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
        UIImagePickerController *PickerImage = [[UIImagePickerController alloc]init];
        PickerImage.sourceType = UIImagePickerControllerSourceTypeCamera;
        PickerImage.allowsEditing = YES;
        PickerImage.delegate = self;
        [self presentViewController:PickerImage animated:YES completion:nil];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    UIImage * newAvatar=[info objectForKey:@"UIImagePickerControllerEditedImage"];
    self.myIcon=newAvatar;
    [self.pullMenuView setAvatar:self.myIcon];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)pan:(UIPanGestureRecognizer *)pan{
    CGPoint transP=[pan translationInView:self.pullMenuView];
    if (pan.state==UIGestureRecognizerStateChanged) {
        if (self.pullMenuView.frame.origin.x<=0) {
            self.pullMenuView.transform=CGAffineTransformTranslate(self.pullMenuView.transform, transP.x, 0);
        }
        if(self.pullMenuView.frame.origin.x>0){
            CGRect frame=self.pullMenuView.frame;
            frame.origin.x=0;
            [UIView animateWithDuration:animationDURATION animations:^{
                self.pullMenuView.frame=frame;
            }];
        }
    }
    else if(pan.state==UIGestureRecognizerStateEnded){
        CGRect frame=self.pullMenuView.frame;
        if(self.pullMenuView.frame.origin.x<-self.pullMenuView.setedPushWidth/2){
            frame.origin.x=-self.pullMenuView.setedPushWidth;
        }
        else{
            frame.origin.x=0;
        }
        [UIView animateWithDuration:animationDURATION animations:^{
            self.pullMenuView.frame=frame;
        }];
    }
    CGFloat dimRatio=0.5+(self.pullMenuView.frame.origin.x/-self.pullMenuView.setedPushWidth)*0.5;
    [UIView animateWithDuration:animationDURATION animations:^{
        self.mainWrapperView.alpha=dimRatio;
    }];
    [pan setTranslation:CGPointZero inView:self.pullMenuView];
}

-(NSMutableArray *)contactArr{
    if (_contactArr==nil) {
        _contactArr=[[NSMutableArray alloc]init];
        self.tableName=[@"contactOf" stringByAppendingString:self.userName];
        self.db=[MyDataBase sharedInstance];
        if ([self.db open])
        {
            NSString *sql=[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (name text, iconImage blob, lastMessage text,lastMessageTime text,unReaderCount integer);",self.tableName];
            BOOL result = [self.db executeUpdate:sql];
            if (result)
            {
                NSLog(@"创建%@成功",self.tableName);
            }
            sql=@"CREATE TABLE IF NOT EXISTS msgT (fromUser text, toUser text, content text,create_time datetime);";
            result = [self.db executeUpdate:sql];
            if (result)
            {
                NSLog(@"创建msgT成功");
            }
            sql = [NSString stringWithFormat:@"SELECT * FROM %@",self.tableName];
            FMResultSet *resultSet = [self.db executeQuery:sql];
            while ([resultSet next]) {
                EmmmContact * contact=[[EmmmContact alloc]init];
                contact.name=[resultSet stringForColumn:@"name"];
                contact.lastMessage=[resultSet stringForColumn:@"lastMessage"];
                contact.lastMessageTime=[resultSet stringForColumn:@"lastMessageTime"];
                NSData * imageData=[resultSet dataForColumn:@"iconImage"];
//                NSLog(@"%@\n==================",imageData);
                contact.iconImage=[UIImage imageWithData:imageData];
                contact.unReaderCount=[resultSet intForColumn:@"unReaderCount"];
                [self.contactArr addObject:contact];
            }
        }
    }
    return _contactArr;
}

-(void)QuitLogin{
    NSUserDefaults * defaults=[NSUserDefaults standardUserDefaults];
    [defaults setBool:NO forKey:@"loginSuccessJudge"];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)ChangePassword{
    UIAlertController *passwordInput=[UIAlertController alertControllerWithTitle:@"修改密码" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [passwordInput addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"原密码";
    }];
    [passwordInput addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"新密码";
    }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){}];
    UIAlertAction* confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action){
        MBProgressHUD * hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            MBProgressHUD *hud2=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud2.mode=MBProgressHUDModeText;
            hud2.label.text=@"修改成功";
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [hud2 hideAnimated:YES];
            });
        });
    }];
    [passwordInput addAction:cancelAction];
    [passwordInput addAction:confirmAction];
    [self.navigationController presentViewController:passwordInput animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated{
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    self.pullMenuView.hidden=NO;
}

-(void)viewWillDisappear:(BOOL)animated{
    self.pullMenuView.hidden=YES;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    EmmmContact * contact=self.contactArr[indexPath.row];
    EmmmContactCell * cell=[self.contactTableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    [cell SetWithContact:contact];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.contactArr.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 72.5f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    EmmmContact * contact=self.contactArr[indexPath.row];
    EmmmChatViewController * vc=[[EmmmChatViewController alloc]initWithContact:contact];
    vc.myIcon=self.myIcon;
    vc.userName=self.userName;
    [self.navigationController pushViewController:vc animated:YES];
}


-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if (![touch.view isDescendantOfView:self.searchBar]&&[self.searchBar isFirstResponder]) {
        [self.searchBar resignFirstResponder];
    }
    //设置菜单弹出时点击主界面菜单收回
        if (self.pullMenuView.frame.origin.x!=-self.pullMenuView.setedPushWidth&&![touch.view isDescendantOfView:self.pullMenuView.actualMenuView]) {
            CGRect frame=self.pullMenuView.frame;
            frame.origin.x=-self.pullMenuView.setedPushWidth;
            [UIView animateWithDuration:animationDURATION animations:^{
                self.pullMenuView.frame=frame;
                self.mainWrapperView.alpha=1;
            }];
            return YES;
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
    [self.contactArr removeObjectAtIndex:indexPath.row];
}



@end
