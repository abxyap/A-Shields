#import <rocketbootstrap/rocketbootstrap.h>
#import <AppSupport/CPDistributedMessagingCenter.h>
#import <LocalAuthentication/LocalAuthentication.h>

// typedef void (^callbackFunction)(BOOL success, LAError error);
//
// @interface LAContext (AShields)
// @property (nonatomic, strong) callbackFunction replyFunction;
// @end
//
// %hook LAContext
// %property (nonatomic, strong) callbackFunction replyFunction;
// -(void)evaluatePolicy:(LAPolicy)policy localizedReason:(NSString *)localizedReason reply:(void (^)(BOOL success, LAError error))reply {
// 	if(policy != LAPolicyDeviceOwnerAuthenticationWithBiometrics  && policy != LAPolicyDeviceOwnerAuthentication) return %orig;
//
//   NSString *bundle = [[NSBundle mainBundle] bundleIdentifier];
//   self.replyFunction = reply;
//
// 	CPDistributedMessagingCenter *c = [CPDistributedMessagingCenter centerNamed:@"com.rpgfarm.a-shields"];
// 	rocketbootstrap_distributedmessagingcenter_apply(c);
//
//   [c sendMessageName:@"verifyTouchID" userInfo:@{
//     @"title": localizedReason,
//     @"bundle": bundle
//   }];
//
//   [[objc_getClass("NSDistributedNotificationCenter") defaultCenter] addObserver:self selector:@selector(handleReply:) name:[NSString stringWithFormat:@"com.rpgfarm.a-shields-app-support.%@", bundle] object:nil];
// }
//
// %new
// -(void)handleReply:(NSNotification *)notification {
//   BOOL success = [[notification.userInfo objectForKey:@"success"] boolValue];
//   if(success) self.replyFunction(true, 0);
// 	else self.replyFunction(false, LAErrorUserCancel);
// }
// %end

void loadPrefs() {
	// prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.rpgfarm.ashieldsprefs.plist"];
}

%ctor {
  CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.rpgfarm.ashields/settingsupdate"), NULL, CFNotificationSuspensionBehaviorCoalesce);
  loadPrefs();
}
