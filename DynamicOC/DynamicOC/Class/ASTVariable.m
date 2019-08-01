//
//  ASTVariable.m
//  DynamicOC
//
//  Created by dKingbin on 2019/7/21.
//  Copyright © 2019 dKingbin. All rights reserved.
//

#import "ASTVariable.h"

@implementation ASTVariable

- (instancetype)toMutableCopy
{
	ASTVariable* result = [[ASTVariable alloc]init];
	result.type = self.type;
	result.name = self.name;
	result.value = self.value;
	result.keyword = self.keyword;
	result.hasPointer = self.hasPointer;
	result.hasBlock = self.hasBlock;

	result.postOperation = self.postOperation;
	result.jumpType = self.jumpType;

	return result;
}


@end
