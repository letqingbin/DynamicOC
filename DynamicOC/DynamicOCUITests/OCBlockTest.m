//
//  OCBlockTest.m
//  DynamicOCUITests
//
//  Created by dKingbin on 2019/7/26.
//  Copyright © 2019 dKingbin. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "ASTHeader.h"
#import "ASTUtil.h"
#import "OCCfuntionHelper.h"
#import "ASTVariable.h"

@interface OCBlockTest : XCTestCase

@end

@implementation OCBlockTest

- (void)testBlock
{
    NSString* text = @"__block int result = 0;\
    UIView* view = [[UIView alloc]init];\
    void(^blk)(NSInteger toAdd) = ^(NSInteger toAdd){\
    result = result + toAdd;\
    view.tag = 1024;\
    };\
    blk(3);\
    return view.tag;";
    
    ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == 1024, nil);
}

- (void)testBlock1
{
    NSString* text = @"__block int result = 0;\
    UIView* view = [[UIView alloc]init];\
    void(^blk)(NSInteger toAdd) = ^(NSInteger toAdd){\
    result = result + toAdd;\
    view.tag = 1024;\
    };\
    blk(666);\
    return result;";
    
    ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == 666, nil);
}

- (void)testBlock2
{
    NSString *text = @"NSArray *content = @[@6,@7,@8,@9,@1,@2,@3,@4];\
    __block NSInteger result = 0;\
    [content enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {\
        result = result + 1;\
    }];\
    return result;";
    
    ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == 8, nil);
}

- (void)testBlock3
{
    NSString *text = @"NSArray *content = @[@6,@7,@8,@9,@1,@2,@3,@4];\
    NSComparisonResult (^comparison)(id obj1, id obj2) = ^NSComparisonResult(id obj1, id obj2) {\
    return [obj1 doubleValue] > [obj2 doubleValue];\
    };\
    content = [content sortedArrayUsingComparator:comparison];\
    return content;";

    ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value[6] intValue] == 8, nil);
}

- (void)testBlock4
{
	NSString *text = @"^{};";

	ASTNode* root = [ASTUtil parseString:text];
	
	[root execute];
}

//TODO
//- (void)testBlock5
//{
//    NSString *text = @"NSArray *content = @[@6,@7,@8,@9,@1,@2,@3,@4];\
//    __block NSInteger result = 0;\
//    [content enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {\
//        result = result + 1;\
//        if(result == 1) *stop = YES;\
//    }]; \
//    return result;";
//
//    ASTNode* root = [ASTUtil parseString:text];
//    
//    ASTVariable* result = [root execute];
//    NSAssert([result.value doubleValue] == 1, nil);
//}

@end
