//
//  ASTNode.m
//  DynamicOC
//
//  Created by dKingbin on 2019/7/11.
//  Copyright © 2019 dKingbin. All rights reserved.
//

#import "ASTNode.h"

#import "OCCfuntionHelper.h"
#import "OCCFuntionWrapper.h"

#import "ASTUtil.h"
#import "ASTVariable.h"
#import "OCBlockWrapper.h"

#import "ASTPropertyNode.h"
#import "ASTMethodNode.h"
#import "ASTBlockNode.h"

#import <objc/message.h>

@interface ASTNode()

@end

@implementation ASTNode

- (void)addChild:(ASTNode *)node
{
	[self.allChilds addObject:node];
}

- (id)execute
{
	if(self.type == ASTNodeTypeProgram)
	{
		//program
		ASTVariable* var;
		for(ASTNode* node in self.allChilds)
		{
			var = [node execute];

			if(var.jumpType != ASTJumpTypeDefault)
			{
				return var;
			}
		}
	}
	else if(self.type == ASTNodeTypeExpression)
	{
		ASTVariable* var;
		for(ASTNode* node in self.allChilds)
		{
			var = [node execute];

			if(var.jumpType != ASTJumpTypeDefault)
			{
				if(var.postOperation)
				{
					var.postOperation();
				}

				var.postOperation = nil;

				return var;
			}
		}

		if(var.postOperation)
		{
			var.postOperation();
		}

		var.postOperation = nil;

		return var;
	}
	else if(self.type == ASTNodeTypeScope)
	{
		ASTVariable* var = [self handleScope];
		if(var) return var;
	}
	else if(self.type == ASTNodeTypeFor)
	{
		ASTVariable* var = [self handleFor];
		if(var) return var;
	}
	else if(self.type == ASTNodeTypeWhile)
	{
		ASTVariable* var = [self handleWhile];
		if(var) return var;
	}
	else if(self.type == ASTNodeTypeDoWhile)
	{
		ASTVariable* var = [self handleDoWhile];
		if(var) return var;
	}
	else if(self.type == ASTNodeTypeIf)
	{
		ASTVariable* var = [self handleIf];
		if(var) return var;
	}
	else if(self.type >= ASTNodeTypeAssign && self.type <= ASTNodeTypeSubAssign)
	{
		// = += -=
		return [self handleAssignment];
	}
	else if(self.type >= ASTNodeTypeOperationAND && self.type <= ASTNodeGreaterThan)
	{
		return [self handleCompare];
	}
	else if(self.type >= ASTNodeTypeOperationMUL && self.type <= ASTNodeTypeOperationSUB)
	{
		return [self handleArithmetic];
	}
	else if(self.type >= ASTNodeTypeOperationRemainder && self.type <= ASTNodeTypeOperationBitNOT)
	{
		return [self handleShiftAndBitOperaiton];
	}
	else if(self.type >= ASTNodeTypeOperationPrefixInc && self.type <= ASTNodeTypeUnaryNot)
	{
		return [self handleUnaryOperation];
	}
	else if(self.type == ASTNodeTypeOperationCondition)
	{
		return [self handleTrinocularCondition];
	}
	else if(self.type == ASTNodeTypeDeclarator)
	{
		return [self handleDeclarator];
	}
	else if(self.type == ASTNodeTypeBlockDeclarator)
	{
		return [self handleBlockDeclarator];
	}
	else if(self.type == ASTNodeTypeBlock)
	{
		return [self handleBlock];
	}
	else if(self.type == ASTNodeTypeCallCFunction)
	{
		return [self handleCallCFunction];
	}
	else if(self.type == ASTNodeTypeCallOCFunction)
	{
		return [self handleCallOCFunction];
	}
	else if(self.type == ASTNodeTypeOCArgument)
	{
		return [self handleCallOCArgument];
	}
	else if(self.type == ASTNodeTypePropertyList)
	{
		return [self handleProperty];
	}
	else if(self.type == ASTNodeTypeMemberVariables)
	{
		return [self handleMemberVariables];
	}
	else if(self.type == ASTNodeTypeNumber)
	{
		return [self handleNSNumber];
	}
	else if(self.type == ASTNodeTypeArray)
	{
		return [self handleArray];
	}
	else if(self.type == ASTNodeTypeIndex)
	{
		return [self handleContainerIndex];
	}
	else if(self.type == ASTNodeTypeDictionary)
	{
		return [self handleArrayDictionary];
	}
	else if(self.type == ASTNodeTypeSwitch)
	{
		[self handleSwitch];
	}
	else if(self.type >= ASTNodeTypeReturn && self.type <= ASTNodeTypeContinue)
	{
		return [self handleJump];
	}

	//constant
	//ASTNodeTypeKEYWORD

	ASTVariable* var = [[ASTVariable alloc]init];
	var.type  = self.type;
	var.value = self.value;

	return var;
}

- (id)handleScope
{
	[self.context pushContext];

	ASTVariable* var;
	for(ASTNode* node in self.allChilds)
	{
		var = [node execute];

		if(var.jumpType != ASTJumpTypeDefault)
		{
			[self.context popContext];
			return var;
		}
	}

	[self.context popContext];

	return nil;
}

- (id)handleDeclarator
{
	if(self.allChilds.count < 2) return nil;

	ASTNode* typeNode = self.allChilds[0];

	ASTNode* variableNode = self.allChilds[1];
	NSString* variable = variableNode.value;

	ASTVariable* result = [[ASTVariable alloc]init];
	result.type  = typeNode.type;
	result.name  = variable;
	result.hasBlock = typeNode.hasBlock;
	result.hasPointer = typeNode.hasPointer;

	if(typeNode.type == ASTNodeTypeKEYWORD)
	{
		result.keyword = typeNode.keyword;
		[ASTUtil defaultValueForOCStruct:result];
	}

	[self.context pushValue:result forKey:variable];

	return result;
}

- (id)handleBlockDeclarator
{
	return nil;
}

- (id)handleNSNumber
{
	ASTNode* node = self.value;
	ASTVariable* result = [[ASTVariable alloc]init];

	if(node.type == ASTNodeTypeVariable)
	{
		result = [self.context fetchValueFromKey:node.value];
	}
	else
	{
		//constant/expression/nsnumber
		result = [node execute];
	}

#define DC_CAST_NSNUMBER(_nodeType, _type, _caller, _selector) \
case _nodeType: { \
_type val_ = [_caller.value _selector];  \
_caller.value = @(val_); \
break; \
}
	switch (node.type) {
			DC_CAST_NSNUMBER(ASTNodeTypeChar, char, result, charValue)
			DC_CAST_NSNUMBER(ASTNodeTypeUnsignedChar, unsigned char, result, unsignedCharValue)
			DC_CAST_NSNUMBER(ASTNodeTypeShort, short, result, shortValue)
			DC_CAST_NSNUMBER(ASTNodeTypeUnsignedShort, unsigned short, result, unsignedShortValue)
			DC_CAST_NSNUMBER(ASTNodeTypeInt, int, result, intValue)
			DC_CAST_NSNUMBER(ASTNodeTypeUnsignedInt, unsigned int, result, unsignedIntValue)
			DC_CAST_NSNUMBER(ASTNodeTypeLong, long, result, longValue)
			DC_CAST_NSNUMBER(ASTNodeTypeUnsignedLong, unsigned long, result, unsignedLongValue)
			DC_CAST_NSNUMBER(ASTNodeTypeFloat, float, result, floatValue)
			DC_CAST_NSNUMBER(ASTNodeTypeDouble, double, result, doubleValue)
			DC_CAST_NSNUMBER(ASTNodeTypeBOOL, BOOL, result, boolValue)
		default:
			break;
	}

	result.type = ASTNodeTypeNumber;

	return result;
}

- (id)handleArray
{
	ASTNode* containerNode = self.allChilds[0];

	NSMutableArray* array = [NSMutableArray array];
	ASTVariable* var;
	for(ASTNode* node in containerNode.allChilds)
	{
		if(node.type == ASTNodeTypeVariable)
		{
			var = [self.context fetchValueFromKey:node.value];
			[array addObject:var.value];
		}
		else
		{
			var = [node execute];
			[array addObject:var.value];
		}
	}

	ASTVariable* result = [[ASTVariable alloc]init];
	result.type = ASTNodeTypeArray;
	result.value = [array copy];

	return result;
}

- (id)handleContainerIndex
{
	if(self.allChilds.count < 2) return nil;

	ASTNode* containerNode = self.allChilds[0];
	ASTNode* indexNode = self.allChilds[1];

	ASTVariable* containerVar;
	if(containerNode.type == ASTNodeTypeVariable)
	{
		containerVar = [self.context fetchValueFromKey:containerNode.value];
	}
	else
	{
		//property
		containerVar = [containerNode execute];
	}

	ASTVariable* indexVar;
	for(ASTNode* node in indexNode.allChilds)
	{
		indexVar = [node execute];
	}

	ASTVariable* result = [[ASTVariable alloc]init];

	if([ASTUtil checkOCContainerIndexType:indexVar.type])
	{
		//array index
		NSArray* array = containerVar.value;
		result.value = array[[indexVar.value integerValue]];
	}
	else
	{
		//dictionary index
		NSDictionary* dict = containerVar.value;
		result.value = [dict objectForKey:indexVar.value];
	}

	[ASTUtil castTypeFromValue:result];
	return result;
}

- (id)handleArrayDictionary
{
	ASTNode* containerNode = self.allChilds[0];

	NSMutableDictionary* dict = [NSMutableDictionary dictionary];
	for(ASTNode* node in containerNode.allChilds)
	{
		if(node.type != ASTNodeTypeKeyValue) continue;

		ASTNode* keyNode = node.allChilds[0];
		ASTVariable* keyVar = [[ASTVariable alloc]init];
		if(keyNode.type == ASTNodeTypeVariable)
		{
			keyVar = [self.context fetchValueFromKey:keyNode.value];
		}
		else
		{
			//property/NSNumber/NSString/function/array/dictionary...
			keyVar = [keyNode execute];
		}

		ASTNode* valueNode = node.allChilds[1];
		ASTVariable* valueVar = [[ASTVariable alloc]init];
		if(valueNode.type == ASTNodeTypeVariable)
		{
			valueVar = [self.context fetchValueFromKey:valueNode.value];
		}
		else
		{
			//property/NSNumber/NSString/function/array/dictionary...
			valueVar = [valueNode execute];
		}

		dict[keyVar.value] = valueVar.value;
	}

	ASTVariable* result = [[ASTVariable alloc]init];
	result.type = ASTNodeTypeDictionary;
	result.value = [dict mutableCopy];

	return result;
}

- (id)handleOperation:(ASTNode*)node
{
	id result;
	if(node.type == ASTNodeTypeVariable)
	{
		result = [self.context fetchValueFromKey:node.value];
	}
	else
	{
		result = [node execute];
	}

	return result;
}

- (id)handleArithmetic
{
	ASTNode* node = self.allChilds[0];
	ASTVariable* leftVal = [self handleOperation:node];

	node = self.allChilds[1];
	ASTVariable* rightVal = [self handleOperation:node];

	ASTVariable* result = [[ASTVariable alloc]init];

#define DC_SWITCH_RIGHT_OPERATION(_ival, _op, _nodeType, _type, _rcaller, _rselector) \
case _nodeType: { \
_type c2_ = [_rcaller.value _rselector];\
result.value = @(_ival _op c2_); \
break; \
}

#define DC_SWITCH_LEFT_OPERATION(_op, _nodeType, _type, _lcaller, _rcaller, _lselector) \
case _nodeType: { \
_type ival = [_lcaller.value _lselector]; 	\
switch(_rcaller.type) { \
DC_SWITCH_RIGHT_OPERATION(ival, _op, ASTNodeTypeChar, char, _rcaller, charValue)\
DC_SWITCH_RIGHT_OPERATION(ival, _op, ASTNodeTypeUnsignedChar, unsigned char, _rcaller, unsignedCharValue)\
DC_SWITCH_RIGHT_OPERATION(ival, _op, ASTNodeTypeShort, short , _rcaller, shortValue)\
DC_SWITCH_RIGHT_OPERATION(ival, _op, ASTNodeTypeUnsignedShort, unsigned short, _rcaller, unsignedShortValue)\
DC_SWITCH_RIGHT_OPERATION(ival, _op, ASTNodeTypeInt, int, _rcaller, intValue)\
DC_SWITCH_RIGHT_OPERATION(ival, _op, ASTNodeTypeUnsignedInt, unsigned int, _rcaller, unsignedIntValue)\
DC_SWITCH_RIGHT_OPERATION(ival, _op, ASTNodeTypeLong, long , _rcaller, longValue)\
DC_SWITCH_RIGHT_OPERATION(ival, _op, ASTNodeTypeUnsignedLong, unsigned long, _rcaller, unsignedLongValue)\
DC_SWITCH_RIGHT_OPERATION(ival, _op, ASTNodeTypeFloat, float , _rcaller, floatValue)\
DC_SWITCH_RIGHT_OPERATION(ival, _op, ASTNodeTypeDouble, double , _rcaller, doubleValue)\
DC_SWITCH_RIGHT_OPERATION(ival, _op, ASTNodeTypeBOOL, BOOL , _rcaller, boolValue)\
default: { \
break; \
}	\
}	\
break;	\
}

#define DC_CASE_ARITHMETIC(_opType, _op, _lcaller, _rcaller) \
case _opType: { \
switch(_lcaller.type) { \
DC_SWITCH_LEFT_OPERATION(_op, ASTNodeTypeChar, char, _lcaller, _rcaller, charValue)\
DC_SWITCH_LEFT_OPERATION(_op, ASTNodeTypeUnsignedChar, unsigned char, _lcaller, _rcaller, unsignedCharValue)\
DC_SWITCH_LEFT_OPERATION(_op, ASTNodeTypeShort, short, _lcaller, _rcaller, shortValue)\
DC_SWITCH_LEFT_OPERATION(_op, ASTNodeTypeUnsignedShort, unsigned short, _lcaller, _rcaller, unsignedShortValue)\
DC_SWITCH_LEFT_OPERATION(_op, ASTNodeTypeInt, int, _lcaller, _rcaller, intValue)\
DC_SWITCH_LEFT_OPERATION(_op, ASTNodeTypeUnsignedInt, unsigned int, _lcaller, _rcaller, unsignedIntValue)\
DC_SWITCH_LEFT_OPERATION(_op, ASTNodeTypeLong, long, _lcaller, _rcaller, longValue)\
DC_SWITCH_LEFT_OPERATION(_op, ASTNodeTypeUnsignedLong, unsigned long, _lcaller, _rcaller, unsignedLongValue)\
DC_SWITCH_LEFT_OPERATION(_op, ASTNodeTypeFloat, float, _lcaller, _rcaller, floatValue)\
DC_SWITCH_LEFT_OPERATION(_op, ASTNodeTypeDouble, double, _lcaller, _rcaller, doubleValue)\
DC_SWITCH_LEFT_OPERATION(_op, ASTNodeTypeBOOL, BOOL, _lcaller, _rcaller, boolValue)\
default: { \
break; \
}	\
} \
break; \
}

	switch (self.type) {
			DC_CASE_ARITHMETIC(ASTNodeTypeOperationMUL, *, leftVal, rightVal)
			DC_CASE_ARITHMETIC(ASTNodeTypeOperationDIV, /, leftVal, rightVal)
			DC_CASE_ARITHMETIC(ASTNodeTypeOperationADD, +, leftVal, rightVal)
			DC_CASE_ARITHMETIC(ASTNodeTypeOperationSUB, -, leftVal, rightVal)
		default:
			break;
	}

	[ASTUtil castTypeFromValue:result];

	return result;
}

- (id)handleShiftAndBitOperaiton
{
	ASTNode* node = self.allChilds[0];
	ASTVariable* leftVal = [self handleOperation:node];

	node = self.allChilds[1];
	ASTVariable* rightVal = [self handleOperation:node];

	ASTVariable* result = [[ASTVariable alloc]init];

#define DC_SWITCH_LEFT_SHIFT_OPERATION(_op, _nodeType, _type, _lcaller, _rcaller, _lselector) \
case _nodeType: { \
_type ival = [_lcaller.value _lselector]; 	\
switch(_rcaller.type) { \
DC_SWITCH_RIGHT_OPERATION(ival, _op, ASTNodeTypeChar, char, _rcaller, charValue)\
DC_SWITCH_RIGHT_OPERATION(ival, _op, ASTNodeTypeUnsignedChar, unsigned char, _rcaller, unsignedCharValue)\
DC_SWITCH_RIGHT_OPERATION(ival, _op, ASTNodeTypeShort, short , _rcaller, shortValue)\
DC_SWITCH_RIGHT_OPERATION(ival, _op, ASTNodeTypeUnsignedShort, unsigned short, _rcaller, unsignedShortValue)\
DC_SWITCH_RIGHT_OPERATION(ival, _op, ASTNodeTypeInt, int, _rcaller, intValue)\
DC_SWITCH_RIGHT_OPERATION(ival, _op, ASTNodeTypeUnsignedInt, unsigned int, _rcaller, unsignedIntValue)\
DC_SWITCH_RIGHT_OPERATION(ival, _op, ASTNodeTypeLong, long , _rcaller, longValue)\
DC_SWITCH_RIGHT_OPERATION(ival, _op, ASTNodeTypeUnsignedLong, unsigned long, _rcaller, unsignedLongValue)\
default: { \
break; \
}	\
}	\
break;	\
}

#define DC_CASE_SHIFT_OPERATION(_opType, _op, _lcaller, _rcaller) \
case _opType: { \
switch(_lcaller.type) { \
DC_SWITCH_LEFT_SHIFT_OPERATION(_op, ASTNodeTypeChar, char, _lcaller, _rcaller, charValue)\
DC_SWITCH_LEFT_SHIFT_OPERATION(_op, ASTNodeTypeUnsignedChar, unsigned char, _lcaller, _rcaller, unsignedCharValue)\
DC_SWITCH_LEFT_SHIFT_OPERATION(_op, ASTNodeTypeShort, short, _lcaller, _rcaller, shortValue)\
DC_SWITCH_LEFT_SHIFT_OPERATION(_op, ASTNodeTypeUnsignedShort, unsigned short, _lcaller, _rcaller, unsignedShortValue)\
DC_SWITCH_LEFT_SHIFT_OPERATION(_op, ASTNodeTypeInt, int, _lcaller, _rcaller, intValue)\
DC_SWITCH_LEFT_SHIFT_OPERATION(_op, ASTNodeTypeUnsignedInt, unsigned int, _lcaller, _rcaller, unsignedIntValue)\
DC_SWITCH_LEFT_SHIFT_OPERATION(_op, ASTNodeTypeLong, long, _lcaller, _rcaller, longValue)\
DC_SWITCH_LEFT_SHIFT_OPERATION(_op, ASTNodeTypeUnsignedLong, unsigned long, _lcaller, _rcaller, unsignedLongValue)\
default: { \
break; \
}	\
} \
break; \
}

	switch (self.type) {
			DC_CASE_SHIFT_OPERATION(ASTNodeTypeOperationRemainder, %, leftVal, rightVal)
			DC_CASE_SHIFT_OPERATION(ASTNodeTypeOperationRightShitf, >>, leftVal, rightVal)
			DC_CASE_SHIFT_OPERATION(ASTNodeTypeOperationLeftShitf, <<, leftVal, rightVal)
			DC_CASE_SHIFT_OPERATION(ASTNodeTypeOperationBitAND, &, leftVal, rightVal)
			DC_CASE_SHIFT_OPERATION(ASTNodeTypeOperationBitOR, |, leftVal, rightVal)
			DC_CASE_SHIFT_OPERATION(ASTNodeTypeOperationBitNOT, ^, leftVal, rightVal)
		default:
			break;
	}

	[ASTUtil castTypeFromValue:result];

	return result;
}


- (id)handleUnaryOperation
{
	ASTNode* node = self.allChilds[0];
	ASTVariable* result = [[ASTVariable alloc]init];
	if(node.type == ASTNodeTypeVariable)
	{
		ASTVariable* var = [self.context fetchValueFromKey:node.value];
		result = [var toMutableCopy];
	}
	else
	{
		result = [node execute];
	}

#define DC_EXECUTE_UNARY(_nodeType, _type, _caller, _selector, _op, _isDec) \
case _nodeType: { \
_type val_ = [_caller.value _selector];  \
val_ = _op val_; \
if(_isDec) { \
val_ = - val_;	\
}	\
_caller.value = @(val_); \
break; \
}

#define DC_CASE_UNARY(_opType, _op, _caller, _isDec) \
case _opType: { \
switch(_caller.type) { \
DC_EXECUTE_UNARY(ASTNodeTypeChar, char, _caller, charValue, _op, _isDec) \
DC_EXECUTE_UNARY(ASTNodeTypeUnsignedChar, unsigned char, _caller, unsignedCharValue, _op, _isDec) \
DC_EXECUTE_UNARY(ASTNodeTypeShort, short, _caller, shortValue, _op, _isDec) \
DC_EXECUTE_UNARY(ASTNodeTypeUnsignedShort, unsigned short, _caller, unsignedShortValue, _op, _isDec) \
DC_EXECUTE_UNARY(ASTNodeTypeInt, int, _caller, intValue, _op, _isDec) \
DC_EXECUTE_UNARY(ASTNodeTypeUnsignedInt, unsigned int, _caller, unsignedIntValue, _op, _isDec) \
DC_EXECUTE_UNARY(ASTNodeTypeLong, long, _caller, longValue, _op, _isDec) \
DC_EXECUTE_UNARY(ASTNodeTypeUnsignedLong, unsigned long, _caller, unsignedLongValue, _op, _isDec) \
DC_EXECUTE_UNARY(ASTNodeTypeFloat, float, _caller, floatValue, _op, _isDec) \
DC_EXECUTE_UNARY(ASTNodeTypeDouble, double, _caller, doubleValue, _op, _isDec) \
DC_EXECUTE_UNARY(ASTNodeTypeBOOL, BOOL, _caller, boolValue, _op, _isDec) \
default: { \
id obj = _caller.value; \
_caller.value = @(!obj); \
_caller.type = ASTNodeTypeBOOL; \
_caller.keyword = nil;\
break; \
} \
} \
break; \
}

	switch (self.type) {
			DC_CASE_UNARY(ASTNodeTypeOperationPrefixInc, 1+, result, NO)
			DC_CASE_UNARY(ASTNodeTypeOperationPrefixDec, 1-, result, YES)
			DC_CASE_UNARY(ASTNodeTypeUnaryMinus, -, result, NO)
			DC_CASE_UNARY(ASTNodeTypeUnaryPlus, +, result, NO)
			DC_CASE_UNARY(ASTNodeTypeUnaryNot, !, result, NO)

		case ASTNodeTypeOperationPostfixInc: {
			// i++
            __weak ASTVariable* weakResult = result;
			result.postOperation = ^{
                __strong ASTVariable* result = weakResult;

				switch (ASTNodeTypeOperationPrefixInc) {
						DC_CASE_UNARY(ASTNodeTypeOperationPrefixInc, 1+, result, NO)
					default:break;
				}

				[self.context pushValue:result forKey:node.value];
			};
			break;
		}

		case ASTNodeTypeOperationPostfixDec: {
			// i--
			__weak ASTVariable* weakResult = result;
			result.postOperation = ^{
				__strong ASTVariable* result = weakResult;

				switch (ASTNodeTypeOperationPrefixDec) {
						DC_CASE_UNARY(ASTNodeTypeOperationPrefixDec, 1-, result, YES)
					default:break;
				}

				[self.context pushValue:result forKey:node.value];
			};
			break;
		}

		default:
		{
			break;
		}
	}

	if(self.type == ASTNodeTypeOperationPrefixInc || self.type == ASTNodeTypeOperationPrefixDec)
	{
		[self.context pushValue:result forKey:node.value];
	}

	return result;
}

- (id)handleTrinocularCondition
{
	//?:
	ASTNode* conditionNode = self.allChilds[0];
	ASTNode* leftNode = self.allChilds[1];
	ASTNode* rightNode = self.allChilds[2];

	ASTVariable* result;
	if(conditionNode.type == ASTNodeTypeVariable)
	{
		result = [self.context fetchValueFromKey:conditionNode.value];
	}
	else
	{
		//constant/expression
		result = [conditionNode execute];
	}

	BOOL ok = NO;

#define DC_CHECK_CONDITION(_val) \
if(_val) { \
ok = YES; \
}

#define DC_CASE_CONDITION(_nodeType, _type, _caller, _selector) \
case _nodeType: { \
_type val_ = [_caller.value _selector]; \
DC_CHECK_CONDITION(val_) \
break; \
}

	switch (result.type) {
			DC_CASE_CONDITION(ASTNodeTypeChar, char, result, charValue)
			DC_CASE_CONDITION(ASTNodeTypeUnsignedChar, unsigned char, result, unsignedCharValue)
			DC_CASE_CONDITION(ASTNodeTypeShort, short, result, shortValue)
			DC_CASE_CONDITION(ASTNodeTypeUnsignedShort, unsigned short, result, unsignedShortValue)
			DC_CASE_CONDITION(ASTNodeTypeInt, int, result, intValue)
			DC_CASE_CONDITION(ASTNodeTypeUnsignedInt, unsigned int, result, unsignedIntValue)
			DC_CASE_CONDITION(ASTNodeTypeLong, long, result, longValue)
			DC_CASE_CONDITION(ASTNodeTypeUnsignedLong, unsigned long, result, unsignedLongValue)
			DC_CASE_CONDITION(ASTNodeTypeFloat, float, result, floatValue)
			DC_CASE_CONDITION(ASTNodeTypeDouble, double, result, doubleValue)
			DC_CASE_CONDITION(ASTNodeTypeBOOL, BOOL, result, boolValue)
		default:
		{
			DC_CHECK_CONDITION(result.value)
			break;
		}
	}

	if(ok)
	{
		if(leftNode.type != ASTNodeTypePlaceholder)
		{
			if(leftNode.type == ASTNodeTypeVariable)
			{
				result.value = [self.context fetchValueFromKey:leftNode.value];
			}
			else
			{
				//constant/expression
				result = [leftNode execute];
			}
		}
	}
	else
	{
		if(rightNode.type != ASTNodeTypePlaceholder)
		{
			if(rightNode.type == ASTNodeTypeVariable)
			{
				result.value = [self.context fetchValueFromKey:rightNode.value];
			}
			else
			{
				//constant/expression
				result = [rightNode execute];
			}
		}
	}

	return result;
}

- (id)handleCallCFunction
{
	//arguments
	ASTNode* arguments = self.allChilds[0];
	NSMutableArray* argumentsList = [NSMutableArray array];
	for(ASTNode* node in arguments.allChilds)
	{
		ASTVariable* result = [node execute];

		if(result.type == ASTNodeTypeVariable)
		{
			result = [self.context fetchValueFromKey:result.value];
		}

		if(result.value != nil)
		{
			[argumentsList addObject:result.value];
		}
		else
		{
			[argumentsList addObject:[ASTCallMethod nilObj]];
		}
	}

	ASTVariable* result = [[ASTVariable alloc]init];

	//function
	id func = self.value;
	NSString* funcName;
	if([func isMemberOfClass:ASTNode.class])
	{
		//call block

		ASTNode* node = func;
		id funcPtr;
		if(node.type == ASTNodeTypeVariable)
		{
			ASTVariable* var = [self.context fetchValueFromKey:node.value];
			funcPtr = var.value;
		}

		[OCBlockWrapper excuteBlock:funcPtr withParams:argumentsList];
	}
	else
	{
		//call c function
		funcName = func;

		if([ASTUtil callCFunctionWhitelist:funcName])
		{
			result.value = [OCCFuntionWrapper callCFunction:funcName arguments:argumentsList];
		}
		else
		{
			result.value = [OCCfuntionHelper callCFunction:funcName arguments:argumentsList];
		}

		[ASTUtil castTypeFromValue:result];
	}

	return result;
}

- (id)handleCallOCArgument
{
	ASTMethodNode* node = self.value;
	NSString* selector = [NSString stringWithFormat:@"%@:",node.name];

	ASTNode* argumentNode = node.argument;
	ASTVariable* result = [[ASTVariable alloc]init];
	if(argumentNode.type == ASTNodeTypeExpression)
	{
		//invokeVariableParameterMethod
		NSMutableArray* arguments = [NSMutableArray array];
		for(ASTNode* node in argumentNode.allChilds)
		{
			ASTVariable* var = [[ASTVariable alloc]init];
			if(node.type == ASTNodeTypeVariable)
			{
				var = [self.context fetchValueFromKey:node.value];
			}
			else
			{
				var = [node execute];
			}

			if(var.value != nil)
			{
				[arguments addObject:var.value];
			}
			else
			{
				[arguments addObject:[ASTCallMethod nilObj]];
			}
		}

		result.value = arguments;
	}
	else
	{
		//block
		ASTVariable* var = [argumentNode execute];
		result.value = @[var.value];
		result.type  = var.type;
	}

	result.name = selector;
	return result;
}

- (id)handleCallOCFunction
{
	ASTNode* methodNode = self.allChilds[0];
	id caller;

	NSMutableString* selectorName = [[NSMutableString alloc]init];

	ASTNode* argumentNode = self.allChilds[1];
	NSMutableArray* argumentsList = [NSMutableArray array];
	if(argumentNode.type == ASTNodeTypeUnarySelector)
	{
		[selectorName appendString:argumentNode.value];
	}
	else if(argumentNode.type == ASTNodeTypeOCArgumentList)
	{
		for(ASTMethodNode* node in argumentNode.allChilds)
		{
			ASTVariable* result = [node execute];
			[selectorName appendString:result.name];

			if(result.value == nil) continue;
			[argumentsList addObjectsFromArray:result.value];
		}
	}

	if([methodNode.value isEqualToString:@"super"])
	{
		//super selector
		SEL selector = NSSelectorFromString(selectorName);
		NSString* superSelectorName = [NSString stringWithFormat:@"SUPER_%@",selectorName];
		SEL superSelector = NSSelectorFromString(superSelectorName);

		//super class
		ASTVariable* varSelf = [self.context fetchValueFromKey:@"self"];
		id obj = varSelf.value;
		Class cls = [obj class];
		Class superCls = [cls superclass];

		Method superMethod = class_getInstanceMethod(superCls, selector); //only instance method?
		IMP superIMP = method_getImplementation(superMethod);
		class_addMethod(cls, superSelector, superIMP, method_getTypeEncoding(superMethod));
		selector = superSelector;

		selectorName = [superSelectorName mutableCopy];
		caller = obj;
	}
	else if(methodNode.type == ASTNodeTypeKEYWORD)
	{
		caller = NSClassFromString(methodNode.keyword);
	}
	else if(methodNode.type == ASTNodeTypeVariable)
	{
		ASTVariable* var = [self.context fetchValueFromKey:methodNode.value];
		caller = var.value;
	}
	else
	{
		ASTVariable* var = [methodNode execute];
		caller = var.value;
	}

	ASTVariable* result = [[ASTVariable alloc]init];
	result.value = [ASTCallMethod invokeWithCaller:caller selectorName:selectorName argments:argumentsList];
	[ASTUtil castTypeFromValue:result];

	return result;
}

- (id)handleAssignment
{
	ASTVariable* var;
	ASTVariable* result;

	//result side from assignment
	result = [self.allChilds[1] execute];

	if(result.type == ASTNodeTypeVariable)
	{
		result = [self.context fetchValueFromKey:result.value];
	}
	else
	{
		//basic type
	}

	//variable side from assignment
	ASTNode* varNode = self.allChilds[0];
	if(varNode.type == ASTNodeTypePropertyList)
	{
		//call oc setter function

		ASTPropertyNode* node = (ASTPropertyNode*)varNode;
		node.handleType = ASTPropertyHandleTypeDefualtSetter;
		node.setterVaule = result.value;
		result = [node execute];

		ASTPropertyNode* child = node.allChilds[0];
		ASTNode* invokeNode = child.invoker;
		if(invokeNode.type == ASTNodeTypeVariable && [ASTUtil checkOCStructType:result.value])
		{
			//oc struct
			ASTVariable* var = [[ASTVariable alloc]init];
			[ASTUtil castTypeFromValue:result];
			var.value = result.value;
			[self.context pushValue:var forKey:invokeNode.value];
		}

		return result;
	}
	else if(varNode.type == ASTNodeTypeMemberVariables)
	{
		ASTPropertyNode* node = (ASTPropertyNode*)varNode;
		ASTNode* invokeNode = node.invoker;
		ASTVariable* invokeVar;
		if(invokeNode.type == ASTNodeTypeVariable)
		{
			invokeVar = [self.context fetchValueFromKey:invokeNode.value];
		}
		else
		{
			invokeVar = [invokeNode execute];
		}

		NSString* selector = node.selector;

		[invokeVar.value setValue:result.value forKey:selector];
	}
	else if(varNode.type == ASTNodeTypeIndex)
	{
		//array[i]

		ASTNode* containerNode = varNode.allChilds[0];
		ASTNode* indexNode = varNode.allChilds[1];

		ASTVariable* containerVar = [[ASTVariable alloc]init];
		if(containerNode.type == ASTNodeTypeVariable)
		{
			containerVar = [self.context fetchValueFromKey:containerNode.value];
		}
		else
		{
			//property
			containerVar = [containerNode execute];
		}

		ASTVariable* indexVar = [[ASTVariable alloc]init];
		if(indexNode.type == ASTNodeTypeVariable)
		{
			indexVar = [self.context fetchValueFromKey:indexNode.value];
		}
		else
		{
			//constant/property
			indexVar = [indexNode execute];
		}

		if([ASTUtil checkOCContainerIndexType:indexVar.type])
		{
			//array index
			NSMutableArray* array = containerVar.value;
			array[[indexVar.value integerValue]] = result.value;
		}
		else
		{
			//dictionary index
			NSMutableDictionary* dict = containerVar.value;
			dict[indexVar.value] = result.value;
		}
	}
	else if(varNode.type == ASTNodeTypeAddressAssign)
	{
		//TODO
		//*stop = YES;
	}
	else
	{
		var = [varNode execute];
		result.hasBlock = var.hasBlock;
		result.hasPointer = var.hasPointer;

		NSString* key = var.name;
		if(var.type == ASTNodeTypeVariable)
		{
			key = var.value;
			var = [self.context fetchValueFromKey:key];
		}
		else if(var.type == ASTNodeTypeKEYWORD)
		{
			result.type = var.type;
			result.keyword = var.keyword;
		}
		else
		{
			//basic type
		}

		switch (var.type) {
#define DC_CASE_ASSIGNMENT(_nodeType, _caller, _selector) \
case _nodeType: {					  \
_caller.value = @([_caller.value _selector]); 		\
_caller.type = _nodeType;	\
break;	\
}

				DC_CASE_ASSIGNMENT(ASTNodeTypeChar, result, charValue)
				DC_CASE_ASSIGNMENT(ASTNodeTypeUnsignedChar, result, unsignedCharValue)
				DC_CASE_ASSIGNMENT(ASTNodeTypeShort, result, shortValue)
				DC_CASE_ASSIGNMENT(ASTNodeTypeUnsignedShort, result, unsignedShortValue)
				DC_CASE_ASSIGNMENT(ASTNodeTypeInt, result, intValue)
				DC_CASE_ASSIGNMENT(ASTNodeTypeUnsignedInt, result, unsignedIntValue)
				DC_CASE_ASSIGNMENT(ASTNodeTypeLong, result, longValue)
				DC_CASE_ASSIGNMENT(ASTNodeTypeUnsignedLong, result, unsignedLongValue)
				DC_CASE_ASSIGNMENT(ASTNodeTypeFloat, result, floatValue)
				DC_CASE_ASSIGNMENT(ASTNodeTypeDouble, result, doubleValue)
				DC_CASE_ASSIGNMENT(ASTNodeTypeBOOL, result, boolValue)
			default:
				break;
		}

		//for basic type, should use mutablecopy to avoid object reference;
		ASTVariable* realResult = [[ASTVariable alloc]init];

		if(var.hasBlock)
		{
			realResult = var;
			realResult.value = result.value;

			realResult.type  = result.type;
			realResult.name  = result.name;
			realResult.keyword  = result.keyword;
			realResult.jumpType = result.jumpType;
		}
		else
		{
			realResult = [result toMutableCopy];
			realResult.hasBlock = var.hasBlock;
			realResult.hasPointer = var.hasPointer;
		}

		[self.context pushValue:realResult forKey:key];
	}

//	NSLog(@"%@",result.value);

	return result;
}

- (id)handleProperty
{
	return nil;
}

- (id)handleBlock
{
	return nil;
}

- (id)handleMemberVariables
{
	ASTPropertyNode* nodeSelf = (ASTPropertyNode*)self;

	ASTNode* invokeNode = nodeSelf.invoker;
	ASTVariable* invokeVar;
	if(invokeNode.type == ASTNodeTypeVariable)
	{
		invokeVar = [self.context fetchValueFromKey:invokeNode.value];
	}
	else
	{
		invokeVar = [invokeNode execute];
	}

	NSString* selector = nodeSelf.selector;

	ASTVariable* result = [[ASTVariable alloc]init];
	result.value = [invokeVar.value valueForKeyPath:selector];
	[ASTUtil castTypeFromValue:result];

	return result;
}

- (id)handleCompare
{
	ASTNode* leftNode = self.allChilds[0];
	ASTVariable* leftVar = [[ASTVariable alloc]init];
	if(leftNode.type == ASTNodeTypeVariable)
	{
		leftVar = [self.context fetchValueFromKey:leftNode.value];
	}
	else if(leftNode.type == ASTNodeTypeNil)
	{
		leftVar.type = ASTNodeTypeNil;
		leftVar.value = nil;
	}
	else
	{
		leftVar = [leftNode execute];
	}

	ASTNode* rightNode = self.allChilds[1];
	ASTVariable* rightVar = [[ASTVariable alloc]init];
	if(rightNode.type == ASTNodeTypeVariable)
	{
		rightVar = [self.context fetchValueFromKey:rightNode.value];
	}
	else if(rightNode.type == ASTNodeTypeNil)
	{
		rightVar.type = ASTNodeTypeNil;
		rightVar.value = nil;
	}
	else
	{
		rightVar = [rightNode execute];
	}

	ASTVariable* result = [[ASTVariable alloc]init];
	result.type = ASTNodeTypeBOOL;

	BOOL ok = NO;

#define DC_COMPARE_CASE_RIGHT(_ival, _op, _nodeType, _type, _rcaller, _rselector) \
case _nodeType: { \
_type c2_ = [_rcaller.value _rselector];\
ok = _ival _op c2_; \
break; \
}

#define DC_COMPARE_CASE_LEFT(_op, _nodeType, _type, _lcaller, _rcaller, _lselector) \
case _nodeType: { \
_type ival = [_lcaller.value _lselector]; 	\
switch(_rcaller.type) { \
DC_COMPARE_CASE_RIGHT(ival, _op, ASTNodeTypeChar, char, _rcaller, charValue)\
DC_COMPARE_CASE_RIGHT(ival, _op, ASTNodeTypeUnsignedChar, unsigned char, _rcaller, unsignedCharValue)\
DC_COMPARE_CASE_RIGHT(ival, _op, ASTNodeTypeShort, short , _rcaller, shortValue)\
DC_COMPARE_CASE_RIGHT(ival, _op, ASTNodeTypeUnsignedShort, unsigned short, _rcaller, unsignedShortValue)\
DC_COMPARE_CASE_RIGHT(ival, _op, ASTNodeTypeInt, int, _rcaller, intValue)\
DC_COMPARE_CASE_RIGHT(ival, _op, ASTNodeTypeUnsignedInt, unsigned int, _rcaller, unsignedIntValue)\
DC_COMPARE_CASE_RIGHT(ival, _op, ASTNodeTypeLong, long , _rcaller, longValue)\
DC_COMPARE_CASE_RIGHT(ival, _op, ASTNodeTypeUnsignedLong, unsigned long, _rcaller, unsignedLongValue)\
DC_COMPARE_CASE_RIGHT(ival, _op, ASTNodeTypeFloat, float , _rcaller, floatValue)\
DC_COMPARE_CASE_RIGHT(ival, _op, ASTNodeTypeDouble, double , _rcaller, doubleValue)\
DC_COMPARE_CASE_RIGHT(ival, _op, ASTNodeTypeBOOL, BOOL , _rcaller, boolValue)\
default: { \
ok = _lcaller.value _op _rcaller.value;\
break; \
}	\
}	\
break;	\
}

#define DC_SELECT_OP(_opType, _op, _lcaller, _rcaller) \
case _opType: { \
switch(_lcaller.type) { \
DC_COMPARE_CASE_LEFT(_op, ASTNodeTypeChar, char, _lcaller, _rcaller, charValue)\
DC_COMPARE_CASE_LEFT(_op, ASTNodeTypeUnsignedChar, unsigned char, _lcaller, _rcaller, unsignedCharValue)\
DC_COMPARE_CASE_LEFT(_op, ASTNodeTypeShort, short, _lcaller, _rcaller, shortValue)\
DC_COMPARE_CASE_LEFT(_op, ASTNodeTypeUnsignedShort, unsigned short, _lcaller, _rcaller, unsignedShortValue)\
DC_COMPARE_CASE_LEFT(_op, ASTNodeTypeInt, int, _lcaller, _rcaller, intValue)\
DC_COMPARE_CASE_LEFT(_op, ASTNodeTypeUnsignedInt, unsigned int, _lcaller, _rcaller, unsignedIntValue)\
DC_COMPARE_CASE_LEFT(_op, ASTNodeTypeLong, long, _lcaller, _rcaller, longValue)\
DC_COMPARE_CASE_LEFT(_op, ASTNodeTypeUnsignedLong, unsigned long, _lcaller, _rcaller, unsignedLongValue)\
DC_COMPARE_CASE_LEFT(_op, ASTNodeTypeFloat, float, _lcaller, _rcaller, floatValue)\
DC_COMPARE_CASE_LEFT(_op, ASTNodeTypeDouble, double, _lcaller, _rcaller, doubleValue)\
DC_COMPARE_CASE_LEFT(_op, ASTNodeTypeBOOL, BOOL, _lcaller, _rcaller, boolValue)\
default: { \
ok = _lcaller.value _op _rcaller.value;\
break; \
}	\
} \
break; \
}

	switch (self.type) {
			DC_SELECT_OP(ASTNodeTypeOperationAND, &&, leftVar, rightVar)
			DC_SELECT_OP(ASTNodeTypeOperationOR, ||, leftVar, rightVar)
			DC_SELECT_OP(ASTNodeTypeEqual, ==, leftVar, rightVar)
			DC_SELECT_OP(ASTNodeTypeLessEqual, <=, leftVar, rightVar)
			DC_SELECT_OP(ASTNodeTypeGreaterEqual, >=, leftVar, rightVar)
			DC_SELECT_OP(ASTNodeTypeNotEqual, !=, leftVar, rightVar)
			DC_SELECT_OP(ASTNodeLessThan, <, leftVar, rightVar)
			DC_SELECT_OP(ASTNodeGreaterThan, >, leftVar, rightVar)
		default:
			break;
	}

	result.value = @(ok);

	return result;
}

- (BOOL)checkLogic:(ASTVariable*)var
{
	if(var.type == ASTNodeTypeNumber
	   || var.type == ASTNodeTypeString
	   || var.type == ASTNodeTypeArray
	   || var.type == ASTNodeTypeDictionary
	   || var.type == ASTNodeTypeNil)
	{
		return var.value != nil;
	}

	if((var.type == ASTNodeTypeKEYWORD)
	   && ![ASTUtil checkOCStructType:var.value])
	{
		return var.value != nil;
	}

	if(var.type == ASTNodeTypeVariable)
	{
		var = [self.context fetchValueFromKey:var.value];
		return [self checkLogic:var];
	}

	//constant
	return [var.value boolValue];
}

- (id)handleIf
{
	if(self.allChilds.count < 1) return nil;

	ASTNode* expressionNode = self.allChilds[0];
	ASTVariable* expression = [expressionNode execute];

	if(self.allChilds.count < 2) return nil;
	ASTVariable* statement;

	if([self checkLogic:expression])
	{
		ASTNode* statementNode = self.allChilds[1];
		statement = [statementNode execute];

		if(statement.jumpType != ASTJumpTypeDefault)
		{
			return statement;
		}
	}
	else
	{
		if(self.allChilds.count < 3) return nil;
		ASTNode* elseNode = self.allChilds[2];
		ASTVariable* result;

		for(ASTNode* node in elseNode.allChilds)
		{
			result = [node execute];
		}

		if(result.jumpType != ASTJumpTypeDefault)
		{
			return result;
		}
	}

	return nil;
}

- (id)handleWhile
{
	if(self.allChilds.count < 1) return nil;

	ASTNode* expressionNode = self.allChilds[0];
	ASTVariable* expression = [expressionNode execute];

	if(self.allChilds.count < 2) return nil;

	ASTNode* statementNode = self.allChilds[1];
	ASTVariable* statement;

	while ([self checkLogic:expression])
	{
		statement = [statementNode execute];

		if(statement.jumpType == ASTJumpTypeReturn)
		{
			return statement;
		}
		else if(statement.jumpType == ASTJumpTypeBreak)
		{
			break;
		}
		else if(statement.jumpType == ASTJumpTypeContinue)
		{
			expression = [expressionNode execute];
			continue;
		}
		else
		{
			expression = [expressionNode execute];
		}
	}

	return nil;
}

- (id)handleDoWhile
{
	if(self.allChilds.count < 2) return nil;

	ASTNode* statementNode = self.allChilds[1];
	ASTNode* expressionNode = self.allChilds[0];
	ASTVariable* expression;
	ASTVariable* statement;

	do {
		statement = [statementNode execute];    //execute first, then just

		if(statement.jumpType == ASTJumpTypeReturn)
		{
			return statement;
		}
		else if(statement.jumpType == ASTJumpTypeBreak)
		{
			break;
		}
		else if(statement.jumpType == ASTJumpTypeContinue)
		{
			expression = [expressionNode execute];
			continue;
		}
		else
		{
			expression = [expressionNode execute];
		}

		expression = [expressionNode execute];

	} while ([self checkLogic:expression]);

	return nil;
}

- (id)handleFor
{
	ASTNode* initialNode    = self.allChilds[0];
	ASTNode* conditionNode  = self.allChilds[1];
	ASTNode* incrementNode  = self.allChilds[2];
	ASTNode* statementsNode = self.allChilds[3];

	[self.context pushContext];
	ASTVariable* statement;
	for ([initialNode execute];
		 ([self checkLogic:[conditionNode execute]] || conditionNode.type == ASTNodeTypePlaceholder);
		 [incrementNode execute])
	{
		statement = [statementsNode execute];

		if(statement.jumpType == ASTJumpTypeReturn)
		{
			[self.context popContext];
			return statement;
		}
		else if(statement.jumpType == ASTJumpTypeBreak)
		{
			break;
		}
		else if(statement.jumpType == ASTJumpTypeContinue)
		{
			continue;
		}
	}

	[self.context popContext];

	return nil;
}

- (id)handleSwitch
{
	//TODO
	//DO NOT SUPPORT YET
	//use if/else instead
	assert(0);
	return nil;
}

- (id)handleJump
{
	ASTNode* node = self.value;

	ASTVariable* result = [[ASTVariable alloc]init];

	if(self.type == ASTNodeTypeReturn)
	{
		//return;
		if(node == nil)
		{
			result.jumpType = ASTJumpTypeReturn;
			return result;
		}

		result = [node execute];

		if(result.type == ASTNodeTypeVariable)
		{
			result = [self.context fetchValueFromKey:result.value];
		}

		result.jumpType = ASTJumpTypeReturn;
	}
	else if(self.type == ASTNodeTypeContinue)
	{
		result.jumpType = ASTJumpTypeContinue;
	}
	else if(self.type == ASTNodeTypeBreak)
	{
		result.jumpType = ASTJumpTypeBreak;
	}

	return result;
}

- (NSMutableArray *)allChilds
{
	if(!_allChilds)
	{
		_allChilds = [NSMutableArray array];
	}

	return _allChilds;
}

@end
