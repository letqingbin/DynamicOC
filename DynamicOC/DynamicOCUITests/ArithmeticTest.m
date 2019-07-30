//
//  ArithmeticTest.m
//  DynamicOCUITests
//
//  Created by dKingbin on 2019/7/23.
//  Copyright © 2019 dKingbin. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "ASTHeader.h"
#import "ASTUtil.h"
#import "OCCfuntionHelper.h"

@interface ArithmeticTest : XCTestCase

@end

@implementation ArithmeticTest

- (void)testAdd
{
    NSString* text = @"int i=1;int j=2;i=i+j;return i;";
    ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == 3, nil);
}

- (void)testSub
{
    NSString* text = @"int i=10;int j=2;i=i-j;return i;";
    ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == 8, nil);
}

- (void)testSub1
{
    NSString* text = @"int i=10;int j=2;i=j-i;return i;";
    ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == -8, nil);
}

- (void)testMul
{
    NSString* text = @"int i=3;int j=2;i=i*j;return i;";
    ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == 6, nil);
}

- (void)testMul1
{
    NSString* text = @"int i=0;int j=2;i=i*j;return i;";
    ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == 0, nil);
}

- (void)testDiv
{
    NSString* text = @"int i=4;int j=2;i=i/j;return i;";
    ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == 2, nil);
}

- (void)testRemainder
{
    NSString* text = @"int i=5;int j=2;i=i%j;return i;";
    ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == 1, nil);
}

- (void)testRightShitf
{
    NSString* text = @"int i=20;int j=2;i=i>>j;return i;";
    ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == 5, nil);
}

- (void)testLeftShitf
{
    NSString* text = @"int i=5;int j=2;i=i<<j;return i;";
    ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == 20, nil);
}

- (void)testBitAnd
{
    NSString* text = @"int i=1;int j=1;i=i&j;return i;";
    ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == 1, nil);
}

- (void)testBitOR
{
    NSString* text = @"int i=1;int j=0;i=i|j;return i;";
    ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == 1, nil);
}

- (void)testBitNOT
{
    NSString* text = @"int i=1; int j=1; i = i^j; return i;";
    ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == 0, nil);
}

- (void)testArithmetic
{
    NSString* text = @"int i = (1+1)*2; return i;";
    ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == 4, nil);
}

- (void)testArithmetic1
{
    NSString* text = @"int i = 1+1*2; return i;";
    ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == 3, nil);
}

- (void)testArithmetic2
{
    NSString* text = @"int i = 1+1/2; return i;";
    ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == 1, nil);
}

- (void)testArithmetic3
{
    NSString* text = @"float i = 1+1/2.0; return i;";
    ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == 1.5, nil);
}

- (void)testArithmetic4
{
    NSString* text = @"int i = 1+1/2.0; return i;";
    ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == 1, nil);
}

- (void)testArithmetic5
{
	NSString* text = @"return 5-(1+2*4);";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	NSAssert([result.value doubleValue] == -4, nil);
}

- (void)testArithmetic6
{
    NSString* text = @"int ival = 10; int j = ival * (10); return j;";
    ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == 100, nil);
}

@end
