[中文介绍](https://github.com/dKingbin/DynamicOC/blob/master/README-chs.md)

# DynamicOC
A hotfix library based on flex/yacc. You can call any Objective-C class and method using DynamicOC.
DynamicOC is functionally similar to [JSPath](https://github.com/bang590/JSPatch), but it only needs to write native OC syntax to implement hotfix.

## Features

- dynamically execute Objective-C code
- dynamically execute C function and block 
- dynamically add property
- dynamically replace method
- dynamically add method
- Completed and detailed unit test
-  powerful OC syntax parser based on flex/yacc
- support CGRect/CGSize/CGPoint/NSRange/UIEdgeInsets/CGAffineTransform C-struct
...

## Basic Usage

####  dynamically execute block 

```
NSString* text = @" \
__block int result = 0;\
UIView* view = [[UIView alloc]init];\
void(^blk)(int value) = ^(int value){\
    view.tag = value;\
};\
blk(1024);\
return view.tag;";

ASTNode* root = [ASTUtil parseString:text];
[ASTUtil linkContextToRoot:root];
ASTVariable* result = [root execute];
NSAssert([result.value doubleValue] == 1024, nil);
```

#### dynamically execute C function

```
int echo(int value) {
    return value;
}

NSString* text = @" \
[OCCfuntionHelper defineCFunction:@\"echo\" types:@\"int, int\"]; \
return echo(1024);";

ASTNode* root = [ASTUtil parseString:text];
[ASTUtil linkContextToRoot:root];
ASTVariable* result = [root execute];
NSAssert([result.value doubleValue] == 1024, nil);
```

#### dynamically add property

```
NSString* text = @" \
[OCCfuntionHelper defineCFunction:@\"objc_setAssociatedObject\" types:@\"void,id,void *,id,unsigned int\"];\
[OCCfuntionHelper defineCFunction:@\"objc_getAssociatedObject\" types:@\"id,id,void *\"];\
NSString* key = @\"key\"; \
objc_setAssociatedObject(self, key, @(1024), 1);\
return objc_getAssociatedObject(self, key);";

ASTNode* root = [ASTUtil parseString:text];
[ASTUtil linkContextToRoot:root];
ASTVariable* result = [root execute];
NSAssert([result.value doubleValue] == 1024, nil);
```

####  Supported Syntax

* [x]  if/else  while do/while for
* [x]  return break continue 
* [x]  i++ i-- ++i --i
* [x]  +i  -i  !i
* [x]  + - * / %     Arithmetic operation
* [x]  >> << & | ^ Bit operation
* [x]  && || >= <= != > < Compare operation
* [x]  ?:
* [x]  __block
* [x] array[i] dict[@""]
* [x] @666  @()  @[]  @{}
* [x] self super
* [x] self.property 
* [x] self->_property
* [x] most of objective-c keyword

## TODO
* [ ] @avaiable()
* [ ] [NSString stringWithFormat:"%d",value] : use [NSString stringWithFormat:"%@",@(value)] instead。
* [ ] dispatch_async / dispatch_after ...
* [ ] *stop =YES, in block
* [ ] fix bugs

## Communication

- GitHub : [dKingbin](https://github.com/dKingbin)
- Email : loveforjyboss@163.com

### License

```
Copyright (c) 2019 dKingbin
Licensed under MIT or later
```

DynamicOC required features are based on or derives from projects below:
- MIT
- [JSPatch](https://github.com/bang590/JSPatch)
- [Aspects](https://github.com/steipete/Aspects)
- [OCEval](https://github.com/lilidan/OCEval)
