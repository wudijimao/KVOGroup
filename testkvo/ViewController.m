//
//  ViewController.m
//  testkvo
//
//  Created by ximiao on 15/10/13.
//  Copyright (c) 2015年 ximiao. All rights reserved.
//

#import "ViewController.h"
#import "MVKVOGroup.h"

@interface DSMovieInfo : NSObject
USEMVKVOGroup
@property (nonatomic, strong)NSString *id_;
@property (nonatomic, strong)NSString *name;
@property (nonatomic, strong)NSString *title;
@property (nonatomic, strong)NSString *like;
@property (nonatomic, strong)NSNumber *testNumber;
@property (nonatomic, assign)BOOL testBool;
@end

@implementation DSMovieInfo
MVKVOGroupKeyImpl(id_, Id_)
MVKVOGroupParamImpl(name, Name, NSString*)
MVKVOGroupParamImpl(title, Title, NSString*)
MVKVOGroupParamImpl(like, Like, NSString*)
MVKVOGroupParamImpl(testNumber, TestNumber, NSNumber*)
MVKVOGroupParamImplBOOL(testBool, TestBool);
/*
- (void)setId_:(NSString *)id_ {
    do {
    if (!(id_)) { [[NSAssertionHandler currentHandler] handleFailureInMethod:_cmd object:self file:[NSString stringWithUTF8String:"/Users/ximiao/Documents/testkvo/testkvo/ViewController.m"] lineNumber:23 description:(@"必须要有一个合理的id")]; }
} while(0);
    if (id_ && id_.length > 0) {
        NSMapTable *holder = [[self class] MVKVOGroupHolder];
        self.MVKVOGroupSameIDInfo = [holder objectForKey:id_];
        if (!self.MVKVOGroupSameIDInfo) {
            self.MVKVOGroupSameIDInfo = [NSMutableDictionary dictionary];
            [holder setObject:self.MVKVOGroupSameIDInfo forKey:id_];
            self.MVKVOGroupSameIDOberverDict = [NSMutableDictionary dictionary]; [self.MVKVOGroupSameIDInfo setObject:self.MVKVOGroupSameIDOberverDict forKey:@"USEMVKVOGroupBlockHolder"];
        } else {
            self.MVKVOGroupSameIDOberverDict = [self.MVKVOGroupSameIDInfo objectForKey:@"USEMVKVOGroupBlockHolder"]; } _id_ = id_;
    }
}
- (NSString*)MVKVOGroupKey {
    return _id_;
    
}
+ (NSMapTable*)MVKVOGroupHolder {
    static NSMapTable *_globalInfos;
    if (!_globalInfos) {
        _globalInfos = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsCopyIn valueOptions:NSPointerFunctionsWeakMemory];
    } return _globalInfos; }
- (void)MVKVOGroupSetValue:(id)value ForKeyPath:(NSString*)keyPath {
    id oldValue = [self.MVKVOGroupSameIDInfo objectForKey:keyPath];
    [self.MVKVOGroupSameIDInfo setValue:value forKey:keyPath];
    NSMutableArray *observers = [self.MVKVOGroupSameIDOberverDict objectForKey:keyPath];
    for (MVKVOGroupOberver * observer in observers) {
        if(observer.block) { observer.block(keyPath, oldValue, value);
        }
    }
}
- (MVKVOGroupOberver*)MVMakeKVOGroupObserver:(NSObject*)obj ForKeyPath:(NSString*)keyPath Block:(void (^)(NSString *keyPath, id oldValue, id newValue))block { NSMutableArray *observers = [self.MVKVOGroupSameIDOberverDict objectForKey:keyPath];
    if (!observers) {
        observers = [[NSMutableArray alloc] init];
        [self.MVKVOGroupSameIDOberverDict setObject:observers forKey:keyPath];
    }
    __attribute__((objc_ownership(weak))) NSMutableArray* weakObservers = observers; MVKVOGroupOberver *observer = [MVKVOGroupOberver new];observer.block = block;observer.holder = obj;__attribute__((objc_ownership(weak))) MVKVOGroupOberver *weakObserver = observer; [obj addDeallocedCallback:^(WKObjectLifeWatcher *objectLifeWatcher)
    {
        [weakObservers removeObject:weakObserver]; } forKey:keyPath]; [observers addObject:observer]; if(observer.block) {id value = [self.MVKVOGroupSameIDInfo objectForKey:keyPath]; observer.block(keyPath, value, value);
        }
    return observer;
}
- (void)setName:(NSString*)name {
    [self MVKVOGroupSetValue:name ForKeyPath:@"name"];
}
- (NSString*)name { return [self.MVKVOGroupSameIDInfo objectForKey:@"name"]; }
- (void)setTitle:(NSString*)title { [self MVKVOGroupSetValue:title ForKeyPath:@"title"]; }
- (NSString*)title { return [self.MVKVOGroupSameIDInfo objectForKey:@"title"]; }
- (void)setLike:(NSString*)like { [self MVKVOGroupSetValue:like ForKeyPath:@"like"]; }
- (NSString*)like { return [self.MVKVOGroupSameIDInfo objectForKey:@"like"]; }
- (void)setTestNumber:(NSNumber*)testNumber { [self MVKVOGroupSetValue:testNumber ForKeyPath:@"testNumber"]; }
- (NSNumber*)testNumber { return [self.MVKVOGroupSameIDInfo objectForKey:@"testNumber"]; }
- (void)setTestBool:(BOOL)testBool { [self MVKVOGroupSetValue:[NSNumber numberWithBool:testBool] ForKeyPath:@"testBool"]; }
- (BOOL)testBool { return [[self.MVKVOGroupSameIDInfo objectForKey:@"testBool"] boolValue]; };
 */
@end

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UISwitch *switcher;
@property (weak, nonatomic) IBOutlet UISwitch *switcher2;
@property (weak, nonatomic) IBOutlet UISwitch *switcher3;
@property (nonatomic, strong)DSMovieInfo *info1;
@property (nonatomic, strong)DSMovieInfo *info2;
@property (nonatomic, strong)DSMovieInfo *info3;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.info1 = [DSMovieInfo new];
    self.info1.id_ = @"testid1111";
    self.info1.name = @"name1";
    self.info1.testBool = YES;
    
    self.info2 = [[DSMovieInfo alloc] init];
    self.info2.id_ = @"testid1111";
    
    self.info3 = [[DSMovieInfo alloc] init];
    self.info3.id_ = @"testid2222";
    
    __weak ViewController *weakSelf = self;
    [MVKVOGroupMakeObserver(self.info1, testBool, self) setBlock:^(NSString *keyPath, id oldValue, id newValue) {
        BOOL newBool = [(NSNumber*)newValue boolValue];
        weakSelf.switcher.on = newBool;
    }];
    [MVKVOGroupMakeObserver(self.info2, testBool, self) setBlock:^(NSString *keyPath, id oldValue, id newValue) {
        BOOL newBool = [(NSNumber*)newValue boolValue];
        weakSelf.switcher2.on = newBool;
    }];
    [MVKVOGroupMakeObserver(self.info3, testBool, self) setBlock:^(NSString *keyPath, id oldValue, id newValue) {
        BOOL newBool = [(NSNumber*)newValue boolValue];
        weakSelf.switcher3.on = newBool;
    }];
    
    [self.info2 MVMakeKVOGroupObserver:self ForKeyPath:@"name" Block:^(NSString *keyPath, id oldValue, id newValue) {
        weakSelf.label.text = newValue;
    }];
}
- (IBAction)onBtnClicked:(id)sender {
    self.info1.name = @"hahahhahha";
}
- (IBAction)onSwitch:(id)sender {
    UISwitch* sw = sender;
    self.info1.testBool = sw.on;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end






