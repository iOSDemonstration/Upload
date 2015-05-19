//
//  ViewController.m
//  Upload
//
//  Created by Jayce Yang on 5/18/15.
//  Copyright (c) 2015 DJI. All rights reserved.
//

#import "ViewController.h"

#import "NetworkClient.h"

typedef NS_ENUM(NSInteger, ActionState) {
    ActionStateStop = 0,
    ActionStateStart,
    ActionStatePause
};

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *actionButton;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (strong, nonatomic) AFHTTPRequestOperation *actionOperation;
@property (nonatomic) ActionState state;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self reset];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)action:(UIButton *)sender {
    switch (self.state) {
        case ActionStateStop:
        {
            self.state = ActionStateStart;
            [sender setTitle:@"Pause" forState:UIControlStateNormal];
        }
            break;
        case ActionStateStart:
        {
            self.state = ActionStatePause;
            [sender setTitle:@"Resume" forState:UIControlStateNormal];
            [self.actionOperation pause];
        }
            break;
        case ActionStatePause:
        {
            self.state = ActionStateStart;
            [sender setTitle:@"Pause" forState:UIControlStateNormal];
            [self.actionOperation resume];
        }
            break;
        default:
            break;
    }
    BOOL useVideo = NO;
    NSString *path = @"uploadtest/fileupload";
    NSData *data = UIImagePNGRepresentation([UIImage imageNamed:@"Avatar.png"]);
    NSString *fileName = @"Swift.png";
    NSString *mimeType = @"image/png";
    if (useVideo) {
        data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"403_hd_intermediate_swift" ofType:@"mov"]];
        fileName = @"Swift.mov";
        mimeType = @"video/mov";
    }
    self.actionOperation = [[NetworkClient sharedClient] POSTMultipartFormRequestURLString:path parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:data
                                    name:@"file"
                                fileName:fileName
                                mimeType:mimeType];
    } success:^(id data) {
        NSLog(@"%@", data);
        [self reset];
    } failure:^(NSString *message, ErrorCode code) {
        NSLog(@"%@", message);
        [self reset];
    } uploadProgress:^(long long totalBytes, long long totalBytesExpected) {
        CGFloat progress = 1.0f * totalBytes / totalBytesExpected;
//        NSLog(@"%f", progress);
        self.progressView.progress = progress;
    }];
}

- (void)reset {
    self.state = ActionStateStop;
    [self.actionButton setTitle:@"Start" forState:UIControlStateNormal];
    self.progressView.progress = 0;
}

@end
