#import <UIKit/UIKit.h>
#import <HBLog.h>
#include <objc/runtime.h>
#include <BiometricKit/BiometricKit.h>
@interface SBFCredentialSet
@end
@interface SBUIBiometricResource : NSObject {
  bool _isMatchingAllowed;
}
@property (nonatomic,retain) SBFCredentialSet * unlockCredentialSet;
+(id)sharedInstance;
-(void)addObserver:(id)arg1;
-(void)removeObserver:(id)arg1;
-(id)acquireMatchingAssertionWithMode:(unsigned long long)arg1 reason:(id)arg2 ;
-(void)_matchingAllowedStateMayHaveChangedForReason:(id)arg1 ;
-(void)_presenceDetectAllowedStateMayHaveChangedForReason:(id)arg1;
-(void)_removeMatchingAssertion:(id)arg1 ;
-(void)_addMatchingAssertion:(id)arg1 ;

-(void)restartMatchingIfNeededForAssertion:(id)arg1 ;
-(void)_deactivateAssertion:(id)arg1 ;
-(void)_activateMatchAssertion:(id)arg1 ;
@end

@interface _SBUIBiometricMatchingAssertion : NSObject
-(id)initWithMatchMode:(unsigned long long)arg1 reason:(id)arg2 invalidationBlock:(/*^block*/id)arg3 ;
-(void)invalidate;
@end
@interface _SBUIBiometricKitInterface : NSObject
-(id)createMatchOperationsWithMode:(unsigned long long)arg1 andCredentialSet:(id)arg2 error:(id*)arg3 ;
@end

#define TouchIDFingerDown  1
#define TouchIDFingerUp    0
#define TouchIDFingerHeld  2
#define TouchIDMatched     3
#define TouchIDMaybeMatched 4
#define TouchIDNotMatched  9

typedef void (^callbackFunction)(BOOL);
typedef void (^callbackFunction2)(int);

@interface ASScanner : NSObject
@property (assign, nonatomic) BOOL isMonitoring;
@property (strong, nonatomic) _SBUIBiometricMatchingAssertion *assertion;
@property (copy, nonatomic) callbackFunction callback;
@property (copy, nonatomic) callbackFunction2 eventAlert;

+ (instancetype)sharedInstance;
- (void)startMonitoring;
- (void)stopMonitoring;

@end
