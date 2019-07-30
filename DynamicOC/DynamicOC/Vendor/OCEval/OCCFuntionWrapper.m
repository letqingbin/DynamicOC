//
//  OCCFuntionWrapper.m
//  OCParser
//
//  Created by sgcy on 2018/11/21.
//  Copyright © 2018年 sgcy. All rights reserved.
//


#import "OCCFuntionWrapper.h"
#import "ASTCallMethod.h"
#import "OCBlockWrapper.h"

#import <objc/runtime.h>

@implementation OCCFuntionWrapper

+ (id)callCFunction:(NSString *)funcName arguments:(NSArray *)arguments
{
    funcName = [funcName stringByAppendingString:@":"];
    return [ASTCallMethod invokeWithCaller:self selectorName:funcName argments:@[arguments]];
}

+ (void)dispatch_after:(NSArray*)arugments
{
	double delayInSeconds = [arugments[0] doubleValue];	
	id funcPtr = arugments[1];

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[OCBlockWrapper excuteBlock:funcPtr withParams:@[]];
	});
}

+ (id)CGRectMake:(NSArray *)arguments
{
    return [NSValue valueWithCGRect:CGRectMake([arguments[0] doubleValue], [arguments[1] doubleValue], [arguments[2] doubleValue], [arguments[3] doubleValue])];
}

+ (id)CGRectZero:(NSArray *)arguments
{
    return [NSValue valueWithCGRect:CGRectZero];
}

+ (id)CGPointMake:(NSArray *)arguments
{
    return [NSValue valueWithCGPoint:CGPointMake([arguments[0] doubleValue], [arguments[1] doubleValue])];
}

+ (id)CGPointZero:(NSArray *)arguments
{
    return [NSValue valueWithCGPoint:CGPointZero];
}

+ (id)CGSizeMake:(NSArray *)arguments
{
    return [NSValue valueWithCGSize:CGSizeMake([arguments[0] doubleValue], [arguments[1] doubleValue])];
}

+ (id)CGSizeZero:(NSArray *)arguments
{
	return [NSValue valueWithCGSize:CGSizeZero];
}

+ (id)NSMakeRange:(NSArray *)arguments
{
    return [NSValue valueWithRange:NSMakeRange([arguments[0] integerValue], [arguments[1] integerValue])];
}

+ (id)UIEdgeInsetsMake:(NSArray *)arguments
{
    return [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake([arguments[0] floatValue], [arguments[1] floatValue], [arguments[2] floatValue], [arguments[3] floatValue])];
}

+ (id)UIEdgeInsetsZero:(NSArray*)arguments
{
	return [NSValue valueWithUIEdgeInsets:UIEdgeInsetsZero];
}

+ (id)CGVectorMake:(NSArray *)arguments
{
    return [NSValue valueWithCGVector:CGVectorMake([arguments[0] floatValue], [arguments[1] floatValue])];
}

+ (id)CGAffineTransformMake:(NSArray *)arguments
{
    return [NSValue valueWithCGAffineTransform:CGAffineTransformMake([arguments[0] floatValue], [arguments[1] floatValue], [arguments[2] floatValue], [arguments[3] floatValue],[arguments[4] floatValue],[arguments[5] floatValue])];
}

@end

