//
//  LoginViewController.m
//  emmmChat
//
//  Created by 李嘉银 on 13/12/2017.
//  Copyright © 2017 李嘉银. All rights reserved.
//
#define darkBlueColor [UIColor colorWithRed:70/255. green:128/255. blue:246/255. alpha:1]

#import "LoginViewController.h"

@interface LoginViewController ()
@property(strong,nonatomic)UITextField * accountTextField;
@property(strong,nonatomic)UITextField * passwordTextField;
@property(strong,nonatomic)UIButton * submitBtn;
@property(strong,nonatomic)UIButton * switchToLoginBtn;
@property(strong,nonatomic)UIButton * switchToRegisterBtn;
@property(strong,nonatomic)UIView * switchUnderLine;
@property BOOL loginSuccess;
@property BOOL loginOrRegister; //1为登陆，0为注册
@end

@implementation LoginViewController

-(instancetype)init{
    self=[super init];
    self.view.backgroundColor=[UIColor whiteColor];
    //顶部logo
    UIImageView * iconImageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon-s"]];
    [self.view addSubview:iconImageView];
    [iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).with.offset(67); //with is an optional semantic filler
        make.left.equalTo(self.view.mas_left).with.offset(141);
        make.right.equalTo(self.view.mas_right).with.offset(-141);
        make.height.equalTo(@(110.f));
    }];
    //中部登陆/注册切换
    self.loginOrRegister=YES;
    self.switchToLoginBtn=[UIButton buttonWithType:UIButtonTypeSystem];
    self.switchToRegisterBtn=[UIButton buttonWithType:UIButtonTypeSystem];
    [self.view addSubview:self.switchToRegisterBtn];
    [self.view addSubview:self.switchToLoginBtn];
    self.switchToLoginBtn.backgroundColor=darkBlueColor;
    self.switchToRegisterBtn.backgroundColor=[UIColor grayColor];
    [self.switchToLoginBtn addTarget:self action:@selector(SwitchToLogin) forControlEvents:UIControlEventTouchUpInside];
    [self.switchToRegisterBtn addTarget:self action:@selector(SwitchToRegister) forControlEvents:UIControlEventTouchUpInside];
    [self.switchToLoginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(iconImageView.mas_bottom).with.offset(52);
        make.left.equalTo(self.view.mas_left).with.offset(98);
        make.width.equalTo(self.switchToRegisterBtn.mas_width).with.offset(0);
        make.height.equalTo(@(30.f));
    }];
    [self.switchToRegisterBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(iconImageView.mas_bottom).with.offset(52);
        make.left.equalTo(self.switchToLoginBtn.mas_right).with.offset(0);
        make.right.equalTo(self.view.mas_right).with.offset(-98);
        make.height.equalTo(@(30.f));
    }];
    self.switchToRegisterBtn.layer.affineTransform=CGAffineTransformMakeScale(0.8, 0.8);
    // 切换按钮的下划线
    self.switchUnderLine=[[UIView alloc]init];
    self.switchUnderLine.backgroundColor=[UIColor blueColor];
    [self.view addSubview:self.switchUnderLine];
    [self.switchUnderLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.switchToLoginBtn.mas_bottom);
        make.left.equalTo(self.switchToLoginBtn.mas_left);
        make.right.equalTo(self.switchToLoginBtn.mas_right);
        make.height.equalTo(@(3));
    }];
    // 输入框
    UIView * inputView=[[UIView alloc]init];
    [self.view addSubview:inputView];
    [inputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.switchToRegisterBtn.mas_bottom).with.offset(44);
        make.left.equalTo(self.view.mas_left).with.offset(33);
        make.right.equalTo(self.view.mas_right).with.offset(-33);
        make.height.equalTo(@(89.f));
    }];
    inputView.layer.borderColor=darkBlueColor.CGColor;
    inputView.layer.borderWidth=2.0f;
    inputView.layer.cornerRadius=8.0f;
    //输入框中的分割线
    UIView * separater=[[UIView alloc]init];
    [inputView addSubview:separater];
    [separater mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(inputView.mas_centerY);
        make.left.equalTo(inputView.mas_left).with.offset(39.5);
        make.right.equalTo(inputView.mas_right).with.offset(0);
        make.height.equalTo(@(2.f));
    }];
    separater.layer.borderColor=darkBlueColor.CGColor;
    separater.layer.borderWidth=1.0f;
    //输入框中的icon
    UIImageView * icon1=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"账号"]];
    UIImageView * icon2=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"账号"]];
    [inputView addSubview:icon1];
    [inputView addSubview:icon2];
    [icon1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(separater.mas_top).with.offset(-5);
        make.left.equalTo(inputView.mas_left).with.offset(14);
        make.right.equalTo(separater.mas_left).with.offset(0);
        make.top.equalTo(inputView.mas_top).with.offset(10);
    }];
    [icon2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(inputView.mas_bottom).with.offset(-5);
        make.left.equalTo(inputView.mas_left).with.offset(14);
        make.right.equalTo(separater.mas_left).with.offset(0);
        make.top.equalTo(separater.mas_bottom).with.offset(10);
    }];
    //输入框中的UITextField
    self.accountTextField=[[UITextField alloc]init];
    self.passwordTextField=[[UITextField alloc]init];
    [self.view addSubview:self.accountTextField];
    [self.view addSubview:self.passwordTextField];
    self.accountTextField.autocapitalizationType=UITextAutocapitalizationTypeNone;
    self.passwordTextField.autocapitalizationType=UITextAutocapitalizationTypeNone;
    self.accountTextField.delegate=self;
    self.passwordTextField.delegate=self;
    self.accountTextField.placeholder=@"请输入账号";
    self.passwordTextField.placeholder=@"请输入密码";
    self.accountTextField.clearButtonMode=UITextFieldViewModeWhileEditing;
    self.passwordTextField.clearButtonMode=UITextFieldViewModeWhileEditing;
    self.accountTextField.returnKeyType=UIReturnKeyNext;
    self.passwordTextField.returnKeyType=UIReturnKeyContinue;
    self.passwordTextField.secureTextEntry=YES;
    [self.accountTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(separater.mas_top).with.offset(0);
        make.left.equalTo(icon1.mas_right).with.offset(5);
        make.right.equalTo(inputView.mas_right).with.offset(0);
        make.top.equalTo(inputView.mas_top).with.offset(10);
    }];
    [self.passwordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(inputView.mas_bottom).with.offset(0);
        make.left.equalTo(icon2.mas_right).with.offset(5);
        make.right.equalTo(inputView.mas_right).with.offset(0);
        make.top.equalTo(separater.mas_bottom).with.offset(10);
    }];
    //确定按钮
    self.submitBtn=[UIButton buttonWithType:UIButtonTypeSystem];
    self.submitBtn.backgroundColor=darkBlueColor;
    [self.submitBtn setTitle:@"登陆" forState:UIControlStateNormal];
    [self.submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.submitBtn setFont:[UIFont systemFontOfSize:20 weight:UIFontWeightBold]];
    [self.view addSubview:self.submitBtn];
    self.submitBtn.layer.borderColor=darkBlueColor.CGColor;
    self.submitBtn.layer.borderWidth=2.0f;
    self.submitBtn.layer.cornerRadius=8;
    self.submitBtn.enabled=NO;
    [self.submitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(inputView.mas_bottom).with.offset(36.5);
        make.left.equalTo(self.view.mas_left).with.offset(33);
        make.right.equalTo(self.view.mas_right).with.offset(-33);
        make.bottom.equalTo(self.view.mas_bottom).with.offset(-201.5);
    }];
    [self.submitBtn addTarget:self action:@selector(TryLogin) forControlEvents:UIControlEventTouchUpInside];
    return self;
}

-(void)SwitchToLogin{
    self.loginOrRegister=YES;
    CGPoint center=self.switchUnderLine.center;
    center.x=self.switchToLoginBtn.center.x;
    [UIView animateWithDuration:0.4 animations:^{
        self.switchUnderLine.center=center;
        self.switchToLoginBtn.layer.affineTransform=CGAffineTransformIdentity;
        self.switchUnderLine.layer.affineTransform=CGAffineTransformIdentity;
        self.switchToRegisterBtn.layer.affineTransform=CGAffineTransformMakeScale(0.8, 0.8);
        self.switchToRegisterBtn.backgroundColor=[UIColor grayColor];
        self.switchToLoginBtn.backgroundColor=darkBlueColor;
        [self.submitBtn setTitle:@"登陆" forState:UIControlStateNormal];
        self.accountTextField.placeholder=@"请输入账号";
        self.passwordTextField.placeholder=@"请输入密码";
    }];
}

-(void)SwitchToRegister{
    self.loginOrRegister=NO;
    
//    CGPoint center=self.switchUnderLine.center;
//    center.x=self.switchToRegisterBtn.center.x;
    [UIView animateWithDuration:0.4 animations:^{
//        self.switchUnderLine.center=center;
        self.switchToRegisterBtn.layer.affineTransform=CGAffineTransformIdentity;
        self.switchToLoginBtn.layer.affineTransform=CGAffineTransformMakeScale(0.8, 0.8);
        self.switchUnderLine.layer.affineTransform=CGAffineTransformMakeTranslation(self.switchToRegisterBtn.center.x-self.switchToLoginBtn.center.x, 0);
        self.switchToRegisterBtn.backgroundColor=darkBlueColor;
        self.switchToLoginBtn.backgroundColor=[UIColor grayColor];
        [self.submitBtn setTitle:@"注册" forState:UIControlStateNormal];
        self.accountTextField.placeholder=@"请设置账号";
        self.passwordTextField.placeholder=@"请设置密码";
    }];
    
}

-(void)TryLogin{
    //判断账号密码是否正确
    if([self.accountTextField.text isEqualToString:@"lagagggggg"]
       &&[self.passwordTextField.text isEqualToString:@"19970720"]){
        self.loginSuccess=1;
    }
    else{

    }
    if (self.loginSuccess) {
        NSUserDefaults * defaults=[NSUserDefaults standardUserDefaults];
        [defaults setBool:self.loginSuccess forKey:@"loginSuccess"];
        [self JumpToMainInterface];
    }
    
}

-(void)JumpToMainInterface{
    EmmmMainViewController * mainInterface=[[EmmmMainViewController alloc]init];
    [self.navigationController pushViewController:mainInterface animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
//    [self.navigationController setNavigationBarHidden:YES animated:animated];
    NSUserDefaults * defaults=[NSUserDefaults standardUserDefaults];
    self.loginSuccess=[defaults boolForKey:@"loginSuccess"];
    if (self.loginSuccess) {
        [self JumpToMainInterface];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.accountTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString * accountText=self.accountTextField.text;
    NSString * passwordText=self.passwordTextField.text;
    if (textField==self.accountTextField) {
        accountText=[accountText stringByAppendingString:string];
    }
    else if (textField==self.passwordTextField) {
        passwordText=[passwordText stringByAppendingString:string];
    }
    if (accountText.length!=0&&
        passwordText.length!=0) {
        self.submitBtn.enabled=YES;
    }
    else{
        self.submitBtn.enabled=NO;
    }
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField==self.accountTextField) {
        [self.passwordTextField becomeFirstResponder];
    }
    else if(textField==self.passwordTextField){
        if (self.accountTextField.text.length!=0&&
            self.passwordTextField.text.length!=0) {
            [self TryLogin];
        }
    }
    return YES;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
