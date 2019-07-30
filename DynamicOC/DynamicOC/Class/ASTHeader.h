//
//  ASTHeader.h
//  DynamicOC
//
//  Created by dKingbin on 2019/7/14.
//  Copyright © 2019 dKingbin. All rights reserved.
//

#ifndef ASTHeader_h
#define ASTHeader_h

typedef enum {
    
    ASTNodeTypePointer ,     //*
    ASTNodeTypeOCBlock ,     //__block
    
	ASTNodeTypeKEYWORD ,     //Object
    
	//basic type
	ASTNodeTypeChar          ,
	ASTNodeTypeUnsignedChar  ,
	ASTNodeTypeShort         ,
	ASTNodeTypeUnsignedShort ,
	ASTNodeTypeInt  ,
	ASTNodeTypeUnsignedInt  ,
	ASTNodeTypeLong ,
	ASTNodeTypeUnsignedLong ,
	ASTNodeTypeFloat  ,
	ASTNodeTypeDouble ,
    ASTNodeTypeBOOL   ,
	ASTNodeTypeVoid   ,

    ASTNodeTypeString ,
    ASTNodeTypeNumber ,
	ASTNodeTypeArray  ,
	ASTNodeTypeDictionary ,
    ASTNodeTypeNil ,
    
    ASTNodeTypeScope ,		 // {}
    ASTNodeTypeVariable,     //
    ASTNodeTypeContainer,    // NSArray/NSDictionary
    ASTNodeTypeIndex ,       // index for NSArray/NSDictionary
    ASTNodeTypeKeyValue,
    ASTNodeTypeDeclarator,
    
    ASTNodeTypeOperationMUL , // 'x'
    ASTNodeTypeOperationDIV , // '/'
    ASTNodeTypeOperationADD , // '+'
    ASTNodeTypeOperationSUB , // '-'

    ASTNodeTypeOperationRemainder , // '%'
	ASTNodeTypeOperationRightShitf ,  // '>>'
	ASTNodeTypeOperationLeftShitf ,   // '<<'
	ASTNodeTypeOperationBitAND, // &
	ASTNodeTypeOperationBitOR,  // |
	ASTNodeTypeOperationBitNOT, // ^


	ASTNodeTypeOperationAND , // '&&'
	ASTNodeTypeOperationOR ,  // '||'
	ASTNodeTypeEqual ,     // '=='
	ASTNodeTypeLessEqual , // '<='
	ASTNodeTypeGreaterEqual , // '>='
	ASTNodeTypeNotEqual , // '!='
	ASTNodeLessThan,      // '<'
	ASTNodeGreaterThan,   // '>'


    ASTNodeTypeOperationPrefixInc , // '++i'
    ASTNodeTypeOperationPrefixDec , // '--i'
    ASTNodeTypeOperationPostfixInc , // 'i++'
    ASTNodeTypeOperationPostfixDec , // 'i--'
    ASTNodeTypeUnaryMinus, // '-i'
    ASTNodeTypeUnaryPlus,  // '+i'
    ASTNodeTypeUnaryNot,   // '!i'

    
    ASTNodeTypeOperationCondition,  // ?:
    ASTNodeTypePlaceholder,

    ASTNodeTypeAssign ,    // '='
    ASTNodeTypeAddAssign , // '+='
    ASTNodeTypeSubAssign , // '-='
    ASTNodeTypeExpression,
	ASTNodeTypeAddressAssign ,  // *stop = YES;

    ASTNodeTypeCArugmentList ,
	ASTNodeTypeOCArgument,
	ASTNodeTypeOCArgumentList ,
	ASTNodeTypeUnarySelector,

    ASTNodeTypeBlockDeclarator,
    ASTNodeTypeBlockDeclareArugmentList,
	ASTNodeTypeBlockArugmentList,
	ASTNodeTypeBlock,

    ASTNodeTypeCallCFunction, // func();
	ASTNodeTypeCallOCFunction,// [self func];
	ASTNodeTypeProperty,
	ASTNodeTypePropertyList,
	ASTNodeTypeMemberVariables, 

	ASTNodeTypeReturn,		//return
	ASTNodeTypeBreak,		//break
	ASTNodeTypeContinue,	//continue

	ASTNodeTypeIf,			//if
    ASTNodeTypeElse,        //else
	ASTNodeTypeWhile,		//while
	ASTNodeTypeDoWhile,		//do while
	ASTNodeTypeFor,			//for
	ASTNodeTypeCase,		//case
    ASTNodeTypeDefault,     //defaults
    ASTNodeTypeSwitch,      //switch
    
	ASTNodeTypeProgram,     // program
} ASTNodeType;

typedef enum {
	ASTJumpTypeDefault ,
	ASTJumpTypeReturn ,
	ASTJumpTypeBreak ,
	ASTJumpTypeContinue ,
} ASTJumpType;

typedef struct yy_buffer_state *YY_BUFFER_STATE;
YY_BUFFER_STATE  yy_scan_string(const char *s);

int yyparse(void);
void yy_delete_buffer(YY_BUFFER_STATE buf);

#endif /* ASTHeader_h */
