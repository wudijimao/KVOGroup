//
//  MVKVOGroup.h
//  testkvo
//
//  Created by ximiao on 15/10/20.
//  Copyright © 2015年 ximiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WKObjectLifeWatcher.h"

typedef void (^MVKVOGroupCallbackBlock)(NSString *keyPath, id oldValue, id newValue);

@interface MVKVOGroupOberver : NSObject
@property (nonatomic, strong)NSString *keyPath;
@property (nonatomic, copy)MVKVOGroupCallbackBlock block;
@property (nonatomic, weak)id<NSObject> holder;
@property (nonatomic, weak)id<NSObject> observedData;
//@property (nonatomic, weak)NSMutableArray *observerList;
//@property (nonatomic, weak)NSString *mark;
//@property (nonatomic, weak)id<NSObject> userData;
//- (void)remove;
- (void)setBlock:(MVKVOGroupCallbackBlock)block;
@end


#define MVKVOGroupMakeObserver(observedData, keyPath, observer) ((void)observedData.keyPath, [observedData MVMakeKVOGroupObserver:observer ForKeyPath:@#keyPath Block:nil])
//只支持String
//每个id有一个USEMVKVOGroupInf
#define USEMVKVOGroup @property (nonatomic, strong)NSMutableDictionary *MVKVOGroupSameIDInfo; \
@property (nonatomic, strong)NSMutableDictionary *MVKVOGroupSameIDOberverDict;
//每个类型有一个MVKVOGroupHolder
#define MVKVOGroupKeyImpl(PARAM1, PARAM2)  \
- (void)set##PARAM2:(NSString *)PARAM1 { \
NSAssert(PARAM1, @"必须要有一个合理的id"); \
if (PARAM1 && PARAM1.length > 0) { \
NSMapTable *holder = [[self class] MVKVOGroupHolder]; \
self.MVKVOGroupSameIDInfo = [holder objectForKey:PARAM1]; \
if (!self.MVKVOGroupSameIDInfo) { \
self.MVKVOGroupSameIDInfo = [NSMutableDictionary dictionary]; \
[holder setObject:self.MVKVOGroupSameIDInfo forKey:PARAM1]; \
self.MVKVOGroupSameIDOberverDict = [NSMutableDictionary dictionary]; \
[self.MVKVOGroupSameIDInfo setObject:self.MVKVOGroupSameIDOberverDict forKey:@"USEMVKVOGroupBlockHolder"]; \
} else { \
self.MVKVOGroupSameIDOberverDict = [self.MVKVOGroupSameIDInfo objectForKey:@"USEMVKVOGroupBlockHolder"]; \
} \
_##PARAM1 = PARAM1; \
} \
} \
- (NSString*)MVKVOGroupKey { \
return _##PARAM1; \
} \
+ (NSMapTable*)MVKVOGroupHolder { \
static NSMapTable *_globalInfos; \
if (!_globalInfos) {  \
_globalInfos = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsCopyIn valueOptions:NSPointerFunctionsWeakMemory];  \
}  \
return _globalInfos; \
} \
- (void)MVKVOGroupSetValue:(id)value ForKeyPath:(NSString*)keyPath { \
id oldValue = [self.MVKVOGroupSameIDInfo objectForKey:keyPath]; \
[self.MVKVOGroupSameIDInfo setValue:value forKey:keyPath]; \
NSMutableArray *observers = [self.MVKVOGroupSameIDOberverDict objectForKey:keyPath]; \
for (MVKVOGroupOberver * observer in observers) { \
if(observer.block) { \
observer.block(keyPath, oldValue, value); \
}\
} \
} \
- (MVKVOGroupOberver*)MVMakeKVOGroupObserver:(NSObject*)obj ForKeyPath:(NSString*)keyPath Block:(void (^)(NSString *keyPath, id oldValue, id newValue))block { \
NSMutableArray *observers = [self.MVKVOGroupSameIDOberverDict objectForKey:keyPath]; \
if (!observers) { \
observers = [[NSMutableArray alloc] init]; \
[self.MVKVOGroupSameIDOberverDict setObject:observers forKey:keyPath];  \
} \
__weak NSMutableArray* weakObservers = observers; \
MVKVOGroupOberver *observer = [MVKVOGroupOberver new];\
observer.block = block;\
observer.holder = obj;\
__weak MVKVOGroupOberver *weakObserver = observer; \
[obj addDeallocedCallback:^(WKObjectLifeWatcher *objectLifeWatcher) {  \
[weakObservers removeObject:weakObserver];  \
} forKey:keyPath];  \
[observers addObject:observer];  \
if(observer.block) {\
id value = [self.MVKVOGroupSameIDInfo objectForKey:keyPath]; \
observer.block(keyPath, value, value);\
} \
return observer; \
}

#define MVKVOGroupParamImpl(PARAM1, PARAM2, TYPE) \
- (void)set##PARAM2:(TYPE)PARAM1 { \
[self MVKVOGroupSetValue:PARAM1 ForKeyPath:@#PARAM1];  \
}  \
- (TYPE)PARAM1 { \
return [self.MVKVOGroupSameIDInfo objectForKey:@#PARAM1]; \
}
#define MVKVOGroupParamImplBOOL(PARAM1, PARAM2) \
- (void)set##PARAM2:(BOOL)PARAM1 { \
[self MVKVOGroupSetValue:[NSNumber numberWithBool:PARAM1] ForKeyPath:@#PARAM1];  \
}  \
- (BOOL)PARAM1 { \
return [[self.MVKVOGroupSameIDInfo objectForKey:@#PARAM1] boolValue]; \
}

