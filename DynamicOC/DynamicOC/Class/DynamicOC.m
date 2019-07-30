//
//  DynamicOC.m
//  DynamicOC
//
//  Created by dKingbin on 2019/7/29.
//  Copyright © 2019 dKingbin. All rights reserved.
//

#import "DynamicOC.h"

#import "Aspects.h"
#import <objc/runtime.h>

#import "ASTUtil.h"
#import "ASTHeader.h"
#import "ASTContext.h"
#import "OCCfuntionHelper.h"
#import "ASTCallMethod.h"

extern NSMutableDictionary* gblVariables;

@implementation DynamicOC

+ (void)hookClass:(NSString *)clsName
		 selector:(NSString *)selName
		 argNames:(NSArray<__kindof NSString *> *)argNames
		  isClass:(BOOL)isClass
   implementation:(NSString *)imp
{
	Class class = NSClassFromString(clsName);
	SEL selector = NSSelectorFromString(selName);

	if (isClass) {
		class = objc_getMetaClass([NSStringFromClass(class) UTF8String]);
	}
    
	//register variable for yacc
	[ASTUtil registerVariableForYacc:@"self"];
	[ASTUtil registerVariableForYacc:@"super"];
	[ASTUtil registerVariableForYacc:@"originalInvocation"];
	for(NSString* name in argNames)
	{
		[ASTUtil registerVariableForYacc:name];
	}
    
    ASTNode* rootNode = [ASTUtil parseString:imp];

	NSError *error;
	[class aspect_hookSelector:selector withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> aspectInfo) {

		ASTVariable* varSelf = [[ASTVariable alloc]init];
		varSelf.value = aspectInfo.instance;
		varSelf.type  = ASTNodeTypeVariable;
		[rootNode.context pushValue:varSelf forKey:@"self"];

		ASTVariable* varOriginInvocation = [[ASTVariable alloc]init];
		varOriginInvocation.value = aspectInfo.originalInvocation;
		varOriginInvocation.type  = ASTNodeTypeKEYWORD;
		varOriginInvocation.keyword = @"NSInvocation";
		[rootNode.context pushValue:varOriginInvocation forKey:@"originalInvocation"];

		NSAssert(aspectInfo.arguments.count == argNames.count, @"Error: Method params count must be same.");
		[aspectInfo.arguments enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
			NSString *name = argNames[idx];

			ASTVariable* objVar = [[ASTVariable alloc]init];

			NSString* keyword;
			if([obj isKindOfClass:NSObject.class])
			{
				NSObject* clsObj = obj;
				keyword = NSStringFromClass(clsObj.class);

				objVar.type = ASTNodeTypeKEYWORD;
				objVar.keyword = keyword;
			}
			else
			{
				objVar.type = ASTNodeTypeVariable;
			}

			objVar.value  = obj;
			[rootNode.context pushValue:objVar forKey:name];
		}];

		ASTVariable* var = [rootNode execute];
		id result = var.value;

		const char *argumentType = aspectInfo.originalInvocation.methodSignature.methodReturnType;

		switch (argumentType[0] == 'r' ? argumentType[1] : argumentType[0]) {

				#define OC_CALL_ARG_CASE(_typeString, _type, _selector) \
				case _typeString: {                              \
				_type value = [result _selector];                     \
				[aspectInfo.originalInvocation setReturnValue:&value];\
				break; \
				}
				OC_CALL_ARG_CASE('c', char, charValue)
				OC_CALL_ARG_CASE('C', unsigned char, unsignedCharValue)
				OC_CALL_ARG_CASE('s', short, shortValue)
				OC_CALL_ARG_CASE('S', unsigned short, unsignedShortValue)
				OC_CALL_ARG_CASE('i', int, intValue)
				OC_CALL_ARG_CASE('I', unsigned int, unsignedIntValue)
				OC_CALL_ARG_CASE('l', long, longValue)
				OC_CALL_ARG_CASE('L', unsigned long, unsignedLongValue)
				OC_CALL_ARG_CASE('q', long long, longLongValue)
				OC_CALL_ARG_CASE('Q', unsigned long long, unsignedLongLongValue)
				OC_CALL_ARG_CASE('f', float, floatValue)
				OC_CALL_ARG_CASE('d', double, doubleValue)
				OC_CALL_ARG_CASE('B', BOOL, boolValue)

			case ':': {
				SEL value = nil;
				if (result != [ASTCallMethod nilObj]) {
					value = NSSelectorFromString(result);
				}
				[aspectInfo.originalInvocation setReturnValue:&value];
				break;
			}
			case '{': {
				void *pointer = NULL;
				[result getValue:&pointer];
				[aspectInfo.originalInvocation setReturnValue:&pointer];
				break;
			}
			default: {
				if (result == [ASTCallMethod nilObj] ||
					([result isKindOfClass:[NSNumber class]] && strcmp([result objCType], "c") == 0 && ![result boolValue])) {
					result = nil;
					[aspectInfo.originalInvocation setReturnValue:&result];
					break;
				}
				if (result) {
					[aspectInfo.originalInvocation setReturnValue:&result];
				}
			}
		}

	} error:&error];
}

@end
