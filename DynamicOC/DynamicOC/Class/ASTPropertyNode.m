//
//  ASTPropertyNode.m
//  DynamicOC
//
//  Created by dKingbin on 2019/7/15.
//  Copyright © 2019 dKingbin. All rights reserved.
//

#import "ASTPropertyNode.h"
#import "ASTVariable.h"
#import "ASTContext.h"
#import "ASTUtil.h"

@interface ASTPropertyNode ()
@end

@implementation ASTPropertyNode

- (id)handleProperty
{
	id invoker;

	for(int i=0; i<self.allChilds.count; i++)
	{
		ASTPropertyNode* node = self.allChilds[i];

		if(i == 0)
		{
			invoker = [self getInvoker:node];
		}
		else
		{
			node.invoker = invoker;
		}

		if(i == self.allChilds.count-1)
		{
			ASTVariable* result = [[ASTVariable alloc]init];

			//the last object
			if(self.handleType != ASTPropertyHandleTypeDefaultGetter)
			{
				//setter
				NSString* selectorName = [self getSelectorSetter:node];
				result.value = [ASTCallMethod invokeWithCaller:invoker selectorName:selectorName argments:@[self.setterVaule]];

				//rollback to CGRect/CGSize/CGPoint/NSRange/UIOffset/CGVector/UIEdgeInsets/CGAffineTransform
				if(result.value != nil && self.allChilds.count >= 2 && [ASTUtil checkOCStructType:result.value])
				{
					id value = result.value;
					for(int j=(int)self.allChilds.count-2;j>=0;j--)
					{
						ASTPropertyNode* jNode = self.allChilds[j];

						if(j == 0)
						{
							invoker = [self getInvoker:jNode];
						}
						else
						{
							invoker = jNode.invoker;
						}

						NSString* selectorName = [self getSelectorSetter:jNode];
						value = [ASTCallMethod invokeWithCaller:invoker selectorName:selectorName argments:@[value]];
					}

					result.value = value;
				}
			}
			else
			{
				//getter
				NSString* selectorName = [self getSelectorGetter:node];
				result.value = [ASTCallMethod invokeWithCaller:invoker selectorName:selectorName argments:@[]];
			}

            [ASTUtil castTypeFromValue:result];
			return result;
		}

		NSString* selectorName = [self getSelectorGetter:node];
		invoker = [ASTCallMethod invokeWithCaller:invoker selectorName:selectorName argments:@[]];
	}

	return nil;
}

- (id)getInvoker:(ASTPropertyNode*)node
{
	id invoker;
	ASTVariable* var;

	ASTNode* invokeNode = node.invoker;
	if([invokeNode.value isEqualToString:@"super"])
	{
		//super
		ASTVariable* varSelf = [self.context fetchValueFromKey:@"self"];
		id obj = varSelf.value;

		invoker = obj;
	}
	else if(invokeNode.type == ASTNodeTypeVariable)
	{
		//self/variable
		var = [self.context fetchValueFromKey:invokeNode.value];
		invoker = var.value;
	}
	else if(invokeNode.type == ASTNodeTypeKEYWORD)
	{
		//keyword
		invoker = NSClassFromString(invokeNode.keyword);
	}
	else
	{
		var = [invokeNode execute];
		invoker = var.value;
	}

	return invoker;
}

- (NSString*)getSelectorSetter:(ASTPropertyNode*)node
{
    NSString* selectorName = node.selector;
	NSString* headStr = [selectorName substringToIndex:1];
	selectorName = [NSString stringWithFormat:@"set%@%@:",headStr.uppercaseString, [selectorName substringFromIndex:1]];

	return selectorName;
}

- (NSString*)getSelectorGetter:(ASTPropertyNode*)node
{
    return node.selector;
}


@end
