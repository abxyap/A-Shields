#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSListItemsController.h>

@interface PSListController (Private)
-(void)_returnKeyPressed:(id)arg1;
@end

@interface PSTextFieldSpecifier : PSSpecifier
@property (nonatomic, retain) NSString *placeholder;
@end

@interface ASPCustomizeController : PSListController

@end
