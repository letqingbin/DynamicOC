//
//  DynamicOC.h
//  DynamicOC
//
//  Created by dKingbin on 2019/7/29.
//  Copyright © 2019 dKingbin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DynamicOC : NSObject

+ (void)hookClass:(NSString *)clsName
		 selector:(NSString *)selName
		 argNames:(NSArray<__kindof NSString *> *)argNames //original parameters variable name
		  isClass:(BOOL)isClass 	//hook class method or instance method
   implementation:(NSString *)imp;

@end

