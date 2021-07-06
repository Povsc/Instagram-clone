//
//  ComposeViewController.m
//  Instagram-clone
//
//  Created by felipeccm on 7/6/21.
//

#import "ComposeViewController.h"

@interface ComposeViewController () <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *captionField;

@end

@implementation ComposeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.captionField.delegate = self;
    
    // Make caption frame round
    self.captionField.layer.cornerRadius = 10;
    self.captionField.layer.masksToBounds = true;
    
    // Add placeholder text
    self.captionField.text = @"Caption...";
    self.captionField.textColor = [UIColor  lightGrayColor];
}

- (IBAction)didTapCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (textView.textColor == [UIColor lightGrayColor]) {
        textView.text = nil;
        textView.textColor = [UIColor blackColor];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([textView.text isEqual:@""]) {
        textView.text = @"Caption...";
        textView.textColor = [UIColor lightGrayColor];
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
