//
//  ASTMethodNode.h
//  DynamicOC
//
//  Created by dKingbin on 2019/7/24.
//  Copyright © 2019 dKingbin. All rights reserved.
//

#import "ASTNode.h"
#import "ASTHeader.h"

@interface ASTMethodNode : ASTNode
@property(nonatomic,copy) NSString* name;
@property(nonatomic,strong) ASTNode* argument;
@end

