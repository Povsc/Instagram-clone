//
//  DetailsViewController.m
//  Instagram-clone
//
//  Created by felipeccm on 7/7/21.
//

#import "DetailsViewController.h"

@interface DetailsViewController ()

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Configure labels
    self.authorLabel.text = self.post.author.username;
    self.captionLabel.text = self.post.caption;
    self.likeLabel.text = [self.post.likeCount stringValue];
    
    // Configure date label
    self.createdAtLabel.text = [self stringWithDate:self.post.createdAt];

    // Configure image
    self.postImageView.file = self.post.image;
    [self.postImageView loadInBackground];
}

- (NSString *)stringWithDate:(NSDate *)createdAt{
    // Instantiate formatter
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    // Configure the input format to parse the date string
    formatter.dateFormat = @"E MMM d HH:mm:ss Z y";
    // Compute how much time has passed
    NSTimeInterval secondsSince = [createdAt timeIntervalSinceNow];
    int seconds = secondsSince * (-1);
    int minutes = seconds / 60;
    int hours = minutes / 60;
    int days = hours / 24;
    // Convert Date to String
    if (minutes < 1){
        return [NSString stringWithFormat:@"%ds ago", seconds];
    }
    else if (hours < 1){
        return [NSString stringWithFormat:@"%dm ago", minutes];
    }
    else if (days < 7){
        return [NSString stringWithFormat:@"%dd ago", days];
    }
    else {
        return [formatter stringFromDate:createdAt];
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
