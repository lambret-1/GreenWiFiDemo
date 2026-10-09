#import <substrate.h>
#import <UIKit/UIKit.h>
#import <rootless.h>

static BOOL g_tunnelActive = NO;
static NSString* plistPath = @"/var/jb/tmp/com.demo.greenwifi.state.plist";
static NSString* logPath = @"/var/jb/tmp/greenwifi_tweak.log";
static UIImage* greenWifiImage = nil;

// Tweak日志写入文件
static void tweakLog(NSString *msg) {
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"HH:mm:ss";
    NSString *line = [NSString stringWithFormat:@"[%@] %@\n", [fmt stringFromDate:[NSDate date]], msg];
    NSFileHandle *fh = [NSFileHandle fileHandleForWritingAtPath:logPath];
    if(!fh) {
        [@"" writeToFile:logPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        fh = [NSFileHandle fileHandleForWritingAtPath:logPath];
    }
    [fh seekToEndOfFile];
    [fh writeData:[line dataUsingEncoding:NSUTF8StringEncoding]];
    [fh closeFile];
}

// 读取共享文件标记
BOOL readTunnelFlag() {
    NSDictionary *stateDict = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    if(!stateDict) return NO;
    return [stateDict[@"tunnelActive"] boolValue];
}

// 加载绿色WiFi图标，尝试多个路径
UIImage* loadGreenWiFi() {
    if(greenWifiImage) return greenWifiImage;
    NSArray *paths = @[
        ROOT_PATH_NS(@"/Library/Bundles/GreenWiFiTweak.bundle"),
        @"/var/jb/Library/Bundles/GreenWiFiTweak.bundle",
        @"/Library/Bundles/GreenWiFiTweak.bundle"
    ];
    for(NSString *bundlePath in paths) {
        NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
        if(bundle) {
            UIImage *img = [UIImage imageNamed:@"greenWifi" inBundle:bundle compatibleWithTraitCollection:nil];
            if(img) {
                greenWifiImage = img;
                tweakLog([NSString stringWithFormat:@"图片加载成功: %@", bundlePath]);
                return img;
            }
        }
    }
    tweakLog(@"图片加载失败，所有路径都没找到");
    return nil;
}

// 遍历视图层级，找到所有WiFi相关ImageView并设置图片
static void applyGreenWiFiToView(UIView *view) {
    if(!view) return;
    NSString *clsName = NSStringFromClass([view class]);
    if([clsName containsString:@"Wifi"] || [clsName containsString:@"WiFi"] || [clsName containsString:@"wifi"]) {
        if([view isKindOfClass:[UIImageView class]]) {
            UIImage *img = loadGreenWiFi();
            if(img) {
                ((UIImageView *)view).image = img;
                tweakLog([NSString stringWithFormat:@"已设置图标到: %@", clsName]);
            }
        }
    }
    for(UIView *sub in view.subviews) {
        applyGreenWiFiToView(sub);
    }
}

// 强制刷新状态栏所有WiFi图标
static void forceRefreshStatusBar() {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *keyWindow = nil;
        for(UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if([scene isKindOfClass:[UIWindowScene class]]) {
                for(UIWindow *win in scene.windows) {
                    if(win.isKeyWindow) { keyWindow = win; break; }
                }
            }
        }
        if(keyWindow) {
            applyGreenWiFiToView(keyWindow);
        }
        UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
        if(statusBar) {
            applyGreenWiFiToView(statusBar);
        }
    });
}

// 钩子 _UIStatusBarWifiItemView (iOS13+)
%hook _UIStatusBarWifiItemView
- (void)updateForNewData:(id)arg1 actions:(id)arg2 {
    %orig;
    if(g_tunnelActive) {
        UIImage *img = loadGreenWiFi();
        if(img) {
            [(id)self setValue:img forKey:@"image"];
        }
    }
}
%end

// 钩子 SBStatusBarWiFiItemView
%hook SBStatusBarWiFiItemView
- (void)updateVisualState {
    %orig;
    if(g_tunnelActive) {
        UIImage *img = loadGreenWiFi();
        if(img) {
            [(id)self setValue:img forKey:@"image"];
        }
    }
}
%end

%ctor {
    tweakLog(@"=== GreenWiFiTweak 已加载 ===");
    g_tunnelActive = readTunnelFlag();
    tweakLog([NSString stringWithFormat:@"初始状态 tunnelActive=%d", g_tunnelActive]);

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW,0), ^{
        while(YES) {
            @autoreleasepool {
                BOOL newVal = readTunnelFlag();
                if(newVal != g_tunnelActive) {
                    g_tunnelActive = newVal;
                    tweakLog([NSString stringWithFormat:@"状态变化 tunnelActive=%d", newVal]);
                    if(newVal) {
                        forceRefreshStatusBar();
                    } else {
                        dispatch_async(dispatch_get_main_queue(),^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"SBStatusBarTimeChanged" object:nil];
                        });
                    }
                }
            }
            usleep(500000);
        }
    });
}
