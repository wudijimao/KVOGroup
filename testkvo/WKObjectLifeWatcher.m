//
//  WKObjectLifeWatcher.m
//  WeiboHeadlines
//
//  Created by liuyue on 9/16/13.
//  Copyright (c) 2013 liuyue. All rights reserved.
//

#import "WKObjectLifeWatcher.h"
#import <objc/runtime.h>

static NSMutableDictionary *objectWatchers = nil;

NSString *const WKObjectWillDeallocNotification = @"WKObjectWillDeallocNotification";
NSString *const WKObjectDidDeallocNotification = @"WKObjectDidDeallocNotification";
NSString *const kWKObjectIdentifier = @"kWKObjectIdentifier";
@interface WKObjectLifeWatcher ()
{
    NSString *_objectIdentifier;
    NSMutableDictionary *deallocCallbacks;
    NSMutableDictionary *objectInfos;
    
    BOOL _objectAlive;
    NSCondition *objectLock;
    
    NSUInteger lockCount;
    BOOL   deallocing;
    id _object;
}

@end
@implementation WKObjectLifeWatcher
@synthesize objectIdentifier = _objectIdentifier;
@synthesize objectAlive = _objectAlive;

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        objectWatchers = (NSMutableDictionary *)CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, NULL);
    });
}

- (void)dealloc
{
    [objectWatchers removeObjectForKey:_objectIdentifier];
    [_objectIdentifier release] , _objectIdentifier = nil;
    [objectInfos release] , objectInfos = nil;
    [deallocCallbacks release],deallocCallbacks = nil;
    [objectLock release],objectLock = nil;
    [super dealloc];
}

- (id)initWithObject:(NSObject *)object
{
    self = [self init];
    if (self) {
        CFUUIDRef u = CFUUIDCreate(kCFAllocatorDefault);
        CFStringRef s = CFUUIDCreateString(kCFAllocatorDefault, u);
        CFRelease(u);
        _objectIdentifier =  (NSString *)s;
        
        _object = object;
        [objectWatchers setObject:self forKey:_objectIdentifier];
        _objectAlive = YES;
        lockCount = 0;
    }
    return self;
}

- (id)object
{
    if (_objectAlive) {
        return _object;
    }
    return nil;
}

- (BOOL)isObjectAlive
{
    return _objectAlive;
}

- (void)setObjectInfo:(id)info forKey:(NSString *)key
{
    if (!objectInfos) {
        objectInfos = [[NSMutableDictionary alloc] init];
        objectLock = [[NSCondition alloc] init];
    }
    [objectInfos setObject:info forKey:key];
}

- (id)objectInfoForKey:(NSString *)key
{
    return [objectInfos objectForKey:key];
}

+ (WKObjectLifeWatcher *)watcherWithObject:(NSObject *)object
{
    WKObjectLifeWatcher *watcher = [[WKObjectLifeWatcher alloc] initWithObject:object];
    return [watcher autorelease];
}

+ (WKObjectLifeWatcher *)watcherForObjectIdentifier:(NSString *)identifier
{
    WKObjectLifeWatcher *watcher = [objectWatchers objectForKey:identifier];
    [watcher retain];
    return [watcher autorelease];
}

- (void)addDeallocedCallback:(WKObjectDeallocedCallback)callBack forKey:(NSString *)key
{
    if (!deallocCallbacks) {
        deallocCallbacks = [[NSMutableDictionary alloc] init];
    }
    WKObjectDeallocedCallback block = Block_copy(callBack);
    [deallocCallbacks setObject:block forKey:key];
    Block_release(block);
}

- (void)removeDeallocedCallbackForKey:(NSString *)key
{
    [deallocCallbacks removeObjectForKey:key];
}

- (BOOL)hasDeallocCallback
{
    return [deallocCallbacks count];
}

- (void)objectBeginDealloc
{
    _objectAlive = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:WKObjectWillDeallocNotification
                                                        object:self
                                                      userInfo:@{kWKObjectIdentifier:_objectIdentifier}];
    [deallocCallbacks enumerateKeysAndObjectsUsingBlock:^(id key, WKObjectDeallocedCallback callBack, BOOL *stop) {
        callBack(self);
    }];
}

- (void)objectDidDealloced
{
    [[NSNotificationCenter defaultCenter] postNotificationName:WKObjectDidDeallocNotification
                                                        object:self
                                                      userInfo:@{kWKObjectIdentifier:_objectIdentifier}];
}

- (void)lock
{
    [objectLock lock];
    while (deallocing) {
        [objectLock wait];
    }
    lockCount ++;
}

- (void)unlock
{
    lockCount --;
    if (lockCount <= 0) {
        lockCount = 0;
        [objectLock broadcast];
        [objectLock unlock];
    }
}

- (void)deallocLock
{
    [objectLock lock];
    while (lockCount > 0) {
        [objectLock wait];
    }
    deallocing = YES;
}

- (void)deallocUnlock
{
    deallocing = NO;
    [objectLock broadcast];
    [objectLock unlock];
}

@end



@implementation NSObject (WKObjectLifeWatcher)
static NSString *const kGHObjectLifeWatcher = @"com.sina.Cocoa.GHObjectLifeWatcher";

+ (id)objectForIdentifier:(NSString *)identifier
{
    WKObjectLifeWatcher *watcher = [WKObjectLifeWatcher watcherForObjectIdentifier:identifier];
    return watcher.object;
}
static void exchangeNSObjectDealloc()
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method leftMethod = class_getInstanceMethod([NSObject class], @selector(GHCustomDealloc));
        Method rightMethod = class_getInstanceMethod([NSObject class], @selector(dealloc));
        method_exchangeImplementations(leftMethod, rightMethod);
    });
}
- (void)GHCustomDealloc
{
    WKObjectLifeWatcher *watcher = [self.lifeWatcher retain];
    [watcher deallocLock];
    if (watcher) {
        objc_setAssociatedObject(self, kGHObjectLifeWatcher, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    [watcher objectBeginDealloc];
    [self GHCustomDealloc];
    [watcher objectDidDealloced];
    [watcher deallocUnlock];
    [watcher release];
}

- (NSString *)GHObjectIdentifier
{
    WKObjectLifeWatcher *watcher = [self lifeWatcher];
    return [watcher objectIdentifier];
}

- (NSString *)forceObjectIdentifier
{
    WKObjectLifeWatcher *watcher = [self lifeWatcherForceEnable:YES];
    return [watcher objectIdentifier];
}

- (WKObjectLifeWatcher *)lifeWatcher
{
    return [self lifeWatcherForceEnable:NO];
}

- (WKObjectLifeWatcher *)lifeWatcherForceEnable:(BOOL)enable
{
    WKObjectLifeWatcher *watcher = nil;
    @synchronized(self) {
        watcher = objc_getAssociatedObject(self, kGHObjectLifeWatcher);
        if (!watcher && enable)
        {
            watcher = [[WKObjectLifeWatcher alloc] initWithObject:self];
            objc_setAssociatedObject(self, kGHObjectLifeWatcher, watcher, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            exchangeNSObjectDealloc();
            [watcher release];
        }
    }
    return watcher;
}

- (void)addDeallocedCallback:(WKObjectDeallocedCallback)callBack forKey:(NSString *)key
{
    [[self lifeWatcherForceEnable:YES] addDeallocedCallback:callBack forKey:key];
}

- (void)removeDeallocedCallbackForKey:(NSString *)key
{
    [self.lifeWatcher removeDeallocedCallbackForKey:key];
}

- (void)setObjectInfo:(id)info forKey:(NSString *)key
{
    [[self lifeWatcherForceEnable:YES] setObjectInfo:info forKey:key];
}

- (id)objectInfoForKey:(NSString *)key
{
    return [self.lifeWatcher objectInfoForKey:key];
}
@end
