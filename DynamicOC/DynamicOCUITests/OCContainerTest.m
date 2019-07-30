//
//  OCContainerTest.m
//  DynamicOCUITests
//
//  Created by dKingbin on 2019/7/26.
//  Copyright © 2019 dKingbin. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "ASTHeader.h"
#import "ASTUtil.h"
#import "OCCfuntionHelper.h"

@interface OCContainerTest : XCTestCase

@end

@implementation OCContainerTest

- (void)testNSArray
{
	NSString* text = @"NSArray *array = @[@\"a\",[NSNull null],@\"c\",[NSString string],@(1024)]; return array[4];";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	NSAssert([result.value doubleValue] == 1024, nil);
}

- (void)testNSArraySetterGetter
{
	NSString* text = @"NSArray *array = @[@\"a\",[NSNull null],@\"c\",[NSString string],@(5)];\
	NSMutableArray *mutaArray = [array mutableCopy];\
	mutaArray[5] = @(1024);\
	return mutaArray[5];";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	NSAssert([result.value doubleValue] == 1024, nil);
}

- (void)testNSArraySetterGetter1
{
	NSString* text = @"NSMutableArray *mutaArray = [NSMutableArray array];\
	[mutaArray addObject:@(1024)];\
	return mutaArray[0];";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	NSAssert([result.value doubleValue] == 1024, nil);
}

- (void)testNSArraySetterGetter2
{
	NSString* text = @"NSArray *array = @[@\"a\",[NSNull null],@\"c\",[NSString string],@(5)];\
	NSMutableArray *mutaArray = [array mutableCopy];\
	[mutaArray removeAllObjects];\
	return mutaArray.count == 0 && array.count == 5;";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	NSAssert([result.value boolValue] == YES, nil);
}

- (void)testNSArraySetterGetter3
{
	NSString* text = @"NSArray *array = @[@\"a\",[NSNull null],@\"c\",[NSString string],@(1024)];\
	NSObject *object = [[NSObject alloc] init];\
	NSObject* key = [[NSObject alloc]init]; \
	objc_setAssociatedObject(object, key, array, 1);\
	NSArray *objcArray = objc_getAssociatedObject(object, key); \
	return objcArray[4];";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	NSAssert([result.value doubleValue] == 1024, nil);
}

int indexFunc(int index)
{
	return index;
}

- (void)testNSArraySetterGetter4
{
	[OCCfuntionHelper defineCFunction:@"indexFunc" types:@"int,int"];
	NSString* text = @"NSMutableArray *array = [@[@\"a\",[NSNull null],@\"c\",[NSString string],@(666)] mutableCopy]; return array[indexFunc(4)];";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	NSAssert([result.value doubleValue] == 666, nil);
}

+ (int)indexFunc:(int)index
{
	return index;
}

- (void)testNSArraySetterGetter5
{
	[OCCfuntionHelper defineCFunction:@"indexFunc" types:@"int,int"];
	NSString* text = @"NSMutableArray *array = [@[@\"a\",[NSNull null],@\"c\",[NSString string],@(1024)] mutableCopy]; return array[[OCContainerTest indexFunc:4]];";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	NSAssert([result.value doubleValue] == 1024, nil);
}

- (void)testNSArraySetterGetter6
{
	NSString* text = @"NSDictionary *dict = @{@\"aaa\":@(1),@\"6666\":@{@\"bbb\":@\"cccc\"}}; \
	NSMutableArray *array = [@[dict, @\"a\",[NSNull null],@\"c\",[NSString string],@(1024)] mutableCopy]; \
	return array[0][@\"6666\"][@\"bbb\"];";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	NSAssert([@"cccc" isEqualToString:result.value], nil);
}

- (void)testNSArraySetterGetter7
{
    NSString* text = @"NSMutableArray *array = [@[@1,@666,@3,@4.5,@(1024)] mutableCopy]; \
    return array[1];";
    ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == 666, nil);
}

- (void)testNSDictionarySetterGetter
{
	NSString* text = @"NSDictionary *dict = @{@\"aaa\":@(1024),@\"6666\":@{@\"bbb\":@\"cccc\"}}; return dict[@\"aaa\"];";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	NSAssert([result.value doubleValue] == 1024, nil);
}

- (void)testNSDictionarySetterGetter1
{
	NSString* text = @"NSMutableDictionary *dict = [@{@\"aaa\":@(1024),@\"6666\":@{@\"bbb\":@\"cccc\"}} mutableCopy];dict[@(1024)] = @(666); return dict[@(1024)];";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	NSAssert([result.value doubleValue] == 666, nil);
}

- (void)testNSDictionarySetterGetter2
{
	NSString* text = @"NSDictionary *dict = @{@\"aaa\":@(1),@\"6666\":@{@\"bbb\":@\"cccc\"}};\
	return dict[@\"6666\"][@\"bbb\"];";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	NSAssert([@"cccc" isEqualToString:result.value], nil);
}

- (void)testNSDictionarySetterGetter3
{
	NSString* text = @"NSArray *array = @[@(666),@(1024),@(2048)];NSDictionary *dic = @{@\"aaa\":@(1),@\"6666\":@{@\"bbb\":array}};\
	return dic[@\"6666\"][@\"bbb\"][1];";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	NSAssert([result.value doubleValue] == 1024, nil);
}

- (void)testNSDictionarySetterGetter4
{
	NSString* text = @"NUIView* view = [[UIView alloc]init];view.tag=1024;NSDictionary *dic = @{@\"aaa\":@(1),@\"6666\":@{@\"bbb\":view}};\
	return dic[@\"6666\"][@\"bbb\"].tag;";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	NSAssert([result.value doubleValue] == 1024, nil);
}

- (void)testNSDictionarySetterGetter5
{
	NSString* text = @"NUIView* view = [[UIView alloc]initWithFrame:CGRectMake(1,2,3,4)];NSDictionary *dic = @{@\"aaa\":@(1),@\"6666\":@{@\"bbb\":view}};\
	return dic[@\"6666\"][@\"bbb\"].frame;";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	CGRect rect = [result.value CGRectValue];
	NSAssert(CGRectEqualToRect(rect, CGRectMake(1, 2, 3, 4)), nil);
}

- (void)testNSDictionarySetterGetter6
{
	NSString* text = @"NUIView* view = [[UIView alloc]initWithFrame:CGRectMake(1,2,3,4)];NSDictionary *dic = @{@\"aaa\":@(1),@\"6666\":@{@\"bbb\":view}};\
	return dic[@\"6666\"][@\"bbb\"].frame.size;";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	CGSize size = [result.value CGSizeValue];
	NSAssert(CGSizeEqualToSize(CGSizeMake(3, 4), size), nil);
}

- (void)testNSDictionarySetterGetter7
{
	NSString* text = @"NUIView* view = [[UIView alloc]initWithFrame:CGRectMake(1,2,3,4)];NSDictionary *dic = @{@\"aaa\":@(1),@\"6666\":@{@\"bbb\":view}};\
	return dic[@\"6666\"][@\"bbb\"].frame.size.width;";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	NSAssert([result.value doubleValue] == 3, nil);
}


@end
