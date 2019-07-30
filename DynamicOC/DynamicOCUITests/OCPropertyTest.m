//
//  OCPropertyTest.m
//  DynamicOCUITests
//
//  Created by dKingbin on 2019/7/24.
//  Copyright © 2019 dKingbin. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "ASTHeader.h"
#import "ASTUtil.h"
#import "OCCfuntionHelper.h"
#import <objc/runtime.h>

@interface OCPropertyTest : XCTestCase
{
	int __tag;
	NSString* _str;
}

@property(nonatomic,assign) int value;
@property(nonatomic,assign) CGRect frame;
@end

@implementation OCPropertyTest

- (void)testSelf
{
	self.frame = CGRectMake(0, 0, 375, 667);

	[ASTUtil registerVariableForYacc:@"self"];

	NSMutableDictionary* ctx = [NSMutableDictionary dictionary];
	ASTVariable* varSelf = [[ASTVariable alloc]init];
	varSelf.value = self;
	varSelf.type = ASTNodeTypeVariable;
	[ctx setObject:varSelf forKey:@"self"];

	NSString* text = @"UITableView *tableView = [[UITableView alloc] initWithFrame:self.frame style:0]; return tableView.frame.size.width;";

	ASTNode* root = [ASTUtil parseString:text];
	[root.context pushDefinedContext:ctx];
	ASTVariable* result = [root execute];

	NSAssert([result.value doubleValue] == 375, nil);
}

- (void)testSelf1
{
	self.frame = CGRectMake(0, 0, 375, 667);

	[ASTUtil registerVariableForYacc:@"self"];

	NSMutableDictionary* ctx = [NSMutableDictionary dictionary];
	ASTVariable* varSelf = [[ASTVariable alloc]init];
	varSelf.value = self;
	varSelf.type = ASTNodeTypeVariable;
	[ctx setObject:varSelf forKey:@"self"];

	NSString* text = @"self.frame.size.width = 1024; return self.frame;";

	ASTNode* root = [ASTUtil parseString:text];
	[root.context pushDefinedContext:ctx];

	ASTVariable* result = [root execute];

	NSAssert(CGRectEqualToRect(CGRectMake(0, 0, 1024, 667), [result.value CGRectValue]), nil);
}

- (void)testSuper
{
	[ASTUtil registerVariableForYacc:@"self"];
	[ASTUtil registerVariableForYacc:@"super"];

	NSMutableDictionary* ctx = [NSMutableDictionary dictionary];
	ASTVariable* varSelf = [[ASTVariable alloc]init];
	varSelf.value = self;
	varSelf.type = ASTNodeTypeVariable;
	[ctx setObject:varSelf forKey:@"self"];

	NSString* text = @"return [super name];";

	ASTNode* root = [ASTUtil parseString:text];
	[root.context pushDefinedContext:ctx];

	ASTVariable* result = [root execute];

	NSAssert([[super name] isEqualToString:result.value], nil);
}

- (void)testSuper1
{
	[ASTUtil registerVariableForYacc:@"self"];
	[ASTUtil registerVariableForYacc:@"super"];

	NSMutableDictionary* ctx = [NSMutableDictionary dictionary];
	ASTVariable* varSelf = [[ASTVariable alloc]init];
	varSelf.value = self;
	varSelf.type = ASTNodeTypeVariable;
	[ctx setObject:varSelf forKey:@"self"];

	NSString* text = @"return super.name;";

	ASTNode* root = [ASTUtil parseString:text];
	[root.context pushDefinedContext:ctx];
	
	ASTVariable* result = [root execute];

	NSAssert([[super name] isEqualToString:result.value], nil);
}

- (void)testMemberVariable
{
	NSString* text = @"OCPropertyTest *test = [[OCPropertyTest alloc]init]; test->__tag = 1024; return test->__tag;";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	NSAssert([result.value doubleValue] == 1024, nil);
}

- (void)testMemberVariable1
{
	NSString* text = @"OCPropertyTest *test = [[OCPropertyTest alloc]init]; test->_str = @\"helloworld\"; return test->_str;";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	NSAssert([result.value isEqualToString:@"helloworld"], nil);
}

- (void)testProperty
{
	NSString* text = @"OCPropertyTest *test = [[OCPropertyTest alloc]init]; test->_value = 666; return test->_value;";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	NSAssert([result.value doubleValue] == 666, nil);
}

- (void)testStructGetterSetter
{
	NSString* text = @" UIView *view = [[UIView alloc] init];\
	CGRect bound = [view bounds];\
	return bound;";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	CGRect rect = [result.value CGRectValue];
	NSAssert(CGRectEqualToRect(CGRectZero,rect), nil);
}

- (void)testStructGetterSetter1
{
	NSString* text = @"UIView *view = [[UIView alloc]initWithFrame:CGRectMake(1, 2, 3, 4)];\
	CGRect bound = [view bounds];\
	return bound;";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	CGRect rect = [result.value CGRectValue];
	NSAssert(CGRectEqualToRect(CGRectMake(0, 0, 3, 4),rect), nil);
}

- (void)testStructGetterSetter2
{
	NSString* text = @"CGPoint point = CGPointMake(1,2); return point;";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	CGPoint pt = [result.value CGPointValue];
	NSAssert(CGPointEqualToPoint(pt, CGPointMake(1, 2)), nil);
}

- (void)testStructGetterSetter3
{
	NSString* text = @"CGPoint point = CGPointMake(1,2); return point.x;";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	NSAssert([result.value doubleValue] == 1, nil);
}

- (void)testUIView
{
    NSString* text = @"UIView* view = [[UIView alloc]init];view.tag=1024;return view.tag;";
    ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == 1024, nil);
}

- (void)testOCStructGetterSetter1
{
	NSString* text = @"UIView* view = [[UIView alloc]initWithFrame:CGRectMake(1, 2, 3, 4)];view.frame.size.width=1024; return view.frame.size.width;";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	NSAssert([result.value doubleValue] == 1024, nil);
}

- (void)testOCStructGetterSetter2
{
	NSString* text = @"UIView* view = [[UIView alloc]initWithFrame:CGRectMake(1, 2, 3, 4)];view.frame = CGRectMake(6,6,1024,6); return view.frame.size.width;";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	NSAssert([result.value doubleValue] == 1024, nil);
}

- (void)testOCStructGetterSetter3
{
	NSString* text = @"UIView* view = [[UIView alloc]initWithFrame:CGRectMake(1, 2, 3, 4)];view.frame.size = CGSizeMake(2048,0); return view.frame.size.width;";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	NSAssert([result.value doubleValue] == 2048, nil);
}

- (void)testOCStructGetterSetter4
{
	NSString* text = @"CGRect rect = CGRectMake(1, 2, 3, 4); return rect.size.width;";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	NSAssert([result.value doubleValue] == 3, nil);
}

- (void)testOCStructGetterSetter5
{
	NSString* text = @"CGRect rect = CGRectMake(1, 2, 3, 4); return rect.size.height;";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	NSAssert([result.value doubleValue] == 4, nil);
}

- (void)testOCStructGetterSetter6
{
	NSString* text = @"CGRect rect = CGRectMake(1, 2, 3, 4); return rect.origin.x;";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	NSAssert([result.value doubleValue] == 1, nil);
}

- (void)testOCStructGetterSetter7
{
	NSString* text = @"CGRect rect = CGRectMake(1, 2, 3, 4); return rect.origin.y;";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	NSAssert([result.value doubleValue] == 2, nil);
}

- (void)testOCStructGetterSetter8
{
	NSString* text = @"CGRect rect = CGRectMake(1, 2, 3, 4); rect.origin.x=1024; return rect.origin.x;";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	NSAssert([result.value doubleValue] == 1024, nil);
}

- (void)testOCStructGetterSetter9
{
	NSString* text = @"CGSize size = CGSizeMake(1,2); return size.width;";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	NSAssert([result.value doubleValue] == 1, nil);
}

- (void)testOCStructGetterSetter10
{
	NSString* text = @"CGSize size = CGSizeMake(1,2); return size.height;";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	NSAssert([result.value doubleValue] == 2, nil);
}

- (void)testOCStructGetterSetter11
{
	NSString* text = @"CGSize size = CGSizeMake(1,2); size.width = 1024; return size.width;";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	NSAssert([result.value doubleValue] == 1024, nil);
}

- (void)testOCStructGetterSetter12
{
	NSString* text = @"CGSize size = CGSizeMake(1,2); size.height = 1024; return size.height;";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	NSAssert([result.value doubleValue] == 1024, nil);
}

- (void)testOCStructGetterSetter13
{
	NSString* text = @"CGSize size = CGSizeMake(1,2); size = CGSizeMake(1024,2048); return size;";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	NSAssert(CGSizeEqualToSize(CGSizeMake(1024, 2048), [result.value CGSizeValue]), nil);
}

- (void)testOCStructGetterSetter14
{
	NSString* text = @"UIEdgeInsets inset = UIEdgeInsetsMake(1, 2, 3, 4); return inset;";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	NSAssert(UIEdgeInsetsEqualToEdgeInsets(UIEdgeInsetsMake(1, 2, 3, 4), [result.value UIEdgeInsetsValue]), nil);
}

- (void)testOCStructGetterSetter15
{
	NSString* text = @"UIEdgeInsets inset = UIEdgeInsetsMake(1, 2, 3, 4); inset.top=1024; return inset.top;";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	NSAssert([result.value doubleValue] == 1024, nil);
}

- (void)testOCStructGetterSetter16
{
	NSString* text = @"UIEdgeInsets inset = UIEdgeInsetsMake(1, 2, 3, 4); inset.left=1024; return inset.left;";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	NSAssert([result.value doubleValue] == 1024, nil);
}

- (void)testNSString
{
	NSString* text = @"NSString* str = @\"abcdefgh\"; return str.length;";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	NSAssert([result.value doubleValue] == [@"abcdefgh" length], nil);
}

- (void)testNSNumber
{
	NSString* text = @"NSNumber* ival = @(1024); return ival;";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	NSAssert([result.value doubleValue] == 1024, nil);
}


@end
