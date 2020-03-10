#import <UIKit/UIKit.h>

@interface ASViewController : UIViewController <UITextFieldDelegate>
@property (nonatomic, strong) UIAlertController *alert;
@property (nonatomic) BOOL session;
+ (instancetype)sharedInstance;
-(void)verifyTouchID:(NSString *)alertTitle reply:(void (^)(BOOL))callback;
-(void)closeAlert;
@end
