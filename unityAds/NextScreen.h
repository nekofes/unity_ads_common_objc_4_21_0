//
//  NextScreen.h
//  unityAds
//

#import <UIKit/UIKit.h>
//Unity Ads SDKをインポート
#import <UnityAds/UnityAds.h>
#import "Func.h"
#import "AdManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface NextScreen : UIViewController<AdManagerDelegate>

@property (nonatomic, strong) NSString *gameId;
@property (nonatomic, strong) NSString *interstitialPlacementId;
@property (nonatomic, strong) NSString *bannerPlacementId;
@property (nonatomic) UILabel *lblAdArea;
@property (nonatomic) UIButton *btn;
@property (nonatomic) CGFloat screenWidth;
@property (nonatomic) CGFloat screenHeight;
@property (nonatomic) CGFloat safeAreaBottom;
@property (nonatomic) CGFloat adWidth;
@property (nonatomic) CGFloat adHeight;
@property (nonatomic) CGFloat statusBarHeight;
@end

NS_ASSUME_NONNULL_END
