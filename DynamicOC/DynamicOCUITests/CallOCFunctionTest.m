//
//  CallOCFunctionTest.m
//  DynamicOCUITests
//
//  Created by dKingbin on 2019/7/23.
//  Copyright © 2019 dKingbin. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "ASTHeader.h"
#import "ASTUtil.h"
#import "OCCfuntionHelper.h"

@interface CallOCFunctionTest : XCTestCase

@end

@implementation CallOCFunctionTest

+ (int)echo
{
	return 1024;
}

+ (int)echoInteger:(int)value
{
	return value;
}

+ (float)echoFloat:(float)value
{
	return value;
}

+ (NSString*)echoString:(NSString*)value
{
	return value;
}

+ (float)echo:(float)value1 value2:(float)value2 value3:(float)value3
{
	return value1 + value2 + value3;
}

+ (float)echo:(float)value1 :(float)value2 :(float)value3
{
	return value1 + value2 + value3;
}

- (CGRect)frame
{
	return CGRectMake(0, 0, 375, 667);
}

- (void)testSelf
{
	[ASTUtil registerVariableForYacc:@"self"];

	NSMutableDictionary* ctx = [NSMutableDictionary dictionary];
	ASTVariable* varSelf = [[ASTVariable alloc]init];
	varSelf.value = self;
	varSelf.type = ASTNodeTypeVariable;
	[ctx setObject:varSelf forKey:@"self"];

	NSString* text = @"return [self frame].size.width;";

	ASTNode* root = [ASTUtil parseString:text];
	[root.context pushDefinedContext:ctx];

	ASTVariable* result = [root execute];

	NSAssert([result.value doubleValue] == 375, nil);
}

- (void)testCallOCFunction
{
	NSString* text = @"return [CallOCFunctionTest echo];";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	NSAssert([result.value doubleValue] == 1024, nil);
}

- (void)testCallOCFunction1
{
	NSString* text = @"return [CallOCFunctionTest echoInteger:1024];";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	NSAssert([result.value doubleValue] == 1024, nil);
}

- (void)testCallOCFunction2
{
	NSString* text = @"return [CallOCFunctionTest echoFloat:6.666];";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	NSAssert(fabs([result.value floatValue]-6.666) <= 0.001 , nil);
}

- (void)testCallOCFunction3
{
	NSString* text = @"return [CallOCFunctionTest echoString:@\"DynamicOC!\"];";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	NSAssert([@"DynamicOC!" isEqualToString:result.value], nil);
}

- (void)testCallOCFunction4
{
	NSString* text = @"return [CallOCFunctionTest echo:1.0 value2:2.0 value3:3.0];";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	NSAssert(fabs([result.value floatValue]-6.0) <= 0.001, nil);
}

- (void)testCallOCFunction5
{
	NSString* text = @"return [CallOCFunctionTest echo:1.0 :2.0 :3.0];";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	NSAssert(fabs([result.value floatValue]-6.0) <= 0.001, nil);
}

- (void)testCallOCFunction6
{
	NSString* text = @"NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@(1024),@\"key1\",@(2),@\"key2\", nil]; return dict[@\"key1\"];";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	NSAssert([result.value doubleValue] == 1024, nil);
}

- (void)testCallOCFunction7
{
	NSString* text = @"NSString *str = @\"a\";\
	NSString *str2 = [str stringByAppendingFormat:@\"%@,%@\",@\"2\",@(4+5*2)];\
	return str2;";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	NSAssert([result.value isEqualToString:@"a2,14"], nil);
}

@end
