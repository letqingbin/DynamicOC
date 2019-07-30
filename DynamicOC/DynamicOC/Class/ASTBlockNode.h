//
//  ASTBlockNode.h
//  DynamicOC
//
//  Created by dKingbin on 2019/7/27.
//  Copyright © 2019 dKingbin. All rights reserved.
//

#import "ASTNode.h"

@interface ASTBlockNode : ASTNode
@property (nonatomic,strong) NSMutableArray *typeNames;
@property (nonatomic,strong) NSMutableArray *arguments;
@property (nonatomic,strong) NSMutableDictionary* blockContext;
@property (nonatomic,strong) id blockPtr;
- (id)handleBlock;
@end

