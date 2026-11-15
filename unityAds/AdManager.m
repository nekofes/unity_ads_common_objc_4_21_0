//
//  AdManager.m
//  unityAds
//

#import "AdManager.h"

@implementation AdManager

@synthesize gameId;
@synthesize interstitialPlacementId;
@synthesize bannerPlacementId;

//アプリ全体で1つだけのインスタンスを保証する定番の書き方
+ (instancetype)sharedManager
{
    static AdManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}
-(void)unityId
{
    int mode=[Func testMode];//テストモードの自動判定
    // 各種IDの設定
    //Unity Dashboard（管理画面）でどのように作成・設定したかによって決まります
    gameId = mode==NO ? @"【あなたの本番用GameID】" : @"4550883";
    interstitialPlacementId = mode==NO ? @"【あなたの本番用全画面ID】" : @"Interstitial_iOS";
    bannerPlacementId = mode==NO ? @"【あなたの本番用バナーID】" : @"Banner_iOS";

}

// 広告のロード処理をまとめる
- (void)loadAllAds
{
    [self loadInterstitialAd];
    [self loadBannerAd];
}

#pragma mark - 広告のロード処理（最新方式）
- (void)initializeSDKWithGameId
{
    UADSInitializationConfigurationBuilder *initConfigBuilder = [[UADSInitializationConfigurationBuilder alloc] initWithGameId:gameId];
    initConfigBuilder = [initConfigBuilder withTestMode:[Func testMode]];
    
    __weak typeof(self) weakSelf = self;
    [UnityAds initialize:[initConfigBuilder build] completion:^(id<UnityAdsError> _Nullable error)
    {
        if (!error) {
            NSLog(@"Unity Ads: 初期化に成功しました。各広告のロードを開始します。");
            
            //weakSelf（AdManager自身）のロードメソッドが安全に呼び出されます
            [weakSelf loadAllAds];
        } else {
            NSLog(@"Unity Ads: 初期化に失敗しました: %@", error);
        }
    }];
}

// インタースティシャル広告のロード
- (void)loadInterstitialAd
{
    UADSLoadConfigurationBuilder *interstitialBuilder = [[UADSLoadConfigurationBuilder alloc] initWithPlacementId:interstitialPlacementId];
    
    __weak typeof(self) weakSelf = self;
    //警告解消：[UnityAds load:...]を廃止し、UADSInterstitialAdクラス自身でロードします
    [UADSInterstitialAd load:[interstitialBuilder build] completion:^(UADSInterstitialAd * _Nullable interstitialAd, id<UnityAdsError> _Nullable error) {
        if (interstitialAd) {
            NSLog(@"Unity Ads: インタースティシャル広告のロード完了: %@", weakSelf.interstitialPlacementId);
            weakSelf.interstitialAd = interstitialAd; //オブジェクトを保持
        } else {
            NSLog(@"Unity Ads: インタースティシャル ロード失敗");
        }
    }];
}
// 初期化やロードの処理をこちらに集約します
- (void)initializeSDK
{
    UADSInitializationConfigurationBuilder *builder = [[UADSInitializationConfigurationBuilder alloc] initWithGameId:gameId];
    builder = [builder withTestMode:[Func testMode]];
    
    [UnityAds initialize:[builder build] completion:^(id<UnityAdsError> _Nullable error) {
        if (!error) {
            [self loadBannerAd]; // 初期化成功したらロード
        }
    }];
}

// バナー広告のロード
- (void)loadBannerAd
{
    UADSBannerLoadConfigurationBuilder *bannerBuilder = [[UADSBannerLoadConfigurationBuilder alloc] initWithPlacementId:bannerPlacementId bannerSize:CGSizeMake(320, 50) delegate:(id)self];
    [UADSBannerAd load:[bannerBuilder build] completion:^(UADSBannerAd * _Nullable bannerAd, id<UnityAdsError> _Nullable error) {
        if (bannerAd)
        {
            NSLog(@"Unity Ads: バナーのオブジェクト生成成功。");
            self.bannerAd = bannerAd;
            //広告の準備が完了したことを、登録されている画面へ通知する
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.delegate && [self.delegate respondsToSelector:@selector(adManagerDidRegisterBannerAd)])
                {
                    [self.delegate adManagerDidRegisterBannerAd];
                }
            });
        }
    }];
}
#pragma mark - UADSBannerAdDelegate (バナー広告のイベント通知窓口)

//最新SDKの必須メソッド：これが不足していたためクラッシュしていました
- (void)bannerImpression:(UADSBannerAd * _Nonnull)bannerAd
{
    bannerAd.view.hidden = NO;
    NSLog(@"[AdManager] バナー広告のインプレッション（表示確立）がカウントされました。");
    //画面側（ViewController）の「adManagerDidShowBannerAd」を呼び出して通知する
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(adManagerDidShowBannerAd)]) {
            [self.delegate adManagerDidShowBannerAd];
        }
    });
}

- (void)bannerAdDidShow:(UADSBannerAd * _Nonnull)bannerAd
{
    NSLog(@"[AdManager] バナー広告がユーザーの画面に実際に表示されました。");
    bannerAd.view.hidden = NO;
    //画面側（ViewController）の「adManagerDidShowBannerAd」を呼び出して通知する
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(adManagerDidShowBannerAd)]) {
            [self.delegate adManagerDidShowBannerAd];
        }
    });
}

- (void)bannerAdDidFailToLoad:(UADSBannerAd * _Nonnull)bannerAd error:(UADSBannerError * _Nonnull)error
{
    NSLog(@"[AdManager] Unity Ads: バナーのロードに失敗しました: %@", error.localizedDescription);
    //ロード失敗したことを画面側へ通知する
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(adManagerDidFailToLoadBannerAd)]) {
            [self.delegate adManagerDidFailToLoadBannerAd];
        }
    });
}
//❌ クラッシュする古いコード
/*
- (void)bannerAdDidClick:(UADSBannerAd * _Nonnull)bannerAd {
    NSLog(@"[AdManager] バナー広告がクリックされました。");
}
*/
//メソッド名を「bannerDidClick:」へ修正します（Ad を削る）
- (void)bannerDidClick:(UADSBannerAd *)bannerAd {
    NSLog(@"[AdManager] バナー広告がユーザーにクリックされました。");
}
- (void)bannerDidFailShow:(UADSBannerAd * _Nonnull)banner error:(id<UnityAdsError> _Nonnull)error
{
    //
}
- (void)bannerAdDidLeaveApplication:(UADSBannerAd * _Nonnull)bannerAd
{
    NSLog(@"[AdManager] バナー経由で他のアプリに遷移しました。");
}

@end
