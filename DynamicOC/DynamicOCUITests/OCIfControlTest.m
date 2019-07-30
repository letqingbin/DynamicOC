//
//  OCIfControlTest.m
//  DynamicOCUITests
//
//  Created by dKingbin on 2019/7/23.
//  Copyright © 2019 dKingbin. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "ASTHeader.h"
#import "ASTUtil.h"
#import "OCCfuntionHelper.h"

@interface OCControlTest : XCTestCase

@end

@implementation OCControlTest

- (void)testIf
{
	NSString* text = @"int i=1;if(i==1){ return 1024; }";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	NSAssert([result.value doubleValue] == 1024, nil);
}

- (void)testIf1
{
	NSString* text = @"int i=1;if(i==1);";
	[ASTUtil parseString:text];
}

- (void)testIf2
{
	NSString* text = @"int i=1; int j=2; if(i==j){ return i; } else { return j; }";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	NSAssert([result.value doubleValue] == 2, nil);
}

- (void)testIf3
{
	NSString* text = @"int i=1; int j=2; if(i==j){ return i; } else if( i<= j) { return j; }";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	NSAssert([result.value doubleValue] == 2, nil);
}

- (void)testIf4
{
	NSString* text = @"int i=1; int j=2; if(i==j){ return i; } else if( i>= j) { return j; } else { return 1024; }";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	NSAssert([result.value doubleValue] == 1024, nil);
}

- (void)testIf5
{
	NSString* text = @"NSNumber* ival = @(0);if(ival){ return YES; }";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	NSAssert([result.value boolValue] == YES, nil);
}

- (void)testIf6
{
	NSString* text = @"NSNumber* ival = @(0);if(!ival){ return YES; } else { return NO; }";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	NSAssert([result.value boolValue] == NO, nil);
}

- (void)testIf7
{
	NSString* text = @"NSString* str = @\"abcdefg\"; if(str.length > 0) { return str; }";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	NSAssert([result.value isEqualToString:@"abcdefg"], nil);
}

- (void)testIf8
{
	NSString* text = @"NSString* str = @\"abcdefg\"; if(str) { return str; }";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	NSAssert([result.value isEqualToString:@"abcdefg"], nil);
}

- (void)testIf9
{
    NSString* text = @"NSNumber* ival = nil; if(ival) { return 0; } else { return 1024; }";
    ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == 1024, nil);
}

- (void)testIf10
{
    NSString* text = @"NSNumber* ival = nil; if(!ival) { return 1024; } else { return 0; }";
    ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == 1024, nil);
}

- (void)testIf11
{
    NSString* text = @"if(YES) { return 1024; } else { return 0; }";
    ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == 1024, nil);
}

- (void)testIf12
{
    NSString* text = @"if(YES && NO) { return 1024; } else { return 0; }";
    ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == 0, nil);
}

- (void)testIf13
{
    NSString* text = @"if((YES) && (NO)) { return 1024; } else { return 0; }";
    ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == 0, nil);
}

- (void)testIf14
{
    NSString* text = @"if((YES) || (NO)) { return 1024; } else { return 0; }";
    ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == 1024, nil);
}

- (void)testIf15
{
    NSString* text = @"if((true) || (false)) { return 1024; } else { return 0; }";
    ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == 1024, nil);
}

- (void)testIf16
{
	NSString* text = @"CGRect rect = CGRectMake(1,2,3,4); if(rect.size.width == 3) return rect;";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	NSAssert(CGRectEqualToRect([result.value CGRectValue], CGRectMake(1,2,3,4)), nil);
}

- (void)testIf17
{
	NSString* text = @"UIView* view = [[UIView alloc]init]; view.tag = 1024; if(view.tag == 1024) return view.tag;";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	NSAssert([result.value doubleValue] == 1024, nil);
}

- (void)testIf18
{
	NSString* text = @"UIView* view = [[UIView alloc]init]; view.tag = 1; if(view.tag != 1024) return 6666;";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	NSAssert([result.value doubleValue] == 6666, nil);
}

- (void)testIf19
{
    NSString* text = @"NSArray* array = @[@(1)]; if(array.count>0) return 6666;";
    ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == 6666, nil);
}

- (void)testIf20
{
    NSString* text = @"if([NSString string] != nil) return 6666; else return 1024;";
    ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == 6666, nil);
}

- (void)testIf21
{
    NSString* text = @"if(3 <= 4 && [NSString string] != nil) return 6666; else return 1024;";
    ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == 6666, nil);
}

- (void)testIf22
{
    NSString* text = @"int i=1; if(i > 0) i = 2; if(i < 0) i = 666; else i = 1024; return i;";
    ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == 1024, nil);
}

- (void)testCondition
{
    NSString* text = @"int i=1;int j=2;int k = i <= j ? 666 : 1024; return k;";
    ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == 666, nil);
}

- (void)testCondition1
{
    NSString* text = @"int i=1;int j=2;int k = i > j ? 666 : 1024; return k;";
    ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == 1024, nil);
}

- (void)testCondition2
{
    NSString* text = @"int i=1;int j=2;int k = (i <= j) ? 666 : 1024; return k;";
    ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == 666, nil);
}

- (void)testCondition3
{
    NSString* text = @"NSNumber* ival = @(0);int k = ival ? 666 : 1024; return k;";
    ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == 666, nil);
}

- (void)testCondition4
{
    NSString* text = @"NSNumber* ival = @(0);int k = !ival ? 666 : 1024; return k;";
    ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == 1024, nil);
}

- (void)testCondition5
{
    NSString* text = @"NSString* str = @\"abcedf\";int k = str.length > 0 ? 666 : 1024; return k;";
    ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == 666, nil);
}

- (void)testCondition6
{
    NSString* text = @"NSString* str = @\"abcedf\";int k = [str length] > 0 ? 666 : 1024; return k;";
    ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == 666, nil);
}

- (void)testCondition7
{
    NSString* text = @"NSArray* array = @[@(1),@(2)];int k = array.count > 0 ? 666 : 1024; return k;";
    ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == 666, nil);
}

- (void)testCondition8
{
    NSString* text = @"NSArray* array = @[@(1),@(2)];int k = [array count] > 0 ? 666 : 1024; return k;";
    ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == 666, nil);
}

- (void)testCondition9
{
    NSString* text = @"NSArray* array = @[@(1),@(2)];int k = array[0] > 0 ? 666 : 1024; return k;";
    ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == 666, nil);
}

- (void)testSelf
{
	[ASTUtil registerVariableForYacc:@"self"];
	
	NSMutableDictionary* ctx = [NSMutableDictionary dictionary];
	ASTVariable* varSelf = [[ASTVariable alloc]init];
	varSelf.value = self;
	varSelf.type = ASTNodeTypeVariable;
	[ctx setObject:varSelf forKey:@"self"];

	NSString* text = @"if(!self) return 666; else return 1024;";

	ASTNode* root = [ASTUtil parseString:text];
	[root.context pushDefinedContext:ctx];

	ASTVariable* result = [root execute];
	NSAssert([result.value doubleValue] == 1024, nil);
}

@end
