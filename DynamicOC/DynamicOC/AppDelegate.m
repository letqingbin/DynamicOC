//
//  AppDelegate.m
//  DynamicOC
//
//  Created by dKingbin on 2019/7/23.
//  Copyright © 2019 dKingbin. All rights reserved.
//

#import "AppDelegate.h"
#import "ASTHeader.h"
#import "ASTUtil.h"
#import "OCCfuntionHelper.h"
#import "ASTCallMethod.h"

#import <objc/runtime.h>
#import <dlfcn.h>

#import "DynamicOC.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    NSString* text = @" \
    [OCCfuntionHelper defineCFunction:@\"NSSelectorFromString\" types:@\"SEL,NSString *\"];\
    [OCCfuntionHelper defineCFunction:@\"class_getMethodImplementation\" types:@\"IMP,Class,SEL\"];\
    [OCCfuntionHelper defineCFunction:@\"class_addMethod\" types:@\"BOOL,Class,SEL,IMP,char *\"];\
    SEL viewDidLoad = NSSelectorFromString(@\"viewDidLoad\");\
    IMP imp = class_getMethodImplementation([ViewController class], viewDidLoad);\
    SEL selector = NSSelectorFromString(@\"tableView:numberOfRowsInSection:\");\
    BOOL didAdd1 = class_addMethod([ViewController class], selector,imp ,@\"i@:@i\");\
    SEL selector2 = NSSelectorFromString(@\"tableView:cellForRowAtIndexPath:\");\
    BOOL didAdd2 = class_addMethod([ViewController class], selector2,imp,@\"@@:@@\"); return didAdd2;";

    ASTNode* root = [ASTUtil parseString:text];
    ASTVariable* result = [root execute];
	[root.context clearAllContexts];
    NSAssert([result.value boolValue] == YES, nil);

	[ASTUtil registerVariableForYacc:@"self"];

	text = @"\
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]]; \
	self.window.backgroundColor = [UIColor whiteColor]; \
	ViewController *vc = [[ViewController alloc] init];	\
	UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:vc ];	\
	navc.navigationBar.translucent = NO;	\
	self.window.rootViewController = navc;	\
	[self.window makeKeyAndVisible];	\
	return 666; \
	";

	root = [ASTUtil parseString:text];
	ASTVariable* varSelf = [[ASTVariable alloc]init];
	varSelf.value = self;
	varSelf.type  = ASTNodeTypeVariable;
	[root.context pushValue:varSelf forKey:@"self"];
	result = [root execute];
	[root.context clearAllContexts];
	NSAssert([result.value doubleValue] == 666, nil);


    //numberOfRowsInSection
    NSString *numberOfRowsInSection = @"NSArray *array = objc_getAssociatedObject(self, @\"data\");\
        if (array != nil) {\
            return array.count;\
        }else{\
            return 0;\
        };\
    ";

    [DynamicOC hookClass:@"ViewController"
                selector:@"tableView:numberOfRowsInSection:"
                argNames:@[@"tableView",@"section"]
                 isClass:NO
          implementation:numberOfRowsInSection];


    //cellForRowAtIndexPath
    NSString *cellForRowAtIndexPath = @"\
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@\"aCell\"];\
    if (cell == nil) {\
        cell = [[UITableViewCell alloc] initWithStyle:3 reuseIdentifier:@\"aCell\"];\
    }\
    NSArray *array = objc_getAssociatedObject(self, @\"data\");\
    NSDictionary *model = array[indexPath.row];\
    NSString *title = model[@\"title\"];\
    if (title.length > 45) {\
        title = [title substringWithRange:NSMakeRange(0, 45)];\
    }\
    cell.textLabel.text = title;\
    cell.detailTextLabel.text = [NSString stringWithFormat:@\"%@,%@,%@\",model[@\"company\"],model[@\"location\"],model[@\"created_at\"]];\
    return cell;\
    ";

    [DynamicOC hookClass:@"ViewController"
                selector:@"tableView:cellForRowAtIndexPath:"
                argNames:@[@"tableView",@"indexPath"]
                 isClass:NO
          implementation:cellForRowAtIndexPath];


    //viewDidload
    NSString *viewDidload = @"\
    [OCCfuntionHelper defineCFunction:@\"objc_setAssociatedObject\" types:@\"void,id,void *,id,unsigned int\"];\
    [OCCfuntionHelper defineCFunction:@\"objc_getAssociatedObject\" types:@\"id,id,void *\"];\
    [originalInvocation invoke];\
	self.title = @\"DynamicOC\"; \
	CGRect rect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-64); \
    UITableView *tableView = [[UITableView alloc] initWithFrame:rect style:0];\
    [self.view addSubview:tableView];\
    tableView.delegate = self;\
    tableView.dataSource = self;\
    tableView.tableFooterView = [UIView new];\
    tableView.tableHeaderView = [UIView new];\
	UIActivityIndicatorView* loadingView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:2];	\
	loadingView.frame = CGRectMake(self.view.frame.size.width/2.0-22, self.view.frame.size.height/2.0-22, 44, 44);	\
	[loadingView startAnimating];	\
	[self.view addSubview:loadingView];	\
    NSURL *url = [NSURL URLWithString:@\"https://jobs.github.com/positions.json?page=1&search=iOS\"];\
    NSURLRequest *request = [NSURLRequest requestWithURL:url];\
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * response, NSData * data, NSError * connectionError) {\
		[loadingView stopAnimating];\
		if(data){\
			NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];\
			objc_setAssociatedObject(self, @\"data\", array, 1);\
			[tableView reloadData];\
		}\
    }];\
    ";

    [DynamicOC hookClass:@"ViewController"
             selector:@"viewDidLoad"
             argNames:@[]
              isClass:NO
       implementation:viewDidload];

	return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
	// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
