//
//  MVKVOGroup.m
//  testkvo
//
//  Created by ximiao on 15/10/20.
//  Copyright © 2015年 ximiao. All rights reserved.
//

#import "MVKVOGroup.h"

@implementation MVKVOGroupOberver
//- (void)remove {
//    [self.observerList removeObject:self];
//} {
- (void)setBlock:(MVKVOGroupCallbackBlock)block {
    _block = block;
}
@end
