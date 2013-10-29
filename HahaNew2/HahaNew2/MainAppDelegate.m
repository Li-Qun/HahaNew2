//
//  MainAppDelegate.m
//  HahaNew2
//
//  Created by Li-Qun on 13-9-13.
//  Copyright (c) 2013年 Li-Qun. All rights reserved.
//
#import "MainViewController.h"
#import "MainAppDelegate.h"


@implementation MainAppDelegate

@synthesize hahaItemVC1;

@synthesize window;
@synthesize hostReach;
@synthesize tabBarController;
@synthesize name;
@synthesize isLonIn;
@synthesize HahaUserInfo;
@synthesize textView;
@synthesize csView;
-(NSString *)appKey
{
    return @"4f712ed55270157f46000005";
}

-(void)userDidLogin
{
    self.isLonIn = YES;
    [[MXAccountManager shareInstance] getProfile];
}


-(void)userProfileDidChange
{
    MainAppDelegate *app = (MainAppDelegate *)[[UIApplication sharedApplication] delegate];
    [app.HahaUserInfo setObject:[[[MXAccountManager shareInstance] currentUser] nickName] forKey:@"userNickName"];
    [app.HahaUserInfo synchronize];
}

- (void)reachabilityChanged:(NSNotification *)note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    NetworkStatus status = [curReach currentReachabilityStatus];
    
    if (status == NotReachable) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"网络提示"
                                                        message:@"无法连接到服务器，请查看网络后再试"
                                                       delegate:nil
                                              cancelButtonTitle:@"YES" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}


- (void)dealloc
{
    [window release];
    [name release];
    [hostReach release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //友盟
    [MobClick setDelegate:self reportPolicy:REALTIME];
    [MobClick appLaunched];

    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    /******文本框**********/
    textView=[[UITextView alloc]init];
    textView.backgroundColor=[UIColor whiteColor];
    [textView release];
    /******创建标签控制器************************/
    self.tabBarController=[[UITabBarController alloc]init];
    
    MainViewController  *hotVC=[[MainViewController alloc]init];
    UITabBarItem *hotItem=[[UITabBarItem alloc]initWithTitle:@"最热" image:[UIImage imageNamed:@"title.png"] tag:0];
    hotVC.tabBarItem=hotItem;
    hotVC.pageTitleStr=@"最热";
    hotVC.hahaType = @"hot";
  
    /*******************newVC、hahaVC**********************/
    MainViewController *newVC=[[MainViewController alloc]init];
    UITabBarItem *newItem=[[UITabBarItem alloc]initWithTitle:@"最新" image:[UIImage imageNamed:@"0032.png"] tag:0];
    newVC.tabBarItem=newItem;
    newVC.pageTitleStr=@"最新";
    newVC.hahaType = @"new";

    MainViewController *hahaVC=[[MainViewController alloc]init];
    UITabBarItem *hahaItem=[[UITabBarItem alloc]initWithTitle:@"最哈" image:[UIImage imageNamed:@"title.png"] tag:0];
    hahaVC.tabBarItem=hahaItem;
    hahaVC.pageTitleStr =@"最哈";
    hahaVC.hahaType = @"good";
    //New、Haha内容已在子控制器中初定已完成~
    
    /**************************************/
    UINavigationController *nav1=[[UINavigationController alloc]initWithRootViewController:hotVC];    
    UINavigationController *nav2=[[UINavigationController alloc]initWithRootViewController:newVC];
    UINavigationController *nav3=[[UINavigationController alloc]initWithRootViewController:hahaVC];
    
   
    //创建导航控制器
    NSArray *viewControllers=@[nav1,nav2,nav3];
    [self.tabBarController setViewControllers:viewControllers animated:YES];
    self.window.rootViewController=self.tabBarController;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    [self.tabBarController release];
    

    /*******网络到达交换通知**********************/
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name: kReachabilityChangedNotification
                                               object: nil];
    
    
    [hostReach startNotifier];
    
    /*******网络到达交换通知**********************/
    [[MXAccountManager shareInstance] initlizedWithVersion:@"1.0" appId:@"HahaMX" device:[[UIDevice currentDevice] uniqueIdentifier] pkgType:@"zh"];
    [[MXAccountManager shareInstance] setDelegate:self];
    
    self.HahaUserInfo = [NSUserDefaults standardUserDefaults];
    
    if ([[self.HahaUserInfo objectForKey:@"autoLogIn"] isEqual:@"yes"])
    {
        NSString *name = [NSString stringWithFormat:@"%@",[self.HahaUserInfo objectForKey:@"userNameStr"]];
        NSString *numb = [NSString stringWithFormat:@"%@",[self.HahaUserInfo objectForKey:@"passwordStr"]];
        
        [[MXAccountManager shareInstance] loginAsAccount:name  password:numb
                                            regionDomain:NULL option:MXLoginOptionNone];
    }
    
    [nav1 release];
    [nav2 release];
    [nav3 release];
    [hotVC release];
    [hotItem release];
    [newVC release];
    [newItem release];
    [hahaVC release];
    [hahaItem release];
    
    self.hahaItemVC1=[[HahaItemDetailViewController alloc]init];
    
    
       return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
