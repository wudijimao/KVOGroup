//
//  WKObjectLifeWatcher.h
//  WeiboHeadlines
//
//  Created by liuyue on 9/16/13.
//  Copyright (c) 2013 liuyue. All rights reserved.
//

#import <Foundation/Foundation.h>
extern NSString *const WKObjectWillDeallocNotification;
extern NSString *const WKObjectDidDeallocNotification;
extern NSString *const kWKObjectIdentifier;
@class WKObjectLifeWatcher;
typedef void (^WKObjectDeallocedCallback)(WKObjectLifeWatcher *objectLifeWatcher);

@interface WKObjectLifeWatcher : NSObject
@property (nonatomic, retain, readonly)NSString *objectIdentifier;
@property (nonatomic, assign, readonly, getter = isObjectAlive)BOOL objectAlive;
+ (WKObjectLifeWatcher *)watcherWithObject:(NSObject *)object;
+ (WKObjectLifeWatcher *)watcherForObjectIdentifier:(NSString *)identifier;
- (id)object;
- (void)setObjectInfo:(id)info forKey:(NSString *)key;
- (id)objectInfoForKey:(NSString *)key;
- (void)addDeallocedCallback:(WKObjectDeallocedCallback)callBack forKey:(NSString *)key;
- (void)removeDeallocedCallbackForKey:(NSString *)key;
- (BOOL)hasDeallocCallback;

- (void)objectBeginDealloc;
- (void)objectDidDealloced;

- (void)lock;
- (void)unlock;
@end

@interface NSObject (WKObjectLifeWatcher)
+ (id)objectForIdentifier:(NSString *)identifier;
- (NSString *)GHObjectIdentifier;
- (NSString *)forceObjectIdentifier;
- (WKObjectLifeWatcher *)lifeWatcher;
- (WKObjectLifeWatcher *)lifeWatcherForceEnable:(BOOL)enable;
- (void)addDeallocedCallback:(WKObjectDeallocedCallback)callBack forKey:(NSString *)key;
- (void)removeDeallocedCallbackForKey:(NSString *)key;
- (void)setObjectInfo:(id)info forKey:(NSString *)key;
- (id)objectInfoForKey:(NSString *)key;
@end
