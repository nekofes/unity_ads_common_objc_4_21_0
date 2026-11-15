//
//  NextScreen.m
//  unityAds
//

#import "NextScreen.h"

@interface NextScreen ()

// 最新の広告オブジェクトを保持するプロパティ
@property (nonatomic, strong) UADSBannerAd *bannerAd;
@property (nonatomic, strong) UADSInterstitialAd *interstitialAd;//読み込んだ全画面広告オブジェクトを保持

@end

@implementation NextScreen

@synthesize gameId;
@synthesize interstitialPlacementId;
@synthesize bannerPlacementId;
@synthesize lblAdArea;
@synthesize btn;
@synthesize screenWidth;
@synthesize screenHeight;
@synthesize safeAreaBottom;
@synthesize adWidth;
@synthesize adHeight;
@synthesize statusBarHeight;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 画面の背景色を明示的に「白」にする
    self.view.backgroundColor = [UIColor whiteColor];
    
    //自分自身（ViewController）を通知先としてAdManagerに登録する
    [AdManager sharedManager].delegate = self;

    //画面準備
    //ここではまだ枠サイズが未確定のため、初期配置でaddSubviewだけ行います
    [self screen];
    [[AdManager sharedManager] initializeSDK];

}
-(void)screen
{
    lblAdArea = [[UILabel alloc] init];
    [Func adAreaLabel:lblAdArea];
    [self.view addSubview:lblAdArea];
    //次の画面へ「進む」ボタンの作成
    self.btn = [Func addButtonWithName:btn
                                  name:@"戻る"
                             parentView:self.view
                                  frame:CGRectZero
                                 action:^{
        //前の画面に戻る
        [self.navigationController popViewControllerAnimated:NO];
    }];
}
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    //画面サイズが確定したこの瞬間に、サイズを取得して下地ラベルを正しい位置へ移動させます
    //第一引数に「self.view」を渡し、残りの変数には「&」をつけてポインタを渡します
    [Func screenSize:self.view
         screenWidth:&screenWidth
        screenHeight:&screenHeight
      safeAreaBottom:&safeAreaBottom
             adWidth:&adWidth
            adHeight:&adHeight
     statusBarHeight:&statusBarHeight
    ];

    CGFloat yLabel = screenHeight - (adHeight + safeAreaBottom);

    CGFloat xPos = (screenWidth - adWidth) / 2.0;
    lblAdArea.frame = CGRectMake(0, statusBarHeight, screenWidth, adHeight);
    if (self.btn)
    {
        CGFloat width = 200.0f;
        xPos = (screenWidth - width) / 2.0;
        self.btn.frame = CGRectMake(xPos, yLabel, width, adHeight);
    }

    //共通クラスが保持しているバナーを取得して画面に追加するだけ
    UADSBannerAd *bannerAd = [AdManager sharedManager].bannerAd;
    //【重要】オブジェクトがあり、まだ画面に追加されていなければ、ここで追加します
    if (bannerAd && bannerAd.view)
    {
        if (bannerAd.view.superview == nil)
        {
            //alpha だけでなく、hidden = YES でビュー自体を完全に「非表示の目隠し状態」にします
            bannerAd.view.hidden = YES;
            bannerAd.view.alpha = 1.0;

            xPos = (screenWidth - adWidth) / 2.0;
            CGFloat yPos = screenHeight - adHeight - safeAreaBottom;
            bannerAd.view.frame = CGRectMake(xPos, yPos, adWidth, adHeight);
            [self.view addSubview:bannerAd.view]; //画面に追加します
        }
    }

    if (bannerAd && bannerAd.view && bannerAd.view.superview)
    {
        xPos = (screenWidth - adWidth) / 2.0;
        bannerAd.view.frame = CGRectMake(xPos, statusBarHeight, adWidth, adHeight);

        // 広告が表示されたので、下地ラベルを非表示に切り替えます
        [Func displayAdAreaLabel:lblAdArea hidden:YES];

    }
}
#pragma mark - AdManagerDelegate (AdManagerからの状態通知窓口/広告準備完了の通知を受ける窓口)
- (void)adManagerDidRegisterBannerAd
{
    NSLog(@"[画面連携] 共通クラスからバナー準備完了の通知を受け取りました。画面レイアウトを更新します。");
    
    //これを呼ぶことで、画面に対して「viewDidLayoutSubviews」をもう一度実行するように強制命令を下します！
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
}

//広告が正常に表示された通知を受け取った時
- (void)adManagerDidShowBannerAd
{
    NSLog(@"[画面連動] バナーが表示された通知を受け取りました。目印ラベルを【非表示】にします。");
    
    //広告エリアの下地ラベルを隠す（YES = 非表示）
    [Func displayAdAreaLabel:lblAdArea hidden:YES];

    //広告が貼られた直後なので、念のためもう一度完璧に配置を確定させる
    [self.view setNeedsLayout];
}

// 広告のロードが失敗した通知を受け取った時
- (void)adManagerDidFailToLoadBannerAd
{
    NSLog(@"[画面連動] バナーが失敗した通知を受け取りました。目印ラベルを【表示】にします。");
    
    // 広告が出なかったので、下地ラベルを表示させる（NO = 表示）
    [Func displayAdAreaLabel:lblAdArea hidden:NO];
}

- (void)dealloc
{
    // 現在のdelegateが「自分自身（self）」のときだけ nil に戻す
    if ([AdManager sharedManager].delegate == self)
    {
        [AdManager sharedManager].delegate = nil;
    }
}
@end
