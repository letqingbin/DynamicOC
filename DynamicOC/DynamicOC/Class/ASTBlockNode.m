//
//  ASTBlockNode.m
//  DynamicOC
//
//  Created by dKingbin on 2019/7/27.
//  Copyright © 2019 dKingbin. All rights reserved.
//

#import "ASTBlockNode.h"
#import "ASTUtil.h"
#import "ASTVariable.h"
#import "ASTType.h"
#import "ASTContext.h"
#import "OCBlockWrapper.h"

@implementation ASTBlockNode

- (id)handleBlockDeclarator
{
    if(self.allChilds.count < 3) return nil;
    
    //block return type
    ASTNode* returnTypeNode = self.allChilds[0];
    ASTType* typeName = [ASTUtil typeForNodeType:returnTypeNode.type keyword:returnTypeNode.keyword];
    
    if(typeName == nil)
    {
        typeName = [[ASTType alloc]init];
        typeName.type = returnTypeNode.type;
        typeName.keyword = returnTypeNode.keyword;
    }
    [self.typeNames addObject:typeName.keyword];
    
    //block variable name
    ASTNode* variableNode = self.allChilds[1];
    NSString* variable = variableNode.value;

	//block arugment list
    ASTNode* argumentNode = self.allChilds[2];
    for(ASTNode* node in argumentNode.allChilds)
    {
        typeName = [ASTUtil typeForNodeType:node.type keyword:node.keyword];
        [self.typeNames addObject:typeName.keyword];
    }
    
    ASTVariable* result = [[ASTVariable alloc]init];
    result.type  = ASTNodeTypeBlock;
    result.name  = variable;
    result.value = self;
    
	[self.context pushValue:result forKey:variable];
    
    return result;
}

- (id)handleBlock
{
    ASTNode* returnTypeNode = self.allChilds[0];
    ASTType* typeName = [ASTUtil typeForNodeType:returnTypeNode.type keyword:returnTypeNode.keyword];
    
    if(typeName == nil)
    {
        typeName = [[ASTType alloc]init];
        typeName.type = returnTypeNode.type;
        typeName.keyword = returnTypeNode.keyword;
    }
    [self.typeNames addObject:typeName.keyword];

    ASTNode* argumentNode = self.allChilds[1];
	if(argumentNode.allChilds.count == 0)
	{
		//if empty, default void
		typeName = [ASTUtil typeForNodeType:ASTNodeTypeVoid keyword:nil];
		[self.typeNames addObject:typeName.keyword];
	}
	else
	{
		for(ASTNode* child in argumentNode.allChilds)
		{
			if(child.type == ASTNodeTypeVoid)
			{
				typeName = [ASTUtil typeForNodeType:ASTNodeTypeVoid keyword:nil];
				[self.typeNames addObject:typeName.keyword];
			}
			else
			{
				ASTNode* node = child.allChilds[0];
				typeName = [ASTUtil typeForNodeType:node.type keyword:node.keyword];
				if(typeName == nil)
				{
					typeName = [[ASTType alloc]init];
					typeName.type = node.type;
					typeName.keyword = node.keyword;
				}
				[self.typeNames addObject:typeName.keyword];

				ASTNode* nameNode = child.allChilds[1];
				ASTVariable* argument = [[ASTVariable alloc]init];
				argument.name = nameNode.value; //variable name
				argument.type  = node.type;
				argument.keyword = node.keyword;
				argument.hasBlock = node.hasBlock;
				argument.hasPointer = node.hasPointer;
				[self.arguments addObject:argument];
			}
		}
	}
    
    [self scanAllVariable:self];
    
    OCBlockWrapper* wrapper = [OCBlockWrapper blockWrapperWithNode:self];
    self.blockPtr = (__bridge id)([wrapper blockPtr]);
    
    ASTVariable* result = [[ASTVariable alloc]init];
    result.value = self.blockPtr;
    result.type  = ASTNodeTypeBlock;
    
    return result;
}

- (void)scanAllVariable:(ASTNode*)node
{
    for(ASTNode* child in node.allChilds)
    {
        [self addNodeToContext:child];
        [self scanAllVariable:child];
    }
    
    if([node.value isKindOfClass:ASTNode.class]
       && node.value != nil)
    {
        ASTNode* child = node.value;
        
        [self addNodeToContext:child];
        [self scanAllVariable:child];
    }
}

- (void)addNodeToContext:(ASTNode*)node
{
    if(node.type == ASTNodeTypeVariable)
    {
        if([self.context isKnownKey:node.value])
        {
            ASTVariable* value = [self.context fetchValueFromKey:node.value];
            
            ASTVariable* realResult = value;
            if(!value.hasBlock)
            {
                realResult = [[ASTVariable alloc]init];
                realResult.type  = value.type;
                realResult.name  = value.name;
                realResult.value = value.value;
                realResult.keyword  = value.keyword;
                realResult.hasBlock = value.hasBlock;
                realResult.hasPointer = value.hasPointer;
                realResult.jumpType = value.jumpType;
            }
            
            [self.blockContext setValue:realResult forKey:node.value];
        }
    }
}

- (NSMutableArray*)typeNames
{
    if(!_typeNames)
    {
        _typeNames = [NSMutableArray array];
    }
    return _typeNames;
}

- (NSMutableArray*)arguments
{
    if(!_arguments)
    {
        _arguments = [NSMutableArray array];
    }
    return _arguments;
}

- (NSMutableDictionary *)blockContext
{
    if(!_blockContext)
    {
        _blockContext = [NSMutableDictionary dictionary];
    }

    return _blockContext;
}

@end
