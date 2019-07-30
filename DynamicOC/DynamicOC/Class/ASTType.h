//
//  ASTType.h
//  DynamicOC
//
//  Created by dKingbin on 2019/7/27.
//  Copyright © 2019 dKingbin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASTHeader.h"

@interface ASTType : NSObject
@property (nonatomic,assign) ASTNodeType type;
@property (nonatomic,copy) NSString* keyword;
@property (nonatomic,copy) NSString* typeEncode;
@end

