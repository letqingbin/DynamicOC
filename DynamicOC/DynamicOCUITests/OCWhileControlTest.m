//
//  OCWhileControlTest.m
//  DynamicOCUITests
//
//  Created by dKingbin on 2019/7/23.
//  Copyright © 2019 dKingbin. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "ASTHeader.h"
#import "ASTUtil.h"
#import "OCCfuntionHelper.h"

@interface OCWhileControlTest : XCTestCase

@end

@implementation OCWhileControlTest

- (void)testWhile
{
	NSString* text = @"int i=1;while(i<10){ i++; } return i;";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	NSAssert([result.value doubleValue] == 10, nil);
}

- (void)testWhile1
{
	NSString* text = @"NSNumber* ival = @(0); int i=1;while(ival){ i++; if(i==10) return i; }";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	NSAssert([result.value doubleValue] == 10, nil);
}

- (void)testWhile2
{
	NSString* text = @"NSNumber* ival = @(0); int i=1;while(ival){ i++; if(i==10) break; } return i;";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	NSAssert([result.value doubleValue] == 10, nil);
}

- (void)testWhile3
{
	NSString* text = @"int count = 1; int i=1;while(count < 10){ count++; if(i==5) continue; i++; } return i;";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	NSAssert([result.value doubleValue] == 5, nil);
}

- (void)testWhile4
{
    NSString* text = @"int i=0; do { i=1024;} while(0); return i;";
    ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == 1024, nil);
}

- (void)testWhile5
{
    NSString* text = @"int i=1; do { i= i + 1;} while(i<10); return i;";
    ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == 10, nil);
}

- (void)testWhile6
{
    NSString* text = @"int i=1; do { i= i + 1; if(i==10) break;} while(i<1000); return i;";
    ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == 10, nil);
}

- (void)testWhile7
{
    NSString* text = @"int i=1; do { i= i + 1; if(i==10) return 1024;} while(i<1000);";
    ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == 1024, nil);
}

- (void)testWhile8
{
    NSString* text = @"int count = 1; int i=1;do{ count++; if(i==5) continue; i++; }while(count<10); return i;";
    ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == 5, nil);
}

@end
