#import <UIKit/UIKit.h>

@class SystemMetrics;

@interface OverviewViewController : UITableViewController {
    SystemMetrics *_metrics;
    NSArray *_sections;
    NSTimer *_timer;
}

@end
