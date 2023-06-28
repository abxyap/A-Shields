#import "ASPPINController.h"

#if THEOS_PACKAGE_SCHEME == rootless
#define PREFERENCE_IDENTIFIER @"/var/jb/var/mobile/Library/Preferences/com.rpgfarm.ashieldsprefs.plist"
#elif
#define PREFERENCE_IDENTIFIER @"/var/mobile/Library/Preferences/com.rpgfarm.ashieldsprefs.plist"
#endif

@implementation ASPPINController

- (BOOL)isBlocked {
  return NO;
}

- (BOOL)isNumericPIN {
  return YES;
}

- (BOOL)simplePIN {
  return YES;
}

- (BOOL)useProgressiveDelays {
  return NO;
}

- (int)pinLength {
  return 4;
}

- (BOOL)validatePIN:(NSString *)PIN {
  NSDictionary *preferences = [NSDictionary dictionaryWithContentsOfFile:PREFERENCE_IDENTIFIER];
  NSString *passcode = preferences[@"passcode"];
  return [PIN isEqualToString:passcode];
}

- (void)setPIN:(NSString *)PIN completion:(id)completion {
  NSMutableDictionary *settings = [NSMutableDictionary dictionary];
  NSString *settingsPath = PREFERENCE_IDENTIFIER;
  [settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:settingsPath]];

  settings[@"passcode"] = PIN;
  [settings writeToFile:settingsPath atomically:FALSE];

  [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadSettingPage" object:nil userInfo:nil];
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.rpgfarm.ashields/settingsupdate"), NULL, NULL, true);
}

- (void)setPIN:(NSString *)PIN {
  [self setPIN:PIN completion:nil];
}

- (NSBundle *)stringsBundle {
  return [NSBundle bundleForClass:DevicePINController.class];
}

- (NSString *)stringsTable {
  return @"PIN Entry";
}

- (BOOL)isKindOfClass:(Class)aClass {
  if (aClass == [DevicePINController class]) {
    return YES;
  }
  return [super isKindOfClass:aClass];
}

@end
