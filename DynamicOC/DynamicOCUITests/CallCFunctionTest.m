//
//  CallCFunctionTest.m
//  DynamicOCUITests
//
//  Created by dKingbin on 2019/7/23.
//  Copyright © 2019 dKingbin. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "ASTHeader.h"
#import "ASTUtil.h"
#import "OCCfuntionHelper.h"
#import <objc/runtime.h>
#import <dlfcn.h>

@interface CallCFunctionTest : XCTestCase

@end

@implementation CallCFunctionTest

int funcWithNoArgs()
{
	return 1024;
}

int funcWithOneArg(int value)
{
	return value;
}

NSString* funcWithOCArg(NSString* str)
{
    return str;
}

- (void)testCallCFunctionWithNoArgs
{
	[OCCfuntionHelper defineCFunction:@"funcWithNoArgs" types:@"int"];

	NSString* text = @"int i = funcWithNoArgs(); return i;";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == 1024, nil);
}

- (void)testCallCFunctionWithOneArg
{
	[OCCfuntionHelper defineCFunction:@"funcWithOneArg" types:@"int,int"];

	NSString* text = @"return funcWithOneArg(1024);";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value doubleValue] == 1024, nil);
}

- (void)testCallCFunctionWithOCArg
{
	[OCCfuntionHelper defineCFunction:@"funcWithOCArg" types:@"NSString*,NSString*"];
    
	NSString* text = @"return funcWithOCArg(@\"hello iOS!\");";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
    NSAssert([result.value isEqualToString:@"hello iOS!"], nil);
}

- (void)testOCCFunctionCall
{
	[OCCfuntionHelper defineCFunction:@"NSClassFromString" types:@"Class, NSString *"];

	NSString* text = @"Class cls = NSClassFromString(@\"NSObject\"); return cls;";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	NSAssert(result.value == [NSObject class], nil);
}

- (void)testOCCFunctionCall1
{
	[OCCfuntionHelper defineCFunction:@"NSSelectorFromString" types:@"SEL, NSString *"];

	NSString* text = @"SEL sel = NSSelectorFromString(@\"alloc\"); return sel;";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	SEL sel = [result.value pointerValue];
	NSAssert([NSStringFromSelector(sel) isEqualToString:@"alloc"], nil);
}

- (void)testOCCFunctionCallWithStruct
{
	NSString* text = @"CGPoint point = CGPointMake(2,3); return point;";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	CGPoint point = [result.value CGPointValue];
	NSAssert(point.x == 2 && point.y == 3, nil);
}

- (void)testOCCFunctionCallWithStruct1
{
	NSString* text = @"CGRect rect = CGRectMake(1,2,3,4); return rect;";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	CGRect rect = [result.value CGRectValue];
	NSAssert(CGRectEqualToRect(rect, CGRectMake(1, 2, 3, 4)), nil);
}

- (void)testOCCFunctionCallWithStruct2
{
	NSString* text = @"CGRect rect = CGRectZero(); return rect;";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	CGRect rect = [result.value CGRectValue];
	NSAssert(CGRectEqualToRect(rect, CGRectZero), nil);
}

- (void)testOCCFunctionCallWithStruct3
{
	NSString* text = @"CGSize size = CGSizeZero(); return size;";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	CGSize size = [result.value CGSizeValue];
	NSAssert(CGSizeEqualToSize(size, CGSizeZero), nil);
}

- (void)testOCCFunctionCallWithStruct4
{
	NSString* text = @"CGPoint point = CGPointZero(); return point;";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	CGPoint point = [result.value CGPointValue];
	NSAssert(CGPointEqualToPoint(point, CGPointZero), nil);
}

- (void)testOCCFunctionCallWithStruct5
{
	NSString* text = @"UIEdgeInsets inset = UIEdgeInsetsZero(); return inset;";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	UIEdgeInsets inset = [result.value UIEdgeInsetsValue];
	NSAssert(UIEdgeInsetsEqualToEdgeInsets(inset, UIEdgeInsetsZero), nil);
}

- (void)testGetMethodImp
{
	[OCCfuntionHelper defineCFunction:@"NSClassFromString" types:@"Class, NSString *"];
	[OCCfuntionHelper defineCFunction:@"NSSelectorFromString" types:@"SEL,NSString *"];
	[OCCfuntionHelper defineCFunction:@"class_getMethodImplementation" types:@"IMP,Class,SEL"];

	NSString* text = @"Class cls = NSClassFromString(@\"NSObject\");\
	SEL sel = NSSelectorFromString(@\"copy\");\
	IMP imp = class_getMethodImplementation(cls,sel);\
	return imp;";

	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];
	IMP imp = [result.value pointerValue];
	Method m = class_getInstanceMethod(NSObject.class, @selector(copy));
	IMP imp2 = method_getImplementation(m);
	NSAssert(imp == imp2, nil);
}

- (void)testAddMethod
{
	[OCCfuntionHelper defineCFunction:@"NSClassFromString" types:@"Class, NSString *"];
	[OCCfuntionHelper defineCFunction:@"NSSelectorFromString" types:@"SEL,NSString *"];
	[OCCfuntionHelper defineCFunction:@"class_getMethodImplementation" types:@"IMP,Class,SEL"];
	[OCCfuntionHelper defineCFunction:@"class_addMethod" types:@"BOOL,Class,SEL,IMP,char *"];

	NSString* text = @" Class cls = NSClassFromString(@\"UIView\");\
	SEL sel = NSSelectorFromString(@\"setNeedsDisplay\");\
	IMP imp = class_getMethodImplementation(cls,sel);\
	Class cls2 = NSClassFromString(@\"NSObject\");\
	BOOL didAdd = class_addMethod(cls2,sel,imp,\"v:\"); \
	return didAdd;";

	ASTNode* root = [ASTUtil parseString:text];
	ASTVariable* result = [root execute];
	NSAssert([result.value boolValue], nil);

	NSMethodSignature *methodSignature = [NSObject instanceMethodSignatureForSelector:NSSelectorFromString(@"setNeedsDisplay")];
	NSAssert(methodSignature != nil, nil);
}

- (void)testAssocateObject
{
	[OCCfuntionHelper defineCFunction:@"objc_setAssociatedObject" types:@"void,id,void *,id,unsigned int"];
	[OCCfuntionHelper defineCFunction:@"objc_getAssociatedObject" types:@"id,id,void *"];

	NSString* text = @"NSObject *object = [[NSObject alloc] init];\
	NSString* key = @\"key\"; \
	objc_setAssociatedObject(object, key, @\"1024\", 1);\
	return objc_getAssociatedObject(object,key);";
    
	ASTNode* root = [ASTUtil parseString:text];
	ASTVariable* result = [root execute];;

	NSAssert([result.value isEqualToString:@"1024"], nil);
}

- (void)testAssocateObject1
{
	[OCCfuntionHelper defineCFunction:@"objc_setAssociatedObject" types:@"void,id,void *,id,unsigned int"];
	[OCCfuntionHelper defineCFunction:@"objc_getAssociatedObject" types:@"id,id,void *"];

	NSString* text = @" NSObject *object = [[NSObject alloc] init];\
	NSObject* key = [[NSObject alloc]init]; \
	objc_setAssociatedObject(object, key, @\"1024\", 1);\
	return objc_getAssociatedObject(object, key);";
    
	ASTNode* root = [ASTUtil parseString:text];
	ASTVariable* result = [root execute];

	NSAssert([result.value isEqualToString:@"1024"], nil);
}

- (void)testAssocateObject2
{
	[OCCfuntionHelper defineCFunction:@"objc_setAssociatedObject" types:@"void,id,void *,id,unsigned int"];
	[OCCfuntionHelper defineCFunction:@"objc_getAssociatedObject" types:@"id,id,void *"];

	NSString* text = @"NSObject *object = [[NSObject alloc] init];\
	UIView* view = [[UIView alloc]init]; \
	objc_setAssociatedObject(object, view, @\"2048\", 1);\
	return objc_getAssociatedObject(object,view);";
    
	ASTNode* root = [ASTUtil parseString:text];
	ASTVariable* result = [root execute];

	NSAssert([result.value isEqualToString:@"2048"], nil);
}

- (void)testAssocateObject3
{
	[OCCfuntionHelper defineCFunction:@"objc_setAssociatedObject" types:@"void,id,void *,id,unsigned int"];
	[OCCfuntionHelper defineCFunction:@"objc_getAssociatedObject" types:@"id,id,void *"];

	NSString* text = @" \
	NSString* key = @\"testAssocateObject3\"; \
	objc_setAssociatedObject(XCTestCase.class, key, @\"1024\", 1);\
	return objc_getAssociatedObject(XCTestCase.class, key);";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];

	NSAssert([result.value isEqualToString:@"1024"], nil);
}

- (void)testAssocateObject4
{
	[OCCfuntionHelper defineCFunction:@"objc_setAssociatedObject" types:@"void,id,void *,id,unsigned int"];
	[OCCfuntionHelper defineCFunction:@"objc_getAssociatedObject" types:@"id,id,void *"];

	NSString* text = @" \
	NSString* key = @\"testAssocateObject4\"; \
	objc_setAssociatedObject([XCTestCase class], key, @\"1024\", 1);\
	return objc_getAssociatedObject([XCTestCase class], key);";
	ASTNode* root = [ASTUtil parseString:text];
	
	ASTVariable* result = [root execute];

	NSAssert([result.value isEqualToString:@"1024"], nil);
}

//TODO
//- (void)testDispatch
//{
//    NSString* text = @" \
//    dispatch_after(3, ^(int _){ \
//	   int i = 10; \
//    });";
//	static ASTNode* root;
//	root = [ASTUtil parseString:text];
//
//    [root execute];
//}

@end
