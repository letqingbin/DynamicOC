//
//  UnaryOperationTest.m
//  DynamicOCUITests
//
//  Created by dKingbin on 2019/7/23.
//  Copyright © 2019 dKingbin. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "ASTHeader.h"
#import "ASTUtil.h"
#import "OCCfuntionHelper.h"

@interface UnaryOperationTest : XCTestCase

@end

@implementation UnaryOperationTest

- (void)testUnaryPrefixInc
{
    NSString* text = @"int i=1;int j=++i; return j;";
    ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == 2, nil);
}

- (void)testUnaryPrefixDec
{
    NSString* text = @"int i=1;int j=--i; return j;";
    ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == 0, nil);
}

- (void)testUnaryPostInc
{
    NSString* text = @"int i=1;int j=i++; return j;";
    ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == 1, nil);
}

- (void)testUnaryPostInc1
{
    NSString* text = @"int i=1;int j=i++; return i;";
    ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == 2, nil);
}

- (void)testUnaryPostDec
{
    NSString* text = @"int i=1;int j=i--; return j;";
    ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == 1, nil);
}

- (void)testUnaryPostDec1
{
    NSString* text = @"int i=1;int j=i--; return i;";
    ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == 0, nil);
}

- (void)testUnaryPlus
{
    NSString* text = @"int i=1;int j=+i; return j;";
    ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == 1, nil);
}

- (void)testUnaryMinus
{
    NSString* text = @"int i=1;int j=-i; return j;";
    ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == -1, nil);
}

- (void)testUnaryMinus1
{
    NSString* text = @"int i=1;int j=-(-i); return j;";
    ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == 1, nil);
}

- (void)testUnaryNOT
{
    NSString* text = @"int i=0; i = !i; return i;";
    ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == 1, nil);
}

- (void)testUnaryNOT1
{
    NSString* text = @"NSNumber* ival = @(0); BOOL ok = !ival; return ok;";
    ASTNode* root = [ASTUtil parseString:text];
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == NO, nil);
}

- (void)testUnaryNOT2
{
    NSString* text = @"NSNumber* ival = nil; BOOL ok = !ival; return ok;";
    ASTNode* root = [ASTUtil parseString:text];
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == YES, nil);
}

- (void)testUnaryNOT3
{
	NSString* text = @"NSNumber* ival = nil; !ival; return ival;";
	ASTNode* root = [ASTUtil parseString:text];
	ASTVariable* result = [root execute];
	NSAssert(result.value == nil, nil);
}

@end
