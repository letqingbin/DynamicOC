//
//  OCForControlTest.m
//  DynamicOCUITests
//
//  Created by dKingbin on 2019/7/23.
//  Copyright © 2019 dKingbin. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "ASTHeader.h"
#import "ASTUtil.h"
#import "OCCfuntionHelper.h"

@interface OCForControlTest : XCTestCase

@end

@implementation OCForControlTest

- (void)testFor
{
    NSString* text = @"int i; for(i=0;i<10;i++){} return i;";
    ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == 10, nil);
}

- (void)testFor1
{
    NSString* text = @"int i; for(i=0;i<10;i++); return i;";
    ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == 10, nil);
}

- (void)testFor2
{
    NSString* text = @"int i=0;for(;i<10;i++); return i;";
    ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == 10, nil);
}

- (void)testFor3
{
    NSString* text = @"int i;for(i=0;i<10;i++); return i;";
    ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == 10, nil);
}

- (void)testFor4
{
    NSString* text = @"int i; for(i=0;i<10;){ i++;} return i;";
    ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == 10, nil);
}

- (void)testFor5
{
    NSString* text = @"int i; for(i=0;i<10;i++){ if(i==5)break;} return i;";
    ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == 5, nil);
}

- (void)testFor6
{
    NSString* text = @"for(int i=0;i<10;i++){ if(i==5) return i;}";
    ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == 5, nil);
}

- (void)testFor7
{
    NSString* text = @"int j = 0; for(int i=0;i<10;i++){ if(j==5) continue; j++;} return j;";
    ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == 5, nil);
}


- (void)testFor8
{
    NSString* text = @"for(int i=0;i<10;i++){ } return i;";
    ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert(result.value == nil, nil);
}
@end
