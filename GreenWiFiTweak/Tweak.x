#import <substrate.h>
#import <UIKit/UIKit.h>

static BOOL g_tunnelActive = NO;
static NSString* appGroupID = @"group.com.demo.greenwifi";
static NSString* plistPath = nil;
static UIImage* greenWifiImage = nil;

// 读取AppGroup共享标记
BOOL readTunnelFlag() {
    if(!plistPath) {
        NSURL *groupUrl = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:appGroupID];
        plistPath = [[groupUrl path] stringByAppendingPathComponent:@"tunnelState.plist"];
    }
    NSDictionary *stateDict = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    return [stateDict[@"tunnelActive"] boolValue];
}

// 加载绿色WiFi图片
UIImage* loadGreenWiFi() {
    if(greenWifiImage) return greenWifiImage;
    NSBundle *tweakBundle = [NSBundle bundleWithPath:@"/var/jb/Library/Bundles/GreenWiFiTweak.bundle"];
    greenWifiImage = [UIImage imageNamed:@"greenWifi" inBundle:tweakBundle compatibleWithTraitCollection:nil];
    return greenWifiImage;
}

// 方案1: 钩子 SBStatusBarDataManager
%hook SBStatusBarDataManager
- (void)updateActivationState {
    %orig;
    BOOL active = readTunnelFlag();
    if(active && g_tunnelActive != active) {
        g_tunnelActive = active;
    }
}
%end

// 方案2: 钩子 _UIStatusBarWifiItemView (iOS16+)
%hook _UIStatusBarWifiItemView
- (void)updateForNewData:(id)arg1 actions:(id)arg2 {
    %orig;
    BOOL active = readTunnelFlag();
    if(active) {
        UIImage *img = loadGreenWiFi();
        if(img) {
            [(id)self setImage:img];
        }
    }
    g_tunnelActive = active;
}
%end

// 方案3: 钩子 SBStatusBarWiFiItemView
%hook SBStatusBarWiFiItemView
- (void)updateVisualState {
    %orig;
    BOOL active = readTunnelFlag();
    if(active) {
        UIImage *img = loadGreenWiFi();
        if(img) {
            [(id)self setValue:img forKey:@"image"];
        }
    }
    g_tunnelActive = active;
}
%end

%ctor {
    // 后台轮询监听状态变化，500ms刷新一次
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW,0), ^{
        while(YES) {
            @autoreleasepool {
                BOOL newVal = readTunnelFlag();
                if(newVal != g_tunnelActive) {
                    g_tunnelActive = newVal;
                    dispatch_async(dispatch_get_main_queue(),^{
                        // 触发状态栏刷新
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"SBStatusBarTimeChanged" object:nil];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"_UIStatusBarWillBeginUpdate" object:nil];
                    });
                }
            }
            usleep(500000);
        }
    });
}
