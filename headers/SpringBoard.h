#define kGlyphStateDefault  0
#define kGlyphStateScanning 1

@interface PKGlyphView : UIView

@property (nonatomic, copy) id delegate;
@property (nonatomic) BOOL fadeOnRecognized;
@property (nonatomic, copy) UIColor *primaryColor;
@property (nonatomic, copy) UIColor *secondaryColor;
@property (nonatomic, readonly) int state;

- (instancetype)initWithStyle:(UITableViewStyle)style;
- (void)setState:(NSInteger)state animated:(BOOL)animated completionHandler:(void (^)(void))block;

@end

@interface PSPasscodeField : UIView
@property (assign,getter=isSecureTextEntry,nonatomic) BOOL secureTextEntry;
@property (assign,nonatomic) BOOL securePasscodeEntry;
@property (assign,nonatomic) id delegate;
@property (assign,getter=isEnabled,nonatomic) BOOL enabled;
@property (assign,nonatomic) long long keyboardType;
@property (assign,nonatomic) BOOL shouldBecomeFirstResponderOnTap;
-(id)initWithNumberOfEntryFields:(unsigned long long)arg1 ;
-(BOOL)becomeFirstResponder;
-(void)insertText:(id)arg1 ;
@end
@interface SBWorkspaceTransitionRequest :NSObject
@property (nonatomic,copy) NSString * eventLabel;
@end
@interface SBWorkspaceTransaction : NSObject
@property (nonatomic,readonly) SBWorkspaceTransitionRequest * transitionRequest;
@end
@interface SBToAppsWorkspaceTransaction
@property (nonatomic,readonly) NSSet * toApplicationSceneEntities;
@end
@interface FBProcess
@property (nonatomic, readonly, copy) NSString *name;
- (bool)executableLivesOnSystemPartition;
@end
@interface FBSystemServiceOpenApplicationRequest
@property (nonatomic, copy) NSString *bundleIdentifier;
- (FBProcess *)clientProcess;
@end
@interface UIWindow (Private)
- (void)_setSecure:(BOOL)secure;
@end
@interface SBAppLayout
@property (nonatomic,copy) NSDictionary * rolesToLayoutItemsMap;
-(id)allItems;
@end
@interface SBApplication
@property (nonatomic, readonly) NSString *bundleIdentifier;
@property (nonatomic, readonly) NSString *displayName;
@end
@interface SBIcon : NSObject
- (SBApplication *)application;
- (id)applicationBundleID;
@end
@interface SBIconView : NSObject
@property (nonatomic, assign) SBIcon *icon;
@end
@interface SBUIIconForceTouchViewController
-(void)_presentAnimated:(BOOL)arg1 withCompletionHandler:(/*^block*/id)arg2 ;
-(void)_dismissAnimated:(BOOL)arg1 withCompletionHandler:(/*^block*/id)arg2 ;
-(BOOL)dismissAnimated:(BOOL)arg1 withCompletionHandler:(/*^block*/id)arg2 ;
@end
@interface SBUIIconForceTouchIconViewWrapperView : NSObject
@property (nonatomic,readonly) SBIconView * iconView;
@end
@interface SBDisplayItem
@property (nonatomic,retain) NSString * displayIdentifier;
@end
@interface SBDisplayLayout
@property (nonatomic,retain) NSArray * displayItems;
@end

@interface SBApplicationController
+ (id)sharedInstance;
- (SBApplication *)applicationWithBundleIdentifier:(NSString *)bid;
@end
@interface SFSearchResult
@property (nonatomic, copy) NSString *identifier;
@end
@interface SearchUIAppIconButton : NSObject
@property (retain) SFSearchResult * result;
@end

@interface SpringBoard
-(SBApplication *)_accessibilityFrontMostApplication;
@end
@interface LAContext (AShields)
@property (assign,nonatomic) long long biometryType;
-(void)setOptionAuthenticationTitle:(id)arg1;
@end
@interface SBWiFiManager
+(id)sharedInstance;
-(id)currentNetworkName;
@end