# iOS 动态化热修复方案

### 前言

iOS热修复方案经过JSPatch事件后，也消停了很久。bang神在[《JSPatch – 动态更新iOS APP》](http://blog.cnbang.net/works/2767/)中曾提到，为了更符合Apple的规则，即[《Apple Developer Program License Agreement》 ](http://dev.hel.fi/paatokset/media/att/9a/9aa5692b91f2b538eeb352c425b3e66c09e6b1a5.pdf)里3.3.2提到的不可动态下发可执行代码。
JSPatch特地绕了js的圈子，从而实现曲线救国、实现热更新的方案。但是事实证明了Apple对于这种方案也是不认可的，根本的原因还是在于JSPath做得太过极致--支持绝大部分的OC/C语法。

### 思考

既然JSPatch绕道js的方法，已经被Apple拒绝了，那么就再次回到原点，重新出发。新的框架或者新的方案我觉得至少有一个充分条件，就是不能太极致。
Objective-C作为一种动态的语言，因此能够动态执行所有OC语法是正常的，Aspects类似的框架也是被Apple认可的。至于是否需要运行所有的C函数，这个有待商榷。
第二个方面，则是放弃javascript/lua等类似语言作为更新的脚本，而是采用原生的Objective-C作为更新的脚本语言。

#### 动态运行C函数

C语言是没有反射机制的，作为一门编译型语言，在编译期间就已经生成机器码。因此如果要从字符串中获取到对应的函数指针，那么大概有两种方法:

- 建立映射表, 将函数名和函数指针建立一个映射表。
- dlsym, 根据动态链接库操作句柄与符号，返回符号对应的地址。

第二种是目前JSPatch采用的办法，当然也被Apple警告了。dlsym功能非常强悍，是获取函数指针的最优解。
第一种局限性非常大，但是没有用到黑魔法。

#### 采用Objective-C作为更新的脚本语言
通过flex/yacc，直接解析Objective-C语法，不再采取js/lua等脚本语言。

### DynamicOC
经过上面的思考，在最近业余中做了[DynamicOC](https://github.com/dKingbin/DynamicOC)的项目，百分百原生支持采用Objective-C作为更新的脚本语言。
当然动态运行C函数还是采用dlsym获取函数指针的办法，后面会逐步改为映射表的做法。

#### 原理

[DynamicOC](https://github.com/dKingbin/DynamicOC)使用flex/yacc进行词法解析和语法分析，转为一颗语法生成树AST。
然后通过解析每个节点，从而执行相应的代码。因为采用的是Objective-C作为脚本语言，因此极容易适配。

#### 功能特点

- 动态执行OC代码
- 动态执行C函数和block异步调用
- 动态添加属性
- 动态替换方法
- 动态添加方法
- 有完善的单元测试
-  flex/yacc实现强大的OC语法解析器
- 支持CGRect/CGSize/CGPoint/NSRange/UIEdgeInsets/CGAffineTransform常用结构体
...

### 基本用法

#### 动态执行block

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
ASTVariable* result = [root execute];
NSAssert([result.value doubleValue] == 1024, nil);
```

#### 动态执行C函数

```
int echo(int value) {
return value;
}

NSString* text = @" \
[OCCfuntionHelper defineCFunction:@\"echo\" types:@\"int, int\"]; \
return echo(1024);";

ASTNode* root = [ASTUtil parseString:text];
ASTVariable* result = [root execute];
NSAssert([result.value doubleValue] == 1024, nil);
```

#### 动态添加Property

```
NSString* text = @" \
[OCCfuntionHelper defineCFunction:@\"objc_setAssociatedObject\" types:@\"void,id,void *,id,unsigned int\"];\
[OCCfuntionHelper defineCFunction:@\"objc_getAssociatedObject\" types:@\"id,id,void *\"];\
NSString* key = @\"key\"; \
objc_setAssociatedObject(self, key, @(1024), 1);\
return objc_getAssociatedObject(self, key);";

ASTNode* root = [ASTUtil parseString:text];
ASTVariable* result = [root execute];
NSAssert([result.value doubleValue] == 1024, nil);
```

#### 已支持语法

* [x]  if/else  while do/while for
* [x]  return break continue 
* [x]  i++ i-- ++i --i
* [x]  +i  -i  !i
* [x]  + - * / %等四则运算
* [x]  >> << & | ^ 等位运算
* [x]  && || >= <= != > < 等比较运算
* [x]  ?:
* [x]  __block
* [x] array[i] dict[@""]
* [x] @666  @()  @[]  @{}
* [x] self super
* [x] self.property 
* [x] self->_property
* [x] most of objective-c keyword

### TODO
* [ ] @available()
* [ ] [NSString stringWithFormat:"%d",value] : use [NSString stringWithFormat:"%@",@(value)] instead。
* [ ] dispatch_async / dispatch_after ...
* [ ] *stop =YES, in block
* [ ] fix bugs


### Warnning

```
纯粹是技术分享，鉴于JSPath的被禁，不建议用于上架Appstore。
```

## 参考链接
[JSPatch – 动态更新iOS APP](http://blog.cnbang.net/works/2767/)

[iOS 动态化的故事](http://blog.cnbang.net/tech/3286/)

[Apple Developer Program License Agreement ](http://dev.hel.fi/paatokset/media/att/9a/9aa5692b91f2b538eeb352c425b3e66c09e6b1a5.pdf)

[滴滴 iOS 动态化方案 DynamicCocoa 的诞生与起航](http://www.cocoachina.com/articles/18400)












