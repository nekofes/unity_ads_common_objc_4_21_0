//
//  Func.m
//  unityAds
//

#import "Func.h"

@implementation Func
/*
 テストモードの自動判定
 [戻り値]
 NO : 本番モード
 YES: テストモード
*/
+(BOOL)testMode
{
    BOOL isTestMode = NO; // デフォルトは本番モード
    
    //シミュレータか実機かを自動判定してテストモードを切り替える
    #if TARGET_OS_SIMULATOR
        isTestMode = YES;
        NSLog(@"[Unity Ads] シミュレータ起動のため、テストモード(YES)で初期化します。");
    #else
        NSLog(@"[Unity Ads] 実機起動のため、本番モード(NO)で初期化します。");
    #endif
    
    return isTestMode;
}
// 画面下部のジェスチャーバーの領域（高さ）を取得するメソッド
+(CGFloat)getBottomGestureBarHeight
{
    CGFloat bottomInset = 0.0;
    
    if (@available(iOS 11.0, *))
    {
        // iOS 13以降のSceneベースに対応したウィンドウ取得
        UIWindow *window = nil;
        if (@available(iOS 13.0, *))
        {
            for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes)
            {
                if (scene.activationState == UISceneActivationStateForegroundActive)
                {
                    for (UIWindow *w in scene.windows)
                    {
                        if (w.isKeyWindow)
                        {
                            window = w;
                            break;
                        }
                    }
                }
                if (window) break;
            }
        }
        
        // iOS 12以前の古い取得方法（Sceneが取れなかった場合のフォールバック）
        if (!window)
        {
            window = [UIApplication sharedApplication].keyWindow;
        }
        
        if (window)
        {
            bottomInset = window.safeAreaInsets.bottom;
        }
    }
    
    return bottomInset;
}
#pragma mark ステータスバーの高さを取得
+(CGFloat)getStatusBarHeight
{
    CGFloat height = 0.0f;
    if(@available(iOS 13.0,*))
    {
        NSSet<UIScene*> *scenes = [[UIApplication sharedApplication] connectedScenes];
        for (UIScene *scene in scenes)
        {
            if ([scene isKindOfClass:[UIWindowScene class]])
            {
                UIWindowScene *windowScene = (UIWindowScene*)scene;
                height = windowScene.statusBarManager.statusBarFrame.size.height;
                break;
            }
        }

    }
    else
    {
        //iOS 13.0未満のケース
        //'statusBarFrame' is deprecated: first deprecated in iOS 13.0 - Use the statusBarManager property of the window scene instead.
        height = UIApplication.sharedApplication.statusBarFrame.size.height;
    }
    return height;
}

#pragma mark - レイアウト確定（バナー最下部中央配置）
+(void)screenSize:(UIView *)parentView
      screenWidth:(CGFloat *)screenWidth
     screenHeight:(CGFloat *)screenHeight
   safeAreaBottom:(CGFloat *)safeAreaBottom
          adWidth:(CGFloat *)adWidth
         adHeight:(CGFloat *)adHeight
  statusBarHeight:(CGFloat *)statusBarHeight
{
    //self.view ではなく、引数でもらった parentView を使ってサイズを計算します
    CGSize screenSize = parentView.bounds.size;
    UIEdgeInsets safeArea = UIEdgeInsetsZero;
    
    if (@available(iOS 11.0, *))
    {
        safeArea = parentView.safeAreaInsets;
    }
    
    *screenWidth = screenSize.width;
    *screenHeight = screenSize.height;
    *safeAreaBottom = [Func getBottomGestureBarHeight];
    
    // Unity Adsのバナー広告のサイズ
    *adWidth = 320.0;
    *adHeight = 50.0;
    
    *statusBarHeight = [Func getStatusBarHeight];
}

+(void)adAreaLabel:(UILabel*)lblAdArea
{
    lblAdArea.text=@"ここの上にunity adsの広告が表示されます。\n広告表示後は、このラベルは非表示に切り替わります。";
    lblAdArea.backgroundColor = [UIColor colorWithRed:102.0/255.0 green:153.0/255.0 blue:255.0/255.0 alpha:240.0/255.0];
    lblAdArea.numberOfLines = 2;
    lblAdArea.lineBreakMode = NSLineBreakByWordWrapping;
    lblAdArea.textAlignment = NSTextAlignmentCenter;
}
/*
 広告エリアの表示切り替え
 hidden:
 0:非表示
 1:表示
*/
+(void)displayAdAreaLabel:(UILabel*)lblAdArea hidden:(BOOL)hidden
{
    lblAdArea.hidden = hidden;
}
+ (UIButton *)addButtonWithName:(UIButton*)btn
                           name:(NSString *)name
                     parentView:(UIView *)parentView
                          frame:(CGRect)frame
                         action:(void (^)(void))actionBlock
{
    //ボタンの生成をFunc内で完結
    btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.frame = frame;
    
    //デザインの設定（最新仕様へアップデート）
    [btn setTitle:name forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor colorWithRed:102.0/255.0 green:153.0/255.0 blue:255.0/255.0 alpha:240.0/255.0];
    
    btn.titleLabel.numberOfLines = 1;
    btn.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    btn.titleLabel.lineBreakMode = NSLineBreakByClipping;
    btn.titleLabel.font = [UIFont systemFontOfSize:26.0f];
    
    btn.changesSelectionAsPrimaryAction = YES;
    btn.layer.borderColor = [UIColor colorWithRed:102.0/255.0 green:153.0/255.0 blue:255.0/255.0 alpha:240.0/255.0].CGColor;
    btn.layer.borderWidth = 1.5f;
    btn.layer.cornerRadius = 5.0f;
    
    //イベントの登録処理（手渡された処理ブロックをボタン内部に一時記憶させる）
    if (actionBlock) {
        objc_setAssociatedObject(btn, @"_actionBlockKey", actionBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
        [btn addTarget:self action:@selector(handleButtonTap:) forControlEvents:UIControlEventTouchDown];
    }
    
    //親画面への追加もFunc側で自動実行
    [parentView addSubview:btn];
    
    return btn;
}

//ボタンが押された時に、記憶しておいた画面側のブロック処理を引き出して実行する中継メソッド
+ (void)handleButtonTap:(UIButton *)sender {
    void (^actionBlock)(void) = objc_getAssociatedObject(sender, @"_actionBlockKey");
    if (actionBlock) {
        actionBlock(); // 画面（ViewController）側の処理がここで身代わり実行されます！
    }
}

@end
